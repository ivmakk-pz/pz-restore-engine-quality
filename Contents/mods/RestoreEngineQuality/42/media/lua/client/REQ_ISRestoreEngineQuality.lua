require "TimedActions/ISBaseTimedAction"

local REQ_Requirements = require "REQ_Requirements"
local REQ_Utils = require "REQ_Utils"
local REQ_RestorationPlan = require "REQ_RestorationPlan"

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

---Complete the engine quality restoration action
---@return boolean success
function REQ_ISRestoreEngineQuality:complete()
    if self.vehicle then
        if not self.part then
            REQ_Utils.logError("Engine part not found")
            return false
        end
        
        -- Use the new calculation function for consistency
        local restorationDetails = REQ_RestorationPlan.calculateFromGameState(self.character, self.part)
        local currentQuality = restorationDetails.currentQuality
        local newQuality = restorationDetails.newQuality
        local usedParts = restorationDetails.usedParts
        
        if usedParts > 0 and newQuality > currentQuality then
            -- Use pre-calculated loudness feature and engine power from restoration details
            local engineLoudnessAsFeature = restorationDetails.engineLoudnessFeature
            local newEnginePower = restorationDetails.newEnginePower
            local currentEnginePower = restorationDetails.currentEnginePower

            -- Update engine with new quality
            self.vehicle:setEngineFeature(newQuality, engineLoudnessAsFeature, newEnginePower)

            -- Consume required items recursively across all carried containers (avoid overweight pre-move)
            local removed = REQ_Utils.consumeItemsByTypeRecurse(self.character, 'EngineParts', usedParts)
            if removed < usedParts then
                REQ_Utils.logWarning('Not enough EngineParts consumed: ' .. tostring(removed) .. ' / ' .. tostring(usedParts))
            end
            
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