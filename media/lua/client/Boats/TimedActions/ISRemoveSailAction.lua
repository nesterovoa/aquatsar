--***********************************************************
--**                      AQUATSAR       	               **
--***********************************************************

require 'Boats/Init'
require "TimedActions/ISBaseTimedAction"

ISRemoveSailAction = ISBaseTimedAction:derive("ISRemoveSailAction")

function ISRemoveSailAction:isValid()
	return self.character:getVehicle() ~= nil
end

function ISRemoveSailAction:update()
	-- speed 1 = 1, 2 = 5, 3 = 20, 4 = 40
    local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    local speedCoeff = { [1] = 1, [2] = 5, [3] = 20, [4] = 40 }

	local timeLeftNow =  (1 - self:getJobDelta()) * self.maxTime

	if self.isFadeOut == false and timeLeftNow < 300 * speedCoeff[uispeed] then
		UIManager.FadeOut(self.character:getPlayerNum(), 1)
        self.isFadeOut = true
	end
end

function ISRemoveSailAction:start()

end

function ISRemoveSailAction:stop()
    if self.isFadeOut == true then
		UIManager.FadeIn(self.character:getPlayerNum(), 1)
		UIManager.setFadeBeforeUI(self.character:getPlayerNum(), false)
	end

	ISBaseTimedAction.stop(self)
end

function ISRemoveSailAction:perform()
	local nameOfBoat = AquaBoats[self.boat:getScript():getName()].removeSailsScript
	ISBoatMenu.replaceBoat(self.boat, nameOfBoat)

    local playerNum = self.character:getPlayerNum()
	UIManager.FadeIn(playerNum, 1)
	UIManager.setFadeBeforeUI(playerNum, false)

	ISBaseTimedAction.perform(self)
end

function ISRemoveSailAction:new(character, boat)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    o.character = character
    
    o.isFadeOut = false
	o.maxTime = 400
    o.boat = boat

	return o
end

