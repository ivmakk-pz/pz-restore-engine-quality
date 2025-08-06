-- ===================================================================================================== --
-- ENGINE QUALITY RESTORATION REQUIREMENTS SYSTEM
-- ===================================================================================================== --

local REQ_Requirements = {}
local REQ_RequirementResults = require "REQ_RequirementResults"
local REQ_ModOptions = require "REQ_ModOptions"

-- ===================================================================================================== --
-- REQUIREMENT CHECKING FUNCTIONS
-- ===================================================================================================== --

---Check if mechanic skill requirement is met
---@param character IsoPlayer
---@param part VehiclePart
---@return boolean meetsRequirement
---@return number currentLevel
---@return number requiredLevel
function REQ_Requirements.checkMechanicSkillRequirement(character, part)
    local currentLevel = character:getPerkLevel(Perks.Mechanics)
    local requiredLevel = part:getVehicle():getScript():getEngineRepairLevel()

    return currentLevel >= requiredLevel, currentLevel, requiredLevel
end

---Check if wrench tool in inventory
---@param character IsoPlayer
---@return boolean hasWrench
---@return number count
function REQ_Requirements.checkWrenchRequirement(character)
    local hasWrench = character:getInventory():containsTypeRecurse("Wrench")
    return hasWrench, hasWrench and 1 or 0
end

---Check if enough engine parts are available
---@param character IsoPlayer
---@param requiredCount number?
---@return boolean hasEnoughParts
---@return number currentCount
---@return number requiredCount
function REQ_Requirements.checkEnginePartsRequirement(character, requiredCount)
    requiredCount = requiredCount or REQ_ModOptions.getEnginePartsPerIteration()
    local currentCount = character:getInventory():getNumberOfItem("EngineParts", false, true)
    return currentCount >= requiredCount, currentCount, requiredCount
end

---Check if vehicle key requirement is met
---@param character IsoPlayer
---@param part VehiclePart
---@return boolean hasKey
function REQ_Requirements.checkKeyRequirement(character, part)
    return not VehicleUtils.RequiredKeyNotFound(part, character)
end

---Check if engine quality can be restored (not at 100%)
---@param character IsoPlayer
---@param part VehiclePart
---@return boolean canRestore
---@return number currentQuality
---@return number maxQuality
function REQ_Requirements.checkQualityRestorable(character, part)
    local currentQuality = part:getVehicle():getEngineQuality()
    local maxQuality = 100
    
    return currentQuality < maxQuality, currentQuality, maxQuality
end

-- ===================================================================================================== --
-- REQUIREMENT VALIDATION
-- ===================================================================================================== --

---Check all requirements for engine quality restoration
---@param character IsoPlayer
---@param part VehiclePart
---@return REQ_RequirementResults requirementResults
function REQ_Requirements.validateAllRequirements(character, part)
    local results = {}
    
    -- Check mechanic skill requirement
    local hasSkill, currentSkill, requiredSkill = REQ_Requirements.checkMechanicSkillRequirement(character, part)
    results.mechanicSkill = {
        met = hasSkill,
        current = currentSkill,
        required = requiredSkill,
        name = getText("IGUI_perks_Mechanics")
    }
    
    -- Check wrench requirement  
    local hasWrench, wrenchCount = REQ_Requirements.checkWrenchRequirement(character)
    results.wrench = {
        met = hasWrench,
        current = wrenchCount,
        required = 1,
        name = getItemDisplayName("Base.Wrench")
    }
    
    -- Check engine parts requirement
    local partsPerIteration = REQ_ModOptions.getEnginePartsPerIteration()
    local hasEnoughParts, partsCount, requiredParts = REQ_Requirements.checkEnginePartsRequirement(character, partsPerIteration)
    results.engineParts = {
        met = hasEnoughParts,
        current = partsCount,
        required = requiredParts,
        name = getItemDisplayName("Base.EngineParts")
    }
    
    -- Check key requirement
    local hasKey = REQ_Requirements.checkKeyRequirement(character, part)
    results.vehicleKey = {
        met = hasKey,
        name = getText("Tooltip_vehicle_keyRequired")
    }
    
    -- Check if quality can be restored
    local canRestore, currentQuality, maxQuality = REQ_Requirements.checkQualityRestorable(character, part)
    results.qualityRestorable = {
        met = canRestore,
        current = currentQuality,
        max = maxQuality
    }
    
    -- Return class instance instead of table + boolean
    return REQ_RequirementResults:new(
        results.mechanicSkill,
        results.wrench,
        results.engineParts,
        results.vehicleKey,
        results.qualityRestorable
    )
end

return REQ_Requirements
