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

        -- Initialize sprite animation with a unique atlas name
        iffy.newAtlas("player_atlas", "assets/player.png", "assets/player.csv")

        -- Animation state
        self.currentAnim = "down"
        self.animTimer = 0
        self.animFrame = 1
        self.animDuration = 0.5 -- Switch frames every 0.5 seconds
        self.moving = false

        -- Add a lives property to the Player class
        self.lives = 3

        -- Add properties to track invulnerability, its timer, and visibility for blinking effect
        self.invulnerable = false
        self.invulnerabilityTimer = 0
        self.blinkTimer = 0
        self.visible = true
    end,
}

function Player:update(dt)
    Entity.update(self, dt)

    -- Handle invulnerability logic
    if self.invulnerable then
        self.invulnerabilityTimer = self.invulnerabilityTimer - dt

        -- Player blinks every 0.25 seconds during the entire invulnerability period
        self.blinkTimer = self.blinkTimer - dt
        if self.blinkTimer <= 0 then
            self.visible = not self.visible
            self.blinkTimer = 0.25 -- Toggle visibility every 0.25 seconds
        end

        if self.invulnerabilityTimer <= 0 then
            self.invulnerable = false
            self.visible = true -- Ensure player is visible after invulnerability ends
        end
    end

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
    if self.visible then
        local spriteName = self.currentAnim .. self.animFrame
        iffy.draw("player_atlas", spriteName, self.x, self.y)
    end
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

    -- Allow a margin of error while turning and track if we're near a wall
    local nearWall = false
    for _, col in ipairs(cols) do
        if col.other.type == 'wall' then
            nearWall = true
            if math.abs(col.touch.x - goalX) <= 8 then
                actualX = col.touch.x
            elseif math.abs(col.touch.y - goalY) <= 8 then
                actualY = col.touch.y
            end
        elseif col.other.type == 'enemy' then
            -- Allow some overlap before triggering collision
            local ex, ey, ew, eh = world:getRect(col.other)
            local px, py, pw, ph = world:getRect(self)
            if ex + 8 < px + pw - 8 and ex + ew - 8 > px + 8 and ey + 8 < py + ph - 8 and ey + eh - 8 > py + 8 then
                return false -- Collision with enemy
            end
        end
    end

    -- Only snap to grid when near walls and attempting to turn
    if nearWall then
        -- Check if trying to turn (pressing a perpendicular direction)
        local verticalMove = love.keyboard.isDown(upKey) or love.keyboard.isDown(downKey)
        local horizontalMove = love.keyboard.isDown(leftKey) or love.keyboard.isDown(rightKey)

        if verticalMove then
            -- Only snap X when we're close to a grid line
            local gridX = math.floor((actualX + self.width / 2) / self.width) * self.width
            if math.abs(actualX - gridX) <= 8 then
                actualX = gridX
            end
        elseif horizontalMove then
            -- Only snap Y when we're close to a grid line
            local gridY = math.floor((actualY + self.height / 2) / self.height) * self.height
            if math.abs(actualY - gridY) <= 8 then
                actualY = gridY
            end
        end
    end

    self.x, self.y = actualX, actualY
    return true -- No collision with enemy
end

return Player
