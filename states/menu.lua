local love = require('love')
local Gamestate = require('lib.hump.gamestate')
local Timer = require('lib.hump.timer')

local game = require('states.game')
local settings = require('states.settings')

local menu = {}

function menu:init()
    self.background = love.graphics.newImage('assets/background.png')
    self.title = love.graphics.newImage('assets/title.png')
    self.newGameButtonBg = love.graphics.newImage('assets/new-game-btn-bg.png')
    self.newGameButton = love.graphics.newImage('assets/new-game-btn.png')
    self.settingsIcon = love.graphics.newImage('assets/settings-icon.png')
    self.exitIcon = love.graphics.newImage('assets/exit-icon.png')

    self.titleMusic = love.audio.newSource('assets/HaroldParanormalInstigatorTheme_Loopable.ogg', 'stream')

    self.settingsIconAngle = 0
    self.exitIconAngle = 0

    self:setupAnimations()
end

function menu:setupAnimations()
    Timer.tween(3, self, { settingsIconAngle = 0.1 }, 'linear', function()
        Timer.tween(3, self, { settingsIconAngle = -0.1 }, 'linear')
    end)

    Timer.tween(3, self, { exitIconAngle = 0.1 }, 'linear', function()
        Timer.tween(3, self, { exitIconAngle = -0.1 }, 'linear')
    end)

    Timer.every(6, function()
        Timer.tween(3, self, { settingsIconAngle = 0.1 }, 'linear', function()
            Timer.tween(3, self, { settingsIconAngle = -0.1 }, 'linear')
        end)
        Timer.tween(3, self, { exitIconAngle = 0.1 }, 'linear', function()
            Timer.tween(3, self, { exitIconAngle = -0.1 }, 'linear')
        end)
    end)
end

function menu:enter(previous)
    self.buttonAngle = 0
    Timer.tween(1, self, { buttonAngle = math.pi / 12 }, 'bounce')
    love.audio.play(self.titleMusic)
end

function menu:update(dt)
    Timer.update(dt)
end

function menu:draw()
    love.graphics.draw(self.background, 0, 0)

    local screenWidth = love.graphics.getDimensions()
    local newGameButtonX = (screenWidth - self.newGameButton:getWidth()) / 2

    love.graphics.draw(self.title, 134, 44)
    love.graphics.draw(self.newGameButtonBg, newGameButtonX, 348)
    love.graphics.draw(self.newGameButton, newGameButtonX, 348, self.buttonAngle, 1, 1, -2, 0)
    love.graphics.draw(self.settingsIcon, 666, 541, self.settingsIconAngle, 1, 1, self.settingsIcon:getWidth() / 2,
        self.settingsIcon:getHeight() / 2)
    love.graphics.draw(self.exitIcon, 750, 543, self.exitIconAngle, 1, 1, self.exitIcon:getWidth() / 2,
        self.exitIcon:getHeight() / 2)
end

function menu:keyreleased(key)
    if key == 'return' then
        love.audio.stop(self.titleMusic)
        Gamestate.switch(game)
    end
end

function menu:mousepressed(x, y, button)
    if button == 1 then
        local newGameButtonX = (love.graphics.getWidth() - self.newGameButton:getWidth()) / 2
        local newGameButtonY = 348
        if x >= newGameButtonX and x <= newGameButtonX + self.newGameButton:getWidth() and y >= newGameButtonY and y <= newGameButtonY + self.newGameButton:getHeight() then
            Gamestate.switch(game)
        end

        local settingsIconX = 666 - self.settingsIcon:getWidth() / 2
        local settingsIconY = 541 - self.settingsIcon:getHeight() / 2
        if x >= settingsIconX and x <= settingsIconX + self.settingsIcon:getWidth() and y >= settingsIconY and y <= settingsIconY + self.settingsIcon:getHeight() then
            Gamestate.switch(settings)
        end

        local exitIconX = 750 - self.exitIcon:getWidth() / 2
        local exitIconY = 543 - self.exitIcon:getHeight() / 2
        if x >= exitIconX and x <= exitIconX + self.exitIcon:getWidth() and y >= exitIconY and y <= exitIconY + self.exitIcon:getHeight() then
            love.event.quit()
        end
    end
end

return menu
