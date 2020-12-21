
-- Удаление звука заноса на воде
function SoundControl()
	local player = getPlayer()
	if player then
		local vehicle = player:getVehicle()
		if vehicle ~= nil and AquaTsarConfig.isBoat(vehicle) then
			local emi = vehicle:getEmitter()
			if emi:isPlaying("VehicleSkid") then
				emi:stopSoundByName("VehicleSkid")
			end
		end
	end
		
end

Events.OnTick.Add(SoundControl)