local Gamestate = require('lib.hump.gamestate')
local game = require('states.game')

local level = {}

function level:enter(previous, levelNumber)
    self.levelNumber = levelNumber
    self.timer = 2
    self.font = love.graphics.newFont('assets/MetalMania-Regular.ttf', 72)
end

function level:update(dt)
    self.timer = self.timer - dt
    if self.timer <= 0 then
        Gamestate.switch(game, self.levelNumber)
    end
end

function level:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1, 1)
    local text = string.format("Level %d", self.levelNumber)
    local textW = self.font:getWidth(text)
    local textH = self.font:getHeight()
    love.graphics.print(text,
        love.graphics.getWidth() / 2 - textW / 2,
        love.graphics.getHeight() / 2 - textH / 2)
end

return level
