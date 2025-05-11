local Class = require('lib.hump.class')

local Entity = Class {
    init = function(self, x, y, width, height)
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    end
}

function Entity:update(self, dt)
    -- Update logic for the entity
end

function Entity:draw(self)
    -- Draw logic for the entity
end

return Entity
