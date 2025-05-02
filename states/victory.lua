local love = require('love')

local victory = {}

function victory:init()
    -- Initialization logic for the victory state
end

function victory:enter(previous)
    -- Logic to run when entering the victory state
end

function victory:update(dt)
    -- Update logic for the victory state
end

function victory:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf('VICTORY!', 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), 'center')
end

function victory:keypressed(key)
    if key == 'return' then
        love.event.quit()
    end
end

return victory
