-- Restore Engine Quality Main Client File
-- Author: ivmakk
-- Version: 1.0.0

-- Print mod loading message
local vehicleMechanics = require "REQ_ISVehicleMechanics"

-- Main mod initialization
local RestoreEngineQuality = {}

-- Initialization state tracking
RestoreEngineQuality.isInitialized = false

-- Initialize the mod
function RestoreEngineQuality.init()
    -- Prevent multiple initializations
    if RestoreEngineQuality.isInitialized then
        print("[REQ] Already initialized, skipping...")
        return
    end
    
    print("[REQ] Initializing vehicle mechanics menu extension...")
    
    -- Initialize our vehicle mechanics override to ensure compatibility with other mods
    local success, errorMsg = pcall(function()
        vehicleMechanics.initialize()
        print("[REQ] Vehicle mechanics override loaded for mod compatibility")
    end)
    
    if not success then
        print("[REQ] ERROR: Failed to initialize vehicle mechanics override: " .. tostring(errorMsg))
        print("[REQ] Mod will continue without vehicle mechanics override")
    end

    -- Mark as initialized
    RestoreEngineQuality.isInitialized = true
end

-- Hook into game events - only once
Events.OnInitGlobalModData.Add(RestoreEngineQuality.init)
