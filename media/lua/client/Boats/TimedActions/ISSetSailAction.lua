--***********************************************************
--**                      AQUATSAR       	               **
--***********************************************************

require 'Boats/Init'
require "TimedActions/ISBaseTimedAction"

ISSetSailAction = ISBaseTimedAction:derive("ISSetSailAction")

function ISSetSailAction:isValid()
	return self.character:getVehicle() ~= nil
end

function ISSetSailAction:update()
	-- speed 1 = 1, 2 = 5, 3 = 20, 4 = 40
    local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    if uispeed ~= 1 and self.isFirstSail  then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1)
    end
    local speedCoeff = { [1] = 1, [2] = 5, [3] = 20, [4] = 40 }

	local timeLeftNow =  (1 - self:getJobDelta()) * self.maxTime

	if self.isFadeOut == false and timeLeftNow < 300 * speedCoeff[uispeed] then
		UIManager.FadeOut(self.character:getPlayerNum(), 1)
        self.isFadeOut = true
	end
end

function ISSetSailAction:start()
    if not AquaConfig.Boat(self.boat).sails and	self.character:getModData()["isFirstSail"] == nil then
        self.character:getModData()["isFirstSail"] = false
        getSoundManager():StopMusic()
        self.sound = getSoundManager():playMusic("TrumanSetsSail");
        self.isFirstSail = true
    end
end

function ISSetSailAction:stop()
    if self.sound then
        getSoundManager():StopSound(self.sound)
    end
    
    if self.isFadeOut == true then
		UIManager.FadeIn(self.character:getPlayerNum(), 1)
		UIManager.setFadeBeforeUI(self.character:getPlayerNum(), false)
	end

	ISBaseTimedAction.stop(self)
end

function ISSetSailAction:perform()
    if self.dir == "LEFT" then
        local nameWithSails = AquaConfig.Boat(self.boat).setLeftSailsScript
        if nameWithSails then
            ISBoatMenu.replaceBoat(self.boat, nameWithSails)
        else
            print("AQUATSAR: script for SetLeftSails (" .. self.boat:getScript():getName() .. ") didn't find.")
        end    
    elseif self.dir == "RIGHT" then
        local nameWithSails = AquaConfig.Boat(self.boat).setRightSailsScript
        if nameWithSails then
            ISBoatMenu.replaceBoat(self.boat, nameWithSails)
        else
            print("AQUATSAR: script for SetRightSails (" .. self.boat:getScript():getName() .. ") didn't find.")
        end
    end

    local playerNum = self.character:getPlayerNum()
	UIManager.FadeIn(playerNum, 1)
	UIManager.setFadeBeforeUI(playerNum, false)

	ISBaseTimedAction.perform(self)
end

function ISSetSailAction:new(character, boat, dir)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    o.character = character
    
    o.isFadeOut = false
	o.maxTime = 400
    o.boat = boat
    o.dir = dir

	return o
end

