-- BeginGameState: short intro before each level. Fades in from white,
-- slides a "Level N" banner across the screen, then hands the freshly
-- generated board over to PlayState.

BeginGameState = Class{__includes = BaseState}

function BeginGameState:init()
    -- Opacity of the white overlay; starts fully white and fades out.
    self.transitionAlpha = 1

    -- Built here so the player can see the board behind the banner.
    self.board = Board(VIRTUAL_WIDTH - 272, 16)

    -- Banner starts above the screen.
    self.levelLabelY = -64
end

function BeginGameState:enter(def)
    self.level = def.level

    -- Chain of animations: fade in -> banner down -> wait -> banner out -> play.
    Timer.tween(1, {
        [self] = {transitionAlpha = 0}
    })

    :finish(function()
        Timer.tween(0.25, {
            [self] = {levelLabelY = VIRTUAL_HEIGHT / 2 - 8}
        })

        :finish(function()
            Timer.after(1, function()
                Timer.tween(0.25, {
                    [self] = {levelLabelY = VIRTUAL_HEIGHT + 30}
                })

                :finish(function()
                    gStateMachine:change('play', {
                        level = self.level,
                        board = self.board
                    })
                end)
            end)
        end)
    end)
end

function BeginGameState:update(dt)
    Timer.update(dt)
end

function BeginGameState:render()
    self.board:render()

    -- Translucent banner with the level number.
    love.graphics.setColor(95/255, 205/255, 228/255, 200/255)
    love.graphics.rectangle('fill', 0, self.levelLabelY - 8, VIRTUAL_WIDTH, 48)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level),
        0, self.levelLabelY, VIRTUAL_WIDTH, 'center')

    -- White fade overlay drawn on top of everything.
    love.graphics.setColor(1, 1, 1, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
end
