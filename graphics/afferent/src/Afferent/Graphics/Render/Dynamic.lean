/-
  Afferent Dynamic Rendering Module

  CPU-side particle and orbital state utilities used by Canvas drawing helpers.
-/

import Init.Data.FloatArray

namespace Afferent.Render.Dynamic

/-- Generic particle data for dynamic rendering.
    Each particle has position, velocity, and a base hue. -/
structure ParticleState where
  /-- Per-particle: x, y, vx, vy, hueBase (5 floats) -/
  data : FloatArray
  /-- Number of particles -/
  count : Nat
  /-- Screen bounds for collision detection -/
  screenWidth : Float
  /-- Screen bounds for collision detection -/
  screenHeight : Float
  deriving Inhabited

/-- Create initial particle state with random positions and velocities. -/
def ParticleState.create (count : Nat) (screenWidth screenHeight : Float) (seed : Nat) : ParticleState :=
  let data := Id.run do
    let mut arr := FloatArray.emptyWithCapacity (count * 5)
    let mut s := seed
    for i in [:count] do
      s := (s * 1103515245 + 12345) % (2^31)
      let x := (s.toFloat / 2147483648.0) * screenWidth
      s := (s * 1103515245 + 12345) % (2^31)
      let y := (s.toFloat / 2147483648.0) * screenHeight
      s := (s * 1103515245 + 12345) % (2^31)
      let vx := (s.toFloat / 2147483648.0 - 0.5) * 400.0
      s := (s * 1103515245 + 12345) % (2^31)
      let vy := (s.toFloat / 2147483648.0 - 0.5) * 400.0
      let hue := i.toFloat / count.toFloat
      arr := arr.push x
      arr := arr.push y
      arr := arr.push vx
      arr := arr.push vy
      arr := arr.push hue
    arr
  { data, count, screenWidth, screenHeight }

/-- Update particle positions with simple bouncing physics. -/
def ParticleState.updateBouncing (p : ParticleState) (dt : Float) (shapeRadius : Float) : ParticleState :=
  let data := Id.run do
    let mut arr := p.data
    for i in [:p.count] do
      let base := i * 5
      let x := arr.get! base
      let y := arr.get! (base + 1)
      let vx := arr.get! (base + 2)
      let vy := arr.get! (base + 3)

      let x' := x + vx * dt
      let y' := y + vy * dt

      let (x'', vx', bouncedX) :=
        if x' < shapeRadius then (shapeRadius, -vx, true)
        else if x' > p.screenWidth - shapeRadius then (p.screenWidth - shapeRadius, -vx, true)
        else (x', vx, false)
      let (y'', vy', bouncedY) :=
        if y' < shapeRadius then (shapeRadius, -vy, true)
        else if y' > p.screenHeight - shapeRadius then (p.screenHeight - shapeRadius, -vy, true)
        else (y', vy, false)

      arr := arr.set! base x''
      arr := arr.set! (base + 1) y''
      if bouncedX then
        arr := arr.set! (base + 2) vx'
      if bouncedY then
        arr := arr.set! (base + 3) vy'
    arr
  { p with data }

/-- Create particles in a grid layout with zero velocity. -/
def ParticleState.createGrid (cols rows : Nat) (startX startY spacing : Float)
    (screenWidth screenHeight : Float) : ParticleState :=
  let count := cols * rows
  let data := Id.run do
    let mut arr := FloatArray.emptyWithCapacity (count * 5)
    for row in [:rows] do
      for col in [:cols] do
        let x := startX + col.toFloat * spacing
        let y := startY + row.toFloat * spacing
        let hue := (row * cols + col).toFloat / count.toFloat
        arr := arr.push x
        arr := arr.push y
        arr := arr.push 0.0
        arr := arr.push 0.0
        arr := arr.push hue
    arr
  { data, count, screenWidth, screenHeight }

/-- Orbital particle state. Each particle orbits around a center point. -/
structure OrbitalState where
  /-- Per-particle orbital parameters: phase, radius, speed, hue, size (5 floats) -/
  params : FloatArray
  /-- Number of particles -/
  count : Nat
  /-- Center of orbit X coordinate -/
  centerX : Float
  /-- Center of orbit Y coordinate -/
  centerY : Float
  /-- Screen width for coordinate conversion -/
  screenWidth : Float
  /-- Screen height for coordinate conversion -/
  screenHeight : Float
  deriving Inhabited

/-- Create orbital particles with random parameters. -/
def OrbitalState.create (count : Nat) (centerX centerY : Float)
    (minRadius maxRadius : Float) (speedMin speedMax : Float)
    (sizeMin sizeMax : Float) (screenWidth screenHeight : Float)
    (seed : Nat) : OrbitalState :=
  let twoPi : Float := 6.283185307
  let params := Id.run do
    let mut arr := FloatArray.emptyWithCapacity (count * 5)
    let mut s := seed
    for i in [:count] do
      s := (s * 1103515245 + 12345) % (2^31)
      let phase := (s.toFloat / 2147483648.0) * twoPi
      s := (s * 1103515245 + 12345) % (2^31)
      let radius := minRadius + (s.toFloat / 2147483648.0) * (maxRadius - minRadius)
      s := (s * 1103515245 + 12345) % (2^31)
      let baseSpeed := speedMin + (s.toFloat / 2147483648.0) * (speedMax - speedMin)
      s := (s * 1103515245 + 12345) % (2^31)
      let dir : Float := if s % 2 == 0 then 1.0 else -1.0
      let speed := baseSpeed * dir
      let hue := i.toFloat / count.toFloat
      s := (s * 1103515245 + 12345) % (2^31)
      let size := sizeMin + (s.toFloat / 2147483648.0) * (sizeMax - sizeMin)
      arr := arr.push phase
      arr := arr.push radius
      arr := arr.push speed
      arr := arr.push hue
      arr := arr.push size
    arr
  { params, count, centerX, centerY, screenWidth, screenHeight }

end Afferent.Render.Dynamic
