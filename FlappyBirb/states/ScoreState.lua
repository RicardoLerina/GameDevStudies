ScoreState = Class{__includes = BaseState}

-- Receives the final score through the params PlayState passes to
-- gStateMachine:change('score', { score = ... }).
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- 'return' is the key name LÖVE uses for Enter on most keyboards.
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')
end
