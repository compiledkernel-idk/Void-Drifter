# Void Drifter 3D

![Void Drifter 3D](image.png)

A 3D space shooter implemented in x86-64 assembly language using SDL2 for rendering and audio.

## Technical Overview

Void Drifter 3D is a real-time arcade shooter written entirely in NASM assembly. The game features a custom 3D projection system, collision detection, particle effects, and progressive difficulty scaling.

### Architecture

- **Language**: x86-64 Assembly (NASM syntax)
- **Graphics**: SDL2 rendering API
- **Audio**: SDL2 audio with procedural square wave synthesis
- **Platform**: Linux x86-64
- **Build System**: GNU Make

### Components

- `main.asm` - Core game loop, input handling, game state management
- `math.asm` - 3D vector operations and perspective projection
- `data.asm` - 3D model vertex data
- `sound.asm` - Audio callback and sound synthesis
- `Makefile` - Build configuration

## Build Requirements

- NASM (Netwide Assembler)
- GCC (for linking)
- SDL2 development libraries
- GNU Make

## Clone the repository

```bash
git clone https://github.com/compiledkernel-idk/Void-Drifter.git
```

Navigate to the repository directory:

```bash
cd Void-Drifter
```

## Compilation

```bash
make
```

This produces a statically-linked executable named `game`.

## Execution

```bash
./game
```

## Controls

| Input | Action |
|-------|--------|
| W | Move forward |
| S | Move backward |
| A | Move left |
| D | Move right |
| SPACE | Fire weapon |
| R | Restart (game over state) |
| ESC | Exit application |

## Game Mechanics

### Difficulty Progression

The game implements dynamic difficulty scaling based on player score:

- **Difficulty Level**: `floor(score / 10)`
- **Enemy Speed Multiplier**: `base_speed × (1 + difficulty × 0.2)`
- **Spawn Rate**: `max(30, 60 - difficulty × 3)` frames between spawns

### Scoring System

- Enemy destruction: +1 point
- Score displayed as horizontal bar (top-right)

### Lives System

- Initial lives: 5
- Lives lost on enemy collision
- Game over when lives reach 0
- Lives displayed as triangle indicators (top-left)

### Visual Elements

- **Player Ship**: Cyan wireframe triangle (2.0 unit scale)
- **Enemies**: Red 30×30 pixel square outlines
- **Bullets**: Yellow 10-pixel vertical lines
- **Explosions**: Orange radiating particle effects (10-frame duration)

## Technical Implementation Details

### 3D Projection

Implements perspective projection with the following formula:

```
screen_x = (world_x / world_z) × 400 + 400
screen_y = (world_y / world_z) × 400 + 300
```

Near plane clipping at z = 0.1 to prevent division artifacts.

### Collision Detection

Axis-aligned bounding box (AABB) collision with 1.0 unit threshold:

```
collision = |dx| < 1.0 && |dy| < 1.0 && |dz| < 1.0
```

### Audio Synthesis

Square wave generation at 44.1kHz sample rate:

- Shoot sound: 880Hz, 10,000 samples
- Explosion sound: 110Hz, 20,000 samples

### Performance Characteristics

- Target frame rate: 60 FPS (16ms frame budget)
- Maximum entities: 20 bullets, 10 enemies, 10 explosions
- Stack-aligned function calls for SSE compatibility

## Memory Layout

```
.data   - Game state, constants, model data
.bss    - SDL handles, entity arrays, projection buffer
.text   - Executable code
```

## Known Limitations

- Fixed camera position (z = -5.0)
- No texture mapping (wireframe only)
- Single-threaded execution
- No save/load functionality

## Contributing

Contributions are welcome! Here's how you can help:

### Reporting Issues

- Use the [GitHub Issues](https://github.com/compiledkernel-idk/Void-Drifter/issues) page
- Include steps to reproduce the bug
- Specify your system configuration (OS, SDL2 version)

### Submitting Code

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Test compilation and gameplay
5. Commit with clear messages (`git commit -m "Add feature: description"`)
6. Push to your fork (`git push origin feature/your-feature`)
7. Open a Pull Request

### Development Guidelines

- Follow existing assembly code style
- Add comments for complex logic
- Test on Linux x86-64 before submitting
- Update README if adding features
- Maintain MIT license headers in new files

### Ideas for Contributions

- Port to other platforms (Windows, macOS)
- Add more enemy types or patterns
- Implement power-up system
- Add background music
- Improve 3D rendering (textures, lighting)
- Add multiplayer support
- Create level progression system

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Build Warnings

The linker may emit warnings regarding executable stack sections from `sound.o`. This is expected behavior for assembly modules without GNU stack annotations and does not affect functionality.
