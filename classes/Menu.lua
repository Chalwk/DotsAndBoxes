-- Dots & Boxes - Love2D Game
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local ipairs = ipairs
local math_sin = math.sin
local math_floor = math.floor

local Menu = {}
Menu.__index = Menu

function Menu.new()
    local instance = setmetatable({}, Menu)

    instance.buttons = {}
    instance.screenWidth = 800
    instance.screenHeight = 600
    instance.boardSize = 5
    instance.gameMode = "2player" -- "2player" or "ai"
    instance.aiDifficulty = "medium" -- "easy", "medium", "hard"
    instance.title = {
        text = "Dots & Boxes",
        scale = 1,
        scaleDirection = 1,
        scaleSpeed = 0.5,
        minScale = 0.9,
        maxScale = 1.1,
        rotation = 0,
        rotationSpeed = 0.5
    }

    instance.smallFont = love.graphics.newFont(20)
    instance.mediumFont = love.graphics.newFont(30)
    instance.largeFont = love.graphics.newFont(40)

    instance:createMenuButtons()
    instance:createOptionsButtons()

    return instance
end

function Menu:setScreenSize(width, height)
    self.screenWidth = width
    self.screenHeight = height
    self:updateButtonPositions()
end

function Menu:createMenuButtons()
    self.menuButtons = {
        {
            text = "Start Game",
            action = "start",
            width = 200,
            height = 50,
            x = 0,
            y = 0
        },
        {
            text = "Options",
            action = "options",
            width = 200,
            height = 50,
            x = 0,
            y = 0
        },
        {
            text = "Quit",
            action = "quit",
            width = 200,
            height = 50,
            x = 0,
            y = 0
        }
    }
    self:updateButtonPositions()
end

function Menu:createOptionsButtons()
    self.optionsButtons = {
        {
            text = "Back",
            action = "back",
            width = 200,
            height = 50,
            x = 0,
            y = 0
        },
        {
            text = "3x3",
            action = "size 3",
            width = 100,
            height = 40,
            x = 0,
            y = 0
        },
        {
            text = "4x4",
            action = "size 4",
            width = 100,
            height = 40,
            x = 0,
            y = 0
        },
        {
            text = "5x5",
            action = "size 5",
            width = 100,
            height = 40,
            x = 0,
            y = 0
        },
        {
            text = "6x6",
            action = "size 6",
            width = 100,
            height = 40,
            x = 0,
            y = 0
        },
        {
            text = "2 Players",
            action = "mode 2player",
            width = 150,
            height = 40,
            x = 0,
            y = 0
        },
        {
            text = "VS AI",
            action = "mode ai",
            width = 150,
            height = 40,
            x = 0,
            y = 0
        },
        {
            text = "Easy AI",
            action = "ai_easy",
            width = 120,
            height = 35,
            x = 0,
            y = 0
        },
        {
            text = "Medium AI",
            action = "ai_medium",
            width = 120,
            height = 35,
            x = 0,
            y = 0
        },
        {
            text = "Hard AI",
            action = "ai_hard",
            width = 120,
            height = 35,
            x = 0,
            y = 0
        }
    }
    self:updateOptionsButtonPositions()
end

function Menu:updateButtonPositions()
    local startY = self.screenHeight / 2
    for i, button in ipairs(self.menuButtons) do
        button.x = (self.screenWidth - button.width) / 2
        button.y = startY + (i - 1) * 70
    end
end

function Menu:updateOptionsButtonPositions()
    -- Position back button
    self.optionsButtons[1].x = (self.screenWidth - self.optionsButtons[1].width) / 2
    self.optionsButtons[1].y = self.screenHeight - 100

    -- Position size buttons
    local startX = (self.screenWidth - 500) / 2
    for i = 2, 5 do
        local col = (i - 2) % 2
        local row = math_floor((i - 2) / 2)
        self.optionsButtons[i].x = startX + col * 250
        self.optionsButtons[i].y = self.screenHeight / 3 + row * 60
    end

    -- Position game mode buttons
    self.optionsButtons[6].x = (self.screenWidth - 320) / 2
    self.optionsButtons[6].y = self.screenHeight / 2 + 40
    self.optionsButtons[7].x = self.optionsButtons[6].x + 170
    self.optionsButtons[7].y = self.screenHeight / 2 + 40

    -- Position AI difficulty buttons
    self.optionsButtons[8].x = (self.screenWidth - 400) / 2
    self.optionsButtons[8].y = self.screenHeight / 2 + 100
    self.optionsButtons[9].x = self.optionsButtons[8].x + 140
    self.optionsButtons[9].y = self.screenHeight / 2 + 100
    self.optionsButtons[10].x = self.optionsButtons[9].x + 140
    self.optionsButtons[10].y = self.screenHeight / 2 + 100
end

