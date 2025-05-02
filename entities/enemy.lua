local love = require('love')
local Class = require('lib.hump.class')

local Entity = require('entities.entity')

local Enemy = Class {
    __includes = Entity,
    sprite = love.graphics.newImage('assets/enemy.png'),
    init = function(self, x, y)
        Entity.init(self, x, y, self.sprite:getWidth(), self.sprite:getHeight())
        self.speed = 50
    end,
}

function Enemy:update(dt)
    Entity.update(self, dt)
    self:move(dt)
end

function Enemy:move(dt, world)
    if not self.targetPosition then
        local directions = {
            { x = 1,  y = 0 }, -- Right
            { x = -1, y = 0 }, -- Left
            { x = 0,  y = 1 }, -- Down
            { x = 0,  y = -1 } -- Up
        }

        local direction = directions[love.math.random(#directions)]
        self.targetPosition = {
            x = self.x + direction.x * self.width,
            y = self.y + direction.y * self.height
        }
    end

    local dx = self.targetPosition.x - self.x
    local dy = self.targetPosition.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 0 then
        local moveX = (dx / distance) * self.speed * dt
        local moveY = (dy / distance) * self.speed * dt

        if math.abs(moveX) > math.abs(dx) then moveX = dx end
        if math.abs(moveY) > math.abs(dy) then moveY = dy end

        self.x = self.x + moveX
        self.y = self.y + moveY

        if self.x == self.targetPosition.x and self.y == self.targetPosition.y then
            self.targetPosition = nil
        end
    end

    world:update(self, self.x, self.y)
end

function Enemy:draw()
    love.graphics.draw(self.sprite, self.x, self.y)

    Entity.draw(self)
end

return Enemy
