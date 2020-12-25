require("Boats/Init")
AquatsarYachts.Swim = {}



function AquatsarYachts.Swim.chanceSuccess(playerObj, square)
    local x = playerObj:getX() - square:getX()
    local y = playerObj:getY() - square:getY()    
    local dist = math.sqrt(x*x + y*y)

    if dist < 10 then
        return 90
    else
        return 50
    end
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

    local NminDist = 50
    local SminDist = 50
    local EminDist = 50
    local WminDist = 50

    for i=1, 50 do
        for j = -i, i do
            local sq = cell:getGridSquare(x+i, y+j, 0)
            
            if not WaterBorders.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < WminDist then 
                    WminDist = dist
                    squares["WEST"] = sq
                end
            end
        end 
    end

    for i=1, 50 do
        for j = -i, i do
            local sq = cell:getGridSquare(x-i, y+j, 0)
            
            if not WaterBorders.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < EminDist then 
                    EminDist = dist
                    squares["EAST"] = sq
                end
            end
        end 
    end

    for i=1, 50 do
        for j = -i, i do
            local sq = cell:getGridSquare(x+j, y+i, 0)
            
            if not WaterBorders.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < SminDist then 
                    SminDist = dist
                    squares["SOUTH"] = sq
                end
            end
        end 
    end

    for i=1, 50 do
        for j = -i, i do
            local sq = cell:getGridSquare(x+j, y-i, 0)
            
            if not WaterBorders.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < NminDist then 
                    NminDist = dist
                    squares["NORTH"] = sq
                end
            end
        end 
    end

    return squares
end