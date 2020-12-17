--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISStartBoatEngineManualy = ISBaseTimedAction:derive("ISStartBoatEngineManualy")

function ISStartBoatEngineManualy:isValid()
	local vehicle = self.character:getVehicle()
	return vehicle ~= nil and
--		vehicle:isEngineWorking() and
		vehicle:isDriver(self.character) and
		not vehicle:isEngineRunning() and 
		not vehicle:isEngineStarted()
end

function ISStartBoatEngineManualy:start()
	print("ISStartBoatEngineManualy:start()")
	self.character:getEmitter():playSound("StartEngineManualy")
end

function ISStartBoatEngineManualy:stop()
	ISBaseTimedAction.stop(self)
end

function ISStartBoatEngineManualy:perform()
	local vehicle = self.character:getVehicle()
	local haveKey = false;
	if self.character:getInventory():haveThisKeyId(vehicle:getKeyId()) then
		haveKey = true;
	end
	sendClientCommand(self.character, 'vehicle', 'startEngine', {haveKey=haveKey})

	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISStartBoatEngineManualy:new(character)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.maxTime = 550
	return o
end

