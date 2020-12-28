
-- Удаление звука заноса на воде
function SoundControl()
	local player = getPlayer()
	if player then
		local vehicle = player:getVehicle()
		if vehicle ~= nil and AquaConfig.isBoat(vehicle) then
			local emi = vehicle:getEmitter()
			if emi:isPlaying("VehicleSkid") then
				emi:stopSoundByName("VehicleSkid")
			end
		end
	end

	if player:getSprite():getProperties():Is(IsoFlagType.invisible) and player:getSquare() and not player:getSquare():Is(IsoFlagType.water) then
		player:getSprite():getProperties():UnSet(IsoFlagType.invisible)
	end
end

Events.OnTick.Add(SoundControl)