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

local helpers = require('helpers')
local Toast = require('toast')
local ProgressBar = require('progressBar')

local settingsManager = require('settingsManager')

local game = {}

function game:enter()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.mouse.setVisible(false)

    self.transitioningToVictory = false
    self.transitioningToGameOver = false
    self.transitionTimer = 0

    self.timeElapsed = 0
    self.lastRandomize = 0
    self.randomizeInterval = 30

    self.max_timeout = 160
    self.timeout = self.max_timeout

    self.progressBar = ProgressBar:new(50, 25, 160, 6, {1, 0, 1})

    self.audio = {
        gameMusic = love.audio.newSource('assets/MeltdownTheme_Loopable.ogg', 'stream'),
        portalBeamUpEffect = love.audio.newSource('assets/portal-beam-up.wav', 'static'),
        damageEffect = love.audio.newSource('assets/damage.wav', 'static'),
        settingsUpdatedEffect = love.audio.newSource('assets/settings-updated.wav', 'static'),
        pauseEffect = love.audio.newSource('assets/pause.wav', 'static'),
        unpauseEffect = love.audio.newSource('assets/unpause.wav', 'static'),
    }

    self.audio.gameMusic:setVolume(0.5)
    self.audio.gameMusic:setLooping(true)
    self.audio.gameMusic:play()

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

    local playerTile = roomTiles[love.math.random(#roomTiles)]
    local tileWidth, tileHeight = self.sprites.tile:getDimensions()
    self.player = Player((playerTile.x - 1) * tileWidth, (playerTile.y - 1) * tileHeight, 32, 32)
    self.world:add(self.player, self.player.x, self.player.y, self.player.width, self.player.height)

    local portalTile
    repeat
        portalTile = roomTiles[love.math.random(#roomTiles)]
    until helpers.isTileFarFromPlayer(portalTile, self.player, tileWidth, tileHeight, 25)
    self.portal = Portal((portalTile.x - 1) * tileWidth, (portalTile.y - 1) * tileHeight)
    self.world:add(self.portal, self.portal.x, self.portal.y, self.portal.width, self.portal.height)

    self.enemies = {}
    self.items = {}

    self.enemyCount = 40

    for i = 1, self.enemyCount do
        local enemyTile
        repeat
            enemyTile = roomTiles[love.math.random(#roomTiles)]
        until helpers.isTileFarFromPlayer(enemyTile, self.player, tileWidth, tileHeight, 4)

        local enemy = Enemy((enemyTile.x - 1) * tileWidth, (enemyTile.y - 1) * tileHeight)
        table.insert(self.enemies, enemy)
        self.world:add(enemy, enemy.x, enemy.y, enemy.width, enemy.height)
    end

    self.camera = Camera(self.player.x, self.player.y)

    self.toast = Toast:new(love.graphics.newFont(24), 5)
end

function game:showToast(message)
    self.toast.message = message
    self.toast.timer = self.toast.duration
end

function game:resume(previous)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.mouse.setVisible(false)
    self.audio.gameMusic:play()

    if previous == pause then
        self.audio.unpauseEffect:play()
    end
end

function game:startGameOverTransition()
    if not self.transitioningToGameOver then
        self.transitioningToGameOver = true
        self.transitionTimer = 0
        self:playDamageEffect()
    end
end

function game:update(dt)
    self.timeElapsed = self.timeElapsed + dt

    if self.timeElapsed - self.lastRandomize >= self.randomizeInterval then
        self:showToast("Settings updated")
        self.audio.settingsUpdatedEffect:play()
        settingsManager.randomizeSettings()
        self.lastRandomize = self.timeElapsed
    end

    self.toast:update(dt)

    self.timeout = self.timeout - dt
    if self.timeout <= 0 then
        self.timeout = 0
        self:startGameOverTransition()
    end

    local progressRatio = self.timeout / self.max_timeout
    self.progressBar:update(progressRatio)

    self.player:update(dt)
    self.portal:update(dt)

    local px, py, pw, ph = self.world:getRect(self.player)
    local portalX, portalY, portalW, portalH = self.world:getRect(self.portal)

    if not self.transitioningToVictory and px < portalX + portalW and px + pw > portalX and py < portalY + portalH and py + ph > portalY then
        self.transitioningToVictory = true
        self.transitionTimer = 0
        self.portal.animDuration = 0.05
    end

    if self.transitioningToVictory then
        self.audio.gameMusic:stop()
        self.transitionTimer = self.transitionTimer + dt

        if self.transitionTimer < 0.5 then
            self.audio.portalBeamUpEffect:play()
            -- Smoothly move the player towards the portal's center
            local targetX = portalX + portalW / 2 - self.player.width / 2
            local targetY = portalY + portalH / 2 - self.player.height / 2
            self.player.x = self.player.x + (targetX - self.player.x) * dt * 5
            self.player.y = self.player.y + (targetY - self.player.y) * dt * 5
        elseif self.transitionTimer < 2 then
            self.player.y = self.player.y - 100 * dt
        else
            self:switchState(victory)
        end
        return
    elseif self.transitioningToGameOver then
        self.audio.gameMusic:stop()
        self.transitionTimer = self.transitionTimer + dt
        if self.transitionTimer > 2 then
            self:switchState(gameover)
        end
        return
    end

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

    if not self.player:move(goalX, goalY, dt, self.world) then
        self:startGameOverTransition()
        return
    end

    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt, self.world)
        if self.world:hasItem(enemy) then
            local ex, ey, ew, eh = self.world:getRect(enemy)
            local px, py, pw, ph = self.world:getRect(self.player)
            -- Allow 8 pixels of overlap before triggering collision
            if ex + 8 < px + pw - 8 and ex + ew - 8 > px + 8 and ey + 8 < py + ph - 8 and ey + eh - 8 > py + 8 then
                if not self.player.invulnerable then
                    if self.player.lives > 1 then
                        self.player.lives = self.player.lives - 1
                        self.world:update(enemy, enemy.x, enemy.y)
                        self:playDamageEffect()

                        self.player.invulnerable = true
                        self.player.invulnerabilityTimer = 2
                        self.player.blinkTimer = 0.5
                    else
                        self:startGameOverTransition()
                    end
                    return
                end
            end
        end
    end

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

    love.graphics.draw(self.sprites.clockIcon, 10, 10)

    self.progressBar:draw()

    local lifeIndicatorWidth = self.sprites.playerLifeIndicator:getWidth()
    for i = 1, self.player.lives do
        love.graphics.draw(self.sprites.playerLifeIndicator, love.graphics.getWidth() - (i * (lifeIndicatorWidth + 5)), 10)
    end

    self.toast:draw()

    if self.toast.message then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", love.graphics.getWidth() - 300, love.graphics.getHeight() - 80, 280, 60)
        love.graphics.setColor(1, 1, 1, 1)
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
    local offsets = {
        {0, 0}, {-1, 0}, {1, 0}, {0, -1}, {0, 1},
        {-1, -1}, {-1, 1}, {1, -1}, {1, 1}
    }
    for _, offset in ipairs(offsets) do
        local dx, dy = offset[1], offset[2]
        if self.tiles[y + dy][x + dx] ~= ' ' then
            return false
        end
    end
    return true
end

function game:switchState(state)
    love.graphics.setDefaultFilter("linear", "linear")
    love.mouse.setVisible(true)
    Gamestate.switch(state)
end

function game:pause()
    self.audio.gameMusic:pause()
    self.audio.pauseEffect:play()
    love.graphics.setDefaultFilter("linear", "linear")
    love.mouse.setVisible(true)
    Gamestate.push(pause)
end

function game:playDamageEffect()
    if self.audio.damageEffect:isPlaying() then
        self.audio.damageEffect:stop()
    end
    self.audio.damageEffect:play()
end

return game
