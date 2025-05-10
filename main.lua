local love = require('love')
local Gamestate = require('lib.hump.gamestate')

local menu = require('states.menu')

require('map')

function love.load()
    _G.uiSelectEffect = love.audio.newSource('assets/ui-select.wav', 'static')
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

function love.update(dt)
    Gamestate.update(dt)
end

function love.draw()
    Gamestate.draw()
end

function love.keypressed(key)
    Gamestate.keypressed(key)
end

function love.keyreleased(key)
    Gamestate.keyreleased(key)
end

function love.mousepressed(x, y, button)
    Gamestate.mousepressed(x, y, button)
end