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

	if self.isFadeOut == false and timeLeftNow < 115 * speedCoeff[uispeed] then
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
	local newTrailerName = AquaTsarConfig.getTrailerNameAfterLaunchBoat(self.vehicle)
	local boatName = AquaTsarConfig.getBoatNameAfterLaunchBoat(self.vehicle)
	
	local boat = addVehicleDebug("Base."..boatName, IsoDirections.N, 0, self.square)
	boat:setAngles(self.vehicle:getAngleX(), self.vehicle:getAngleY(), self.vehicle:getAngleZ())

	local partData = self.vehicle:getModData()["boatParts"]
	if partData ~= nil then
		for i=1, boat:getPartCount() do
			local part = boat:getPartByIndex(i)
			if part ~= nil then 
				local tmp = partData[part:getId()]

				if tmp == nil then
					part:setInventoryItem(nil)
				else
					part:setCondition(tmp)
				end
			end
		end
	end

	local data = self.vehicle:getModData()
	local gastank = boat:getPartById("GasTank")
	if gastank and data["boatPart_GasTank"] then
		gastank:setContainerContentAmount(data["boatPart_GasTank"]) 
	end

	local battery = boat:getPartById("Battery")
	if battery and battery:getInventoryItem() and data["boatPart_Battery"] then
		battery:getInventoryItem():setUsedDelta(data["boatPart_Battery"])
	end

	self.vehicle:setScriptName(newTrailerName)
	self.vehicle:scriptReloaded()

	for i=1, boat:getPartCount() do
		local part = boat:getPartByIndex(i-1)	
		if part:isContainer() and part:getItemContainer() ~= nil then
			local itemContainer = part:getItemContainer()
			itemContainer:getItems():clear()
		end
	end


	-- Delete key
	local xx = boat:getX()
	local yy = boat:getY()

	for z=0, 3 do
		for i=xx - 15, xx + 15 do
			for j=yy - 15, yy + 15 do
				local tmpSq = getCell():getGridSquare(i, j, z)
				if tmpSq ~= nil then
					for k=0, tmpSq:getObjects():size()-1 do
						local ttt =	tmpSq:getObjects():get(k)
						if ttt:getContainer() ~= nil then
							local items = ttt:getContainer():getItems()
							for ii=0, items:size()-1 do
								if items:get(ii):getKeyId() == boat:getKeyId() then
									items:remove(ii)
								end
							end
						elseif instanceof(ttt, "IsoWorldInventoryObject") then
							if ttt:getItem() and ttt:getItem():getContainer() then
								local items = ttt:getItem():getContainer():getItems()
								for ii=0, items:size()-1 do
									if items:get(ii):getKeyId() == boat:getKeyId() then
										items:remove(ii)
									end
								end
							end
							
							if ttt:getItem() and ttt:getItem():getKeyId() == boat:getKeyId() then
								tmpSq:removeWorldObject(ttt)
							end
						end
					end
				end
			end
		end
	end


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
    o.maxTime = 100; -- TODO исправить на 1000
    
	if character:isTimedActionInstant() then o.maxTime = 10 end
	return o
end

