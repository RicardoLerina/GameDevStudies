-- StartState: title screen. Shows a random board in the background, an
-- animated rainbow "MATCH 3" logo and a Start / Quit Game menu.

-- Random tile quads used for the decorative background board.
local positions = {}

StartState = Class{__includes = BaseState}

function StartState:init()
    -- 1 = Start, 2 = Quit Game.
    self.currentMenuItem = 1

    -- Palette for the logo letters; rotated every tick to make them cycle.
    self.colors = {
        [1] = {217/255, 87/255, 99/255, 1},
        [2] = {95/255, 205/255, 228/255, 1},
        [3] = {251/255, 242/255, 54/255, 1},
        [4] = {118/255, 66/255, 138/255, 1},
        [5] = {153/255, 229/255, 80/255, 1},
        [6] = {223/255, 113/255, 38/255, 1}
    }

    -- Each letter of the logo and its horizontal offset from the center.
    self.letterTable = {
        {'M', -108},
        {'A', -64},
        {'T', -28},
        {'C', 2},
        {'H', 40},
        {'3', 112}
    }

    -- Shift every color one slot forward; slot 0 is a temporary holder so
    -- the last color wraps around to the first.
    self.colorTimer = Timer.every(0.075, function()
        self.colors[0] = self.colors[6]

        for i = 6, 1, -1 do
            self.colors[i] = self.colors[i - 1]
        end
    end)

    for i = 1, 64 do
        table.insert(positions, gFrames['tiles'][math.random(18)][math.random(6)])
    end

    -- White overlay used to fade out when the game starts.
    self.transitionAlpha = 0

    -- Blocks menu input while the fade-out is running.
    self.pauseInput = false
end

function StartState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if not self.pauseInput then
        -- Only two options, so up and down both just toggle.
        if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
            self.currentMenuItem = self.currentMenuItem == 1 and 2 or 1
            gSounds['select']:play()
        end

        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            if self.currentMenuItem == 1 then
                Timer.tween(1, {
                    [self] = {transitionAlpha = 1}
                }):finish(function()
                    gStateMachine:change('begin-game', {
                        level = 1
                    })

                    -- Stop the logo animation; it would keep running in the
                    -- global Timer after this state is gone.
                    self.colorTimer:remove()
                end)
            else
                love.event.quit()
            end

            self.pauseInput = true
        end
    end

    Timer.update(dt)
end

function StartState:render()
    -- Background board, each tile with a black shadow.
    for y = 1, 8 do
        for x = 1, 8 do
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x],
                (x - 1) * 32 + 128 + 3, (y - 1) * 32 + 16 + 3)

            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x],
                (x - 1) * 32 + 128, (y - 1) * 32 + 16)
        end
    end

    -- Darken the board so the logo and menu stand out.
    love.graphics.setColor(0, 0, 0, 128/255)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    self:drawMatch3Text(-60)
    self:drawOptions(12)

    love.graphics.setColor(1, 1, 1, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draws the logo; y is an offset from the vertical center of the screen.
function StartState:drawMatch3Text(y)
    love.graphics.setColor(1, 1, 1, 128/255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y - 11, 150, 58, 6)

    love.graphics.setFont(gFonts['large'])
    self:drawTextShadow('MATCH 3', VIRTUAL_HEIGHT / 2 + y)

    -- Each letter is printed centered within a width shifted by its offset,
    -- which places it at the right spot over the shadow text.
    for i = 1, 6 do
        love.graphics.setColor(self.colors[i])
        love.graphics.printf(self.letterTable[i][1], 0, VIRTUAL_HEIGHT / 2 + y,
            VIRTUAL_WIDTH + self.letterTable[i][2], 'center')
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Draws the menu; the selected option is shown in a brighter blue.
function StartState:drawOptions(y)
    love.graphics.setColor(1, 1, 1, 128/255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y, 150, 58, 6)

    love.graphics.setFont(gFonts['medium'])
    self:drawTextShadow('Start', VIRTUAL_HEIGHT / 2 + y + 8)

    if self.currentMenuItem == 1 then
        love.graphics.setColor(99/255, 155/255, 1, 1)
    else
        love.graphics.setColor(48/255, 96/255, 130/255, 1)
    end

    love.graphics.printf('Start', 0, VIRTUAL_HEIGHT / 2 + y + 8, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    self:drawTextShadow('Quit Game', VIRTUAL_HEIGHT / 2 + y + 33)

    if self.currentMenuItem == 2 then
        love.graphics.setColor(99/255, 155/255, 1, 1)
    else
        love.graphics.setColor(48/255, 96/255, 130/255, 1)
    end

    love.graphics.printf('Quit Game', 0, VIRTUAL_HEIGHT / 2 + y + 33, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(1, 1, 1, 1)
end

-- Fakes a thick shadow by printing the text several times with small
-- offsets in a dark color.
function StartState:drawTextShadow(text, y)
    love.graphics.setColor(34/255, 32/255, 52/255, 1)
    love.graphics.printf(text, 2, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 0, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 2, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)
end
