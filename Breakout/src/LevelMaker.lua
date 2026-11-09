-- Layout patterns. These are not used by createMap yet, and NONE is assigned
-- twice, so it ends up as 4.
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

SOLID = 1
ALTERNATE = 2
SKIP = 3
NONE = 4

LevelMaker = Class{}

function LevelMaker.createMap(level)
    local bricks = {}

    local numRows = math.random(1, 5)

    -- An odd column count keeps the layout symmetric around the center.
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    -- Difficulty grows with the level: a new tier unlocks every 5 levels
    -- (capped at 3), and the available colors cycle within each tier.
    local highestTier = math.min(3, math.floor(level / 5))
    local highestColor = math.min(5, level % 5 + 3)

    for y = 1, numRows do
        -- Each row randomly decides whether it skips every other brick and
        -- whether it alternates between two colors.
        local skipPattern = math.random(1, 2) == 1 and true or false
        local alternatePattern = math.random(1, 2) == 1 and true or false

        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)

        -- Random starting values, so a pattern can begin on either the first
        -- or the second brick of the row.
        local skipFlag = math.random(2) == 1 and true or false
        local alternateFlag = math.random(2) == 1 and true or false

        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)

        for x = 1, numCols do
            if skipPattern and skipFlag then
                skipFlag = not skipFlag

                -- Lua has no continue statement, so goto jumps to the end of
                -- the loop body instead.
                goto continue
            else
                skipFlag = not skipFlag
            end

            b = Brick(
                -- Columns start at 0 on screen, each brick is 32px wide, there
                -- is an 8px margin, and shorter rows get extra left padding
                -- so they stay centered.
                (x-1)
                * 32
                + 8
                + (13 - numCols) * 16,

                -- Starting at y * 16 leaves one brick height of space at the top.
                y * 16
            )

            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end

            table.insert(bricks, b)

            ::continue::
        end
    end

    -- An empty level would be won instantly, so generate a new one.
    if #bricks == 0 then
        return LevelMaker.createMap(level)
    else
        return bricks
    end
end
