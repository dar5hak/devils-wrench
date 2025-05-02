local love = require('love')
local Camera = require('lib.hump.camera')
local bump = require('lib.bump.bump')
local Gamestate = require('lib.hump.gamestate')
local gameover = require('states.gameover')

local map = require('map')
local Player = require('entities.player')
local Enemy = require('entities.enemy')
local Portal = require('entities.portal')

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

    -- Add portal to a random room tile
    local portalTile = roomTiles[love.math.random(#roomTiles)]
    self.portal = Portal((portalTile.x - 1) * tileWidth, (portalTile.y - 1) * tileHeight)
    self.world:add(self.portal, self.portal.x, self.portal.y, self.portal.width, self.portal.height)

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

    -- Update player movement and check for collisions
    if not self.player:move(goalX, goalY, dt, self.world) then
        Gamestate.switch(gameover)
        return
    end

    -- Check if player reaches the portal
    local px, py, pw, ph = self.world:getRect(self.player)
    local portalX, portalY, portalW, portalH = self.world:getRect(self.portal)
    if px < portalX + portalW and px + pw > portalX and py < portalY + portalH and py + ph > portalY then
        Gamestate.switch(require('states.victory'))
        return
    end

    -- Update enemies
    for _, enemy in ipairs(self.enemies) do
        enemy:move(dt, self.world)
        if self.world:hasItem(enemy) then
            local ex, ey, ew, eh = self.world:getRect(enemy)
            local px, py, pw, ph = self.world:getRect(self.player)
            if ex < px + pw and ex + ew > px and ey < py + ph and ey + eh > py then
                Gamestate.switch(gameover)
                return
            end
        end
    end

    -- Update camera position
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
    self.portal:draw()

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
