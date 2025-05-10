local love = require('love')
local Class = require('lib.hump.class')
local Entity = require('entities.entity')
local iffy = require('lib.iffy.iffy')

local Portal = Class {
    __includes = Entity,
    init = function(self, x, y)
        Entity.init(self, x, y, 32, 32)
        self.type = 'portal'

        iffy.newAtlas("portal_atlas", "assets/portal.png", "assets/portal.csv")

        self.animTimer = 0
        self.animFrame = 1
        self.animDuration = 0.25
    end,
}

function Portal:update(dt)
    Entity.update(self, dt)

    self.animTimer = self.animTimer + dt
    if self.animTimer >= self.animDuration then
        self.animTimer = 0
        self.animFrame = self.animFrame % 4 + 1 -- Cycle between 1, 2, 3, and 4
    end
end

function Portal:draw()
    local spriteName = "portal" .. self.animFrame
    iffy.draw("portal_atlas", spriteName, self.x, self.y)
    Entity.draw(self)
end

return Portal
