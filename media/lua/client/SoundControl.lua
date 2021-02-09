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

function SoundControl.isWater(square)
	if square then
		return square:getProperties():Is(IsoFlagType.water)
	else
		return false
	end
end

function SoundControl.main()
	local player = getPlayer()
	
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
				AUD.insp("Wind", "windSpeed (MPH):", windSpeed/1.60934)
				local volume = 0
				if windSpeed < AquaConfig.windVeryLight then
					AUD.insp("Wind", "windControlSpeed:", "windVeryLight")
					volume = 1
					SoundControl.switchTheWind(emi, "WindLight", volume)
				elseif windSpeed < AquaConfig.windLight then
					AUD.insp("Wind", "windControlSpeed:", "windLight")
					volume = windSpeed/AquaConfig.windLight
					SoundControl.switchTheWind(emi, "WindLight", volume)
				elseif windSpeed < AquaConfig.windMedium then
					AUD.insp("Wind", "windControlSpeed:", "windMedium")
					volume = windSpeed/AquaConfig.windMedium
					SoundControl.switchTheWind(emi, "WindMedium", volume)
				elseif windSpeed < AquaConfig.windStrong then
					AUD.insp("Wind", "windControlSpeed:", "windStrong")
					volume = (windSpeed - 20 * 1.60934)/(AquaConfig.windStrong - 20 * 1.60934)
					SoundControl.switchTheWind(emi, "WindStrong", volume)
				elseif windSpeed < AquaConfig.windVeryStrong then
					AUD.insp("Wind", "windControlSpeed:", "windVeryStrong")
					volume = (windSpeed - 18 * 1.60934)/(AquaConfig.windVeryStrong - 18 * 1.60934)
					SoundControl.switchTheWind(emi, "WindVeryStrong", volume)
				else
					AUD.insp("Wind", "windControlSpeed:", "windStorm")
					volume = (windSpeed - 18 * 1.60934)/(AquaConfig.windVeryStrong - 18 * 1.60934)
					SoundControl.switchTheWind(emi, "WindStorm", 1)
				end
				AUD.insp("Wind", "volume:", volume)
			end

			if boat:getPartById("ManualStarter") then
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
		
		if boat then
			if emiPl:isPlaying("Swim") then
				emiPl:stopSoundByName("Swim")
				getSoundManager():PlaySound("LeaveWater", true, 0.0)
				player:getSprite():getProperties():UnSet(IsoFlagType.invisible)
			end
		elseif player:getSquare() then			
			if player:getSquare():Is(IsoFlagType.water) then
				player:getBodyDamage():setWetness(100)
				if not player:getSprite():getProperties():Is(IsoFlagType.invisible) then
					emiPl:playSound("Dive")
					player:getSprite():getProperties():Set(IsoFlagType.invisible)
					player:setNoClip(true)
				else
					local moveDir = player:getPlayerMoveDir()
					local x = player:getX() + moveDir:getX()
					local y = player:getY() + moveDir:getY()
					local sq = player:getSquare()
					local sqDir = getCell():getGridSquare(player:getX() + moveDir:getX(), 
														  player:getY() + moveDir:getY(), 
														  player:getZ())
					if sq:DistTo(sqDir) >= 1 then
						if sq:isWallTo(sqDir) or sq:isWindowTo(sqDir) then
							player:setNoClip(false)
						elseif not player:isNoClip() then
							-- moveDir:normalize()
							
							moveDir:rotate(3.14)
							local rearSqr = getCell():getGridSquare(player:getX() + moveDir:getX()*2, 
													  player:getY() + moveDir:getY()*2, 
													  player:getZ())

							moveDir = player:getForwardDirection()
							moveDir:rotate(1.57)
							local sideSqr1 = getCell():getGridSquare(player:getX() + moveDir:getY(), 
														  player:getY() + moveDir:getX(), 
														  player:getZ())
							moveDir:rotate(3.14)							  
							local sideSqr2 = getCell():getGridSquare(player:getX() + moveDir:getX(), 
														  player:getY() + moveDir:getY(), 
														  player:getZ())
							
							if sqDir:Is(IsoFlagType.water) and 
									not sq:isWallTo(sideSqr1) and 
									not sq:isWindowTo(sideSqr1) and 
									not sq:isWallTo(sideSqr2) and
									not sq:isWindowTo(sideSqr2) and
									sq:isWallTo(rearSqr) then
								player:setNoClip(true)
								print("NOCLIP")
								-- print("sq ", sq:getX(), " ", sq:getY())
								-- print("sqDir ", sqDir:getX(), " ", sqDir:getY())
								-- print("sideSqr1 ", sideSqr1:getX(), " ", sideSqr1:getY())
								-- print(sq:isWallTo(sideSqr1))
								-- print(sq:isWindowTo(sideSqr1))
								-- print("sideSqr2 ", sideSqr2:getX(), " ", sideSqr2:getY())
								-- print(sq:isWallTo(sideSqr2))
								-- print(sq:isWindowTo(sideSqr2))
								
							end
						end
					end
				end
				
				if not emiPl:isPlaying("Swim") and not player:isDead() then
					player:playSound("Swim")
				end
			else
				if player:getSprite():getProperties():Is(IsoFlagType.invisible) then
					emiPl:playSound("LeaveWater")
					player:getSprite():getProperties():UnSet(IsoFlagType.invisible)
					-- player:setMoveSpeed(1)
					player:setNoClip(false)
				end
				if emiPl:isPlaying("Swim") then
					emiPl:stopSoundByName("Swim")
				end
			end
		end
	end
end

local function onPlayerDeathStopSwimSound()
	getPlayer():getEmitter():stopSoundByName("Swim")
end


Events.OnTick.Add(SoundControl.main)
Events.OnPlayerDeath.Add(onPlayerDeathStopSwimSound)