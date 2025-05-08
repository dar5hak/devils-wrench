local love = require('love')
local Camera = require('lib.hump.camera')
local bump = require('lib.bump.bump')
local Gamestate = require('lib.hump.gamestate')

local map = require('map')

local victory = require('states.victory')
local gameover = require('states.gameover')
local pause = require('states.pause')

local Player = require('entities.player')
local Enemy = require('entities.enemy')
local Portal = require('entities.portal')

local settingsManager = require('settingsManager')

local game = {}

function game:enter()
    self.transitioningToVictory = false
    self.transitionTimer = 0

    self.timeElapsed = 0
    self.lastRandomize = 0
    self.randomizeInterval = 30

    self.gameMusic = love.audio.newSource('assets/MeltdownTheme_Loopable.ogg', 'stream')
    self.gameMusic:setVolume(0.5)
    self.gameMusic:setLooping(true)
    self.gameMusic:play()

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

    self.toast = {
        message = nil,
        timer = 0,
        duration = 5,
        font = love.graphics.newFont(24),
    }
end

function game:showToast(message)
    self.toast.message = message
    self.toast.timer = self.toast.duration
end

function game:resume(previous)
    self.gameMusic:play()
end

function game:update(dt)
    self.timeElapsed = self.timeElapsed + dt

    -- Check if the randomize interval has passed
    if self.timeElapsed - self.lastRandomize >= self.randomizeInterval then
        settingsManager.randomizeSettings()
        self:showToast("Settings updated")
        self.lastRandomize = self.timeElapsed
    end

    -- Update the toast timer and remove the message if it has expired
    if self.toast.timer > 0 then
        self.toast.timer = self.toast.timer - dt
        if self.toast.timer <= 0 then
            self.toast.message = nil
        end
    end

    -- Update player animations
    self.player:update(dt)

    -- Check if player reaches the portal
    local px, py, pw, ph = self.world:getRect(self.player)
    local portalX, portalY, portalW, portalH = self.world:getRect(self.portal)
    if not self.transitioningToVictory and px < portalX + portalW and px + pw > portalX and py < portalY + portalH and py + ph > portalY then
        self.transitioningToVictory = true
        self.transitionTimer = 0
        self.player:move(portalX, portalY, dt, self.world)
    end

    -- Handle transition to victory
    if self.transitioningToVictory then
        self.transitionTimer = self.transitionTimer + dt
        if self.transitionTimer < 1 then
            -- Wait for a second
        elseif self.transitionTimer < 2 then
            self.player.y = self.player.y - 100 * dt
        else
            self.gameMusic:stop()
            Gamestate.switch(victory)
        end
        return
    end

    -- Handle player movement
    local goalX, goalY = self.player.x, self.player.y

    local upKey, downKey, leftKey, rightKey = settingsManager.currentSettings.key.up,
        settingsManager.currentSettings.key.down, settingsManager.currentSettings.key.left,
        settingsManager.currentSettings.key.right

    if love.keyboard.isDown(upKey) then
        goalY = goalY - self.player.speed * dt
    elseif love.keyboard.isDown(downKey) then
        goalY = goalY + self.player.speed * dt
    elseif love.keyboard.isDown(leftKey) then
        goalX = goalX - self.player.speed * dt
    elseif love.keyboard.isDown(rightKey) then
        goalX = goalX + self.player.speed * dt
    end

    -- Update player movement and check for collisions
    if not self.player:move(goalX, goalY, dt, self.world) then
        self.gameMusic:stop()
        Gamestate.switch(gameover)
        return
    end

    -- Update enemies
    for _, enemy in ipairs(self.enemies) do
        enemy:move(dt, self.world)
        if self.world:hasItem(enemy) then
            local ex, ey, ew, eh = self.world:getRect(enemy)
            local px, py, pw, ph = self.world:getRect(self.player)
            if ex < px + pw and ex + ew > px and ey < py + ph and ey + eh > py then
                self.gameMusic:stop()
                Gamestate.switch(gameover)
                return
            end
        end
    end

    -- Update camera position
    self.camera:lookAt(self.player.x, self.player.y)
    self.camera:zoomTo(settingsManager.currentSettings.zoom.scale)
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

    -- Draw toast message if active
    if self.toast.message then
        love.graphics.setColor(0, 0, 0, 0.7) -- Background color (semi-transparent black)
        love.graphics.rectangle("fill", love.graphics.getWidth() - 300, love.graphics.getHeight() - 80, 280, 60)
        love.graphics.setColor(1, 1, 1, 1)   -- Text color (white)
        love.graphics.setFont(self.toast.font)
        love.graphics.printf(self.toast.message, love.graphics.getWidth() - 300, love.graphics.getHeight() - 64, 280,
            "center")
    end
end

function game:keypressed(key)
    if key == 'space' then
        self.gameMusic:pause()
        Gamestate.push(pause)
    end
end

function game:isWithinRoomBounds(x, y)
    return self.tiles[y][x - 1] == ' ' and self.tiles[y][x + 1] == ' ' and
        self.tiles[y - 1][x] == ' ' and self.tiles[y + 1][x] == ' ' and
        self.tiles[y - 1][x - 1] == ' ' and self.tiles[y - 1][x + 1] == ' ' and
        self.tiles[y + 1][x - 1] == ' ' and self.tiles[y + 1][x + 1] == ' ' and
        self.tiles[y][x] == ' '
end

return game
