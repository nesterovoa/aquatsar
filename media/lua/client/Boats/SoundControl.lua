
-- Удаление звука заноса на воде
function SoundControl()
	local player = getPlayer()
	if player then
		local boat = player:getVehicle()
		if boat ~= nil and AquaConfig.isBoat(boat) then
			local emi = boat:getEmitter()
			if emi:isPlaying("VehicleSkid") then
				emi:stopSoundByName("VehicleSkid")
			end
			-- if not emi:isPlaying("BoatSailing") then
				-- print("start(BoatSailing")
				-- emi:playSoundLooped("BoatSailing")
			-- end
			if emi:isPlaying("VehicleStarted") then
				-- print("isPlaying(VehicleStarted")
				emi:stopSoundByName("VehicleStarted")
				-- emi:stopSoundByName("BoatSailing")
				emi:playSound("SuccessStartEngineManualy", boat)
			end
			if emi:isPlaying("VehicleFailingToStart") then
				-- print("isPlaying(VehicleStarted")
				emi:stopSoundByName("VehicleFailingToStart")
				-- emi:stopSoundByName("BoatSailing")
				emi:playSound("FailStartEngineManualy", player)
			end
		-- else
			-- local SM = getSoundManager()
			-- if SM:isPlaying("BoatSailing") then
				-- SM:stopSoundByName("BoatSailing")
			-- end
		end
	end
	
	if player:getSprite():getProperties():Is(IsoFlagType.invisible) and player:getSquare() and not player:getSquare():Is(IsoFlagType.water) then
		player:getSprite():getProperties():UnSet(IsoFlagType.invisible)
	end
end

Events.OnTick.Add(SoundControl)