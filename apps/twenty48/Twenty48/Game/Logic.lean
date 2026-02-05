/-
  Twenty48.Game.Logic
  Game logic and move processing
-/
import Twenty48.Core
import Twenty48.Game.State
import Twenty48.Game.Random

namespace Twenty48.Game

open Twenty48.Core

/-- Spawn a random tile on the grid -/
def spawnTile (state : GameState) : GameState :=
  let (rng1, pos) := randomEmptyCell state.grid state.rng
  match pos with
  | none => { state with rng := rng1 }
  | some p =>
    let (rng2, value) := randomTileValue rng1
    let newGrid := state.grid.set p.x p.y (some value)
    let newBestTile := max state.bestTile value
    { state with
      grid := newGrid
      rng := rng2
      bestTile := newBestTile
      anim := { state.anim with newTilePos := some p }
    }

/-- Check if the grid has a winning tile -/
def hasWinningTile (grid : Grid) : Bool :=
  grid.maxTile >= winningExponent

/-- Check if the game is over (no moves possible) -/
def checkGameOver (state : GameState) : GameState :=
  if state.grid.canMove then
    state
  else
    { state with gameOver := true }

/-- Process a move in a direction -/
def move (state : GameState) (dir : Direction) : GameState := Id.run do
  -- Don't process moves if game over (and not continuing)
  if state.gameOver then return state

  -- Don't process moves if animation is running
  if state.anim.phase != .idle then return state

  -- Perform the slide with movement tracking
  let (newGrid, scoreGained, merges, movements, changed) := state.grid.slideWithMovement dir

  -- If nothing changed, return unchanged state
  if !changed then return state

  -- Save previous state for undo
  let prevGrid := some state.grid
  let prevScore := some state.score

  -- Calculate new score
  let newScore := state.score + scoreGained
  let newBestScore := max state.bestScore newScore

  -- Update best tile
  let newBestTile := max state.bestTile newGrid.maxTile

  -- Check for win
  let justWon := !state.won && !state.continuedAfterWin && hasWinningTile newGrid

  -- Create new state with slide animation (don't spawn tile yet)
  let mergePositions := merges.map (·.pos)
  let mergeValues := merges.map (·.value)
  let newState : GameState :=
    { state with
      grid := newGrid
      score := newScore
      bestScore := newBestScore
      bestTile := newBestTile
      previousGrid := prevGrid
      previousScore := prevScore
      won := state.won || justWon
      anim := {
        phase := .sliding
        timer := 4
        slideDir := dir
        tileMovements := movements
        mergingCells := mergePositions
        mergeValues := mergeValues
        newTilePos := none
      }
    }

  newState

/-- Undo the last move -/
def undo (state : GameState) : GameState :=
  match state.previousGrid, state.previousScore with
  | some grid, some score =>
    { state with
      grid := grid
      score := score
      previousGrid := none
      previousScore := none
      gameOver := false
      anim := AnimState.default
    }
  | _, _ => state

/-- Continue playing after winning -/
def continueAfterWin (state : GameState) : GameState :=
  { state with
    won := false
    continuedAfterWin := true
  }

/-- Restart the game -/
def restart (state : GameState) : GameState :=
  let newState := GameState.new state.rng
  -- Keep the best score
  let withBest := { newState with bestScore := state.bestScore }
  -- Spawn two initial tiles
  let withFirst := spawnTile withBest
  spawnTile withFirst

/-- Initialize a new game with two starting tiles -/
def initGame (seed : UInt64) : GameState :=
  let state := GameState.new seed
  let withFirst := spawnTile state
  spawnTile withFirst

/-- Helper to update anim timer -/
private def decrementTimer (state : GameState) : GameState :=
  let anim := state.anim
  let newAnim := { anim with timer := anim.timer - 1 }
  { state with anim := newAnim }

/-- Helper to set anim to default -/
private def resetAnim (state : GameState) : GameState :=
  { state with anim := AnimState.default }

/-- Update animations (called each frame) -/
def updateAnimations (state : GameState) : GameState :=
  match state.anim.phase with
  | .idle => state

  | .sliding =>
    if state.anim.timer > 1 then
      decrementTimer state
    else if !state.anim.mergingCells.isEmpty then
      -- Start merge animation
      let anim := state.anim
      let newAnim := { anim with phase := .merging, timer := 6 }
      { state with anim := newAnim }
    else
      -- No merges, skip to spawn
      let spawned := spawnTile state
      let anim := spawned.anim
      let newAnim := { anim with phase := .spawning, timer := 5 }
      checkGameOver { spawned with anim := newAnim }

  | .merging =>
    if state.anim.timer > 1 then
      decrementTimer state
    else
      -- Merge complete, spawn new tile
      let spawned := spawnTile state
      let oldAnim := spawned.anim
      let newAnim : AnimState := {
        phase := .spawning
        timer := 5
        slideDir := oldAnim.slideDir
        tileMovements := []
        mergingCells := []
        mergeValues := []
        newTilePos := oldAnim.newTilePos
      }
      checkGameOver { spawned with anim := newAnim }

  | .spawning =>
    if state.anim.timer > 1 then
      decrementTimer state
    else
      resetAnim state

end Twenty48.Game
