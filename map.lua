local astray = require 'lib.astray.astray'

local function generate()
    local mapWidth, mapHeight = 100, 100
    local changeDirectionMod = 10
    local sparsenessMod = 70
    local deadEndRemovalMod = 90
    local numberOfRooms = 5
    local minRoomWidth = 5
    local minRoomHeight = 5
    local maxRoomWidth = 15
    local maxRoomHeight = 15

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

    -- for y = 0, #tiles[1] do
    --     local line = ''
    --     for x = 0, #tiles do
    --         line = line .. tiles[x][y]
    --     end
    --     print(line)
    -- end

    return tiles
end

return {
    generate = generate
}
