local Gamestate = require('lib.hump.gamestate')

local gameover = {}

function gameover:init()
    self.background = love.graphics.newImage('assets/background.jpg')
    self.text = love.graphics.newImage('assets/gameover-text.png')
    self.menuBtn = love.graphics.newImage('assets/gameover-menu-btn.png')
    self.music = love.audio.newSource('assets/Plain_Sight_(Regular).wav', 'stream')
end

function gameover:enter(previous)
    self.music:play()
end

function gameover:draw()
    love.graphics.draw(self.background, 0, 0)

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local textX = (screenWidth - self.text:getWidth()) / 2
    local textY = (screenHeight - self.text:getHeight()) / 2
    local menuBtnX = (screenWidth - self.menuBtn:getWidth()) / 2
    local menuBtnY = 480

    love.graphics.draw(self.text, textX, textY)
    love.graphics.draw(self.menuBtn, menuBtnX, menuBtnY, -0.14)
end

function gameover:keyreleased(key)
    if key == 'return' then
        self.music:stop()
        uiSelectEffect:play()
        Gamestate.pop()
    end
end

function gameover:mousepressed(x, y, button)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local menuBtnX = (screenWidth - self.menuBtn:getWidth()) / 2
    local menuBtnY = 480

    if button == 1 and x >= menuBtnX and x <= menuBtnX + self.menuBtn:getWidth() and
        y >= menuBtnY and y <= menuBtnY + self.menuBtn:getHeight() then
        self.music:stop()
        uiSelectEffect:play()
        Gamestate.pop()
    end
end

return gameover
