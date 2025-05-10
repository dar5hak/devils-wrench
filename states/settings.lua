local love = require('love')
local Gamestate = require('lib.hump.gamestate')

local settingsManager = require('settingsManager')

local settings = {}

function settings:init()
    self.background = love.graphics.newImage('assets/background.jpg')
    self.heading = love.graphics.newImage('assets/settings-heading.png')
    self.keySelectionBox = love.graphics.newImage('assets/key-selection-box.png')
    self.zoomSelectionBox = love.graphics.newImage('assets/zoom-selection-box.png')

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

    local keySetting = settingsManager.currentSettings.key
    local zoomSetting = settingsManager.currentSettings.zoom

    love.graphics.draw(self.keySelectionBox,
        keySetting.x + (keySetting.image:getWidth() - self.keySelectionBox:getWidth()) / 2,
        keySetting.y + (keySetting.image:getHeight() - self.keySelectionBox:getHeight()) / 2)

    love.graphics.draw(self.zoomSelectionBox,
        zoomSetting.x + (zoomSetting.image:getWidth() - self.zoomSelectionBox:getWidth()) / 2,
        zoomSetting.y +
        (zoomSetting.image:getHeight() - self.zoomSelectionBox:getHeight()) / 2)

    for _, keySetting in pairs(settingsManager.keySettings) do
        love.graphics.draw(keySetting.image, keySetting.x, keySetting.y)
    end

    for _, zoomSetting in pairs(settingsManager.zoomSettings) do
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
            uiSelectEffect:play()
            Gamestate.pop()
        end
    end

    for _, keySetting in pairs(settingsManager.keySettings) do
        if x >= keySetting.x and x <= keySetting.x + keySetting.image:getWidth() and
            y >= keySetting.y and y <= keySetting.y + keySetting.image:getHeight() then
            uiSelectEffect:play()
            settingsManager.currentSettings.key = keySetting
        end
    end

    for _, zoomSetting in pairs(settingsManager.zoomSettings) do
        if x >= zoomSetting.x and x <= zoomSetting.x + zoomSetting.image:getWidth() and
            y >= zoomSetting.y and y <= zoomSetting.y + zoomSetting.image:getHeight() then
            uiSelectEffect:play()
            settingsManager.currentSettings.zoom = zoomSetting
        end
    end
end

return settings
