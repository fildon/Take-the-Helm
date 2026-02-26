# Take the Helm

A 2D sailing game built with Godot 4. Steer a boat across an animated ocean, navigating around islands.

## Controls

| Key              | Action         |
| ---------------- | -------------- |
| **W** / **↑**    | Thrust forward |
| **S** / **↓**    | Reverse (slow) |
| **A** / **←**    | Turn left      |
| **D** / **→**    | Turn right     |
| **Scroll wheel** | Zoom in / out  |

## Project structure

```
project.godot            # Engine config & entry point
scenes/
  main.tscn              # Root scene – ocean, islands, boat, camera
  boat.tscn              # Boat with hull, deck, sail polygons + collision
scripts/
  boat.gd                # Thrust-and-steer CharacterBody2D controller
  camera_rig.gd          # Smooth-follow camera with look-ahead & zoom
shaders/
  water.gdshader         # Animated ocean surface (layered sine waves)
```

## Architecture notes

- **Data model is 2D** – all gameplay logic uses `CharacterBody2D`, `Vector2`, and Godot's 2D physics.
- **Graphics** – currently 2D polygons + a water shader. The scene structure is ready for a 3D visual layer (e.g. replacing `Polygon2D` nodes with `MeshInstance3D` or `Sprite3D`) without changing the underlying movement or collision logic.
- **Boat physics** – arcade-style: forward thrust in the facing direction, linear drag simulates water resistance, `move_and_slide()` handles island collisions.
- **Camera** – north-up (no rotation), smooth position tracking with a speed-dependent look-ahead offset.

## Getting started

1. Open the project folder in **Godot 4.4+**.
2. Press **F5** (or **▶ Run**) to play.
