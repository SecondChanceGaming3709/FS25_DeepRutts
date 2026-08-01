DeepMudRutsSettings = {}
DeepMudRutsSettings.cachedFrame = nil
DeepMudRutsSettings.control = nil
DeepMudRutsSettings.presetTexts = {
    g_i18n:getText("dmr_presetStandard"),
    g_i18n:getText("dmr_presetLow"),
    g_i18n:getText("dmr_presetMedium"),
    g_i18n:getText("dmr_presetHigh")
}

function DeepMudRutsSettings:onFrameOpen()
    if self.dmrSettingsDone then
        DeepMudRutsSettings.cachedFrame = self
        DeepMudRutsSettings:updateSetting()
        DeepMudRutsSettings:updatePermission()
        return
    end

    DeepMudRutsSettings.cachedFrame = self
    DeepMudRutsSettings:addTitle(self)
    DeepMudRutsSettings.control =
        DeepMudRutsSettings:addMultiTextOption(
            self,
            "onRutDepthChanged",
            DeepMudRutsSettings.presetTexts,
            g_i18n:getText("dmr_settingRutDepth"),
            g_i18n:getText("dmr_settingRutDepthDescription")
        )

    self.gameSettingsLayout:invalidateLayout()
    self:updateAlternatingElements(self.gameSettingsLayout)
    self:updateGeneralSettings(self.gameSettingsLayout)
    self.dmrSettingsDone = true

    DeepMudRutsSettings:updateSetting()
    DeepMudRutsSettings:updatePermission()

    if g_server == nil then
        DeepMudRutsSettingsEvent.sendRequest()
    end
end

function DeepMudRutsSettings:addTitle(settingsFrame)
    local textElement = TextElement.new()
    textElement.name = "sectionHeader"
    textElement:loadProfile(
        g_gui:getProfile("fs25_settingsSectionHeader"),
        true
    )
    textElement:setText(g_i18n:getText("dmr_settingsTitle"))
    settingsFrame.gameSettingsLayout:addElement(textElement)
    textElement:onGuiSetupFinished()
    textElement.focusId = FocusManager:serveAutoFocusId()
end

function DeepMudRutsSettings:addMultiTextOption(
    settingsFrame,
    callbackName,
    texts,
    title,
    tooltip
)
    local container = BitmapElement.new()
    container:loadProfile(
        g_gui:getProfile("fs25_multiTextOptionContainer"),
        true
    )
    container.focusId = FocusManager:serveAutoFocusId()

    local option = MultiTextOptionElement.new()
    option:loadProfile(
        g_gui:getProfile("fs25_settingsMultiTextOption"),
        true
    )
    option.target = DeepMudRutsSettings
    option:setCallback("onClickCallback", callbackName)
    option:setTexts(texts)
    option.focusId = FocusManager:serveAutoFocusId()

    local optionTitle = TextElement.new()
    optionTitle:loadProfile(
        g_gui:getProfile("fs25_settingsMultiTextOptionTitle"),
        true
    )
    optionTitle:setText(title)
    optionTitle.focusId = FocusManager:serveAutoFocusId()

    local optionTooltip = TextElement.new()
    optionTooltip.name = "ignore"
    optionTooltip:loadProfile(
        g_gui:getProfile("fs25_multiTextOptionTooltip"),
        true
    )
    optionTooltip:setText(tooltip)
    optionTooltip.focusId = FocusManager:serveAutoFocusId()

    option:addElement(optionTooltip)
    container:addElement(option)
    container:addElement(optionTitle)

    FocusManager:loadElementFromCustomValues(
        container,
        nil,
        nil,
        false,
        false
    )
    FocusManager:loadElementFromCustomValues(
        option,
        nil,
        nil,
        false,
        false
    )
    FocusManager:loadElementFromCustomValues(
        optionTitle,
        nil,
        nil,
        false,
        false
    )

    option:onGuiSetupFinished()
    optionTitle:onGuiSetupFinished()
    optionTooltip:onGuiSetupFinished()
    settingsFrame.gameSettingsLayout:addElement(container)
    container:onGuiSetupFinished()

    return option
end

function DeepMudRutsSettings:updateSetting()
    if self.control ~= nil and DeepMudRuts ~= nil then
        self.control:setState(DeepMudRuts.preset)
    end
end

function DeepMudRutsSettings:updatePermission()
    if self.control == nil or self.control.setDisabled == nil then
        return
    end

    local mission = g_currentMission
    local canEdit = g_server ~= nil
        or (mission ~= nil and mission.isMasterUser == true)
    self.control:setDisabled(not canEdit)
end

function DeepMudRutsSettings:onRutDepthChanged(state)
    if DeepMudRutsSettingsEvent ~= nil then
        -- Apply locally for immediate feedback; the server then confirms and
        -- synchronizes the canonical state in multiplayer.
        if g_server == nil then
            DeepMudRuts:setPreset(state, false)
        end
        DeepMudRutsSettingsEvent.sendPreset(state)
    end

    local frame = DeepMudRutsSettings.cachedFrame
    if frame ~= nil and frame.playSample ~= nil then
        frame:playSample(GuiSoundPlayer.SOUND_SAMPLES.CLICK)
    end
end

InGameMenuSettingsFrame.onFrameOpen = Utils.appendedFunction(
    InGameMenuSettingsFrame.onFrameOpen,
    DeepMudRutsSettings.onFrameOpen
)
