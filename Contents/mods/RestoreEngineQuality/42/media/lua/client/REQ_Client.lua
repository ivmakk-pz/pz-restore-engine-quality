-- Restore Engine Quality Main Client File
-- Author: ivmakk
-- Version: 1.0.0

-- Print mod loading message
print("[Restore Engine Quality] Loading client-side components...")

-- Main mod initialization
local RestoreEngineQuality = {} -- Replace ModName with your actual mod name

-- Initialize the mod
function RestoreEngineQuality.init()
    print("[Restore Engine Quality] Client initialization complete")
end

-- Hook into game events
Events.OnGameStart.Add(RestoreEngineQuality.init)

return RestoreEngineQuality
