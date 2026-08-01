FS25 Deep Mud Ruts
Version 1.0

PURPOSE
Increases the strength of FS25's native dynamic wheel deformation so vehicles
leave deeper physical ruts on deformable terrain.

FS25's Ground Deformation gameplay setting must be enabled.

RUT DEPTH PRESETS
Open Game Settings and find the Deep Ruts section:

    Off / Base Game = 1.00x
    Default         = 1.75x
    Medium          = 2.25x
    High            = 2.50x

The selected preset is stored with the savegame. It applies immediately to
loaded wheels. In multiplayer, the server host or administrator controls the
setting and it is synchronized to joining players.

COMPATIBILITY
Designed to work with:

    FS25_MudSystemPhysics
    FS25_useYourTyres

Deep Mud Ruts changes only WheelPhysics.displacementScale. It does not
overwrite WheelPhysics.serverUpdate, updatePhysics, updateTireFriction,
updateContact, or updateBase. It also does not enable the separate extraSink
system.

Mud System Physics may continue controlling wheel sinking, tire pressure,
traction, resistance, and wheel-radius changes.

Use Up Your Tyres may continue controlling tire wear, worn tire radius, and
wear-related friction.

PERFORMANCE
There is no added per-frame update loop. The preset is applied when wheel
physics initializes and when the setting changes. The visible deformation
itself is still handled by FS25's native ground-deformation system.

INSTALLATION
Place FS25_DeepMudRuts.zip in:

Documents/My Games/FarmingSimulator2025/mods

Select the mod when loading the savegame.
