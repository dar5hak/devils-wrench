local love = require('love')
local Gamestate = require('lib.hump.gamestate')

local credits = {}

function credits:init()
    self.background = love.graphics.newImage('assets/background.jpg')
    self.text = love.graphics.newImage('assets/credits-text.png')
    self.details = love.graphics.newImage('assets/credits-details.png')
    self.backBtn = love.graphics.newImage('assets/back-btn.png')
end

function credits:enter(previous)
    -- Logic to run when entering the credits state
end

function credits:update(dt)
    -- Update logic for the credits state
end

function credits:draw()
    love.graphics.draw(self.background, 0, 0)

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local textX = (screenWidth - self.text:getWidth()) / 2
    local textY = 58
    local detailsX = (screenWidth - self.details:getWidth()) / 2
    local detailsY = 190
    local backBtnX = (screenWidth - self.backBtn:getWidth()) / 2
    local backBtnY = screenHeight - self.backBtn:getHeight() - 40

    love.graphics.draw(self.text, textX, textY)
    love.graphics.draw(self.details, detailsX, detailsY)
    love.graphics.draw(self.backBtn, backBtnX, backBtnY, -0.14)
end

function credits:keyreleased(key)
    if key == 'return' then
        uiSelectEffect:play()
        Gamestate.pop()
    end
end

function credits:mousepressed(x, y, button)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local backBtnX = (screenWidth - self.backBtn:getWidth()) / 2
    local backBtnY = 480

    if button == 1 and x >= backBtnX and x <= backBtnX + self.backBtn:getWidth() and
        y >= backBtnY and y <= backBtnY + self.backBtn:getHeight() then
        uiSelectEffect:play()
        Gamestate.pop()
    end
end

return credits