local helpers = {}

function helpers.isTileFarFromPlayer(tile, player, tileWidth, tileHeight, minDistance)
    local playerTileX = math.floor(player.x / tileWidth) + 1
    local playerTileY = math.floor(player.y / tileHeight) + 1
    return math.abs(tile.x - playerTileX) > minDistance or math.abs(tile.y - playerTileY) > minDistance
end

return helpers
