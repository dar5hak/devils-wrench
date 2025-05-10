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
    love.graphics.setDefaultFilter("nearest", "nearest")

    self.transitioningToVictory = false
    self.transitioningToGameOver = false
    self.transitionTimer = 0

    self.timeElapsed = 0
    self.lastRandomize = 0
    self.randomizeInterval = 30

    self.timeout = 300 -- Timeout in seconds

    self.progressBar = {
        width = 100,
        height = 6,
        color = {1, 0, 1}, -- Magenta
        x = 50, -- Position next to the clock icon
        y = 23
    }

    self.gameMusic = love.audio.newSource('assets/MeltdownTheme_Loopable.ogg', 'stream')
    self.gameMusic:setVolume(0.5)
    self.gameMusic:setLooping(true)
    self.gameMusic:play()

    self.portalBeamUpEffect = love.audio.newSource('assets/portal-beam-up.wav', 'static')
    self.damageEffect = love.audio.newSource('assets/damage.wav', 'static')
    self.settingsUpdatedEffect = love.audio.newSource('assets/settings-updated.wav', 'static')
    self.pauseEffect = love.audio.newSource('assets/pause.wav', 'static')
    self.unpauseEffect = love.audio.newSource('assets/unpause.wav', 'static')

    self.sprites = {
        tile = love.graphics.newImage('assets/tile.png'),
        wall = love.graphics.newImage('assets/wall.png'),
        clockIcon = love.graphics.newImage('assets/clock-icon.png'),
        playerLifeIndicator = love.graphics.newImage('assets/player-life-indicator.png'),
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
    love.graphics.setDefaultFilter("nearest", "nearest")
    self.gameMusic:play()

    if previous == pause then
        self.unpauseEffect:play()
    end
end

function game:update(dt)
    self.timeElapsed = self.timeElapsed + dt

    -- Check if the randomize interval has passed
    if self.timeElapsed - self.lastRandomize >= self.randomizeInterval then
        self:showToast("Settings updated")
        self.settingsUpdatedEffect:play()
        settingsManager.randomizeSettings()
        self.lastRandomize = self.timeElapsed
    end

    -- Update the toast timer and remove the message if it has expired
    if self.toast.timer > 0 then
        self.toast.timer = self.toast.timer - dt
        if self.toast.timer <= 0 then
            self.toast.message = nil
        end
    end

    -- Update timeout and progress bar
    self.timeout = self.timeout - dt
    if self.timeout <= 0 then
        self.timeout = 0
        if not self.transitioningToGameOver then
            self.transitioningToGameOver = true
            self.transitionTimer = 0
        end
    end

    -- Gradually transition the progress bar color to red as timeout approaches 0
    local progressRatio = self.timeout / 300
    self.progressBar.width = 100 * progressRatio
    self.progressBar.color = {1, 0, progressRatio} -- Gradually decrease blue from 1 to 0

    -- Update player and portal animations
    self.player:update(dt)
    self.portal:update(dt)

    -- Check if player reaches the portal
    local px, py, pw, ph = self.world:getRect(self.player)
    local portalX, portalY, portalW, portalH = self.world:getRect(self.portal)
    if not self.transitioningToVictory and px < portalX + portalW and px + pw > portalX and py < portalY + portalH and py + ph > portalY then
        self.transitioningToVictory = true
        self.transitionTimer = 0
        self.portal.animDuration = 0.05
        self.player:move(portalX, portalY, dt, self.world)
    end

    -- Handle transitions
    if self.transitioningToVictory then
        self.gameMusic:stop()
        self.transitionTimer = self.transitionTimer + dt
        if self.transitionTimer < 0.5 then
            self.portalBeamUpEffect:play()
        elseif self.transitionTimer < 2 then
            self.player.y = self.player.y - 100 * dt
        else
            self:switchState(victory)
        end
        return
    elseif self.transitioningToGameOver then
        self.gameMusic:stop()
        self.damageEffect:play()
        self.transitionTimer = self.transitionTimer + dt
        if self.transitionTimer > 2 then
            self:switchState(gameover)
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
        if not self.transitioningToGameOver then
            self.transitioningToGameOver = true
            self.transitionTimer = 0
        end
        return
    end

    -- Update enemies
    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt, self.world) -- Call update instead of move directly
        if self.world:hasItem(enemy) then
            local ex, ey, ew, eh = self.world:getRect(enemy)
            local px, py, pw, ph = self.world:getRect(self.player)
            -- Allow 8 pixels of overlap before triggering collision
            if ex + 8 < px + pw - 8 and ex + ew - 8 > px + 8 and ey + 8 < py + ph - 8 and ey + eh - 8 > py + 8 then
                if not self.player.invulnerable then
                    if self.player.lives > 1 then
                        self.player.lives = self.player.lives - 1
                        self.world:update(enemy, enemy.x, enemy.y)
                        self.damageEffect:play()

                        -- Trigger invulnerability and blinking effect
                        self.player.invulnerable = true
                        self.player.invulnerabilityTimer = 2
                        self.player.blinkTimer = 0.5
                    else
                        if not self.transitioningToGameOver then
                            self.transitioningToGameOver = true
                            self.transitionTimer = 0
                        end
                    end
                    return
                end
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

    -- Draw the clock icon
    love.graphics.draw(self.sprites.clockIcon, 10, 10)

    -- Draw the progress bar
    love.graphics.setColor(self.progressBar.color)
    love.graphics.rectangle("fill", self.progressBar.x, self.progressBar.y, self.progressBar.width, self.progressBar.height)
    love.graphics.setColor(1, 1, 1) -- Reset color to white

    -- Draw player life indicators in the top-right corner
    local lifeIndicatorWidth = self.sprites.playerLifeIndicator:getWidth()
    for i = 1, self.player.lives do
        love.graphics.draw(self.sprites.playerLifeIndicator, love.graphics.getWidth() - (i * (lifeIndicatorWidth + 5)), 10)
    end

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
        self:pause()
    end
end

function game:isWithinRoomBounds(x, y)
    return self.tiles[y][x - 1] == ' ' and self.tiles[y][x + 1] == ' ' and
        self.tiles[y - 1][x] == ' ' and self.tiles[y + 1][x] == ' ' and
        self.tiles[y - 1][x - 1] == ' ' and self.tiles[y - 1][x + 1] == ' ' and
        self.tiles[y + 1][x - 1] == ' ' and self.tiles[y + 1][x + 1] == ' ' and
        self.tiles[y][x] == ' '
end

function game:switchState(state)
    love.graphics.setDefaultFilter("linear", "linear")
    Gamestate.switch(state)
end

function game:pause()
    self.gameMusic:pause()
    self.pauseEffect:play()
    love.graphics.setDefaultFilter("linear", "linear")
    Gamestate.push(pause)
end

return game
