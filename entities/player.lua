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

function Player:move(goalX, goalY, dt, world)
    local actualX, actualY, cols = world:move(self, goalX, goalY, function(item, other)
        if other.type == 'wall' then
            return 'slide'
        end
        return nil
    end)

    -- Allow a margin of error while turning
    for _, col in ipairs(cols) do
        if col.other.type == 'wall' then
            if math.abs(col.touch.x - goalX) <= 6 then
                actualX = col.touch.x
            elseif math.abs(col.touch.y - goalY) <= 6 then
                actualY = col.touch.y
            end
        elseif col.other.type == 'enemy' then
            return false -- Collision with enemy
        end
    end

    -- Snap player to grid for smoother movement
    local tileWidth, tileHeight = self.sprite:getDimensions()
    if love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        actualX = math.floor((actualX + tileWidth / 2) / tileWidth) * tileWidth
    elseif love.keyboard.isDown('left') or love.keyboard.isDown('right') then
        actualY = math.floor((actualY + tileHeight / 2) / tileHeight) * tileHeight
    end

    self.x, self.y = actualX, actualY
    return true -- No collision with enemy
end

return Player
