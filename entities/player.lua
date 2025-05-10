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

        iffy.newAtlas("player_atlas", "assets/player.png", "assets/player.csv")

        self.currentAnim = "down"
        self.animTimer = 0
        self.animFrame = 1
        self.animDuration = 0.5
        self.moving = false

        self.lives = 3

        self.invulnerable = false
        self.invulnerabilityTimer = 0
        self.blinkTimer = 0
        self.visible = true
    end,
}

function Player:update(dt)
    Entity.update(self, dt)

    if self.invulnerable then
        self.invulnerabilityTimer = self.invulnerabilityTimer - dt

        self.blinkTimer = self.blinkTimer - dt
        if self.blinkTimer <= 0 then
            self.visible = not self.visible
            self.blinkTimer = 0.25
        end

        if self.invulnerabilityTimer <= 0 then
            self.invulnerable = false
            self.visible = true
        end
    end

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
    self.moving = false

    local upKey = settingsManager.currentSettings.key.up
    local downKey = settingsManager.currentSettings.key.down
    local leftKey = settingsManager.currentSettings.key.left
    local rightKey = settingsManager.currentSettings.key.right

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
            local ex, ey, ew, eh = world:getRect(col.other)
            local px, py, pw, ph = world:getRect(self)
            if ex + 8 < px + pw - 8 and ex + ew - 8 > px + 8 and ey + 8 < py + ph - 8 and ey + eh - 8 > py + 8 then
                return false
            end
        end
    end

    if nearWall then
        local verticalMove = love.keyboard.isDown(upKey) or love.keyboard.isDown(downKey)
        local horizontalMove = love.keyboard.isDown(leftKey) or love.keyboard.isDown(rightKey)

        if verticalMove then
            local gridX = math.floor((actualX + self.width / 2) / self.width) * self.width
            if math.abs(actualX - gridX) <= 8 then
                actualX = gridX
            end
        elseif horizontalMove then
            local gridY = math.floor((actualY + self.height / 2) / self.height) * self.height
            if math.abs(actualY - gridY) <= 8 then
                actualY = gridY
            end
        end
    end

    self.x, self.y = actualX, actualY
    return true
end

return Player
