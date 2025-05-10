local ProgressBar = {}
ProgressBar.__index = ProgressBar

function ProgressBar:new(x, y, width, height, color)
    return setmetatable({
        x = x, y = y,
        width = width, height = height,
        color = color or {1, 0, 1},
    }, ProgressBar)
end

function ProgressBar:update(ratio)
    self.width = 100 * ratio
    self.color = {1, 0, ratio}
end

function ProgressBar:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end

return ProgressBar
