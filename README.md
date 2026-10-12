# Vampire Telekinesis (Godot 4)

A small Godot 4 starter project for a pixel-art vampire and telekinetic physics prototype.

## Controls
- WASD / arrow keys: move
- Mouse: aim
- E: grab the first physics body along the mouse ray
- Space: throw (hold to charge, then release to throw)
- Q: release without throwing

## Setup
1. Open `project.godot` in Godot 4.3 or later.
2. Press F6 to run `scenes/main.tscn`, or F5 to run the project.
3. Drag the mouse ray over a crate and press E, then hold Space briefly and release Space to throw.
4. Q releases a held object.

## Important prototype notes
- The sample scene uses Polygon2D art so it can run without imported sprite assets.
- `telekinetic_distortion.gdshader` is a screen-reading shader template. It needs a suitable CanvasLayer/ColorRect overlay and a configured effect center to use it in-game; it is not automatically applied.
- `pixel_particle.gdshader` is a shared particle shader template. Assign it to a ShaderMaterial on a particle draw pass when you add particle textures.
- The sample crate has no fragment scene assigned, so it will be removed when its impact threshold is reached. Assign a fragment PackedScene in the Inspector to spawn physical rubble.
- For a production project, add target layers, enemy health, blood decals, mobile quality settings, sound, and object pooling.
- Collision shape subresources are declared in each scene. If your Godot version flags a scene serialization issue, open and re-save the scene from the editor; scene serialization details can vary slightly across minor versions.
