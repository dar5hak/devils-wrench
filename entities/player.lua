local love = require('love')
local Class = require('lib.hump.class')
local Entity = require('entities.entity')
local settingsManager = require('settingsManager')
local iffy = require('lib.iffy.iffy')

local Player = Class {
    __includes = Entity,
    init = function(self, x, y)
        Entity.init(self, x, y, 32, 32)
        self.speed = 100

        -- Initialize sprite animation
        iffy.newAtlas("assets/player.png")

        -- Animation state
        self.currentAnim = "down"
        self.animTimer = 0
        self.animFrame = 1
        self.animDuration = 0.5 -- Switch frames every 0.5 seconds
        self.moving = false
    end,
}

function Player:update(dt)
    Entity.update(self, dt)

    -- Update animation timer
    if self.moving then
        self.animTimer = self.animTimer + dt
        if self.animTimer >= self.animDuration then
            self.animTimer = 0
            self.animFrame = self.animFrame == 1 and 2 or 1
        end
    else
        self.animFrame = 1
        self.animTimer = 0
    end
end

function Player:draw()
    local spriteName = self.currentAnim .. self.animFrame
    iffy.drawSprite(spriteName, self.x, self.y)
    Entity.draw(self)
end

function Player:move(goalX, goalY, dt, world)
    -- Reset moving state
    self.moving = false

    -- Only allow one direction at a time
    local upKey = settingsManager.currentSettings.key.up
    local downKey = settingsManager.currentSettings.key.down
    local leftKey = settingsManager.currentSettings.key.left
    local rightKey = settingsManager.currentSettings.key.right

    -- Update animation direction based on pressed key
    if love.keyboard.isDown(upKey) and not (love.keyboard.isDown(leftKey) or love.keyboard.isDown(rightKey)) then
        self.currentAnim = "up"
        self.moving = true
    elseif love.keyboard.isDown(downKey) and not (love.keyboard.isDown(leftKey) or love.keyboard.isDown(rightKey)) then
        self.currentAnim = "down"
        self.moving = true
    elseif love.keyboard.isDown(leftKey) and not (love.keyboard.isDown(upKey) or love.keyboard.isDown(downKey)) then
        self.currentAnim = "left"
        self.moving = true
    elseif love.keyboard.isDown(rightKey) and not (love.keyboard.isDown(upKey) or love.keyboard.isDown(downKey)) then
        self.currentAnim = "right"
        self.moving = true
    end

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
    if love.keyboard.isDown(upKey) or love.keyboard.isDown(downKey) then
        actualX = math.floor((actualX + self.width / 2) / self.width) * self.width
    elseif love.keyboard.isDown(leftKey) or love.keyboard.isDown(rightKey) then
        actualY = math.floor((actualY + self.height / 2) / self.height) * self.height
    end

    self.x, self.y = actualX, actualY
    return true -- No collision with enemy
end

return Player
