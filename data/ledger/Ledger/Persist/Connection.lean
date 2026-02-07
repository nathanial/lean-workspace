/- 
  Ledger.Persist.Connection

  PersistentConnection wraps Connection and automatically persists
  transactions to a JSONL file.
-/

import Ledger.Core.EntityId
import Ledger.Core.Attribute
import Ledger.Core.Value
import Ledger.Core.Datom
import Ledger.Tx.Types
import Ledger.Db.Database
import Ledger.Db.TimeTravel
import Ledger.Db.Connection
import Ledger.Persist.Policy
import Ledger.Persist.JSON
import Ledger.Persist.JSONL
import Ledger.Persist.Snapshot

open Ledger.Persist.JSON
open Ledger.Persist.JSONL
open Ledger.Persist.Snapshot

namespace Ledger.Persist

/-- Persistent connection that auto-writes transactions to JSONL. -/
structure PersistentConnection where
  /-- The underlying in-memory connection. -/
  conn : Connection
  /-- Path to the JSONL journal file. -/
  journalPath : System.FilePath
  /-- Open file handle for appending. -/
  handle : IO.FS.Handle
  /-- Compaction/snapshot policy. -/
  policy : CompactionPolicy
  /-- Journal entries since the last snapshot basis. -/
  entriesSinceSnapshot : Nat
  /-- Approximate current journal file size in bytes. -/
  journalBytes : Nat
  /-- Monotonic timestamp of last compaction (ms). -/
  lastCompactionMs : Nat

namespace PersistentConnection

structure CompactionResult where
  snapshotPath : System.FilePath
  journalPath : System.FilePath
  keptEntries : Nat
  journalBytesBefore : Nat
  journalBytesAfter : Nat
  deriving Repr, Inhabited

private def nowMonoMs : IO Nat := do
  IO.monoMsNow

private def fileBytes (path : System.FilePath) : IO Nat := do
  if ← path.pathExists then
    return (← IO.FS.readFile path).length
  return 0

private def snapshotForPolicy (pc : PersistentConnection) : Snapshot :=
  Snapshot.fromConnectionWithRetention pc.conn pc.policy.history

private def writeSnapshotAtomically (path : System.FilePath) (snap : Snapshot) : IO Unit := do
  let tmp := System.FilePath.mk (path.toString ++ ".tmp")
  Snapshot.write tmp snap
  IO.FS.rename tmp path

private def journalContent (entries : Array TxLogEntry) : String :=
  String.intercalate "\n" (entries.toList.map txLogEntryToJson)

private def writeJournalAtomically (path : System.FilePath) (entries : Array TxLogEntry) : IO Nat := do
  let content := journalContent entries
  let tmp := System.FilePath.mk (path.toString ++ ".tmp")
  IO.FS.writeFile tmp content
  IO.FS.rename tmp path
  return content.length

private def shouldAutoCompact (pc : PersistentConnection) (tsMs : Nat) : Bool :=
  if !pc.policy.enabled then
    false
  else
    let overEntries := pc.entriesSinceSnapshot >= pc.policy.maxEntriesSinceSnapshot
    let overBytes := pc.journalBytes >= pc.policy.maxJournalBytes
    let cooledDown :=
      if pc.lastCompactionMs == 0 then true
      else tsMs - pc.lastCompactionMs >= pc.policy.minCompactionIntervalMs
    (overEntries || overBytes) && cooledDown

