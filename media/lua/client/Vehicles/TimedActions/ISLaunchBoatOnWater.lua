--**************************************************************
--**                    Developer: Aiteron                    **
--**************************************************************

require "TimedActions/ISBaseTimedAction"

ISLaunchBoatOnWater = ISBaseTimedAction:derive("ISLaunchBoatOnWater")


function ISLaunchBoatOnWater:isValid()
	return self.vehicle and not self.vehicle:isRemovedFromWorld();
end

function ISLaunchBoatOnWater:update()
	self.character:faceThisObject(self.vehicle)

	-- speed 1 = 1, 2 = 5, 3 = 20, 4 = 40
	local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
	local speedCoeff = { [1] = 1, [2] = 5, [3] = 20, [4] = 40 }

	local timeLeftNow =  (1 - self:getJobDelta()) * self.maxTime

	if self.isFadeOut == false and timeLeftNow < 100 * speedCoeff[uispeed] then
		UIManager.FadeOut(self.character:getPlayerNum(), 1)
		self.isFadeOut = true
	end

    self.character:setMetabolicTarget(Metabolics.HeavyWork);
end

function ISLaunchBoatOnWater:start()
	self:setActionAnim("Loot")
end

function ISLaunchBoatOnWater:stop()
	if self.isFadeOut == true then
		UIManager.FadeIn(self.character:getPlayerNum(), 1)
		UIManager.setFadeBeforeUI(self.character:getPlayerNum(), false)
	end

	ISBaseTimedAction.stop(self)
end

function ISLaunchBoatOnWater:perform()
    local newTrailerName = AquaTsarConfig.trailerAfterBoatLaunchTable[self.vehicle:getScript():getName()]
	local boatName = AquaTsarConfig.boatAfterBoatLaunchFromTrailerTable[self.vehicle:getScript():getName()]
	self.vehicle:setScriptName(newTrailerName)
	self.vehicle:scriptReloaded()
	
	local boat = addVehicleDebug("Base."..boatName, IsoDirections.N, 0, self.square)
	boat:setAngles(self.vehicle:getAngleX(), self.vehicle:getAngleY(), self.vehicle:getAngleZ())

	local playerNum = self.character:getPlayerNum()
	UIManager.FadeIn(playerNum, 1)
	UIManager.setFadeBeforeUI(playerNum, false)

	ISBaseTimedAction.perform(self)
end


function ISLaunchBoatOnWater:new(character, vehicle, sq)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
    o.vehicle = vehicle
    o.square = sq

	o.isFadeOut = false
    o.maxTime = 1000;
    
	if character:isTimedActionInstant() then o.maxTime = 10 end
	return o
end