function Menu:update(dt, screenWidth, screenHeight)
    if screenWidth ~= self.screenWidth or screenHeight ~= self.screenHeight then
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self:updateButtonPositions()
        self:updateOptionsButtonPositions()
    end

    -- Update title animation
    self.title.scale = self.title.scale + self.title.scaleDirection * self.title.scaleSpeed * dt

    if self.title.scale > self.title.maxScale then
        self.title.scale = self.title.maxScale
        self.title.scaleDirection = -1
    elseif self.title.scale < self.title.minScale then
        self.title.scale = self.title.minScale
        self.title.scaleDirection = 1
    end

    self.title.rotation = self.title.rotation + self.title.rotationSpeed * dt
end

function Menu:draw(screenWidth, screenHeight, state)
    -- Draw animated title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.largeFont)

    love.graphics.push()
    love.graphics.translate(screenWidth / 2, screenHeight / 4)
    love.graphics.rotate(math_sin(self.title.rotation) * 0.1)
    love.graphics.scale(self.title.scale, self.title.scale)
    love.graphics.printf(self.title.text, -screenWidth / 2, -self.largeFont:getHeight() / 2, screenWidth, "center")
    love.graphics.pop()

    if state == "menu" then
        self:drawMenuButtons()
        -- Draw instructions
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(self.smallFont)
        love.graphics.printf("Connect dots to complete boxes!\nTwo player turn-based game.",
            0, screenHeight / 4 + 80, screenWidth, "center")
    elseif state == "options" then
        self:drawOptionsButtons()
        -- Draw current selections
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(self.mediumFont)
        love.graphics.printf("Board Size: " .. self.boardSize .. "x" .. self.boardSize,
            0, screenHeight / 4, screenWidth, "center")

        love.graphics.printf("Game Mode: " .. (self.gameMode == "ai" and "VS AI" or "2 Players"),
            0, screenHeight / 4 + 40, screenWidth, "center")

        if self.gameMode == "ai" then
            love.graphics.printf("AI Difficulty: " .. self.aiDifficulty:gsub("^%l", string.upper),
                0, screenHeight / 4 + 80, screenWidth, "center")
        end
    end

    -- Draw copyright
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.setFont(self.smallFont)
    love.graphics.printf("© 2025 Jericho Crosby – Dots & Boxes", 10, screenHeight - 25, screenWidth - 20, "right")
end

function Menu:drawMenuButtons()
    for _, button in ipairs(self.menuButtons) do
        self:drawButton(button)
    end
end

function Menu:drawOptionsButtons()
    for _, button in ipairs(self.optionsButtons) do
        self:drawButton(button)

        -- Highlight selected board size
        if button.action:sub(1, 4) == "size" then
            local size = tonumber(button.action:sub(6))
            if size == self.boardSize then
                love.graphics.setColor(0, 1, 0, 0.3)
                love.graphics.rectangle("fill", button.x - 5, button.y - 5, button.width + 10, button.height + 10)
            end
        end

        -- Highlight selected game mode
        if button.action:sub(1, 4) == "mode" then
            local mode = button.action:sub(6)
            if mode == self.gameMode then
                love.graphics.setColor(0, 1, 0, 0.3)
                love.graphics.rectangle("fill", button.x - 5, button.y - 5, button.width + 10, button.height + 10)
            end
        end

        -- Highlight selected AI difficulty
        if button.action:sub(1, 3) == "ai_" then
            local difficulty = button.action:sub(4)
            if difficulty == self.aiDifficulty then
                love.graphics.setColor(0, 1, 0, 0.3)
                love.graphics.rectangle("fill", button.x - 5, button.y - 5, button.width + 10, button.height + 10)
            end
        end
    end
end

function Menu:drawButton(button)
    -- Button background
    love.graphics.setColor(0.3, 0.3, 0.5, 0.8)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

    -- Button border
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height)

    -- Button text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.mediumFont)
    local textWidth = self.mediumFont:getWidth(button.text)
    local textHeight = self.mediumFont:getHeight()
    love.graphics.print(button.text, button.x + (button.width - textWidth) / 2,
        button.y + (button.height - textHeight) / 2)

    love.graphics.setLineWidth(1)
end

function Menu:handleClick(x, y, state)
    local buttons = state == "menu" and self.menuButtons or self.optionsButtons

    for _, button in ipairs(buttons) do
        if x >= button.x and x <= button.x + button.width and
            y >= button.y and y <= button.y + button.height then
            return button.action
        end
    end

    return nil
end

function Menu:setBoardSize(size)
    self.boardSize = size
end

function Menu:getBoardSize()
    return self.boardSize
end

function Menu:setGameMode(mode)
    self.gameMode = mode
end

function Menu:getGameMode()
    return self.gameMode
end

function Menu:setAIDifficulty(difficulty)
    self.aiDifficulty = difficulty
end

function Menu:getAIDifficulty()
    return self.aiDifficulty
end

return Menu