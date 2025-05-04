local love = require('love')

local settings = {}

function settings:init()
    self.heading = love.graphics.newImage('assets/settings-heading.png')

    self.keySettings = {
        arrows = { x = 132, y = 188, image = love.graphics.newImage('assets/keys-arrows.png') },
        wasd = { x = 332, y = 188, image = love.graphics.newImage('assets/keys-wasd.png') },
        vim = { x = 532, y = 188, image = love.graphics.newImage('assets/keys-vim.png') },
    }
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
    love.graphics.draw(self.keySettings.arrows.image, self.keySettings.arrows.x, self.keySettings.arrows.y)
    love.graphics.draw(self.keySettings.wasd.image, self.keySettings.wasd.x, self.keySettings.wasd.y)
    love.graphics.draw(self.keySettings.vim.image, self.keySettings.vim.x, self.keySettings.vim.y)
    love.graphics.draw(self.zoom1, 172, 357)
    love.graphics.draw(self.zoom2, 350, 357)
    love.graphics.draw(self.zoom3, 550, 338)
    love.graphics.draw(self.saveBtn, saveBtnX, saveBtnY, -0.14)
end

return settings
