--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISStartBoatEngineManualy = ISBaseTimedAction:derive("ISStartBoatEngineManualy")

function ISStartBoatEngineManualy:isValid()
	local boat = self.character:getVehicle()
	return boat ~= nil and
--		boat:isEngineWorking() and
		boat:isDriver(self.character) and
		not boat:isEngineRunning() and 
		not boat:isEngineStarted()
end

function ISStartBoatEngineManualy:start()
	--print("ISStartBoatEngineManualy:start()")
	self.soundId = self.character:getEmitter():playSound("TryStartEngineManualy")
end

function ISStartBoatEngineManualy:stop()
	self.character:getEmitter():stopSound(self.soundId)
	ISBaseTimedAction.stop(self)
end

function ISStartBoatEngineManualy:perform()
	local boat = self.character:getVehicle()
	local haveKey = false;
	-- if self.character:getInventory():haveThisKeyId(boat:getKeyId()) then
		-- haveKey = true;
	-- end
	boat:setHotwired(true)
	sendClientCommand(self.character, 'vehicle', 'startEngine', {haveKey=haveKey})
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISStartBoatEngineManualy:new(character)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.maxTime = 9 * 50
	return o
end

