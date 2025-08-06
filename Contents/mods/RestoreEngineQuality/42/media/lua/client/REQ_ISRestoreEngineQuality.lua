require "TimedActions/ISBaseTimedAction"

local REQ_Requirements = require "REQ_Requirements"
local REQ_ModOptions = require "REQ_ModOptions"
local REQ_Utils = require "REQ_Utils"

---@class REQ_ISRestoreEngineQuality : ISBaseTimedAction
---@field vehicle BaseVehicle
---@field part VehiclePart
---@field item InventoryItem
---@field jobType string
local REQ_ISRestoreEngineQuality = ISBaseTimedAction:derive("ISRestoreEngineQuality")


function REQ_ISRestoreEngineQuality:isValid()
    local requirementResults = REQ_Requirements.validateAllRequirements(self.character, self.part)
    return requirementResults:areAllRequirementsMet()
end

function REQ_ISRestoreEngineQuality:waitToStart()
	self.character:faceThisObject(self.vehicle)
	return self.character:shouldBeTurning()
end

function REQ_ISRestoreEngineQuality:update()
	self.character:faceThisObject(self.vehicle)
	self.item:setJobDelta(self:getJobDelta())

	self.character:setMetabolicTarget(Metabolics.MediumWork);
end

function REQ_ISRestoreEngineQuality:start()
	self.item:setJobType(getText("IGUI_RepairEngine"))
	self:setActionAnim("VehicleWorkOnMid")
end

function REQ_ISRestoreEngineQuality:stop()
	self.item:setJobDelta(0)
	ISBaseTimedAction.stop(self)
end

function REQ_ISRestoreEngineQuality:perform()
	self.item:setJobDelta(0)
	ISBaseTimedAction.perform(self)
end

function REQ_ISRestoreEngineQuality:getEngineQuality(part)
    if part:getId() == "Engine" and part:getVehicle() then
        return part:getVehicle():getEngineQuality()
    end
    return 100
end

---Static helper function to calculate quality improvement per iteration
---@param mechanicLevel number
---@param engineRepairLevel number
---@return number qualityPerIteration
function REQ_ISRestoreEngineQuality.calculateQualityPerIteration(mechanicLevel, engineRepairLevel)
    local skill = mechanicLevel - engineRepairLevel
    local qualityPerIteration = 1 + (skill / 2)
    if qualityPerIteration > 5 then qualityPerIteration = 5 end
    return qualityPerIteration
end

---Calculate loudness feature value to preserve original loudness after Java conversion
---Java does: (int)(loudness / 2.7F), so we need to find input that results in desired output
---@param targetLoudness number The desired final loudness value
---@return number featureValue The loudness feature value to pass to setEngineFeature()
function REQ_ISRestoreEngineQuality.calculateLoudnessFeature(targetLoudness)
    local margin = math.min(1.0, math.max(0.1, targetLoudness * 0.0001))
    return (targetLoudness * 2.7) + margin
end

---Calculate new engine power based on quality using the same logic as vanilla engine creation
---@param vehicle BaseVehicle
---@param newQuality number
---@return number newEnginePower
function REQ_ISRestoreEngineQuality.calculateNewEnginePower(vehicle, newQuality)
    local baseEnginePower = vehicle:getScript():getEngineForce()
    local currentEnginePower = vehicle:getEnginePower()
    
    -- Use same calculation as vanilla engine creation (from Vehicles.lua)
    local qualityBoosted = newQuality * 1.6
    if qualityBoosted > 100 then qualityBoosted = 100 end
    local qualityModifier = math.max(0.6, (qualityBoosted / 100))
    local newEnginePower = math.max(currentEnginePower, baseEnginePower * qualityModifier)
    
    return newEnginePower
end

