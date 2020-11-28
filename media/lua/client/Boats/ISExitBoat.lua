--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require 'Boats/Init'
require "TimedActions/ISBaseTimedAction"

ISExitBoat = ISBaseTimedAction:derive("ISExitBoat")

function ISExitBoat:isValid()
	return self.character:getVehicle() ~= nil
end

function ISExitBoat:update()
	local vehicle = self.character:getVehicle()
	local seat = vehicle:getSeat(self.character)
	vehicle:playPassengerAnim(seat, "exit")
	if self.character:GetVariable("ExitAnimationFinished") == "true" then
		self.character:ClearVariable("ExitAnimationFinished")
		self.character:ClearVariable("bExitingVehicle")
		self:forceComplete()
	end
end

function ISExitBoat:start()
	self.action:setBlockMovementEtc(true) -- ignore 'E' while exiting
	local vehicle = self.character:getVehicle()
	local seat = vehicle:getSeat(self.character)
--	if vehicle:isDriver(self.character) and vehicle:isEngineRunning() then
--		if isClient() then
--			sendClientCommand(self.character, 'vehicle', 'shutOff', {})
--		else
--			vehicle:shutOff()
--		end
--	end
	self.character:SetVariable("bExitingVehicle", "true")
	vehicle:playPassengerSound(seat, "exit")
end

function ISExitBoat:stop()
	self.character:clearVariable("bExitingVehicle")
	self.character:clearVariable("ExitAnimationFinished")
	local vehicle = self.character:getVehicle()
	local seat = vehicle:getSeat(self.character)
	vehicle:playPassengerAnim(seat, "idle")
	ISBaseTimedAction.stop(self)
end

function ISExitBoat:perform()
	local vehicle = self.character:getVehicle()
	local seat = vehicle:getSeat(self.character)
--	if vehicle:isDriver(self.character) and vehicle:isEngineRunning() then
--		if isClient() then
--			sendClientCommand(self.character, 'vehicle', 'shutOff', {})
--		else
--			vehicle:shutOff()
--		end
--	end
	vehicle:exit(self.character)
	vehicle:setCharacterPosition(self.character, seat, "outside")
	self.character:PlayAnim("Idle")
	triggerEvent("OnExitVehicle", self.character)
    vehicle:updateHasExtendOffsetForExitEnd(self.character)
	vehicle:getAttachmentWorldPos("exitLeft", AquatsarYachts.exitLeftVector)
	vehicle:getAttachmentWorldPos("exitRight", AquatsarYachts.exitRightVector)
	vehicle:getAttachmentWorldPos("exitRear", AquatsarYachts.exitRearVector)
	
	self.character:setX(AquatsarYachts.exitLeftVector:x())
	self.character:setY(AquatsarYachts.exitLeftVector:y())
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISExitBoat:new(character)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.maxTime = -1
	return o
end

