---
id: 512
title: Linalg Demo: Easing Function Widgets
status: closed
priority: medium
created: 2026-01-30T02:28:06
updated: 2026-01-30T22:02:02
labels: []
assignee: 
project: afferent
blocks: []
blocked_by: []
---

# Linalg Demo: Easing Function Widgets

## Description
Create 3 easing and interpolation visualization widgets:

1. **EasingFunctionGallery** - Grid of animated boxes using different easing functions. Graph overlay showing function shape. All 18+ functions: quadIn/Out/InOut, cubicIn/Out/InOut, sineIn/Out/InOut, expoIn/Out/InOut, circIn/Out/InOut, backIn/Out/InOut, elasticIn/Out/InOut, bounceIn/Out/InOut. Side-by-side comparison mode.

2. **SmoothDampFollower** - Target point with smooth-following object. Shows velocity graph. Sliders for smoothTime and maxSpeed. Demonstrates SmoothDamp.step, SmoothDampState/2/3, critically damped spring behavior.

3. **SpringAnimationPlayground** - Oscillating object with spring physics. Damping ratio slider (underdamped, critically damped, overdamped). Frequency slider. Shows decay envelope and energy graph. Demonstrates damped harmonic oscillator math.

## Progress
- [2026-01-30T22:01:58] Implemented easing gallery, SmoothDamp follower, and spring playground demos; wired registry/imports; build.sh passes with existing warnings.
- [2026-01-30T22:02:02] Closed: Added easing gallery, SmoothDamp follower, and spring playground demos; updated registry/imports; build.sh succeeds (existing warnings only).
