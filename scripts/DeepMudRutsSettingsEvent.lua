DeepMudRutsSettingsEvent = {}
local DeepMudRutsSettingsEvent_mt =
    Class(DeepMudRutsSettingsEvent, Event)

InitEventClass(
    DeepMudRutsSettingsEvent,
    "DeepMudRutsSettingsEvent"
)

function DeepMudRutsSettingsEvent.emptyNew()
    return Event.new(DeepMudRutsSettingsEvent_mt)
end

function DeepMudRutsSettingsEvent.new(isRequest, preset)
    local self = DeepMudRutsSettingsEvent.emptyNew()
    self.isRequest = isRequest == true
    self.preset = preset or DeepMudRuts.DEFAULT_PRESET
    return self
end

function DeepMudRutsSettingsEvent:writeStream(streamId, connection)
    streamWriteBool(streamId, self.isRequest)
    if not self.isRequest then
        streamWriteFloat32(streamId, self.preset)
    end
end

function DeepMudRutsSettingsEvent:readStream(streamId, connection)
    self.isRequest = streamReadBool(streamId)
    if not self.isRequest then
        self.preset = streamReadFloat32(streamId)
    end
    self:run(connection)
end

local function dmrIsMasterConnection(connection)
    local mission = g_currentMission
    local userManager = mission ~= nil and mission.userManager or nil
    if connection == nil or userManager == nil
        or userManager.getIsConnectionMasterUser == nil then
        return false
    end

    local ok, isMaster = pcall(
        userManager.getIsConnectionMasterUser,
        userManager,
        connection
    )
    return ok and isMaster == true
end

function DeepMudRutsSettingsEvent:run(connection)
    if self.isRequest then
        if g_server ~= nil and connection ~= nil
            and connection.sendEvent ~= nil then
            connection:sendEvent(
                DeepMudRutsSettingsEvent.new(
                    false,
                    DeepMudRuts.preset
                )
            )
        end
        return
    end

    if g_server ~= nil then
        -- A remote settings change is accepted only from the server admin.
        if connection == nil or connection.getIsServer == nil
            or connection:getIsServer()
            or not dmrIsMasterConnection(connection) then
            if connection ~= nil and connection.sendEvent ~= nil then
                connection:sendEvent(
                    DeepMudRutsSettingsEvent.new(
                        false,
                        DeepMudRuts.preset
                    )
                )
            end
            return
        end

        DeepMudRuts:setPreset(self.preset, true)
        g_server:broadcastEvent(
            DeepMudRutsSettingsEvent.new(false, DeepMudRuts.preset),
            false
        )
    else
        -- Clients accept the authoritative setting only from their server.
        if connection ~= nil and connection.getIsServer ~= nil
            and connection:getIsServer() then
            DeepMudRuts:setPreset(self.preset, false)
        end
    end
end

function DeepMudRutsSettingsEvent.sendRequest()
    if g_client ~= nil and g_client.getServerConnection ~= nil then
        g_client:getServerConnection():sendEvent(
            DeepMudRutsSettingsEvent.new(true)
        )
    end
end

function DeepMudRutsSettingsEvent.sendPreset(preset)
    if g_server ~= nil then
        DeepMudRuts:setPreset(preset, true)
        g_server:broadcastEvent(
            DeepMudRutsSettingsEvent.new(false, DeepMudRuts.preset),
            false
        )
    elseif g_client ~= nil and g_client.getServerConnection ~= nil then
        g_client:getServerConnection():sendEvent(
            DeepMudRutsSettingsEvent.new(false, preset)
        )
    end
end

local function dmrConnectionFinishedHook(
    mission,
    connection,
    x,
    y,
    z,
    viewDistanceCoeff
)
    if mission ~= nil and connection ~= nil
        and mission.getIsServer ~= nil
        and mission:getIsServer() then
        connection:sendEvent(
            DeepMudRutsSettingsEvent.new(
                false,
                DeepMudRuts.preset
            )
        )
    end
end

if FSBaseMission ~= nil
    and FSBaseMission.onConnectionFinishedLoading ~= nil
    and Utils ~= nil and Utils.appendedFunction ~= nil
    and _G.__DeepMudRutsJoinSyncHooked ~= true then
    FSBaseMission.onConnectionFinishedLoading = Utils.appendedFunction(
        FSBaseMission.onConnectionFinishedLoading,
        dmrConnectionFinishedHook
    )
    _G.__DeepMudRutsJoinSyncHooked = true
end
