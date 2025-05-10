local astray = require 'lib.astray.astray'

local M = {}

function M.generate()
    local mapWidth, mapHeight = 100, 100
    local changeDirectionMod = 5
    local sparsenessMod = 45
    local deadEndRemovalMod = 90
    local numberOfRooms = 8
    local minRoomWidth = 5
    local minRoomHeight = 5
    local maxRoomWidth = 10
    local maxRoomHeight = 10

    local generator = astray.Astray:new(
        mapWidth / 2 - 1,
        mapHeight / 2 - 1,
        changeDirectionMod,
        sparsenessMod,
        deadEndRemovalMod,
        astray.RoomGenerator:new(
            numberOfRooms,
            minRoomWidth,
            maxRoomWidth,
            minRoomHeight,
            maxRoomHeight
        )
    )

    local dungeon = generator:Generate()

    local symbols = {
        Wall = '#',
        Empty = ' ',
        DoorN = ' ',
        DoorS = ' ',
        DoorE = ' ',
        DoorW = ' '
    }

    local tiles = generator:CellToTiles(dungeon, symbols)

    return dungeon, tiles
end

function M.printTiles(tiles)
    for y = 0, #tiles[1] do
        local line = ''
        for x = 0, #tiles do
            line = line .. tiles[x][y]
        end
        print(line)
    end
end

return M
