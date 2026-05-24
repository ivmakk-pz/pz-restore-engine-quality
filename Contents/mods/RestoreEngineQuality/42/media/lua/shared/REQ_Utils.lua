-- ===================================================================================================== --
-- UTILITY FUNCTIONS AND CONSTANTS FOR RESTORE ENGINE QUALITY
-- ===================================================================================================== --

-- DEBUG MODE TOGGLE: Set to false for production safety mode
local DEBUG_MODE = false

-- Log level constants
local LOG_LEVELS = {
    INFO = "INFO",
    WARN = "WARN", 
    ERROR = "ERROR",
    DEBUG = "DEBUG"
}

local REQ_Utils = {}

-- ===================================================================================================== --
-- COLOR CONSTANTS
-- ===================================================================================================== --

-- Tooltip colors used throughout the mod
REQ_Utils.Colors = {
    -- Standard requirement colors (matches vanilla game)
    POSITIIVE = "<GHC>",  -- Green - ISVehicleMechanics.ghs equivalent  
    NEGATIVE = "<BHC>",   -- Red - ISVehicleMechanics.bhs equivalent
    NEUTRAL = "<RGB:1,1,1>", -- Pure white for emphasis
}

-- ===================================================================================================== --
-- COLOR UTILITY FUNCTIONS
-- ===================================================================================================== --

---Get color for requirement status (met/unmet)
---@param isMet boolean
---@return string color Color code for tooltip
function REQ_Utils.getRequirementColor(isMet)
    return isMet and REQ_Utils.Colors.POSITIIVE or REQ_Utils.Colors.NEGATIVE
end

-- ===================================================================================================== --
-- LOGGING UTILITIES
-- ===================================================================================================== --

---Core logging function with level
---@param message string
---@param level string
local function logMessage(message, level)
    if not DEBUG_MODE and level == LOG_LEVELS.DEBUG then
        return
    end
    
    local prefix = string.format("[REQ] %s", level)
    print(prefix .. " " .. tostring(message))
end

---Log info message
---@param message string
function REQ_Utils.logInfo(message)
    logMessage(message, LOG_LEVELS.INFO)
end

---Log warning message
---@param message string
function REQ_Utils.logWarning(message)
    logMessage(message, LOG_LEVELS.WARN)
end

---Log error message
---@param message string
function REQ_Utils.logError(message)
    logMessage(message, LOG_LEVELS.ERROR)
end

---Log debug message (only shows when DEBUG_MODE is true)
---@param message string
function REQ_Utils.logDebug(message)
    logMessage(message, LOG_LEVELS.DEBUG)
end

return REQ_Utils
