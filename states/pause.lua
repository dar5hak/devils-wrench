local love = require('love')
local Gamestate = require('lib.hump.gamestate')

local pause = {}

function pause:init()
    self.background = love.graphics.newImage('assets/background.jpg')
    self.text = love.graphics.newImage('assets/paused-text.png')
    self.backBtn = love.graphics.newImage('assets/back-btn.png')
end

function pause:enter(from)
    self.from = from -- Record the previous state
end

function pause:draw()
    love.graphics.draw(self.background, 0, 0)

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local textX = (screenWidth - self.text:getWidth()) / 2
    local textY = (screenHeight - self.text:getHeight()) / 2
    local backBtnX = (screenWidth - self.backBtn:getWidth()) / 2
    local backBtnY = 480

    love.graphics.draw(self.text, textX, textY)
    love.graphics.draw(self.backBtn, backBtnX, backBtnY, -0.14)
end

function pause:keypressed(key)
    if key == 'space' then
        Gamestate.pop()
    end
end

function pause:mousepressed(x, y, button)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local backBtnX = (screenWidth - self.backBtn:getWidth()) / 2
    local backBtnY = 480

    if button == 1 and x >= backBtnX and x <= backBtnX + self.backBtn:getWidth() and
        y >= backBtnY and y <= backBtnY + self.backBtn:getHeight() then
        Gamestate.pop()
    end
end

return pause
