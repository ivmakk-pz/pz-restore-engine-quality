-- ===================================================================================================== --
-- MOD OPTIONS FOR RESTORE ENGINE QUALITY
-- ===================================================================================================== --

local REQ_Utils = require "REQ_Utils"

local REQ_ModOptions = {
    enginePartsPerIteration = nil,
}

-- ===================================================================================================== --
-- OPTION ACCESS FUNCTIONS
-- ===================================================================================================== --

---Get the number of engine parts required per restoration iteration
---@return number partsPerIteration Between 1-5, default 2
function REQ_ModOptions.getEnginePartsPerIteration()
    return REQ_ModOptions.enginePartsPerIteration and REQ_ModOptions.enginePartsPerIteration:getValue() or 2
end

-- ===================================================================================================== --
-- MOD OPTIONS INITIALIZATION
-- ===================================================================================================== --

---Initialize mod options when the game starts
---@return boolean registered True if the options were registered with PZAPI
function REQ_ModOptions.initialize()
    if not PZAPI or not PZAPI.ModOptions then
        REQ_Utils.logWarning("ModOptions API not available, using default values")
        return false
    end

    -- Create the mod options object
    local options = PZAPI.ModOptions:create("Ivmakk_RestoreEngineQuality", getText("UI_options_REQ_title"))
    
    -- Add engine parts per iteration slider
    REQ_ModOptions.enginePartsPerIteration = options:addSlider(
        "enginePartsPerIteration",
        getText("UI_options_REQ_enginePartsPerIteration"),
        1,    -- minimum value
        5,    -- maximum value
        1,    -- step
        2,    -- default value
        getText("UI_options_REQ_enginePartsPerIteration_tooltip")
    )
    options:addDescription(getText("UI_options_REQ_enginePartsPerIteration_tooltip"))

    return true
end

return REQ_ModOptions
