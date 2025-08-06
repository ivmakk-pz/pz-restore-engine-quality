require "TimedActions/ISBaseTimedAction"

local REQ_Requirements = require "REQ_Requirements"
local REQ_ModOptions = require "REQ_ModOptions"

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

---Complete the engine quality restoration action
---@return boolean success
function REQ_ISRestoreEngineQuality:complete()
    local numberOfParts = self.character:getInventory():getNumberOfItem("EngineParts", false, true)
    
    if self.vehicle then
        if not self.part then
            print("[REQ] Error: Engine part not found")
            return false
        end
        
        local currentQuality = self:getEngineQuality(self.part)
        
        -- Maximum quality is always 100%
        local mechanicLevel = self.character:getPerkLevel(Perks.Mechanics)
        local maxQuality = 100
        
        -- Calculate quality improvement per iteration based on skill
        local qualityPerIteration = REQ_ISRestoreEngineQuality.calculateQualityPerIteration(mechanicLevel, self.vehicle:getScript():getEngineRepairLevel())
        
        -- Get configurable engine parts per iteration from mod options
        local partsPerIteration = REQ_ModOptions.getEnginePartsPerIteration()
        
        local usedParts = 0
        local newQuality = currentQuality
        
        -- Use configurable engine parts per restoration iteration
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
        
        if usedParts > 0 and newQuality > currentQuality then
            local baseEnginePower = self.vehicle:getScript():getEngineForce()
            local currentEnginePower = self.vehicle:getEnginePower()

            print("[REQ] Script engine loudness: " .. self.vehicle:getScript():getEngineLoudness())
            print("[REQ] Part vehicle engine loudness: " .. self.part:getVehicle():getEngineLoudness())
            print("[REQ] SandboxVars.ZombieAttractionMultiplier: " .. tostring(SandboxVars.ZombieAttractionMultiplier or 1))
            
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
            print("[REQ] Engine loudness change from " .. engineLoudness .. " to " .. self.vehicle:getEngineLoudness())
            print("[REQ] Engine quality change from " .. currentQuality .. " to " .. self:getEngineQuality(self.part))
            print("[REQ] Engine power change from " .. currentEnginePower .. " to " .. self.vehicle:getEnginePower())

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