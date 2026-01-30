---
id: 515
title: Linalg Demo: Physics Simulation Widgets
status: open
priority: medium
created: 2026-01-30T02:28:07
updated: 2026-01-30T02:28:07
labels: []
assignee: 
project: afferent
blocks: []
blocked_by: []
---

# Linalg Demo: Physics Simulation Widgets

## Description
Create 6 physics simulation visualization widgets:

1. **ParticleIntegrationComparison** - Multiple particles with different integrators starting same position. Shows divergence over time. Energy conservation graph. Presets: harmonic oscillator, orbit, projectile. Demonstrates Particle, Integration.eulerStep, semiImplicitEulerStep, verletStep, rk4Step.

2. **CollisionResponseDemo** - Two particles/bodies colliding. Shows collision normal, impulse vector, before/after velocities. Restitution and friction sliders. Demonstrates Contact, Material, CollisionResponse.particleImpulse, resolveParticleCollision.

3. **RigidBodySimulator** - 3D rigid body (box/sphere/cylinder) with applied forces. Shows angular velocity, torque. Click to apply force at point. Demonstrates RigidBody, applyForce, applyForceAtPoint, applyTorque, InertiaTensor shapes.

4. **InertiaTensorVisualizer** - Rigid body with inertia tensor shown as ellipsoid. Shape dropdown, dimension sliders. Parallel axis theorem offset. Demonstrates InertiaTensor module, solidSphere, solidBox, solidCylinder, parallelAxis.

5. **SweptCollisionDemo** - Moving sphere/AABB sweeping through space. Shows swept volume (capsule). Exact time/point of impact. Demonstrates SweptCollision functions, SweptHit, comparison with discrete collision (tunneling).

6. **ConstraintSolver** - Simple distance/position constraints between particles. Shows constraint forces. Demonstrates basic constraint satisfaction for physics simulations.

