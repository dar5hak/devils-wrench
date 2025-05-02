local love = require('love')
local Class = require('lib.hump.class')

local Entity = require('entities.entity')

local Portal = Class {
    __includes = Entity,
    sprite = love.graphics.newImage('assets/portal.png'),
    init = function(self, x, y)
        Entity.init(self, x, y, self.sprite:getWidth(), self.sprite:getHeight())
        self.type = 'portal'
    end,
}

function Portal:draw()
    love.graphics.draw(self.sprite, self.x, self.y)
    Entity.draw(self)
end

return Portal
