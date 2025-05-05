local love = require('love')
local Gamestate = require('lib.hump.gamestate')

local settings = {}

function settings:init()
    self.background = love.graphics.newImage('assets/background.png')
    self.heading = love.graphics.newImage('assets/settings-heading.png')
    self.keySelectionBox = love.graphics.newImage('assets/key-selection-box.png')
    self.zoomSelectionBox = love.graphics.newImage('assets/zoom-selection-box.png')

    self.keySettings = {
        arrows = { x = 132, y = 188, image = love.graphics.newImage('assets/keys-arrows.png') },
        wasd = { x = 332, y = 188, image = love.graphics.newImage('assets/keys-wasd.png') },
        vim = { x = 532, y = 188, image = love.graphics.newImage('assets/keys-vim.png') },
    }

    self.zoomSettings = {
        zoom1 = { x = 172, y = 357, image = love.graphics.newImage('assets/zoom-1.png') },
        zoom2 = { x = 350, y = 357, image = love.graphics.newImage('assets/zoom-2.png') },
        zoom3 = { x = 550, y = 338, image = love.graphics.newImage('assets/zoom-3.png') },
    }

    self.currentSettings = {
        key = self.keySettings.arrows,
        zoom = self.zoomSettings.zoom1,
    }

    self.saveBtn = love.graphics.newImage('assets/save-btn.png')
end

function settings:enter(previous)
    -- Logic to run when entering the settings state
end

function settings:update(dt)
    -- Update logic for the settings state
end

function settings:draw()
    love.graphics.draw(self.background, 0, 0)

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local headingX = (screenWidth - self.heading:getWidth()) / 2
    local headingY = 58
    local saveBtnX = (screenWidth - self.saveBtn:getWidth()) / 2
    local saveBtnY = screenHeight - self.saveBtn:getHeight() - 40

    love.graphics.draw(self.heading, headingX, headingY)

    love.graphics.draw(self.keySelectionBox,
        self.currentSettings.key.x + (self.currentSettings.key.image:getWidth() - self.keySelectionBox:getWidth()) / 2,
        self.currentSettings.key.y + (self.currentSettings.key.image:getHeight() - self.keySelectionBox:getHeight()) / 2)
    love.graphics.draw(self.zoomSelectionBox,
        self.currentSettings.zoom.x + (self.currentSettings.zoom.image:getWidth() - self.zoomSelectionBox:getWidth()) / 2,
        self.currentSettings.zoom.y + (self.currentSettings.zoom.image:getHeight() - self.zoomSelectionBox:getHeight()) / 2)

    for _, keySetting in pairs(self.keySettings) do
        love.graphics.draw(keySetting.image, keySetting.x, keySetting.y)
    end

    for _, zoomSetting in pairs(self.zoomSettings) do
        love.graphics.draw(zoomSetting.image, zoomSetting.x, zoomSetting.y)
    end


    love.graphics.draw(self.saveBtn, saveBtnX, saveBtnY, -0.14)
end

function settings:mousepressed(x, y, button)
    if button == 1 then
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local saveBtnX = (screenWidth - self.saveBtn:getWidth()) / 2
        local saveBtnY = screenHeight - self.saveBtn:getHeight() - 40

        if x >= saveBtnX and x <= saveBtnX + self.saveBtn:getWidth() and
            y >= saveBtnY and y <= saveBtnY + self.saveBtn:getHeight() then
            Gamestate.pop()
        end
    end

    for _, keySetting in pairs(self.keySettings) do
        if x >= keySetting.x and x <= keySetting.x + keySetting.image:getWidth() and
            y >= keySetting.y and y <= keySetting.y + keySetting.image:getHeight() then
            self.currentSettings.key = keySetting
        end
    end

    for _, zoomSetting in pairs(self.zoomSettings) do
        if x >= zoomSetting.x and x <= zoomSetting.x + zoomSetting.image:getWidth() and
            y >= zoomSetting.y and y <= zoomSetting.y + zoomSetting.image:getHeight() then
            self.currentSettings.zoom = zoomSetting
        end
    end
end

return settings
