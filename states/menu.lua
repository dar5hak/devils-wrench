local Gamestate = require('lib.hump.gamestate')
local Timer = require('lib.hump.timer')
local iffy = require('lib.iffy.iffy')

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
    self.blinkingEyes = love.graphics.newImage('assets/blinking-eyes.png')

    self.titleMusic = love.audio.newSource('assets/HaroldParanormalInstigatorTheme_Loopable.ogg', 'stream')
    self.titleMusic:setVolume(0.5)
    self.titleMusic:setLooping(true)

    self.settingsIconAngle = 0
    self.exitIconAngle = 0
    self.creditsIconAngle = 0

    self.hoveredControl = nil

    iffy.newAtlas("blinking_eyes_atlas", "assets/blinking-eyes.png", "assets/blinking-eyes.csv")
    self.blinkingEyesFrame = "eyes1"
    self.blinkingEyesTimer = 0
    self.blinkingEyesDuration = 1 / 3
    self.newGameButtonX = 300
    self.newGameButtonY = 348
    self.blinkingEyesPosition = {
        x = self.newGameButtonX + 170,
        y = self.newGameButtonY + 45
    }

    self:setupAnimations()
end

function menu:setupAnimations()
    self:setupBlinkingAnimation()

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

function menu:setupBlinkingAnimation()
    local baseX = self.newGameButtonX
    local baseY = self.newGameButtonY

    local function updateRandomPosition()
        self.blinkingEyesPosition.x = baseX + love.math.random(40, 160)
        self.blinkingEyesPosition.y = baseY + love.math.random(45, 60)
    end

    local function blink()
        Timer.after(0.2, function()
            self.blinkingEyesFrame = "eyes2"
            Timer.after(0.2, function()
                self.blinkingEyesFrame = "eyes3"
                Timer.after(2, function()
                    self.blinkingEyesFrame = "eyes2"
                    Timer.after(0.2, function()
                        self.blinkingEyesFrame = "eyes1"
                        updateRandomPosition()
                        Timer.after(4, blink)
                    end)
                end)
            end)
        end)
    end

    Timer.after(3, blink)
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

    if mouseX >= self.newGameButtonX and mouseX <= self.newGameButtonX + self.newGameButton:getWidth() and
        mouseY >= self.newGameButtonY and mouseY <= self.newGameButtonY + self.newGameButton:getHeight() then
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
        Timer.tween(randomAngle / 8, self, { buttonAngle = randomAngle }, 'linear', function()
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

    local newGameButtonBgOffsetX, newGameButtonBgOffsetY = 14, 10

    love.graphics.draw(self.newGameButtonBg, self.newGameButtonX, self.newGameButtonY, 0, 1, 1, newGameButtonBgOffsetX,
        newGameButtonBgOffsetY)

    iffy.draw("blinking_eyes_atlas", self.blinkingEyesFrame, self.blinkingEyesPosition.x,
        self.blinkingEyesPosition.y, 0, 1, 1, self.blinkingEyes:getWidth() / 2,
        self.blinkingEyes:getHeight() / 2)

    love.graphics.draw(self.newGameButton, self.newGameButtonX, self.newGameButtonY, self.buttonAngle, 1, 1, newGameButtonBgOffsetX,
        newGameButtonBgOffsetY)

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
        if x >= self.newGameButtonX and x <= self.newGameButtonX + self.newGameButton:getWidth() and y >= self.newGameButtonY and y <= self.newGameButtonY + self.newGameButton:getHeight() then
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
