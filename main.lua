-- Dots & Boxes - Love2D Game
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Game = require("classes/Game")
local Menu = require("classes/Menu")
local BackgroundManager = require("classes/BackgroundManager")

local game, menu, backgroundManager
local screenWidth, screenHeight
local gameState = "menu"

local function updateScreenSize()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

function love.load()
    love.window.setTitle("Dots & Boxes")

    -- Enable anti-aliasing for smoother graphics
    love.graphics.setLineStyle("smooth")

    -- Initialize managers and systems
    game = Game.new()
    menu = Menu.new()
    backgroundManager = BackgroundManager.new()

    updateScreenSize()

    -- Set initial positions
    menu:setScreenSize(screenWidth, screenHeight)
    game:setScreenSize(screenWidth, screenHeight)
end

function love.update(dt)
    updateScreenSize()

    if gameState == "menu" then
        menu:update(dt, screenWidth, screenHeight)
    elseif gameState == "playing" then
        game:update(dt)
    elseif gameState == "options" then
        menu:update(dt, screenWidth, screenHeight)
    end

    -- Update background animations
    backgroundManager:update(dt)
end

function love.draw()
    -- Draw background based on game state
    if gameState == "menu" or gameState == "options" then
        backgroundManager:drawMenuBackground(screenWidth, screenHeight)
    elseif gameState == "playing" then
        backgroundManager:drawGameBackground(screenWidth, screenHeight)
    end

    if gameState == "menu" or gameState == "options" then
        menu:draw(screenWidth, screenHeight, gameState)
    elseif gameState == "playing" then
        game:draw()
    end
end

-- Input handling
function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        if gameState == "menu" then
            local action = menu:handleClick(x, y, "menu")
            if action == "start" then
                gameState = "playing"
                game:startNewGame(menu:getBoardSize(), menu:getGameMode(), menu:getAIDifficulty())
            elseif action == "options" then
                gameState = "options"
            elseif action == "quit" then
                love.event.quit()
            end
        elseif gameState == "options" then
            local action = menu:handleClick(x, y, "options")
            if not action then return end
            if action == "back" then
                gameState = "menu"
            elseif action:sub(1, 4) == "size" then
                local size = tonumber(action:sub(6))
                menu:setBoardSize(size)
            elseif action:sub(1, 4) == "mode" then
                local mode = action:sub(6)
                menu:setGameMode(mode)
            elseif action:sub(1, 3) == "ai_" then
                local difficulty = action:sub(4)
                menu:setAIDifficulty(difficulty)
            end
        elseif gameState == "playing" then
            if game:handleClick(x, y) then
                -- Check if game is over
                if game:isGameOver() then
                    -- Return to menu after a short delay or on click
                    -- For now, we'll stay in playing state and show game over screen
                end
            end
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        if gameState == "playing" then
            gameState = "menu"
        elseif gameState == "options" then
            gameState = "menu"
        else
            love.event.quit()
        end
    elseif key == "r" and gameState == "playing" then
        game:startNewGame(menu:getBoardSize(), menu:getGameMode(), menu:getAIDifficulty())
    elseif key == "u" and gameState == "playing" then
        game:undoMove()
    elseif key == "f1" then
        -- Toggle debug info if needed
        game:toggleDebug()
    end
end

function love.resize(w, h)
    updateScreenSize()
    menu:setScreenSize(screenWidth, screenHeight)
    game:setScreenSize(screenWidth, screenHeight)
end