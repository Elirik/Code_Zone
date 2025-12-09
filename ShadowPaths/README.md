# Shadow Paths

A dark fantasy 2D RPG where exploration choices permanently corrupt the player character. Combines Pokemon-inspired exploration with Dark Souls narrative design and Gothic horror aesthetics.

## Game Overview

**Shadow Paths** is a story-driven RPG about a scholar who discovers forbidden knowledge that gradually transforms them. Every choice matters, and every discovered secret leaves visible physical and psychological scars.

### Key Features

- **Dynamic Corruption System**: Player character visually transforms based on choices (4 stages of corruption)
- **Branching Narrative**: 5 distinct endings based on corruption level and major choices
- **Meaningful Choices**: Every decision has visible, permanent consequences
- **Turn-Based Combat**: Strategic combat enhanced by corruption-granted abilities
- **Exploration**: Secret areas revealed through corruption and investigation
- **Atmospheric Presentation**: Dynamic lighting, weather, and visual corruption effects

### Corruption Mechanics

The core mechanic of Shadow Paths is the corruption system:

- **Stage 1 (0-25%)**: Subtle changes - unusual eye color, faint scar patterns
- **Stage 2 (25-50%)**: Obvious markings - glowing runes, skin discoloration
- **Stage 3 (50-75%)**: Major transformation - limb distortion, inhuman features
- **Stage 4 (75-100%)**: Complete corruption - monstrous form

Corruption affects:
- Visual appearance of the player character
- Available abilities and powers
- NPC reactions and relationships
- Access to certain areas
- Story progression and endings

## Technical Implementation

### Engine & Language
- **Engine**: Godot 4.x
- **Language**: GDScript
- **Platform**: Windows/Mac/Linux (Desktop)

### Architecture

#### Core Systems
- `GameStateManager.gd`: Manages corruption, choices, world state
- `Player.gd`: Player character with corruption visual feedback
- `SaveSystem.gd`: Multiple save slots with auto-save functionality

#### Combat System
- `CombatEngine.gd`: Turn-based combat with action queue
- `Enemy.gd`: Enemy AI with corruption-based variants
- `Ability.gd`: Ability system with corruption requirements

#### World Systems
- `ExplorationController.gd`: Overworld exploration and interactions
- `NPC.gd`: Dynamic NPCs that react to player corruption
- `Interactable.gd`: Objects that present choices and secrets
- `EncounterZone.gd`: Random encounters with corruption scaling

#### UI Systems
- `UIController.gd`: Health, mana, corruption meters with corruption-based theming
- Dialogue system with branching choices
- Inventory management with corruption-aware items

#### Data Systems
- Item database with corruption-enhanced equipment
- Dialogue database with corruption-based conditional responses
- Quest and world state tracking

### File Structure

```
ShadowPaths/
├── scenes/                  # Scene files (.tscn)
│   ├── Main.tscn           # Main game scene
│   ├── world/              # World exploration scenes
│   ├── ui/                 # User interface scenes
│   └── combat/             # Combat system scenes
├── scripts/                # GDScript files
│   ├── core/               # Core game systems
│   ├── world/              # World exploration systems
│   ├── combat/             # Combat mechanics
│   ├── narrative/          # Story and dialogue
│   └── ui/                 # User interface logic
├── assets/                 # Game assets
│   ├── art/                # Visual assets
│   ├── audio/              # Sound and music
│   └── data/               # Game data and databases
└── tests/                  # Test scenes and scripts
```

## Game Progression

### Three-Act Structure

**Act I: The Call (Hours 1-4)**
- Introduction to the world and first taste of forbidden power
- Tutorial for corruption system
- First major moral choice

**Act II: The Descent (Hours 4-12)**
- Hub-based exploration with corrupted regions
- Escalating choices with increasing stakes
- Growing isolation as corruption becomes visible

**Act III: The Consequence (Hours 12-16)**
- Point of no return at 75% corruption
- Final choice determining ending
- Face consequences of accumulated choices

### Five Endings

1. **Corrupted Victory**: Rule as monster (High corruption, embrace choice)
2. **Redemptive Sacrifice**: Die as human (High corruption, redeem choice)
3. **Transcendent Being**: Become something else (High corruption, transcend choice)
4. **Wounded Survivor**: Live with scars (Low corruption, all paths)
5. **Normal Life**: Reject all knowledge (No corruption, special path)

## Controls

- **Arrow Keys/WASD**: Movement
- **E/Space**: Interact
- **I**: Open inventory
- **Escape**: Close menus
- **Mouse**: Navigate UI

## Development Status

### Implemented Features (Phase 1 Complete)

✅ **Core Systems**
- Project structure and basic setup
- Player movement and collision detection
- Character stats and progression system
- Inventory and item management
- Save/load functionality with multiple slots
- UI framework with health/mana/corruption display

✅ **Combat System**
- Turn-based combat engine with action queue
- Enemy AI with corruption-based variants
- Ability system with corruption requirements
- Status effects and buffs/debuffs

✅ **Corruption Mechanics**
- Visual corruption progression (4 stages)
- Corruption-based ability unlocks
- NPC reactions based on corruption level
- Choice and consequence tracking

✅ **World Systems**
- NPC interaction system with corruption awareness
- Interactable objects with choice mechanics
- Random encounter zones with corruption scaling
- Environment and exploration controller

✅ **Data Systems**
- Item database with corruption-enhanced equipment
- Dialogue database with branching choices
- Forbidden knowledge system

### Next Development Phases

**Phase 2: Content & Polish (Weeks 5-8)**
- Create world maps and environments
- Add visual assets and character sprites
- Implement particle effects for corruption
- Build comprehensive quest system

**Phase 3: Audio & Atmosphere (Weeks 9-12)**
- Compose dynamic music system
- Add sound effects and ambient audio
- Implement voice distortion for corrupted dialogue
- Create atmospheric visual effects

**Phase 4: Content Creation (Weeks 13-16)**
- Develop complete story content
- Create all 5 endings
- Add side quests and optional content
- Balance gameplay and corruption progression

## Testing

The project includes basic test scenes for:
- Combat system functionality
- Corruption mechanics
- Inventory management
- Save/load operations

Run tests by opening scenes in the `/tests/` directory.

## Contributing

This is a solo developer project following the development roadmap outlined in `planning.md`. The architecture is designed to be modular and extensible for future content additions.

## License

This project is created for educational and portfolio purposes. Assets and code are original unless otherwise specified.

---

**Built with Godot 4.x**
*A game where every choice leaves a scar*