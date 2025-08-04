-- ===================================================================================================== --
-- MOD OPTIONS FOR RESTORE ENGINE QUALITY
-- ===================================================================================================== --

local REQ_ModOptions = {}

-- ===================================================================================================== --
-- OPTION ACCESS FUNCTIONS
-- ===================================================================================================== --

---Get the number of engine parts required per restoration iteration
---@return number partsPerIteration Between 1-5, default 2
function REQ_ModOptions.getEnginePartsPerIteration()
    if not PZAPI or not PZAPI.ModOptions then
        return 2 -- Default fallback if mod options not available
    end
    
    local options = PZAPI.ModOptions:getOptions("Ivmakk_RestoreEngineQuality")
    if not options then
        return 2 -- Default fallback if options not found
    end
    
    local partsOption = options:getOption("enginePartsPerIteration")
    if not partsOption then
        return 2 -- Default fallback if specific option not found
    end
    
    return partsOption:getValue()
end

-- ===================================================================================================== --
-- MOD OPTIONS INITIALIZATION
-- ===================================================================================================== --

---Initialize mod options when the game starts
function REQ_ModOptions.initialize()
    if not PZAPI or not PZAPI.ModOptions then
        print("[REQ] ModOptions API not available, using default values")
        return
    end
    
    -- Create the mod options object
    local options = PZAPI.ModOptions:create("Ivmakk_RestoreEngineQuality", getText("UI_options_REQ_title"))
    
    -- Add engine parts per iteration slider
    local partsSlider = options:addSlider(
        "enginePartsPerIteration",  
        getText("UI_options_REQ_enginePartsPerIteration"),
        1,    -- minimum value
        5,    -- maximum value  
        1,    -- step
        2,    -- default value
        getText("UI_options_REQ_enginePartsPerIteration_tooltip")
    )
end

-- Hook into game initialization
Events.OnGameStart.Add(REQ_ModOptions.initialize)

return REQ_ModOptions
