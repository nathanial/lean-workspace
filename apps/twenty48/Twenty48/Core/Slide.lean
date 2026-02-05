/-
  Twenty48.Core.Slide
  Tile sliding and merging logic
-/
import Twenty48.Core.Types
import Twenty48.Core.Grid

namespace Twenty48.Core

/-- Information about a merge that occurred -/
structure MergeEvent where
  pos : Point       -- Final position after merge
  value : Nat       -- New value (exponent)
  deriving Repr, BEq

/-- Information about a tile movement for animation -/
structure TileMovement where
  fromPos : Point   -- Original position
  toPos : Point     -- Final position
  tile : Tile       -- The tile value (exponent)
  deriving Repr, BEq

/-- Reverse an array -/
def reverseArray (arr : Array α) : Array α :=
  arr.toList.reverse.toArray

/-- Slide a line of tiles toward index 0, merging adjacent equals.
    Returns (newTiles, scoreGained, mergePositions) -/
def slideLine (tiles : Array Tile) : Array Tile × Nat × List Nat := Id.run do
  -- First, collect non-empty tiles
  let nonEmpty := tiles.filter Option.isSome

  if nonEmpty.isEmpty then
    return (tiles, 0, [])

  -- Merge adjacent equal tiles
  let mut result : Array Tile := #[]
  let mut score := 0
  let mut mergePositions : List Nat := []
  let mut i := 0

  while i < nonEmpty.size do
    if h : i < nonEmpty.size then
      let current := nonEmpty[i]
      -- Check if next tile exists and is equal
      if hi1 : i + 1 < nonEmpty.size then
        let next := nonEmpty[i + 1]
        match current, next with
        | some v1, some v2 =>
          if v1 == v2 then
            -- Merge: create tile with value + 1 (double the value)
            let merged := some (v1 + 1)
            result := result.push merged
            score := score + tileValue merged
            mergePositions := (result.size - 1) :: mergePositions
            i := i + 2  -- Skip both tiles
          else
            result := result.push current
            i := i + 1
        | _, _ =>
          result := result.push current
          i := i + 1
      else
        result := result.push current
        i := i + 1
    else
      i := i + 1

  -- Pad with empty tiles to maintain size
  while result.size < gridSize do
    result := result.push none

  (result, score, mergePositions.reverse)

/-- Slide the grid in a direction.
    Returns (newGrid, scoreGained, mergeEvents, changed) -/
def Grid.slide (g : Grid) (dir : Direction) : Grid × Nat × List MergeEvent × Bool := Id.run do
  let mut result := g
  let mut totalScore := 0
  let mut merges : List MergeEvent := []

  match dir with
  | .left =>
    for y in List.range gridSize do
      let row := g.getRow y
      let (newRow, score, mergePositions) := slideLine row
      result := result.setRow y newRow
      totalScore := totalScore + score
      for x in mergePositions do
        if h : x < newRow.size then
          match newRow[x] with
          | some v => merges := ⟨⟨x, y⟩, v⟩ :: merges
          | none => pure ()

  | .right =>
    for y in List.range gridSize do
      let row := g.getRow y
      let (newRow, score, mergePositions) := slideLine (reverseArray row)
      let finalRow := reverseArray newRow
      result := result.setRow y finalRow
      totalScore := totalScore + score
      for x in mergePositions do
        let actualX := gridSize - 1 - x
        if h : actualX < finalRow.size then
          match finalRow[actualX] with
          | some v => merges := ⟨⟨actualX, y⟩, v⟩ :: merges
          | none => pure ()

  | .up =>
    for x in List.range gridSize do
      let col := g.getCol x
      let (newCol, score, mergePositions) := slideLine col
      result := result.setCol x newCol
      totalScore := totalScore + score
      for y in mergePositions do
        if h : y < newCol.size then
          match newCol[y] with
          | some v => merges := ⟨⟨x, y⟩, v⟩ :: merges
          | none => pure ()

  | .down =>
    for x in List.range gridSize do
      let col := g.getCol x
      let (newCol, score, mergePositions) := slideLine (reverseArray col)
      let finalCol := reverseArray newCol
      result := result.setCol x finalCol
      totalScore := totalScore + score
      for y in mergePositions do
        let actualY := gridSize - 1 - y
        if h : actualY < finalCol.size then
          match finalCol[actualY] with
          | some v => merges := ⟨⟨x, actualY⟩, v⟩ :: merges
          | none => pure ()

  let changed := !(g == result)
  (result, totalScore, merges.reverse, changed)

/-- Check if a move is possible in a direction -/
def Grid.canSlide (g : Grid) (dir : Direction) : Bool :=
  let (_, _, _, changed) := g.slide dir
  changed

/-- Check if any move is possible -/
def Grid.canMove (g : Grid) : Bool :=
  g.canSlide .up || g.canSlide .down || g.canSlide .left || g.canSlide .right

/-- Slide a line and track where each tile came from.
    Returns (newTiles, scoreGained, mergePositions, movements) where
    movements maps final index → original index -/
