require "TimedActions/ISBaseTimedAction"

local REQ_Requirements = require "REQ_Requirements"
local REQ_Utils = require "REQ_Utils"
local REQ_Inventory = require "REQ_Inventory"
local REQ_RestorationPlan = require "REQ_RestorationPlan"

---@class REQ_ISRestoreEngineQuality : ISBaseTimedAction
---@field vehicle BaseVehicle
---@field part VehiclePart
---@field item InventoryItem
---@field jobType string
local REQ_ISRestoreEngineQuality = ISBaseTimedAction:derive("ISRestoreEngineQuality")

-- Expose as a global matching the derive() type name so multiplayer can reconstruct
-- the networked timed action. The receiving side resolves the class by type string
-- via LuaManager.get("ISRestoreEngineQuality") + getFunctionObject("ISRestoreEngineQuality.new");
-- both look up _G, so a local-only/require module would fail and the action never completes.
ISRestoreEngineQuality = REQ_ISRestoreEngineQuality


function REQ_ISRestoreEngineQuality:isValid()
    return true
end

-- One-time gate, run once as the queue reaches this action (not per tick like isValid).
-- Guards a stale queued action whose requirements lapsed after it was queued (e.g. a
-- second restore whose parts were consumed by the first). Client-side queue logic only;
-- server-side network reconstruction never calls it.
function REQ_ISRestoreEngineQuality:isValidStart()
    return REQ_Requirements.validateAllRequirements(self.character, self.part):areAllRequirementsMet()
end

function REQ_ISRestoreEngineQuality:getDuration()
    if self.part == nil or self.item == nil then
        return 0
    end
    if self.character:isTimedActionInstant() then
        return 1
    end
    return self.maxTime
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

            -- Update engine with new quality
            self.vehicle:setEngineFeature(newQuality, engineLoudnessAsFeature, newEnginePower)

            -- Consume required items recursively across all carried containers (avoid overweight pre-move)
            local removed = REQ_Inventory.consumeItemsByTypeRecurse(self.character, 'EngineParts', usedParts)
            if removed < usedParts then
                REQ_Utils.logWarning('Not enough EngineParts consumed: ' .. tostring(removed) .. ' / ' .. tostring(usedParts))
            end
            
            -- Grant XP (more than regular repair)
            addXp(self.character, Perks.Mechanics, usedParts * 3)
            
            -- Transmit changes to other players
            self.vehicle:transmitEngine()
            
            self.character:sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, { success = true })
        end
    end
    
    return true
end

---Create new engine quality restoration action
---@param character IsoPlayer
---@param part VehiclePart? nil-tolerant: server-side MP reconstruction may pass nil
---@param item InventoryItem? nil-tolerant: server-side MP reconstruction may pass nil
---@param maxTime number?
---@return any
function REQ_ISRestoreEngineQuality:new(character, part, item, maxTime)
    local o = ISBaseTimedAction.new(self, character)
    ---@diagnostic disable-next-line: inject-field
    o.part = part
    if part ~= nil then
        ---@diagnostic disable-next-line: inject-field
        o.vehicle = part:getVehicle()
    end
    ---@diagnostic disable-next-line: inject-field
    o.item = item
    o.maxTime = maxTime or 400  -- Longer than regular repair
    ---@diagnostic disable-next-line: inject-field
    o.jobType = "Restore Engine Quality"
    return o
end

return REQ_ISRestoreEngineQuality