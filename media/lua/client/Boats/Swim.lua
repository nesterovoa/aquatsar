require("Boats/Init")
AquatsarYachts.Swim = {}



function AquatsarYachts.Swim.chanceSuccess(playerObj, direction)
    return 33
end

function AquatsarYachts.Swim.swimToLand(playerObj, chance)
    print("swim")    
end


----

function AquatsarYachts.Swim.getPlayerEquipWeight(playerObj)
    return round(playerObj:getInventory():getCapacityWeight(), 2)
end

function AquatsarYachts.Swim.getSwimSquares(x, y)
    local squares = {}
    local cell = getCell()

    local NminDist = 9999999
    local SminDist = 9999999
    local EminDist = 9999999
    local WminDist = 9999999

    for i=-50, 50 do
        for j=-50, 50 do
            local sq = cell:getGridSquare(x+i, y+j, 0)

            if not WaterBorders.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if i < 0 and dist < WminDist then 
                    WminDist = dist
                    squares["WEST"] = sq
                end

                if i > 0 and dist < EminDist then 
                    EminDist = dist
                    --squares["EAST"] = sq
                end

                if j < 0 and dist < NminDist then 
                    NminDist = dist
                    --squares["NORTH"] = sq
                end

                if j > 0 and dist < SminDist then 
                    SminDist = dist
                    squares["SOUTH"] = sq
                end
            end
        end
    end

    return squares
end