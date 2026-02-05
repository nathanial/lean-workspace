/-
  Blockfall.Game.Logic
  Game logic functions
-/
import Blockfall.Core
import Blockfall.Game.State
import Blockfall.Game.Scoring

namespace Blockfall.Game

open Blockfall.Core

/-- Move the current piece in a direction -/
def move (state : GameState) (dir : Direction) : GameState :=
  let newPos := state.currentPos + dir.toOffset
  if collides state.board state.current newPos then
    state
  else
    { state with currentPos := newPos }

/-- Move left -/
def moveLeft (state : GameState) : GameState :=
  move state .left

/-- Move right -/
def moveRight (state : GameState) : GameState :=
  move state .right

/-- Soft drop (move down one) and award points -/
def softDrop (state : GameState) : GameState :=
  let newPos := state.currentPos + Direction.down.toOffset
  if collides state.board state.current newPos then
    state
  else
    { state with
      currentPos := newPos
      score := state.score + softDropPoints
    }

/-- Rotate the current piece clockwise with wall kicks -/
def rotate (state : GameState) : GameState :=
  match tryRotate state.board state.current state.currentPos true with
  | some (newPiece, newPos) =>
    { state with current := newPiece, currentPos := newPos }
  | none => state

/-- Lock the current piece and handle line clears with animations -/
def lock (state : GameState) : GameState := Id.run do
  -- Lock piece to board
  let board := lockPiece state.board state.current state.currentPos

  -- Set lock flash animation
  let lockedCells := state.current.cellsAt state.currentPos
  let anim := { state.anim with
    lockFlashCells := lockedCells
    lockFlashColor := state.current.color
    lockFlashTimer := 3
  }

  -- Check for complete rows
  let completeRows := board.completeRows

  if completeRows.isEmpty then
    -- No lines to clear, spawn new piece immediately
    let mut newState := { state with
      board := board
      tickCounter := 0
      anim := anim
    }
    newState := newState.spawnPiece
    newState
  else
    -- Lines to clear - start animation, delay actual clearing
    let (clearedBoard, numCleared) := board.clearLines
    let newLinesCleared := state.linesCleared + numCleared
    let newLevel := levelFromLines newLinesCleared
    let points := linePoints numCleared newLevel

    -- Store pending state and start animation
    let anim := { anim with
      clearingRows := completeRows
      clearTimer := 12  -- 12 frames of flashing
      pendingBoard := some clearedBoard
    }

    { state with
      board := board  -- Keep original board (lines visible during animation)
      score := state.score + points
      linesCleared := newLinesCleared
      level := newLevel
      tickCounter := 0
      anim := anim
    }

/-- Finish line clear animation - apply pending board and spawn new piece -/
def finishLineClear (state : GameState) : GameState :=
  match state.anim.pendingBoard with
  | some newBoard =>
    let anim := { state.anim with
      clearingRows := []
      clearTimer := 0
      pendingBoard := none
    }
    let newState := { state with
      board := newBoard
      anim := anim
    }
    newState.spawnPiece
  | none =>
    -- Shouldn't happen, but just spawn a piece
    state.spawnPiece

/-- Hard drop - drop instantly and lock with trail animation -/
def hardDrop (state : GameState) : GameState :=
  let startY := state.currentPos.y
  let targetY := state.ghostY
  let dropDistance := (targetY - startY).toNat

  -- Only show trail if dropping at least 2 cells
  let anim := if dropDistance >= 2 then
    { state.anim with
      dropTrailCells := state.current.cells
      dropTrailStartY := startY
      dropTrailEndY := targetY
      dropTrailColor := state.current.color
      dropTrailTimer := 4
      dropTrailX := state.currentPos.x
    }
  else state.anim

  let points := dropDistance * hardDropPoints
  let droppedState := { state with
    currentPos := ⟨state.currentPos.x, targetY⟩
    score := state.score + points
    anim := anim
  }
  lock droppedState

/-- Update animation timers (called each frame) -/
def updateAnimations (state : GameState) : GameState := Id.run do
  let mut anim := state.anim

  -- Decrement drop trail timer
  if anim.dropTrailTimer > 0 then
    anim := { anim with dropTrailTimer := anim.dropTrailTimer - 1 }

  -- Decrement lock flash timer
  if anim.lockFlashTimer > 0 then
    anim := { anim with lockFlashTimer := anim.lockFlashTimer - 1 }

  -- Handle line clear animation
  if anim.clearTimer > 0 then
    anim := { anim with clearTimer := anim.clearTimer - 1 }
    if anim.clearTimer == 0 then
      -- Animation done, apply pending board and spawn new piece
      return finishLineClear { state with anim := anim }

  -- Handle game over fill animation
  if state.gameOver && anim.gameOverFillTimer > 0 then
    anim := { anim with gameOverFillTimer := anim.gameOverFillTimer - 1 }
    if anim.gameOverFillTimer == 0 && anim.gameOverFillRow > 0 then
      -- Move to next row
      anim := { anim with
        gameOverFillRow := anim.gameOverFillRow - 1
        gameOverFillTimer := 2
      }

  { state with anim := anim }

/-- Apply gravity (called each frame) -/
def applyGravity (state : GameState) : GameState :=
  -- First update animations
  let state := updateAnimations state

  -- If line clear animation is in progress, don't apply gravity
  if state.anim.clearTimer > 0 then
    state
  else if state.paused || state.gameOver then
    state
  else
    let newTick := state.tickCounter + 1
    if newTick >= state.gravityDelay then
      -- Time to drop
      let newPos := state.currentPos + Direction.down.toOffset
      if collides state.board state.current newPos then
        -- Can't move down, lock piece
        lock state
      else
        { state with currentPos := newPos, tickCounter := 0 }
    else
      { state with tickCounter := newTick }

/-- Toggle pause state -/
def togglePause (state : GameState) : GameState :=
  { state with paused := !state.paused }

/-- Restart the game -/
def restart (_state : GameState) (seed : UInt64) : GameState :=
  GameState.new seed

end Blockfall.Game
