local love = require('love')
local Gamestate = require('lib.hump.gamestate')
local Timer = require('lib.hump.timer')

local game = require('states.game')
local settings = require('states.settings')

local menu = {}

function menu:init()
    self.background = love.graphics.newImage('assets/background.jpg')
    self.title = love.graphics.newImage('assets/title.png')
    self.newGameButtonBg = love.graphics.newImage('assets/new-game-btn-bg.png')
    self.newGameButton = love.graphics.newImage('assets/new-game-btn.png')
    self.settingsIcon = love.graphics.newImage('assets/settings-icon.png')
    self.exitIcon = love.graphics.newImage('assets/exit-icon.png')
    self.creditsIcon = love.graphics.newImage('assets/credits-icon.png')

    self.titleMusic = love.audio.newSource('assets/HaroldParanormalInstigatorTheme_Loopable.ogg', 'stream')
    self.titleMusic:setVolume(0.5)
    self.titleMusic:setLooping(true)

    self.settingsIconAngle = 0
    self.exitIconAngle = 0
    self.creditsIconAngle = 0

    self.hoveredControl = nil

    self:setupAnimations()
end

function menu:setupAnimations()
    Timer.tween(3, self, { settingsIconAngle = 0.1 }, 'linear', function()
        Timer.tween(3, self, { settingsIconAngle = -0.1 }, 'linear')
    end)

    Timer.tween(3, self, { exitIconAngle = 0.1 }, 'linear', function()
        Timer.tween(3, self, { exitIconAngle = -0.1 }, 'linear')
    end)

    Timer.tween(3, self, { creditsIconAngle = 0.1 }, 'linear', function()
        Timer.tween(3, self, { creditsIconAngle = -0.1 }, 'linear')
    end)

    Timer.every(6, function()
        Timer.tween(3, self, { settingsIconAngle = 0.1 }, 'linear', function()
            Timer.tween(3, self, { settingsIconAngle = -0.1 }, 'linear')
        end)
        Timer.tween(3, self, { exitIconAngle = 0.1 }, 'linear', function()
            Timer.tween(3, self, { exitIconAngle = -0.1 }, 'linear')
        end)
        Timer.tween(3, self, { creditsIconAngle = 0.1 }, 'linear', function()
            Timer.tween(3, self, { creditsIconAngle = -0.1 }, 'linear')
        end)
    end)
end

function menu:enter(previous)
    self.buttonAngle = 0
    Timer.tween(1, self, { buttonAngle = math.pi / 12 }, 'bounce')
    self.titleMusic:play()
end

function menu:resume()
    self.titleMusic:play()
end

function menu:update(dt)
    Timer.update(dt)

    local mouseX, mouseY = love.mouse.getPosition()
    local newGameButtonX = (love.graphics.getWidth() - self.newGameButton:getWidth()) / 2
    local newGameButtonY = 348

    if mouseX >= newGameButtonX and mouseX <= newGameButtonX + self.newGameButton:getWidth() and
        mouseY >= newGameButtonY and mouseY <= newGameButtonY + self.newGameButton:getHeight() then
        self.hoveredControl = 'newGame'
    elseif mouseX >= 666 - self.settingsIcon:getWidth() / 2 and
        mouseX <= 666 + self.settingsIcon:getWidth() / 2 and
        mouseY >= 541 - self.settingsIcon:getHeight() / 2 and
        mouseY <= 541 + self.settingsIcon:getHeight() / 2 then
        self.hoveredControl = 'settings'
    elseif mouseX >= 750 - self.exitIcon:getWidth() / 2 and
        mouseX <= 750 + self.exitIcon:getWidth() / 2 and
        mouseY >= 543 - self.exitIcon:getHeight() / 2 and
        mouseY <= 543 + self.exitIcon:getHeight() / 2 then
        self.hoveredControl = 'exit'
    elseif mouseX >= 60 - self.creditsIcon:getWidth() / 2 and
        mouseX <= 60 + self.creditsIcon:getWidth() / 2 and
        mouseY >= 543 - self.creditsIcon:getHeight() / 2 and
        mouseY <= 543 + self.creditsIcon:getHeight() / 2 then
        self.hoveredControl = 'credits'
    else
        self.hoveredControl = nil
    end

    if self.hoveredControl == 'newGame' and not self.isTweening then
        self.isTweening = true
        local randomAngle = math.random(0, 2 * math.pi)
        Timer.tween(randomAngle / 4, self, { buttonAngle = randomAngle }, 'linear', function()
            self.isTweening = false
        end)
    end
