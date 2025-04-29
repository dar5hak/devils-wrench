local love = require('love')

function love.conf(t)
    t.window.title = "Devil’s Wrench"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
    t.window.fullscreen = false
end