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

---Calculate maximum restorable quality (always 100%)
---@param mechanicLevel number
---@return number maxQuality
function REQ_ISRestoreEngineQuality:getMaxQuality(mechanicLevel)
    return 100  -- Always allow restoration to 100%
end

---Static helper function to calculate maximum restorable quality (always 100%)
---@param mechanicLevel number
---@return number maxQuality
function REQ_ISRestoreEngineQuality.calculateMaxQuality(mechanicLevel)
    return 100  -- Always allow restoration to 100%
end

---Static helper function to calculate quality improvement per iteration
---@param mechanicLevel number
---@param engineRepairLevel number
---@return number qualityPerIteration
function REQ_ISRestoreEngineQuality.calculateQualityPerIteration(mechanicLevel, engineRepairLevel)
    local skill = mechanicLevel - engineRepairLevel
    local qualityPerIteration = 3 + (skill / 2)
    if qualityPerIteration > 10 then qualityPerIteration = 10 end
    return qualityPerIteration
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
        
        local done = 0
        local newQuality = currentQuality
        
        -- Use configurable engine parts per restoration iteration
        for i=1,numberOfParts,partsPerIteration do
            if numberOfParts - (i - 1) >= partsPerIteration then
                newQuality = newQuality + qualityPerIteration
                done = done + partsPerIteration
                
                if newQuality >= maxQuality then
                    newQuality = maxQuality
                    break
                end
            end
        end
        
        if done > 0 and newQuality > currentQuality then
           local baseEnginePower = self.vehicle:getScript():getEngineForce()
            local currentEnginePower = self.vehicle:getEnginePower()
            -- Multiply by 2.7 to compensate for Java setEngineFeature() dividing by 2.7F (see BaseVehicle#setEngineFeature() in BaseVehicle.java)
            -- This keeps the engine loudness constant after repair
            local engineLoudness = self.part:getVehicle():getEngineLoudness() * 2.7
         
            -- Calculate new engine power based on quality
            local qualityBoosted = newQuality * 1.6
            if qualityBoosted > 100 then qualityBoosted = 100 end
            local qualityModifier = math.max(0.6, (qualityBoosted / 100))
            local newEnginePower = math.max(currentEnginePower, baseEnginePower * qualityModifier)
            
            -- Update engine with new quality
            self.vehicle:setEngineFeature(newQuality, engineLoudness, newEnginePower)
            
            -- Remove used engine parts
            local items = self.character:getInventory():RemoveAll('EngineParts', tonumber(done))
            sendRemoveItemsFromContainer(self.character:getInventory(), items)
            
            -- Grant XP (more than regular repair)
            addXp(self.character, Perks.Mechanics, done * 3)
            
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