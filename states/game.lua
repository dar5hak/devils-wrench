local love = require('love')
local Camera = require('lib.hump.camera')
local bump = require('lib.bump.bump')

local map = require('map')
local Player = require('entities.player')

local game = {}

function game:init()
    self.sprites = {
        tile = love.graphics.newImage('assets/tile.png'),
        wall = love.graphics.newImage('assets/wall.png'),
    }

    self.tiles = map.generate()

    self.world = bump.newWorld()

    local emptyTiles = {}
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[y] do
            local tile = self.tiles[y][x]
            if tile == ' ' then
                table.insert(emptyTiles, { x = x, y = y })
            elseif tile == '#' then
                local tileWidth, tileHeight = self.sprites.tile:getDimensions()
                self.world:add({ type = 'wall' }, (x - 1) * tileWidth, (y - 1) * tileHeight, tileWidth, tileHeight)
            end
        end
    end

    local randomTile = emptyTiles[love.math.random(#emptyTiles)]
    local tileWidth, tileHeight = self.sprites.tile:getDimensions()
    self.player = Player((randomTile.x - 1) * tileWidth, (randomTile.y - 1) * tileHeight, 32, 32)
    self.world:add(self.player, self.player.x, self.player.y, self.player.width, self.player.height)

    self.enemies = {}
    self.items = {}

    self.camera = Camera(self.player.x, self.player.y)
end

function game:enter(previous)
    -- Logic to run when entering the game state
end

function game:update(dt)
    local goalX, goalY = self.player.x, self.player.y

    if love.keyboard.isDown('up') then
        goalY = goalY - self.player.speed * dt
    elseif love.keyboard.isDown('down') then
        goalY = goalY + self.player.speed * dt
    elseif love.keyboard.isDown('left') then
        goalX = goalX - self.player.speed * dt
    elseif love.keyboard.isDown('right') then
        goalX = goalX + self.player.speed * dt
    end

    local actualX, actualY, cols = self.world:move(self.player, goalX, goalY, function(item, other)
        if other.type == 'wall' then
            return 'slide'
        end
        return nil
    end)

    -- Allow a margin of error while turning
    for _, col in ipairs(cols) do
        if col.other.type == 'wall' then
            if math.abs(col.touch.x - goalX) <= 6 then
                actualX = col.touch.x
            elseif math.abs(col.touch.y - goalY) <= 6 then
                actualY = col.touch.y
            end
        end
    end

    -- Snap player to grid for smoother movement
    local tileWidth, tileHeight = self.sprites.tile:getDimensions()
    if love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        actualX = math.floor((actualX + tileWidth / 2) / tileWidth) * tileWidth
    elseif love.keyboard.isDown('left') or love.keyboard.isDown('right') then
        actualY = math.floor((actualY + tileHeight / 2) / tileHeight) * tileHeight
    end

    self.player.x, self.player.y = actualX, actualY

    self.camera:lookAt(self.player.x, self.player.y)
end

function game:draw()
    self.camera:attach()

    local tileWidth, tileHeight = self.sprites.tile:getDimensions()

    for y = 1, #self.tiles do
        for x = 1, #self.tiles[y] do
            local tile = self.tiles[y][x]

            if tile == '#' then
                love.graphics.draw(self.sprites.wall, (x - 1) * tileWidth, (y - 1) * tileHeight)
            elseif tile == ' ' or tile == 'N' or tile == 'S' or tile == 'E' or tile == 'W' then
                love.graphics.draw(self.sprites.tile, (x - 1) * tileWidth, (y - 1) * tileHeight)
            end
        end
    end

    self.player:draw()
    -- Draw enemies and items

    self.camera:detach()
end

return game
