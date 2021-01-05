SoundControl = {}
SoundTable = {}
SoundTable.Wind = {}
SoundTable.Swim = {}
SoundTable.waterConstruction = nil

function SoundControl.switchTheWind(emi, nameOfWind, volume)
	if emi:isPlaying(nameOfWind) then 
		-- AUD.insp("Boat", "SoundTable.Wind[nameOfWind]:", SoundTable.Wind[nameOfWind])
		emi:setVolume(SoundTable.Wind[nameOfWind], volume)
		return 
	end
	for i, j in pairs(SoundTable.Wind) do 
		emi:stopSoundByName(i)
	end
	local songId = emi:playSoundLooped(nameOfWind)
	SoundTable.Wind = {}
	SoundTable.Wind[nameOfWind] = songId
	emi:setVolume(SoundTable.Wind[nameOfWind], volume)
end

function SoundControl.stopWeatherSound(emi)
	emi:stopSoundByName("BoatSailing")
	print("Stop BoatSailing")
	-- emi:stopSoundByName("BoatSailingByWind")
	for i, j in pairs(SoundTable.Wind) do 
		emi:stopSoundByName(i)
	end
	SoundTable.Wind = {}
end

function SoundControl.isWater(paramIsoObject)
	if not instanceof(paramIsoObject, "IsoObject") then return false end
	local tileName = paramIsoObject:getTile()
	if not tileName then
		return false
	elseif string.match(string.lower(tileName), "blends_natural_02") then
		return true
	else
		return false
	end
end

function SoundControl.checkWaterBuild(paramIsoObject)
	-- print(paramIsoObject)
	if SoundControl.isWater(paramIsoObject) then
		local floorTile = paramIsoObject:getTile()
		local sq = paramIsoObject:getSquare()
		if not SoundTable.waterConstruction then SoundTable.waterConstruction  = {} end
		SoundTable.waterConstruction[sq] = floorTile
	end
end

function SoundControl.main()
	local player = getPlayer()
	if SoundTable.waterConstruction then 
		print("SoundTable.waterConstruction")
		for sq, floorTile in pairs(SoundTable.waterConstruction) do 
			if not floorTile then return end
			local old_tile = sq:getFloor():getTile()
			sq:addFloor(floorTile)
			sq:RecalcProperties()
			if string.match(old_tile, "carpentry_02") then
				sq:AddWorldInventoryItem("Base.Plank", ZombRandFloat(0,0.9), ZombRandFloat(0,0.9), 0)
			end
			getSoundManager():PlaySound("ThrowInWater", true, 0.0)
			player:Say(getText("IGUI_PlayerText_PontoonNeeded"))
		end
		SoundTable.waterConstruction = nil
	end
	
	if player then
		local boat = player:getVehicle()
		if boat ~= nil and AquaConfig.isBoat(boat) then
			local boatSpeed = boat:getCurrentSpeedKmHour()
			local emi = boat:getEmitter()
			if emi:isPlaying("VehicleSkid") then -- Удаление звука заноса на воде
				emi:stopSoundByName("VehicleSkid")
			end
			if emi:isPlaying("BoatSailing") then 
				local windSpeed = getClimateManager():getWindspeedKph()
				--AUD.insp("Wind", "windSpeed:", windSpeed/1.60934)
				local volume = 0
				if windSpeed < AquaConfig.windLight then
					AUD.insp("Wind", "windControlSpeed:", "WindLight")
					volume = windSpeed/AquaConfig.windLight
					SoundControl.switchTheWind(emi, "WindLight", volume)
				elseif windSpeed < AquaConfig.windMedium then
					AUD.insp("Wind", "windControlSpeed:", "WindMedium")
					volume = windSpeed/AquaConfig.windMedium
					SoundControl.switchTheWind(emi, "WindMedium", volume)
				elseif windSpeed < AquaConfig.windStrong then
					AUD.insp("Wind", "windControlSpeed:", "WindStrong")
					volume = (windSpeed - 20 * 1.60934)/(AquaConfig.windStrong - 20 * 1.60934)
					SoundControl.switchTheWind(emi, "WindStrong", volume)
				elseif windSpeed < AquaConfig.windVeryStrong then
					AUD.insp("Wind", "windControlSpeed:", "WindVeryStrong")
					volume = (windSpeed - 18 * 1.60934)/(AquaConfig.windVeryStrong - 18 * 1.60934)
					SoundControl.switchTheWind(emi, "WindVeryStrong", volume)
				else
					SoundControl.switchTheWind(emi, "WindVeryStrong", 1)
				end
				AUD.insp("Wind", "volume:", volume)
			end

			if AquaConfig.Boat(boat).manualStarter then
				if emi:isPlaying("VehicleStarted") then
					emi:stopSoundByName("VehicleStarted")
					emi:playSound("SuccessStartEngineManualy", boat)
				end
				if emi:isPlaying("VehicleFailingToStart") then
					emi:stopSoundByName("VehicleFailingToStart")
					emi:playSound("FailStartEngineManualy", player)
				end
			end
		end
	
		local emiPl = player:getEmitter()
		
		if boat and emiPl:isPlaying("Swim") then
			emiPl:stopSoundByName("Swim")
		end

		if not player:getVehicle() and player:getSquare() then
			if player:getSquare():Is(IsoFlagType.water) then
				if not player:getSprite():getProperties():Is(IsoFlagType.invisible) then
					getSoundManager():PlaySound("Dive", true, 0.0)
					player:getSprite():getProperties():Set(IsoFlagType.invisible)
				end
				if not emiPl:isPlaying("Swim") then
					player:playSound("Swim")
				end
			else
				if player:getSprite():getProperties():Is(IsoFlagType.invisible) then
					getSoundManager():PlaySound("LeaveWater", true, 0.0)
					player:getSprite():getProperties():UnSet(IsoFlagType.invisible)
				end
				if emiPl:isPlaying("Swim") then
					emiPl:stopSoundByName("Swim")
				end
			end
		end
	end
end

Events.OnTileRemoved.Add(SoundControl.checkWaterBuild)
Events.OnTick.Add(SoundControl.main)