local love = require('love')
local Class = require('lib.hump.class')
local Entity = require('entities.entity')
local iffy = require('lib.iffy.iffy')

local Enemy = Class {
    __includes = Entity,
    init = function(self, x, y)
        Entity.init(self, x, y, 32, 32)
        self.speed = 50

        -- Initialize sprite animation with a unique atlas name
        iffy.newAtlas("enemy_atlas", "assets/enemy.png", "assets/enemy.csv")

        -- Animation state
        self.currentAnim = "down"
        self.animTimer = 0
        self.animFrame = 1
        self.animDuration = 0.5
        self.moving = false
    end,
}

function Enemy:update(dt, world) -- Added world parameter
    Entity.update(self, dt)
    self:move(dt, world)         -- Pass world to move function

    -- Update animation timer
    if self.moving then
        self.animTimer = self.animTimer + dt
        if self.animTimer >= self.animDuration then
            self.animTimer = 0
            self.animFrame = self.animFrame % 3 + 1 -- Cycle between 1, 2, and 3
        end
    else
        self.animFrame = 1
        self.animTimer = 0
    end
end

function Enemy:move(dt, world)
    local wasMoving = self.moving
    self.moving = false

    if not self.targetPosition then
        local directions = {
            { x = 1,  y = 0,  anim = "right" },
            { x = -1, y = 0,  anim = "left" },
            { x = 0,  y = 1,  anim = "down" },
            { x = 0,  y = -1, anim = "up" }
        }

        local direction = directions[love.math.random(#directions)]
        self.targetPosition = {
            x = self.x + direction.x * self.width,
            y = self.y + direction.y * self.height
        }
        self.currentAnim = direction.anim
    end

    local dx = self.targetPosition.x - self.x
    local dy = self.targetPosition.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 0.1 then
        self.moving = true
        local moveX = (dx / distance) * self.speed * dt
        local moveY = (dy / distance) * self.speed * dt

        if math.abs(moveX) > math.abs(dx) then moveX = dx end
        if math.abs(moveY) > math.abs(dy) then moveY = dy end

        local goalX = self.x + moveX
        local goalY = self.y + moveY

        local actualX, actualY, cols = world:move(self, goalX, goalY, function(item, other)
            if other.type == 'wall' then
                return 'slide'
            end
            return nil
        end)

        self.x, self.y = actualX, actualY
        world:update(self, self.x, self.y)

        -- Check if we hit a wall or reached our target
        local hitWall = false
        for _, col in ipairs(cols) do
            if col.other.type == 'wall' then
                hitWall = true
                break
            end
        end

        -- Choose new direction if we hit a wall or reached our target
        if hitWall or (math.abs(self.x - self.targetPosition.x) < 0.1 and math.abs(self.y - self.targetPosition.y) < 0.1) then
            self.targetPosition = nil
        end
    else
        self.targetPosition = nil
    end
end

function Enemy:draw()
    local spriteName = self.currentAnim .. self.animFrame
    iffy.draw("enemy_atlas", spriteName, self.x, self.y)
    Entity.draw(self)
end

return Enemy
