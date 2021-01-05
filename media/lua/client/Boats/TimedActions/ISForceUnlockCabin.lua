--***********************************************************
--**                      AQUATSAR       	               **
--***********************************************************

require 'Boats/Init'
require "TimedActions/ISBaseTimedAction"

ISForceUnlockCabin = ISBaseTimedAction:derive("ISForceUnlockCabin")

function ISForceUnlockCabin:isValid()
	return self.character:getVehicle() ~= nil
end

function ISForceUnlockCabin:update()
	-- speed 1 = 1, 2 = 5, 3 = 20, 4 = 40
    local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    if uispeed ~= 1 and self.isFirstSail  then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1)
    end
    local speedCoeff = { [1] = 1, [2] = 5, [3] = 20, [4] = 40 }

	local timeLeftNow =  (1 - self:getJobDelta()) * self.maxTime

	if self.isFadeOut == false and timeLeftNow < 300 * speedCoeff[uispeed] then
		UIManager.FadeOut(self.playerNum, 1)
        self.isFadeOut = true
	end
end

function ISForceUnlockCabin:start()
    
end

function ISForceUnlockCabin:stop()
    if self.isFadeOut == true then
		UIManager.FadeIn(self.playerNum, 1)
		UIManager.setFadeBeforeUI(self.playerNum, false)
	end
	ISBaseTimedAction.stop(self)
end

function ISForceUnlockCabin:perform()
    if ZombRand(100) < 35 then
        self.boat:getModData()["AquaCabin_isUnlocked"] = true
        self.boat:getModData()["AquaCabin_isLockRuined"] = true
        self.character:getEmitter():playSound("UnlockDoor")				    
    else
        getSoundManager():PlayWorldSoundWav("PZ_MetalSnap", self.character:getCurrentSquare(), 1, 10, 2, true)
    end

    self.character:getStats():setEndurance(self.character:getStats():getEndurance() - 0.7)
    self.character:getStats():setBoredom(self.character:getStats():getBoredom() + 40)
    self.character:getBodyDamage():setUnhappynessLevel(self.character:getBodyDamage():getUnhappynessLevel() + 30)

	UIManager.FadeIn(self.playerNum, 1)
	UIManager.setFadeBeforeUI(self.playerNum, false)

	ISBaseTimedAction.perform(self)
end

function ISForceUnlockCabin:new(character, boat)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    o.character = character
    o.playerNum = character:getPlayerNum()
    o.isFadeOut = false
	o.maxTime = 4000
    o.boat = boat

	return o
end

