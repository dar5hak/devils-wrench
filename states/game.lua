local love = require('love')
local Camera = require('lib.hump.camera')
local bump = require('lib.bump.bump')
local Gamestate = require('lib.hump.gamestate')
local gameover = require('states.gameover')

local map = require('map')
local Player = require('entities.player')
local Enemy = require('entities.enemy')

local game = {}

function game:init()
    self.sprites = {
        tile = love.graphics.newImage('assets/tile.png'),
        wall = love.graphics.newImage('assets/wall.png'),
    }

    self.dungeon, self.tiles = map.generate()

    self.world = bump.newWorld()

    local roomTiles = {}
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[y] do
            local tile = self.tiles[y][x]
            if tile == ' ' and self:isWithinRoomBounds(x, y) then
                table.insert(roomTiles, { x = x, y = y })
            elseif tile == '#' then
                local tileWidth, tileHeight = self.sprites.tile:getDimensions()
                self.world:add({ type = 'wall' }, (x - 1) * tileWidth, (y - 1) * tileHeight, tileWidth, tileHeight)
            end
        end
    end

    local randomTile = roomTiles[love.math.random(#roomTiles)]
    local tileWidth, tileHeight = self.sprites.tile:getDimensions()
    self.player = Player((randomTile.x - 1) * tileWidth, (randomTile.y - 1) * tileHeight, 32, 32)
    self.world:add(self.player, self.player.x, self.player.y, self.player.width, self.player.height)

    self.enemies = {}
    self.items = {}

    self.enemyCount = 40

    for i = 1, self.enemyCount do
        local randomTile
        repeat
            randomTile = roomTiles[love.math.random(#roomTiles)]
        until math.abs(randomTile.x - math.floor(self.player.x / tileWidth) - 1) > 4 or math.abs(randomTile.y - math.floor(self.player.y / tileHeight) - 1) > 4

        local enemy = Enemy((randomTile.x - 1) * tileWidth, (randomTile.y - 1) * tileHeight)
        table.insert(self.enemies, enemy)
        self.world:add(enemy, enemy.x, enemy.y, enemy.width, enemy.height)
    end

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
        elseif col.other.type == 'enemy' then
            Gamestate.switch(gameover)
            return
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

    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt, self.player, self.world)
        if self.world:hasItem(enemy) then
            local ex, ey, ew, eh = self.world:getRect(enemy)
            local px, py, pw, ph = self.world:getRect(self.player)
            if ex < px + pw and ex + ew > px and ey < py + ph and ey + eh > py then
                Gamestate.switch(gameover)
                return
            end
        end
    end
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

    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end

    self.camera:detach()
end

function game:isWithinRoomBounds(x, y)
    return self.tiles[y][x - 1] == ' ' and self.tiles[y][x + 1] == ' ' and
        self.tiles[y - 1][x] == ' ' and self.tiles[y + 1][x] == ' ' and
        self.tiles[y - 1][x - 1] == ' ' and self.tiles[y - 1][x + 1] == ' ' and
        self.tiles[y + 1][x - 1] == ' ' and self.tiles[y + 1][x + 1] == ' ' and
        self.tiles[y][x] == ' '
end

return game