def slideLineWithMovement (tiles : Array Tile) (originalIndices : Array Nat)
    : Array Tile × Nat × List Nat × Array (List Nat) := Id.run do
  -- First, collect non-empty tiles with their original indices
  let mut nonEmpty : Array (Tile × Nat) := #[]
  for i in List.range tiles.size do
    if h : i < tiles.size then
      if tiles[i].isSome then
        if h2 : i < originalIndices.size then
          nonEmpty := nonEmpty.push (tiles[i], originalIndices[i])

  if nonEmpty.isEmpty then
    -- No tiles, return empty arrays
    let emptyMovements := Array.replicate tiles.size []
    return (tiles, 0, [], emptyMovements)

  -- Merge adjacent equal tiles, tracking movements
  let mut result : Array Tile := #[]
  let mut movements : Array (List Nat) := #[]  -- For each output position, list of input positions
  let mut score := 0
  let mut mergePositions : List Nat := []
  let mut i := 0

  while i < nonEmpty.size do
    if h : i < nonEmpty.size then
      let (current, currentIdx) := nonEmpty[i]
      -- Check if next tile exists and is equal
      if hi1 : i + 1 < nonEmpty.size then
        let (next, nextIdx) := nonEmpty[i + 1]
        match current, next with
        | some v1, some v2 =>
          if v1 == v2 then
            -- Merge: create tile with value + 1 (double the value)
            let merged := some (v1 + 1)
            result := result.push merged
            movements := movements.push [currentIdx, nextIdx]  -- Both tiles merged here
            score := score + tileValue merged
            mergePositions := (result.size - 1) :: mergePositions
            i := i + 2  -- Skip both tiles
          else
            result := result.push current
            movements := movements.push [currentIdx]
            i := i + 1
        | _, _ =>
          result := result.push current
          movements := movements.push [currentIdx]
          i := i + 1
      else
        result := result.push current
        movements := movements.push [currentIdx]
        i := i + 1
    else
      i := i + 1

  -- Pad with empty tiles to maintain size
  while result.size < gridSize do
    result := result.push none
    movements := movements.push []

  (result, score, mergePositions.reverse, movements)

/-- Slide the grid in a direction with movement tracking.
    Returns (newGrid, scoreGained, mergeEvents, tileMovements, changed) -/
def Grid.slideWithMovement (g : Grid) (dir : Direction)
    : Grid × Nat × List MergeEvent × List TileMovement × Bool := Id.run do
  let mut result := g
  let mut totalScore := 0
  let mut merges : List MergeEvent := []
  let mut allMovements : List TileMovement := []

  match dir with
  | .left =>
    for y in List.range gridSize do
      let row := g.getRow y
      let originalIndices := (List.range gridSize).toArray
      let (newRow, score, mergePositions, movements) :=
        slideLineWithMovement row originalIndices
      result := result.setRow y newRow
      totalScore := totalScore + score
      -- Record merge events
      for x in mergePositions do
        if h : x < newRow.size then
          match newRow[x] with
          | some v => merges := ⟨⟨x, y⟩, v⟩ :: merges
          | none => pure ()
      -- Record tile movements (only for non-empty tiles)
      for x in List.range gridSize do
        if h : x < movements.size then
          for origX in movements[x] do
            if h2 : x < newRow.size then
              if newRow[x].isSome then
                allMovements := ⟨⟨origX, y⟩, ⟨x, y⟩, newRow[x]⟩ :: allMovements

  | .right =>
    for y in List.range gridSize do
      let row := g.getRow y
      -- Reverse indices: [3, 2, 1, 0]
      let originalIndices := ((List.range gridSize).reverse).toArray
      let (newRow, score, mergePositions, movements) :=
        slideLineWithMovement (reverseArray row) originalIndices
      let finalRow := reverseArray newRow
      result := result.setRow y finalRow
      totalScore := totalScore + score
      -- Record merge events
      for x in mergePositions do
        let actualX := gridSize - 1 - x
        if h : actualX < finalRow.size then
          match finalRow[actualX] with
          | some v => merges := ⟨⟨actualX, y⟩, v⟩ :: merges
          | none => pure ()
      -- Record tile movements
      let reversedMovements := reverseArray movements
      for x in List.range gridSize do
        if h : x < reversedMovements.size then
          for origX in reversedMovements[x] do
            if h2 : x < finalRow.size then
              if finalRow[x].isSome then
                allMovements := ⟨⟨origX, y⟩, ⟨x, y⟩, finalRow[x]⟩ :: allMovements

  | .up =>
    for x in List.range gridSize do
      let col := g.getCol x
      let originalIndices := (List.range gridSize).toArray
      let (newCol, score, mergePositions, movements) :=
        slideLineWithMovement col originalIndices
      result := result.setCol x newCol
      totalScore := totalScore + score
      -- Record merge events
      for y in mergePositions do
        if h : y < newCol.size then
          match newCol[y] with
          | some v => merges := ⟨⟨x, y⟩, v⟩ :: merges
          | none => pure ()
      -- Record tile movements
      for y in List.range gridSize do
        if h : y < movements.size then
          for origY in movements[y] do
            if h2 : y < newCol.size then
              if newCol[y].isSome then
                allMovements := ⟨⟨x, origY⟩, ⟨x, y⟩, newCol[y]⟩ :: allMovements

  | .down =>
    for x in List.range gridSize do
      let col := g.getCol x
      let originalIndices := ((List.range gridSize).reverse).toArray
      let (newCol, score, mergePositions, movements) :=
        slideLineWithMovement (reverseArray col) originalIndices
      let finalCol := reverseArray newCol
      result := result.setCol x finalCol
      totalScore := totalScore + score
      -- Record merge events
      for y in mergePositions do
        let actualY := gridSize - 1 - y
        if h : actualY < finalCol.size then
          match finalCol[actualY] with
          | some v => merges := ⟨⟨x, actualY⟩, v⟩ :: merges
          | none => pure ()
      -- Record tile movements
      let reversedMovements := reverseArray movements
      for y in List.range gridSize do
        if h : y < reversedMovements.size then
          for origY in reversedMovements[y] do
            if h2 : y < finalCol.size then
              if finalCol[y].isSome then
                allMovements := ⟨⟨x, origY⟩, ⟨x, y⟩, finalCol[y]⟩ :: allMovements

  let changed := !(g == result)
  (result, totalScore, merges.reverse, allMovements.reverse, changed)

end Twenty48.Core
