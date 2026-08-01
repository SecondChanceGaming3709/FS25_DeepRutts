# FS25_DeepRutts
Make every pass leave a deeper mark.


# Deep Ruts – FS25

**Make every pass leave a deeper mark.**

Deep Ruts increases the strength of Farming Simulator 25’s native ground-deformation system, allowing tractors and other vehicles to leave deeper, more noticeable physical wheel ruts on supported terrain.

The mod does not replace FS25’s deformation system or add fake tire-track decals. Terrain type, ground moisture, vehicle weight, tire width, and driving speed still determine how the ground reacts.

## Rut Depth Settings

Change the rut depth under **Game Settings → Deep Ruts**:

* **Off / Base Game – 1.00x**
* **Default – 1.75x**
* **Medium – 2.25x**
* **High – 2.50x**

The selected setting is saved with your savegame and applies immediately.

## Mod Compatibility

Deep Ruts is designed to work alongside:

* **Mud System Physics**
* **Use Up Your Tyres**

Deep Ruts changes only the native terrain-displacement strength. Mud System Physics can continue controlling mud sinking, traction, resistance, tire pressure, and related mud effects.

Use Up Your Tyres can continue controlling tire wear, worn tire radius, and wear-related friction.

## Performance

Deep Ruts does not add a continuous per-frame update loop. The selected multiplier is applied when wheel physics initializes or when the setting changes. Actual terrain deformation is still processed by FS25’s native system.

Performance impact should be minimal, although very high ground-deformation settings may have a greater visual impact on heavily traveled areas.

## Requirements

* Farming Simulator 25
* **Ground Deformation must be enabled** in the game settings
* The map must support FS25’s native dynamic ground deformation

## Multiplayer

Multiplayer is supported. The server host or administrator controls the rut-depth setting, which is synchronized with joining players.

For the best results, all players should use the same mod version.

## Installation

1. Download `FS25_DeepMudRuts.zip`.

2. Place the ZIP file in:

   `Documents/My Games/FarmingSimulator2025/mods`

3. Enable **Deep Ruts** when loading your savegame.

4. Select your preferred depth under **Game Settings → Deep Ruts**.

**Author: SecondChanceGaming3709**
