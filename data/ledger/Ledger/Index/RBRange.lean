/-
  Ledger.Index.RBRange

  Range query utilities for RBMap-based indexes.
  Provides efficient range iteration with lower-bound seeking.
-/

import Batteries.Data.RBMap

namespace Ledger.RBRange

private def upperBoundByKey? {K V : Type} [Ord K]
    (map : Batteries.RBMap K V compare) (cut : K → Ordering) : Option (K × V) :=
  Batteries.RBSet.upperBoundP? map (fun (kv : K × V) => cut kv.1)

private def strictGreaterCut {K : Type} [Ord K] (k : K) : K → Ordering :=
  fun cand => if compare k cand == .lt then .lt else .gt

/-- Collect values from an RBMap while a predicate holds on the key.
    Uses ForIn with early termination for efficiency.

    The predicate should define a contiguous range in the sorted key order.
    Once the predicate returns false after returning true, iteration stops.

    Complexity: O(s + k) where s = elements before range, k = elements in range.
    Early termination when exiting range avoids full O(n) scan. -/
def collectWhile {K V : Type} [Ord K] (map : Batteries.RBMap K V compare)
    (inRange : K → Bool) : List V := Id.run do
  let mut result : Array V := #[]
  let mut started := false
  for (k, v) in map do
    if inRange k then
      started := true
      result := result.push v
    else if started then
      -- We've exited the range after being in it, stop iterating
      break
  return result.toList

/-- Collect key-value pairs from an RBMap while a predicate holds.
    Similar to collectWhile but returns pairs instead of just values. -/
def collectPairsWhile {K V : Type} [Ord K] (map : Batteries.RBMap K V compare)
    (inRange : K → Bool) : List (K × V) := Id.run do
  let mut result : Array (K × V) := #[]
  let mut started := false
  for (k, v) in map do
    if inRange k then
      started := true
      result := result.push (k, v)
    else if started then
      break
  return result.toList

/-- Collect values from an RBMap starting from a lower bound while predicate holds. -/
def collectFromWhile {K V : Type} [Ord K] (map : Batteries.RBMap K V compare)
    (lower : K) (inRange : K → Bool) : List V := Id.run do
  let mut result : Array V := #[]
  let mut next? := upperBoundByKey? map (fun k => compare lower k)
  while true do
    match next? with
    | none => break
    | some (k, v) =>
      if inRange k then
        result := result.push v
        next? := upperBoundByKey? map (strictGreaterCut k)
      else
        break
  return result.toList

/-- Collect key-value pairs from an RBMap starting from a lower bound while predicate holds. -/
def collectPairsFromWhile {K V : Type} [Ord K] (map : Batteries.RBMap K V compare)
    (lower : K) (inRange : K → Bool) : List (K × V) := Id.run do
  let mut result : Array (K × V) := #[]
  let mut next? := upperBoundByKey? map (fun k => compare lower k)
  while true do
    match next? with
    | none => break
    | some (k, v) =>
      if inRange k then
        result := result.push (k, v)
        next? := upperBoundByKey? map (strictGreaterCut k)
      else
        break
  return result.toList

end Ledger.RBRange
