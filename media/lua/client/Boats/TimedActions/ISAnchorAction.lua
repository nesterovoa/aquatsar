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
    if self.drop then
		if self.mode == "anchor" then
			self.character:getEmitter():playSound("AnchorInWater")
		elseif self.mode == "rope" then
			self.character:getEmitter():playSound("BindRoap")
		end
        self.boat:getModData()["aqua_anchor_on"] = true
    else
		if self.mode == "anchor" then
			self.character:getEmitter():playSound("AnchorFromWater")
		elseif self.mode == "rope" then
			self.character:getEmitter():playSound("BindRoap")
		end
        --self.character:getEmitter():playSound("DropWater")
        self.boat:getModData()["aqua_anchor_on"] = false
    end
	ISBaseTimedAction.perform(self)
end

function ISAnchorAction:new(character, boat, drop, mode)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    o.character = character
    if drop then
        o.maxTime = 100
    else
        o.maxTime = 300
    end
    
    o.drop = drop
    o.boat = boat
	o.mode = mode
	
	return o
end




