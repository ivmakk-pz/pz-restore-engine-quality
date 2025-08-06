-- Restore Engine Quality Main Client File
-- Author: ivmakk
-- Version: 1.0.0

local vehicleMechanics = require "REQ_ISVehicleMechanics"
local modOptions = require "REQ_ModOptions"
local REQ_Utils = require "REQ_Utils"

-- Main mod initialization
local RestoreEngineQuality = {}

-- Initialization state tracking
RestoreEngineQuality.isInitialized = false

-- Initialize the mod
function RestoreEngineQuality.init()
    -- Prevent multiple initializations
    if RestoreEngineQuality.isInitialized then
        return
    end
          
    -- Initialize our vehicle mechanics override to ensure compatibility with other mods
    local success, errorMsg = pcall(function()
        modOptions.initialize()
        vehicleMechanics.initialize()
    end)
    
    if not success then
        REQ_Utils.logError(tostring(errorMsg))
    end

    -- Mark as initialized
    RestoreEngineQuality.isInitialized = true
end

-- Hook into game events - only once
Events.OnInitGlobalModData.Add(RestoreEngineQuality.init)