private def compactAt (pc : PersistentConnection) (tsMs : Nat)
    : IO (PersistentConnection × CompactionResult) := do
  let journalBytesBefore := pc.journalBytes
  pc.handle.flush

  let snap := snapshotForPolicy pc
  let snapshotPath := Snapshot.defaultPath pc.journalPath
  writeSnapshotAtomically snapshotPath snap

  let kept ← readJournalSince pc.journalPath snap.basisT
  let journalBytesAfter ← writeJournalAtomically pc.journalPath kept

  let handle ← IO.FS.Handle.mk pc.journalPath .append
  let pc' := { pc with
    handle := handle
    entriesSinceSnapshot := kept.size
    journalBytes := journalBytesAfter
    lastCompactionMs := tsMs
  }
  let result : CompactionResult := {
    snapshotPath := snapshotPath
    journalPath := pc.journalPath
    keptEntries := kept.size
    journalBytesBefore := journalBytesBefore
    journalBytesAfter := journalBytesAfter
  }
  return (pc', result)

/-- Open or create a persistent connection from a JSONL file.
    If the file exists, replays tail transactions after snapshot basis.
    Opens the file for appending new transactions. -/
def createWith (path : System.FilePath) (policy : CompactionPolicy := CompactionPolicy.default)
    : IO PersistentConnection := do
  let snapshotPath := Snapshot.defaultPath path
  let snap? ← Snapshot.read snapshotPath
  let baseConn := match snap? with
    | some snap => Snapshot.toConnection snap
    | none => Connection.create
  let baseTx := match snap? with
    | some snap => snap.basisT
    | none => TxId.genesis

  -- Replay journal tail (if any)
  let tail ← readJournalSince path baseTx
  let conn := replayEntries baseConn tail

  -- Open file for appending
  let handle ← IO.FS.Handle.mk path .append
  let journalBytes ← fileBytes path

  let mut pc : PersistentConnection := {
    conn := conn
    journalPath := path
    handle := handle
    policy := policy
    entriesSinceSnapshot := tail.size
    journalBytes := journalBytes
    lastCompactionMs := 0
  }

  let tsMs ← nowMonoMs
  if shouldAutoCompact pc tsMs then
    let (pc', _) ← compactAt pc tsMs
    pc := pc'

  return pc

/-- Open or create a persistent connection using default bounded-history policy. -/
def create (path : System.FilePath) : IO PersistentConnection :=
  createWith path CompactionPolicy.default

/-- Process a transaction and automatically persist to journal.
    Returns the updated connection and transaction report. -/
def transact (pc : PersistentConnection) (tx : Transaction) (instant : Nat := 0)
    : IO (Except TxError (PersistentConnection × TxReport)) := do
  match pc.conn.transact tx instant with
  | .error e => return .error e
  | .ok (conn', report) =>
    -- Create and persist log entry.
    let entry : TxLogEntry := {
      txId := report.txId
      txInstant := report.txInstant
      datoms := report.txData
    }
    let encoded := txLogEntryToJson entry
    pc.handle.putStrLn encoded
    pc.handle.flush

    let mut nextPc : PersistentConnection := { pc with
      conn := conn'
      entriesSinceSnapshot := pc.entriesSinceSnapshot + 1
      journalBytes := pc.journalBytes + encoded.length + 1
    }

    let tsMs ← nowMonoMs
    if shouldAutoCompact nextPc tsMs then
      let (compacted, _) ← compactAt nextPc tsMs
      nextPc := compacted

    return .ok (nextPc, report)

/-- Compact this connection according to its configured policy. -/
def compact (pc : PersistentConnection) : IO (PersistentConnection × CompactionResult) := do
  let tsMs ← nowMonoMs
  compactAt pc tsMs

/-- Close the journal file handle. -/
def close (pc : PersistentConnection) : IO Unit := do
  pc.handle.flush

/-- Write a snapshot for this connection (default path), following policy retention mode. -/
def snapshot (pc : PersistentConnection) : IO Unit := do
  let snap := snapshotForPolicy pc
  let path := Snapshot.defaultPath pc.journalPath
  writeSnapshotAtomically path snap

/-- Get the underlying database for queries. -/
def db (pc : PersistentConnection) : Db :=
  pc.conn.db

/-- Get the current database snapshot. -/
def current (pc : PersistentConnection) : Db :=
  pc.conn.current

/-- Allocate a new entity ID. -/
def allocEntityId (pc : PersistentConnection) : EntityId × PersistentConnection :=
  let (eid, conn') := pc.conn.allocEntityId
  (eid, { pc with conn := conn' })

/-- Allocate multiple entity IDs. -/
def allocEntityIds (pc : PersistentConnection) (n : Nat) : List EntityId × PersistentConnection :=
  let (eids, conn') := pc.conn.allocEntityIds n
  (eids, { pc with conn := conn' })

/-- Get the basis transaction of the current database. -/
def basisT (pc : PersistentConnection) : TxId :=
  pc.conn.basisT

/-- Get the database as it existed at a specific transaction. -/
def asOf (pc : PersistentConnection) (txId : TxId) : Db :=
  pc.conn.asOf txId

/-- Get all datoms that were asserted or retracted since a specific transaction. -/
def since (pc : PersistentConnection) (txId : TxId) : List Datom :=
  pc.conn.since txId

/-- Get transaction data for a specific transaction. -/
def txData (pc : PersistentConnection) (txId : TxId) : Option TxLogEntry :=
  pc.conn.txData txId

/-- Get the full history of an entity. -/
def entityHistory (pc : PersistentConnection) (entity : EntityId) : List Datom :=
  pc.conn.entityHistory entity

/-- Get the full history of a specific attribute on an entity. -/
def attrHistory (pc : PersistentConnection) (entity : EntityId) (attr : Attribute) : List Datom :=
  pc.conn.attrHistory entity attr

/-- Get all transaction IDs in the log. -/
def allTxIds (pc : PersistentConnection) : List TxId :=
  pc.conn.allTxIds

end PersistentConnection

end Ledger.Persist
