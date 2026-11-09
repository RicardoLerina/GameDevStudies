--[[
push.lua v1.0

The MIT License (MIT)

Copyright (c) 2018 Ulysse Ramage

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

-- push: renders the game at a fixed virtual resolution and scales it to
-- fit any window size, adding letterbox bars to keep the aspect ratio.

-- Options passed to setupScreen (upscale mode, canvas usage).
local settings

-- Virtual (game) size and real (window) size.
local pushWidth, pushHeight
local windowWidth, windowHeight

-- How much to scale and where to place the game inside the window.
local scale = {x = 0, y = 0}
local offset = {x = 0, y = 0}

-- Size of the area actually covered by the game, in window pixels.
local drawWidth, drawHeight

-- Off-screen canvases, only used when settings.canvas is true.
local canvases

local canvasOptions

-- Recomputes scale and offset from the current window size.
local function initValues()
	if settings.upscale then
		scale.x = windowWidth / pushWidth
		scale.y = windowHeight / pushHeight

		-- "normal" keeps the aspect ratio; "pixel-perfect" also rounds the
		-- scale down to a whole number so pixels stay square.
		if settings.upscale == "normal" or settings.upscale == "pixel-perfect" then
			local scaleVal

			scaleVal = math.min(scale.x, scale.y)
			if scaleVal >= 1 and settings.upscale == "pixel-perfect" then scaleVal = math.floor(scaleVal) end

			offset.x = math.floor((scale.x - scaleVal) * (pushWidth / 2))
			offset.y = math.floor((scale.y - scaleVal) * (pushHeight / 2))

			scale.x, scale.y = scaleVal, scaleVal
		-- "stretched" fills the whole window and may distort the image.
		elseif settings.upscale == "stretched" then
			offset.x, offset.y = 0, 0
		else
			error("Invalid upscale setting")
		end
	else
		-- No upscaling: draw at 1:1 and just center the game.
		scale.x, scale.y = 1, 1

		offset.x = math.floor((windowWidth / pushWidth - 1) * (pushWidth / 2))
		offset.y = math.floor((windowHeight / pushHeight - 1) * (pushHeight / 2))
	end

	drawWidth = windowWidth - offset.x * 2
	drawHeight = windowHeight - offset.y * 2
end

-- Creates one canvas per entry plus a private "_render" canvas used
-- to compose the final image.
local function setupCanvas(canvasTable)
	table.insert(canvasTable, {name = "_render", private = true})

	canvases = {}

	for i = 1, #canvasTable do
		local params = canvasTable[i]

		table.insert(
			canvases,
			{
				name = params.name,
				private = params.private,
				shader = params.shader,
				canvas = love.graphics.newCanvas(pushWidth, pushHeight),
				stencil = params.stencil
			}
		)
	end

	canvasOptions = {canvases[1].canvas, stencil = canvases[1].stencil}
end

-- Finds a canvas entry by name.
local function getCanvasTable(name)
	for i = 1, #canvases do
		if canvases[i].name == name then
			return canvases[i]
		end
	end
end

-- Call at the start of love.draw: everything drawn until finish() is
-- in virtual coordinates.
local function start()
	if settings.canvas then
		love.graphics.push()
		love.graphics.setCanvas(canvasOptions)
	else
		love.graphics.translate(offset.x, offset.y)
		love.graphics.setScissor(offset.x, offset.y, pushWidth * scale.x, pushHeight * scale.y)
		love.graphics.push()
		love.graphics.scale(scale.x, scale.y)
	end
end

-- Draws a canvas through a list of shaders. With more than one shader
-- it ping-pongs between two canvases, feeding each pass into the next.
local function applyShaders(canvas, shaders)
	local shader = love.graphics.getShader()

	if #shaders <= 1 then
		love.graphics.setShader(shaders[1])
		love.graphics.draw(canvas)
	else
		local canvas = love.graphics.getCanvas()
		local tmp = getCanvasTable("_tmp")
		local outputCanvas
		local inputCanvas

		if not tmp then
			table.insert(
				canvases,
				{
			 		name = "_tmp",
			  		private = true,
			  		canvas = love.graphics.newCanvas(pushWidth, pushHeight)
		   		}
	   		)

			tmp = getCanvasTable("_tmp")
		end

		love.graphics.push()
		love.graphics.origin()
		for i = 1, #shaders do
			inputCanvas = i % 2 == 1 and canvas or tmp.canvas
			outputCanvas = i % 2 == 0 and canvas or tmp.canvas
			love.graphics.setCanvas(outputCanvas)
			love.graphics.clear()
			love.graphics.setShader(shaders[i])
			love.graphics.draw(inputCanvas)
			love.graphics.setCanvas(inputCanvas)
		end
		love.graphics.pop()

		love.graphics.setCanvas(canvas)
		love.graphics.draw(outputCanvas)
	end

	love.graphics.setShader(shader)
end

-- Call at the end of love.draw to restore the graphics state and, in
-- canvas mode, draw the composed image to the screen.
local function finish(shader)
	if settings.canvas then
		local render = getCanvasTable("_render")

		love.graphics.pop()

		love.graphics.setCanvas(render.canvas)

		for i = 1, #canvases do
			local canvasTable = canvases[i]

			if not canvasTable.private then
				local shader = canvasTable.shader

				applyShaders(canvasTable.canvas, type(shader) == "table" and shader or {shader})
			end
		end
		love.graphics.setCanvas()

		love.graphics.translate(offset.x, offset.y)
		love.graphics.push()
		love.graphics.scale(scale.x, scale.y)
		do
			local shader = shader or render.shader

			applyShaders(render.canvas, type(shader) == "table" and shader or {shader})
		end
		love.graphics.pop()

		for i = 1, #canvases do
			love.graphics.setCanvas(canvases[i].canvas)
			love.graphics.clear()
		end

		love.graphics.setCanvas()
		love.graphics.setShader()
	else
		love.graphics.pop()
		love.graphics.setScissor()
	end
end

-- Public API.
return {
	-- Must be called once in love.load with the virtual size.
	setupScreen = function(width, height, settingsTable)
		pushWidth, pushHeight = width, height
		windowWidth, windowHeight = love.graphics.getDimensions()

		settings = settingsTable

		initValues()

		if settings.canvas then
			setupCanvas({"default"})
		end
	end,

	setupCanvas = setupCanvas,
	-- Redirects drawing to a named canvas (canvas mode only).
	setCanvas = function(name)
		local canvasTable

		if not settings.canvas then return true end

		canvasTable = getCanvasTable(name)
		return love.graphics.setCanvas({canvasTable.canvas, stencil = canvasTable.stencil})
	end,
	-- Without a name, sets the shader used for the final image.
	setShader = function(name, shader)
		if not shader then
			getCanvasTable("_render").shader = name
		else
			getCanvasTable(name).shader = shader
		end
	end,

	updateSettings = function(settingsTable)
		settings.upscale = settingsTable.upscale or settings.upscale
		settings.canvas = settingsTable.canvas or settings.canvas
	end,

	-- Converts window coordinates (e.g. the mouse) to virtual coordinates.
	-- Returns false for an axis that falls outside the game area.
	toGame = function(x, y)
		local normalX, normalY

		x, y = x - offset.x, y - offset.y
		normalX, normalY = x / drawWidth, y / drawHeight

		x = (x >= 0 and x <= pushWidth * scale.x) and math.floor(normalX * pushWidth) or false
		y = (y >= 0 and y <= pushHeight * scale.y) and math.floor(normalY * pushHeight) or false

		return x, y
	end,
	-- Converts virtual coordinates back to window coordinates.
	toReal = function(x, y)
		local realX = offset.x + (drawWidth * x) / pushWidth
		local realY = offset.y + (drawHeight * y)/ pushHeight

		return realX, realY
	end,

	start = start,
	finish = finish,

	-- Forward love.resize here so scaling follows the window.
	resize = function(width, height)
		windowWidth, windowHeight = width, height

		initValues()
	end,

	getWidth = function() return pushWidth end,
	getHeight = function() return pushHeight end,
	getDimensions = function() return pushWidth, pushHeight end
}
