StartState = Class{__includes = BaseState}

-- Selected menu option: 1 = Start, 2 = High Scores. As a file-level local it
-- is remembered when coming back to this screen.
local highlighted = 1

function StartState:enter(params)
    self.highScores = params.highScores
end

function StartState:update(dt)
    -- With only two options, up and down both just toggle the selection.
    if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
        highlighted = highlighted == 1 and 2 or 1
        gSounds['paddle-hit']:play()
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['confirm']:play()

        if highlighted == 1 then
            gStateMachine:change('paddle-select', {
                highScores = self.highScores
            })
        else
            gStateMachine:change('high-scores', {
                highScores = self.highScores
            })
        end
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function StartState:render()
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('BREAKOUT', 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])

    -- The selected option is drawn in cyan, then the color is reset to white.
    if highlighted == 1 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf('START', 0, VIRTUAL_HEIGHT / 2 + 70,
        VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(1, 1, 1, 1)

    if highlighted == 2 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf('HIGH SCORES', 0, VIRTUAL_HEIGHT / 2 + 90,
        VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(1, 1, 1, 1)
end
