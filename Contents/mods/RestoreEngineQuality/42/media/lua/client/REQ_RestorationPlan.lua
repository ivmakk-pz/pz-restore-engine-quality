-- Forward declarations for dependencies
local REQ_ModOptions = require "REQ_ModOptions"

---@class REQ_RestorationPlan
---@field currentQuality number Current engine quality (floored)
---@field newQuality number Projected new engine quality after restoration (floored)
---@field qualityIncrease number Total quality increase (floored)
---@field usedParts number Number of engine parts that will be consumed
---@field availableParts number Number of engine parts available in inventory
---@field qualityPerIteration number Quality improvement per restoration iteration
---@field partsPerIteration number Parts consumed per restoration iteration
---@field currentEnginePower number Current engine power (floored)
---@field newEnginePower number Projected new engine power after restoration (floored)
---@field engineLoudnessFeature number Calculated loudness feature value for setEngineFeature()
local REQ_RestorationPlan = {}

---Calculate quality improvement per iteration based on skill
---@param mechanicLevel number
---@param engineRepairLevel number
---@return number qualityPerIteration
function REQ_RestorationPlan.calculateQualityPerIteration(mechanicLevel, engineRepairLevel)
    local skill = mechanicLevel - engineRepairLevel
    local qualityPerIteration = 1 + (skill / 2)
    if qualityPerIteration > 5 then qualityPerIteration = 5 end
    return qualityPerIteration
end

---Calculate new engine power based on quality using vanilla engine creation logic
---@param vehicle BaseVehicle
---@param newQuality number
---@return number newEnginePower
function REQ_RestorationPlan.calculateNewEnginePower(vehicle, newQuality)
    local baseEnginePower = vehicle:getScript():getEngineForce()
    local currentEnginePower = vehicle:getEnginePower()
    
    -- Use same calculation as vanilla engine creation (from Vehicles.lua)
    local qualityBoosted = newQuality * 1.6
    if qualityBoosted > 100 then qualityBoosted = 100 end
    local qualityModifier = math.max(0.6, (qualityBoosted / 100))
    local newEnginePower = math.max(currentEnginePower, baseEnginePower * qualityModifier)
    
    return newEnginePower
end

---Calculate loudness feature value to preserve original loudness after Java conversion
---Java does: (int)(loudness / 2.7F), so we need to find input that results in desired output
---@param targetLoudness number The desired final loudness value
---@return number featureValue The loudness feature value to pass to setEngineFeature()
function REQ_RestorationPlan.calculateLoudnessFeature(targetLoudness)
    return (targetLoudness + 0.9) * 2.7
end

---Create new restoration details instance
---@param currentQuality number
---@param newQuality number
---@param qualityIncrease number
---@param usedParts number
---@param availableParts number
---@param qualityPerIteration number
---@param partsPerIteration number
---@param currentEnginePower number
---@param newEnginePower number
---@param engineLoudnessFeature number
---@return REQ_RestorationPlan
function REQ_RestorationPlan:new(currentQuality, newQuality, qualityIncrease, usedParts, availableParts, qualityPerIteration, partsPerIteration, currentEnginePower, newEnginePower, engineLoudnessFeature)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    o.currentQuality = currentQuality
    o.newQuality = newQuality
    o.qualityIncrease = qualityIncrease
    o.usedParts = usedParts
    o.availableParts = availableParts
    o.qualityPerIteration = qualityPerIteration
    o.partsPerIteration = partsPerIteration
    o.currentEnginePower = currentEnginePower
    o.newEnginePower = newEnginePower
    o.engineLoudnessFeature = engineLoudnessFeature
    
    return o
end

---Calculate restoration details from current game state
---@param character IsoPlayer
---@param part VehiclePart
---@return REQ_RestorationPlan
function REQ_RestorationPlan.calculateFromGameState(character, part)
    local numberOfParts = character:getInventory():getNumberOfItem("EngineParts", false, true)
    local currentQuality = part:getVehicle():getEngineQuality()
    local mechanicLevel = character:getPerkLevel(Perks.Mechanics)
    local maxQuality = 100
    
    -- Calculate quality improvement per iteration based on skill
    local qualityPerIteration = REQ_RestorationPlan.calculateQualityPerIteration(mechanicLevel, part:getVehicle():getScript():getEngineRepairLevel())
    
    -- Get configurable engine parts per iteration from mod options
    local partsPerIteration = REQ_ModOptions.getEnginePartsPerIteration()
    
    local usedParts = 0
    local newQuality = currentQuality
    
    -- Simulate the restoration process to calculate final quality
    for i=1,numberOfParts,partsPerIteration do
        if numberOfParts - (i - 1) >= partsPerIteration then
            newQuality = newQuality + qualityPerIteration
            usedParts = usedParts + partsPerIteration
            
            if newQuality >= maxQuality then
                newQuality = maxQuality
                break
            end
        end
    end
    
    return REQ_RestorationPlan:new(
        math.floor(currentQuality),
        math.floor(newQuality),
        math.floor(newQuality - currentQuality),
        usedParts,
        numberOfParts,
        qualityPerIteration,
        partsPerIteration,
        math.floor(part:getVehicle():getEnginePower()),
        math.floor(REQ_RestorationPlan.calculateNewEnginePower(part:getVehicle(), math.floor(newQuality))),
        REQ_RestorationPlan.calculateLoudnessFeature(part:getVehicle():getEngineLoudness())
    )
end

return REQ_RestorationPlan
