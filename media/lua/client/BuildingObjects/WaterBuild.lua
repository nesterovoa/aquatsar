local waterConstruction

local function checkWaterBuild(paramIsoObject)
	-- print(paramIsoObject)
	-- print("checkWaterBuild ")
	if SoundControl.isWater(paramIsoObject) then
		local floorTile = paramIsoObject:getTile()
		local sq = paramIsoObject:getSquare()
		if not waterConstruction then waterConstruction  = {} end
		waterConstruction[sq] = floorTile
	end
end

Events.OnTileRemoved.Add(checkWaterBuild)

local function waterBuildOnTick()
    if waterConstruction then 
		print("waterConstruction")
		for sq, floorTile in pairs(waterConstruction) do 
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
		waterConstruction = nil
	end

end


Events.OnTick.Add(waterBuildOnTick)