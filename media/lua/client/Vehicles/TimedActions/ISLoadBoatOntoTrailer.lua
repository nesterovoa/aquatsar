--**************************************************************
--**                    Developer: Aiteron                    **
--**************************************************************

require "TimedActions/ISBaseTimedAction"

ISLoadBoatOntoTrailer = ISBaseTimedAction:derive("ISLoadBoatOntoTrailer")


function ISLoadBoatOntoTrailer:isValid()
	return self.vehicle and not self.vehicle:isRemovedFromWorld();
end

function ISLoadBoatOntoTrailer:update()
	self.character:faceThisObject(self.vehicle)

	-- speed 1 = 1, 2 = 5, 3 = 20, 4 = 40
	local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
	local speedCoeff = { [1] = 1, [2] = 5, [3] = 20, [4] = 40 }

	local timeLeftNow =  (1 - self:getJobDelta()) * self.maxTime

	if self.isFadeOut == false and timeLeftNow < 115 * speedCoeff[uispeed] then
		UIManager.FadeOut(self.character:getPlayerNum(), 1)
		self.isFadeOut = true
	end

    self.character:setMetabolicTarget(Metabolics.HeavyWork);
end

function ISLoadBoatOntoTrailer:start()
	self:setActionAnim("Loot")
end

function ISLoadBoatOntoTrailer:stop()
	if self.isFadeOut == true then
		UIManager.FadeIn(self.character:getPlayerNum(), 1)
		UIManager.setFadeBeforeUI(self.character:getPlayerNum(), false)
	end

	ISBaseTimedAction.stop(self)
end

function ISLoadBoatOntoTrailer:perform()
    local trailerName = AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable[self.vehicle:getScript():getName()][self.boat:getScript():getName()]				
	self.vehicle:setScriptName(trailerName)
	self.vehicle:scriptReloaded()

	local data = self.vehicle:getModData()
	data["boatParts"] = {}
	for i=1, self.boat:getPartCount() do
		local part = self.boat:getPartByIndex(i-1)	

		if part:getInventoryItem() or not part:getTable("install") then
			data["boatParts"][part:getId()] = part:getCondition()
		end		
	end

	local gastank = self.boat:getPartById("GasTank")
	if gastank then
		data["boatPart_GasTank"] = gastank:getContainerContentAmount()
	end

	local battery = self.boat:getPartById("Battery")
	if battery and battery:getInventoryItem() then
		data["boatPart_Battery"] = battery:getInventoryItem():getUsedDelta()
	end

	self.boat:removeFromWorld()

	local playerNum = self.character:getPlayerNum()
	UIManager.FadeIn(playerNum, 1)
	UIManager.setFadeBeforeUI(playerNum, false)

	ISBaseTimedAction.perform(self)
end


function ISLoadBoatOntoTrailer:new(character, vehicle, boat)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
    o.vehicle = vehicle
    o.boat = boat

	o.isFadeOut = false
    o.maxTime = 100;  -- TODO исправить на 1000
    
	if character:isTimedActionInstant() then o.maxTime = 10 end
	return o
end

