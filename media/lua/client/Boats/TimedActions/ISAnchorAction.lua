require "TimedActions/ISBaseTimedAction"

ISAnchorAction = ISBaseTimedAction:derive("ISAnchorAction")

function ISAnchorAction:isValid()
	return true
end

function ISAnchorAction:update()
end

function ISAnchorAction:start()
end

function ISAnchorAction:stop()
	ISBaseTimedAction.stop(self)
end

function ISAnchorAction:perform()
    if self.mode then
        self.character:getEmitter():playSound("DropWater")
        self.boat:getModData()["aqua_anchor_on"] = true
    else
        --self.character:getEmitter():playSound("DropWater")
        self.boat:getModData()["aqua_anchor_on"] = false
    end
	ISBaseTimedAction.perform(self)
end

function ISAnchorAction:new(character, boat, mode)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    o.character = character
    if mode then
        o.maxTime = 100
    else
        o.maxTime = 300
    end
    
    o.mode = mode
    o.boat = boat
	
	return o
end




