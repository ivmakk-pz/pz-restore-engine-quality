-- Restore Engine Quality Main Client File
-- Author: ivmakk
-- Version: 1.1.0

local vehicleMechanics = require "REQ_ISVehicleMechanics"
local modOptions = require "REQ_ModOptions"
local REQ_Utils = require "REQ_Utils"

-- Main mod initialization
local RestoreEngineQuality = {}

-- Initialization state tracking
RestoreEngineQuality.isInitialized = false
RestoreEngineQuality.optionsInitialized = false

-- Register mod options at game boot so they are in PZAPI.ModOptions.Dict at the
-- title screen. Registering later (e.g. on OnInitGlobalModData, which fires only
-- in-world) leaves the option unregistered at the main menu, so a title-screen
-- save of any options mod parks our line newline-less and the vanilla save() bug
-- fuses it into the previous line, resetting the slider to default on next load.
function RestoreEngineQuality.initModOptions()
    -- OnGameBoot can fire from several sites; register only once to avoid a
    -- duplicate options panel and a reset to defaults (create() does not dedup).
    if RestoreEngineQuality.optionsInitialized then
        return
    end

    local success, registered = pcall(function()
        return modOptions.initialize()
    end)

    if not success then
        REQ_Utils.logError(tostring(registered))
        return
    end

    -- Latch the guard only once options are actually registered, so a failed or
    -- skipped attempt (e.g. PZAPI not ready) can retry on a later boot.
    RestoreEngineQuality.optionsInitialized = registered == true
end

-- Initialize the mod
function RestoreEngineQuality.init()
    -- Prevent multiple initializations
    if RestoreEngineQuality.isInitialized then
        return
    end

    -- Initialize our vehicle mechanics override to ensure compatibility with other mods
    local success, errorMsg = pcall(function()
        vehicleMechanics.initialize()
    end)

    if not success then
        REQ_Utils.logError(tostring(errorMsg))
    end

    -- Mark as initialized
    RestoreEngineQuality.isInitialized = true
end

-- Hook into game events - only once
Events.OnGameBoot.Add(RestoreEngineQuality.initModOptions)
Events.OnInitGlobalModData.Add(RestoreEngineQuality.init)
