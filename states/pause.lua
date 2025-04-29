local pause = {}

function pause:init()
    -- Initialization logic for the pause state
end

function pause:enter(from)
    self.from = from -- Record the previous state
end

function pause:draw()
    -- Draw the previous state
    self.from:draw()

    -- Overlay with pause message
    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf('PAUSED', 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), 'center')
end

function pause:keypressed(key)
    if key == 'p' then
        Gamestate.pop()
    end
end

return pause