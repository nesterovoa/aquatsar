local function spawnBoat(playerObj, boatName, sq)
    local boat = addVehicleDebug("Base." .. boatName, IsoDirections.S, 0, sq)
	playerObj:getInventory():AddItem(boat:createVehicleKey())
	boat:repair()
end


local function spawnBoatMenu(player, context, worldobjects, test)
    local waterSquare = nil
    local playerObj = getSpecificPlayer(player)

	for i,v in ipairs(worldobjects) do
		square = v:getSquare();
        if square and square:Is(IsoFlagType.water) then
            waterSquare = square
            break
        end
    end
    
    if waterSquare then
        local boatSpawnMenuOption = context:addOption("DEBUG SpawnBoat", nil, nil)
        local subMenuBoatSpawn = context:getNew(context)
        context:addSubMenu(boatSpawnMenuOption, subMenuBoatSpawn)
        
        for boatName, _ in pairs(AquaConfig.Boats) do
            subMenuBoatSpawn:addOption(boatName, playerObj, spawnBoat, boatName, waterSquare)
        end
    end

end

Events.OnFillWorldObjectContextMenu.Add(spawnBoatMenu);