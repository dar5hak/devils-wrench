local Gamestate = require('lib.hump.gamestate')

local victory = {}

function victory:init()
    self.background = love.graphics.newImage('assets/victory-bg.png')
    self.text = love.graphics.newImage('assets/victory-text.png')
    self.menuBtn = love.graphics.newImage('assets/victory-menu-btn.png')
    self.music = love.audio.newSource('assets/Goblins_Dance_(Battle).wav', 'stream')
end

function victory:enter(previous)
    self.music:play()
end

function victory:draw()
    love.graphics.draw(self.background, 0, 0)

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local textX = (screenWidth - self.text:getWidth()) / 2
    local textY = (screenHeight - self.text:getHeight()) / 2
    local menuBtnX = (screenWidth - self.menuBtn:getWidth()) / 2
    local menuBtnY = 480

    love.graphics.draw(self.text, textX, textY)
    love.graphics.draw(self.menuBtn, menuBtnX, menuBtnY)
end

function victory:keyreleased(key)
    if key == 'return' then
        self.music:stop()
        uiSelectEffect:play()
        Gamestate.switch(require('states.menu'))
    end
end

function victory:mousepressed(x, y, button)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local menuBtnX = (screenWidth - self.menuBtn:getWidth()) / 2
    local menuBtnY = 480

    if button == 1 and x >= menuBtnX and x <= menuBtnX + self.menuBtn:getWidth() and
        y >= menuBtnY and y <= menuBtnY + self.menuBtn:getHeight() then
        self.music:stop()
        uiSelectEffect:play()
        Gamestate.switch(require('states.menu'))
    end
end

return victory
