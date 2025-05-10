local Toast = {}
Toast.__index = Toast

function Toast:new(font, duration)
    return setmetatable({
        message = nil,
        timer = 0,
        duration = duration or 5,
        font = font or love.graphics.newFont(24),
    }, Toast)
end

function Toast:show(message)
    self.message = message
    self.timer = self.duration
end

function Toast:update(dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self.message = nil
        end
    end
end

function Toast:draw()
    if self.message then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", love.graphics.getWidth() - 300, love.graphics.getHeight() - 80, 280, 60)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(self.font)
        love.graphics.printf(self.message, love.graphics.getWidth() - 300, love.graphics.getHeight() - 64, 280, "center")
    end
end

return Toast