---Calculate quality improvement details for restoration preview
---@param character IsoPlayer
---@param part VehiclePart
---@return table restorationDetails
function REQ_ISRestoreEngineQuality.calculateRestorationDetails(character, part)
    local numberOfParts = character:getInventory():getNumberOfItem("EngineParts", false, true)
    local currentQuality = part:getVehicle():getEngineQuality()
    local mechanicLevel = character:getPerkLevel(Perks.Mechanics)
    local maxQuality = 100
    
    -- Calculate quality improvement per iteration based on skill
    local qualityPerIteration = REQ_ISRestoreEngineQuality.calculateQualityPerIteration(mechanicLevel, part:getVehicle():getScript():getEngineRepairLevel())
    
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
    
    return {
        currentQuality = math.floor(currentQuality),
        newQuality = math.floor(newQuality),
        qualityIncrease = math.floor(newQuality - currentQuality),
        usedParts = usedParts,
        availableParts = numberOfParts,
        qualityPerIteration = qualityPerIteration,
        partsPerIteration = partsPerIteration,
        -- Engine power calculations
        currentEnginePower = math.floor(part:getVehicle():getEnginePower()),
        newEnginePower = math.floor(REQ_ISRestoreEngineQuality.calculateNewEnginePower(part:getVehicle(), math.floor(newQuality))),
    }
end

---Complete the engine quality restoration action
---@return boolean success
function REQ_ISRestoreEngineQuality:complete()
    local numberOfParts = self.character:getInventory():getNumberOfItem("EngineParts", false, true)
    
    if self.vehicle then
        if not self.part then
            REQ_Utils.logError("Engine part not found")
            return false
        end
        
        -- Use the new calculation function for consistency
        local restorationDetails = REQ_ISRestoreEngineQuality.calculateRestorationDetails(self.character, self.part)
        local currentQuality = restorationDetails.currentQuality
        local newQuality = restorationDetails.newQuality
        local usedParts = restorationDetails.usedParts
        
        if usedParts > 0 and newQuality > currentQuality then
            local baseEnginePower = self.vehicle:getScript():getEngineForce()
            local currentEnginePower = self.vehicle:getEnginePower()

            REQ_Utils.logDebug("Script engine loudness: " .. self.vehicle:getScript():getEngineLoudness())
            REQ_Utils.logDebug("Part vehicle engine loudness: " .. self.part:getVehicle():getEngineLoudness())
            REQ_Utils.logDebug("SandboxVars.ZombieAttractionMultiplier: " .. tostring(SandboxVars.ZombieAttractionMultiplier or 1))
            
            -- Calculate feature value to preserve original loudness after Java conversion
            local engineLoudness = self.vehicle:getEngineLoudness() -- self.part:getVehicle():getEngineLoudness()
            local engineLoudnessAsFeature = REQ_ISRestoreEngineQuality.calculateLoudnessFeature(engineLoudness)
         
            -- Calculate new engine power based on quality
            local qualityBoosted = newQuality * 1.6
            if qualityBoosted > 100 then qualityBoosted = 100 end
            local qualityModifier = math.max(0.6, (qualityBoosted / 100))
            local newEnginePower = math.max(currentEnginePower, baseEnginePower * qualityModifier)

            -- Update engine with new quality
            self.vehicle:setEngineFeature(newQuality, engineLoudnessAsFeature, newEnginePower)
            REQ_Utils.logDebug("Engine loudness change from " .. engineLoudness .. " to " .. self.vehicle:getEngineLoudness())
            REQ_Utils.logDebug("Engine quality change from " .. currentQuality .. " to " .. self:getEngineQuality(self.part))
            REQ_Utils.logDebug("Engine power change from " .. currentEnginePower .. " to " .. self.vehicle:getEnginePower())

            -- Remove used engine parts
            local items = self.character:getInventory():RemoveAll('EngineParts', tonumber(usedParts))
            sendRemoveItemsFromContainer(self.character:getInventory(), items)
            
            -- Grant XP (more than regular repair)
            addXp(self.character, Perks.Mechanics, usedParts * 3)
            
            -- Transmit changes to other players
            self.vehicle:transmitEngine()
            
            self.character:sendObjectChange('mechanicActionDone', { success = true })
        end
    end
    
    return true
end

---Create new engine quality restoration action
---@param character IsoPlayer
---@param part VehiclePart
---@param item InventoryItem
---@param maxTime number?
---@return any
function REQ_ISRestoreEngineQuality:new(character, part, item, maxTime)
    local o = ISBaseTimedAction.new(self, character)
    ---@diagnostic disable-next-line: inject-field
    o.vehicle = part:getVehicle()
    ---@diagnostic disable-next-line: inject-field
    o.part = part
    ---@diagnostic disable-next-line: inject-field
    o.item = item
    o.maxTime = maxTime or 400  -- Longer than regular repair
    ---@diagnostic disable-next-line: inject-field
    o.jobType = "Restore Engine Quality"
    return o
end

return REQ_ISRestoreEngineQuality