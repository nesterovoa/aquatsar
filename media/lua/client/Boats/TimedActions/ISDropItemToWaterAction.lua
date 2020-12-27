require "TimedActions/ISBaseTimedAction"

ISDropItemToWaterAction = ISBaseTimedAction:derive("ISDropItemToWaterAction")

function ISDropItemToWaterAction:isValid()
	return true
end

function ISDropItemToWaterAction:update()
end

function ISDropItemToWaterAction:start()
	self:setActionAnim("Loot")
	getSoundManager():PlayWorldSoundWav("dropWater4", self.character:getSquare(), 0, 10, 1, true);
end

function ISDropItemToWaterAction:stop()
	ISBaseTimedAction.stop(self)
end

function ISDropItemToWaterAction:perform()
	if self.item:getContainer() ~= nil then
		self.item:getContainer():Remove(self.item)
	end
	
	ISBaseTimedAction.perform(self)
end

function ISDropItemToWaterAction:new(character, item)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.item = item
	o.maxTime = 100
	
	return o
end