end

function menu:draw()
    love.graphics.draw(self.background, 0, 0)
    love.graphics.draw(self.title, 134, 44)

    local settingsIconScale = 1
    local exitIconScale = 1
    local creditsIconScale = 1

    if self.hoveredControl == 'settings' then
        settingsIconScale = 1.1
    elseif self.hoveredControl == 'exit' then
        exitIconScale = 1.1
    elseif self.hoveredControl == 'credits' then
        creditsIconScale = 1.1
    end

    local screenWidth = love.graphics.getDimensions()
    local newGameButtonX = (screenWidth - self.newGameButton:getWidth()) / 2

    love.graphics.draw(self.newGameButtonBg, newGameButtonX, 348, 0, 1, 1, 14, 10)
    love.graphics.draw(self.newGameButton, newGameButtonX, 348, self.buttonAngle, 1, 1, 14, 10)

    love.graphics.draw(self.settingsIcon, 666, 541, self.settingsIconAngle, settingsIconScale, settingsIconScale, self.settingsIcon:getWidth() / 2,
        self.settingsIcon:getHeight() / 2)

    love.graphics.draw(self.exitIcon, 750, 543, self.exitIconAngle, exitIconScale, exitIconScale, self.exitIcon:getWidth() / 2,
        self.exitIcon:getHeight() / 2)

    love.graphics.draw(self.creditsIcon, 60, 543, self.creditsIconAngle, creditsIconScale, creditsIconScale, self.creditsIcon:getWidth() / 2,
        self.creditsIcon:getHeight() / 2)
end

function menu:keyreleased(key)
    if key == 'return' then
        self.titleMusic:stop()
        uiSelectEffect:play()
        Gamestate.push(game)
    end
end

function menu:mousepressed(x, y, button)
    if button == 1 then
        local newGameButtonX = (love.graphics.getWidth() - self.newGameButton:getWidth()) / 2
        local newGameButtonY = 348
        if x >= newGameButtonX and x <= newGameButtonX + self.newGameButton:getWidth() and y >= newGameButtonY and y <= newGameButtonY + self.newGameButton:getHeight() then
            self.titleMusic:stop()
            uiSelectEffect:play()
            Gamestate.push(game)
        end

        local settingsIconX = 666 - self.settingsIcon:getWidth() / 2
        local settingsIconY = 541 - self.settingsIcon:getHeight() / 2
        if x >= settingsIconX and x <= settingsIconX + self.settingsIcon:getWidth() and y >= settingsIconY and y <= settingsIconY + self.settingsIcon:getHeight() then
            uiSelectEffect:play()
            Gamestate.push(settings)
        end

        local exitIconX = 750 - self.exitIcon:getWidth() / 2
        local exitIconY = 543 - self.exitIcon:getHeight() / 2
        if x >= exitIconX and x <= exitIconX + self.exitIcon:getWidth() and y >= exitIconY and y <= exitIconY + self.exitIcon:getHeight() then
            uiSelectEffect:play()
            love.event.quit()
        end

        local creditsIconX = 60 - self.creditsIcon:getWidth() / 2
        local creditsIconY = 543 - self.creditsIcon:getHeight() / 2
        if x >= creditsIconX and x <= creditsIconX + self.creditsIcon:getWidth() and y >= creditsIconY and y <= creditsIconY + self.creditsIcon:getHeight() then
            uiSelectEffect:play()
            Gamestate.push(require('states.credits'))
        end
    end
end

return menu
