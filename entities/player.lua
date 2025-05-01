local love = require('love')
local Class = require('lib.hump.class')

local Entity = require('entities.entity')

local Player = Class {
    __includes = Entity,
    sprite = love.graphics.newImage('assets/player.png'),
    init = function(self, x, y)
        Entity.init(self, x, y, self.sprite:getWidth(), self.sprite:getHeight())
        self.speed = 100
    end,
}

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:draw()
    love.graphics.draw(self.sprite, self.x, self.y)

    Entity.draw(self)
end

return Player
