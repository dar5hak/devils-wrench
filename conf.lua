function love.conf(t)
    t.window.title = "The Devil’s Wrench"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
    t.window.fullscreen = false

    t.releases = {
        title = "The Devil’s Wrench",
        package = "the-devils-wrench",
        identifier = "io.itch.weredroid.thedevilswrench",
        loveVersion = "11.5",
        version = "1.0",
        author = "Weredroid",
        email = "darshak@proton.me",
        homepage = "https://weredroid.itch.io/the-devils-wrench",
        description = "A plain old dungeon crawler… or is it?",
        releaseDirectory = "build",
    }
end