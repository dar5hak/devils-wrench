local love = require('love')

local settings = {}

function settings:init()
    self.heading = love.graphics.newImage('assets/settings-heading.png')
    self.keysArrows = love.graphics.newImage('assets/keys-arrows.png')
    self.keysWSAD = love.graphics.newImage('assets/keys-wsad.png')
    self.keysVim = love.graphics.newImage('assets/keys-vim.png')
    self.zoom1 = love.graphics.newImage('assets/zoom-1.png')
    self.zoom2 = love.graphics.newImage('assets/zoom-2.png')
    self.zoom3 = love.graphics.newImage('assets/zoom-3.png')
    self.saveBtn = love.graphics.newImage('assets/save-btn.png')
end

function settings:enter(previous)
    -- Logic to run when entering the settings state
end

function settings:update(dt)
    -- Update logic for the settings state
end

function settings:draw()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local headingX = (screenWidth - self.heading:getWidth()) / 2
    local headingY = 58
    local saveBtnX = (screenWidth - self.saveBtn:getWidth()) / 2
    local saveBtnY = screenHeight - self.saveBtn:getHeight() - 40

    print(love.graphics.getDimensions())
    print(self.saveBtn:getWidth(), self.saveBtn:getHeight())
    print(saveBtnX, saveBtnY)

    love.graphics.draw(self.heading, headingX, headingY)

    -- Draw other settings elements here
    love.graphics.draw(self.keysArrows, 132, 188)
    love.graphics.draw(self.keysWSAD, 332, 188)
    love.graphics.draw(self.keysVim, 532, 188)
    love.graphics.draw(self.zoom1, 172, 357)
    love.graphics.draw(self.zoom2, 350, 357)
    love.graphics.draw(self.zoom3, 550, 338)
    love.graphics.draw(self.saveBtn, saveBtnX, saveBtnY, -0.14)
end

return settings
