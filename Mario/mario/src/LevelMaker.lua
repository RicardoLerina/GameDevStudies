-- LevelMaker: procedurally generates a level column by column.

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    for x = 1, height do
        table.insert(tiles, {})
    end

    for x = 1, width do
        local tileID = TILE_ID_EMPTY

        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- 1 in 7 columns is a pit.
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- Row where a jump block may spawn; pillars raise it.
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            if math.random(8) == 1 then
                blockHeight = 2

                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,

                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end

                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil

            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- 1 in 10 ground columns gets a jump block.
            if math.random(10) == 1 then
                table.insert(objects,

                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- Called when the player bumps the block from below.
                        onCollide = function(obj)

                            if not obj.hit then

                                -- Only 1 in 5 first hits reveals a gem; the block is spent either way.
                                if math.random(5) == 1 then

                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }

                                    -- Gem pops out of the block.
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            -- Bounce up and back down so every hit gives visible feedback.
                            local restY = (blockHeight - 1) * TILE_SIZE
                            Timer.tween(0.07, {
                                [obj] = {y = restY - 4}
                            }):finish(function()
                                Timer.tween(0.07, {
                                    [obj] = {y = restY}
                                })
                            end)

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end
