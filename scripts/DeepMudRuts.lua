DeepMudRuts = DeepMudRuts or {}

DeepMudRuts.MOD_NAME = g_currentModName or "FS25_DeepMudRuts"
DeepMudRuts.MOD_DIRECTORY = g_currentModDirectory or ""
DeepMudRuts.SAVEGAME_FILENAME = "DeepMudRuts.xml"
DeepMudRuts.PRESET_VALUES = {
    1.00, -- Off / Base Game
    1.75, -- Default
    2.25, -- Medium
    2.50  -- High
}
DeepMudRuts.DEFAULT_PRESET = 2
DeepMudRuts.preset = DeepMudRuts.DEFAULT_PRESET
DeepMudRuts.rutDepthMultiplier =
    DeepMudRuts.PRESET_VALUES[DeepMudRuts.DEFAULT_PRESET]
DeepMudRuts.hookInstalled = false

local function dmrClampPreset(state)
    state = math.floor((tonumber(state) or DeepMudRuts.DEFAULT_PRESET) + 0.5)
    return math.max(1, math.min(#DeepMudRuts.PRESET_VALUES, state))
end

function DeepMudRuts:getNearestPreset(multiplier)
    multiplier = tonumber(multiplier) or self.PRESET_VALUES[self.DEFAULT_PRESET]
    local bestState = self.DEFAULT_PRESET
    local bestDistance = math.huge

    for state, value in ipairs(self.PRESET_VALUES) do
        local distance = math.abs(multiplier - value)
        if distance < bestDistance then
            bestState = state
            bestDistance = distance
        end
    end

    return bestState
end

function DeepMudRuts:loadPackagedDefault()
    local filename = Utils.getFilename("deepMudRuts.xml", self.MOD_DIRECTORY)
    if not fileExists(filename) then
        return
    end

    local xmlFile = loadXMLFile("deepMudRutsDefaults", filename)
    if xmlFile == nil or xmlFile == 0 then
        return
    end

    local multiplier = getXMLFloat(
        xmlFile,
        "deepMudRuts.settings#rutDepthMultiplier"
    )
    delete(xmlFile)

    if multiplier ~= nil then
        self.preset = self:getNearestPreset(multiplier)
        self.rutDepthMultiplier = self.PRESET_VALUES[self.preset]
    end
end

function DeepMudRuts:getSavegameSettingsPath()
    local mission = g_currentMission
    local missionInfo = mission ~= nil and mission.missionInfo or nil
    local savegameDirectory =
        missionInfo ~= nil and missionInfo.savegameDirectory or nil

    if savegameDirectory == nil or savegameDirectory == "" then
        return nil
    end

    return savegameDirectory .. "/" .. self.SAVEGAME_FILENAME
end

function DeepMudRuts:loadSavegameSettings()
    local path = self:getSavegameSettingsPath()
    if path == nil or not fileExists(path) then
        return
    end

    local xmlFile = loadXMLFile("deepMudRutsSavegameSettings", path)
    if xmlFile == nil or xmlFile == 0 then
        Logging.warning("[DeepMudRuts] Could not load savegame settings")
        return
    end

    local state = getXMLInt(xmlFile, "deepMudRuts.settings#preset")
    local multiplier = getXMLFloat(
        xmlFile,
        "deepMudRuts.settings#rutDepthMultiplier"
    )
    delete(xmlFile)

    if state == nil and multiplier ~= nil then
        state = self:getNearestPreset(multiplier)
    end

    if state ~= nil then
        self.preset = dmrClampPreset(state)
        self.rutDepthMultiplier = self.PRESET_VALUES[self.preset]
    end
end

function DeepMudRuts:saveSettings()
    if g_server == nil then
        return
    end

    local path = self:getSavegameSettingsPath()
    if path == nil then
        return
    end

    local xmlFile = createXMLFile(
        "deepMudRutsSavegameSettings",
        path,
        "deepMudRuts"
    )
    if xmlFile == nil or xmlFile == 0 then
        Logging.warning("[DeepMudRuts] Could not save settings")
        return
    end

    setXMLInt(xmlFile, "deepMudRuts.settings#preset", self.preset)
    setXMLFloat(
        xmlFile,
        "deepMudRuts.settings#rutDepthMultiplier",
        self.rutDepthMultiplier
    )
    saveXMLFile(xmlFile)
    delete(xmlFile)
end

function DeepMudRuts:applyToLoadedWheels()
    local mission = g_currentMission
    if mission == nil then
        return
    end

    local vehicles = mission.vehicles
    if vehicles == nil and mission.vehicleSystem ~= nil then
        vehicles = mission.vehicleSystem.vehicles
    end

    for _, vehicle in pairs(vehicles or {}) do
        local wheelsSpec = vehicle ~= nil and vehicle.spec_wheels or nil
        for _, wheel in pairs(
            wheelsSpec ~= nil and wheelsSpec.wheels or {}
        ) do
            local wheelPhysics = wheel ~= nil and wheel.physics or nil
            if wheelPhysics ~= nil
                and wheelPhysics.supportsWheelSink ~= false then
                wheelPhysics.displacementScale = self.rutDepthMultiplier
            end
        end
    end
end

function DeepMudRuts:setPreset(state, shouldSave)
    state = dmrClampPreset(state)
    self.preset = state
    self.rutDepthMultiplier = self.PRESET_VALUES[state]
    self:applyToLoadedWheels()

    if shouldSave == true then
        self:saveSettings()
    end

    if DeepMudRutsSettings ~= nil
        and DeepMudRutsSettings.updateSetting ~= nil then
        DeepMudRutsSettings:updateSetting()
    end

    Logging.info(
        "[DeepMudRuts] Rut depth set to preset %d (%.2fx)",
        self.preset,
        self.rutDepthMultiplier
    )
end

function DeepMudRuts.onWheelPhysicsFinalize(wheelPhysics)
    if wheelPhysics == nil or wheelPhysics.supportsWheelSink == false then
        return
    end

    -- This remains the only wheel-physics value changed by the mod.
    -- Mud System Physics remains responsible for extra sinking, wheel radius,
    -- traction, and resistance. Use Up Your Tyres remains responsible for
    -- tire wear, worn radius, and wear-related friction.
    wheelPhysics.displacementScale = DeepMudRuts.rutDepthMultiplier
end

function DeepMudRuts:installHook()
    if self.hookInstalled then
        return
    end

    if WheelPhysics == nil or WheelPhysics.finalize == nil then
        Logging.error("[DeepMudRuts] WheelPhysics.finalize is unavailable")
        return
    end

    WheelPhysics.finalize = Utils.appendedFunction(
        WheelPhysics.finalize,
        DeepMudRuts.onWheelPhysicsFinalize
    )

    self.hookInstalled = true
    Logging.info(
        "[DeepMudRuts] Installed with %.2fx terrain displacement",
        self.rutDepthMultiplier
    )
end

function DeepMudRuts:loadMap()
    if g_server ~= nil then
        self:loadSavegameSettings()
    end
    self:applyToLoadedWheels()
end

function DeepMudRuts:deleteMap()
    self.preset = self.DEFAULT_PRESET
    self.rutDepthMultiplier = self.PRESET_VALUES[self.DEFAULT_PRESET]
end

local function dmrSavegameHook()
    DeepMudRuts:saveSettings()
end

DeepMudRuts:loadPackagedDefault()
DeepMudRuts:installHook()
addModEventListener(DeepMudRuts)

if FSBaseMission ~= nil and FSBaseMission.saveSavegame ~= nil
    and Utils ~= nil and Utils.appendedFunction ~= nil
    and _G.__DeepMudRutsSaveHooked ~= true then
    FSBaseMission.saveSavegame = Utils.appendedFunction(
        FSBaseMission.saveSavegame,
        dmrSavegameHook
    )
    _G.__DeepMudRutsSaveHooked = true
end
