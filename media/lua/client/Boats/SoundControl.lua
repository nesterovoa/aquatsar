SoundControl = {}
local SoundTable = {}
SoundTable.Wind = {}
SoundTable.Swim = {}

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
	for i, j in pairs(SoundTable.Wind) do 
		emi:stopSoundByName(i)
	end
	SoundTable.Wind = {}
end

function SoundControl.main()
	local player = getPlayer()
	if player then
		local boat = player:getVehicle()
		if boat ~= nil and AquaConfig.isBoat(boat) then
			local emi = boat:getEmitter()
			if emi:isPlaying("VehicleSkid") then -- Удаление звука заноса на воде
				emi:stopSoundByName("VehicleSkid")
			end
			if emi:isPlaying("BoatSailing") then
				local windSpeed = getClimateManager():getWindspeedKph()
				-- AUD.insp("Boat", "windSpeed:", windSpeed/1.60934)
				local volume = 0
				if windSpeed < AquaConfig.windLight then
					-- AUD.insp("Boat", "windControlSpeed:", "WindLight")
					volume = windSpeed/AquaConfig.windLight
					SoundControl.switchTheWind(emi, "WindLight", volume)
				elseif windSpeed < AquaConfig.windMedium then
					-- AUD.insp("Boat", "windControlSpeed:", "WindMedium")
					volume = windSpeed/AquaConfig.windMedium
					SoundControl.switchTheWind(emi, "WindMedium", volume)
				elseif windSpeed < AquaConfig.windStrong then
					-- AUD.insp("Boat", "windControlSpeed:", "WindStrong")
					volume = (windSpeed - 20 * 1.60934)/(AquaConfig.windStrong - 20 * 1.60934)
					SoundControl.switchTheWind(emi, "WindStrong", volume)
				elseif windSpeed < AquaConfig.windVeryStrong then
					-- AUD.insp("Boat", "windControlSpeed:", "WindVeryStrong")
					volume = (windSpeed - 18 * 1.60934)/(AquaConfig.windVeryStrong - 18 * 1.60934)
					SoundControl.switchTheWind(emi, "WindVeryStrong", volume)
				else
					SoundControl.switchTheWind(emi, "WindVeryStrong", 1)
				end
				-- AUD.insp("Boat", "volume:", volume)
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
	end
	
	local emiPl = player:getEmitter()
	
	if player:getVehicle() and emiPl:isPlaying("Swim") then
		emiPl:stopSoundByName("Swim")
	end

	if player:getSquare() and not player:getVehicle() then
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

Events.OnTick.Add(SoundControl.main)