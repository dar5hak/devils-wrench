local keySettings = {
    arrows = { x = 132, y = 188, image = love.graphics.newImage('assets/keys-arrows.png'), up = 'up', down = 'down', left = 'left', right = 'right' },
    wasd = { x = 332, y = 188, image = love.graphics.newImage('assets/keys-wasd.png'), up = 'w', down = 's', left = 'a', right = 'd' },
    vim = { x = 532, y = 188, image = love.graphics.newImage('assets/keys-vim.png'), up = 'k', down = 'j', left = 'h', right = 'l' },
}

local zoomSettings = {
    zoom1 = { x = 172, y = 357, image = love.graphics.newImage('assets/zoom-1.png'), scale = 1 },
    zoom2 = { x = 350, y = 357, image = love.graphics.newImage('assets/zoom-2.png'), scale = 1.5 },
    zoom3 = { x = 550, y = 338, image = love.graphics.newImage('assets/zoom-3.png'), scale = 2 },
}

local currentSettings = {
    key = keySettings.arrows,
    zoom = zoomSettings.zoom1,
}

local function randomizeSettings()
    local newKey, newZoom

    local keyOptions = { 'arrows', 'wasd', 'vim' }
    repeat
        newKey = keySettings[keyOptions[love.math.random(#keyOptions)]]
    until newKey ~= currentSettings.key
    currentSettings.key = newKey

    local zoomOptions = { 'zoom1', 'zoom2', 'zoom3' }
    repeat
        newZoom = zoomSettings[zoomOptions[love.math.random(#zoomOptions)]]
    until newZoom ~= currentSettings.zoom
    currentSettings.zoom = newZoom
end

return {
    keySettings = keySettings,
    zoomSettings = zoomSettings,
    currentSettings = currentSettings,
    randomizeSettings = randomizeSettings,
}
