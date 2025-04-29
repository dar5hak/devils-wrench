local love = require('love')
local Gamestate = require('lib.hump.gamestate')

local menu = require('states.menu')
local game = require('states.game')
local gameover = require('states.gameover')
local settings = require('states.settings')
local credits = require('states.credits')
local pause = require('states.pause')

function love.load()
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

function love.quit()
    -- Cleanup code here
end
