-- Dots & Boxes - Love2D Game
-- Fixed Options layout
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local ipairs = ipairs
local math_sin = math.sin

local Menu = {}
Menu.__index = Menu

function Menu.new()
    local instance = setmetatable({}, Menu)

    instance.buttons = {}
    instance.screenWidth = 800
    instance.screenHeight = 600
    instance.boardSize = 5
    instance.gameMode = "2player"    -- "2player" or "ai"
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

    instance.smallFont = love.graphics.newFont(18)
    instance.mediumFont = love.graphics.newFont(24)
    instance.largeFont = love.graphics.newFont(36)
    instance.sectionFont = love.graphics.newFont(20)

    instance:createMenuButtons()
    instance:createOptionsButtons()

    return instance
end

function Menu:setScreenSize(width, height)
    self.screenWidth = width
    self.screenHeight = height
    self:updateButtonPositions()
    self:updateOptionsButtonPositions()
end

function Menu:createMenuButtons()
    self.menuButtons = {
        {
            text = "Start Game",
            action = "start",
            width = 220,
            height = 50,
            x = 0,
            y = 0
        },
        {
            text = "Options",
            action = "options",
            width = 220,
            height = 50,
            x = 0,
            y = 0
        },
        {
            text = "Quit",
            action = "quit",
            width = 220,
            height = 50,
            x = 0,
            y = 0
        }
    }
    self:updateButtonPositions()
end

function Menu:createOptionsButtons()
    self.optionsButtons = {
        -- Board Size Section
        {
            text = "3x3",
            action = "size 3",
            width = 80,
            height = 35,
            x = 0,
            y = 0,
            section = "size"
        },
        {
            text = "4x4",
            action = "size 4",
            width = 80,
            height = 35,
            x = 0,
            y = 0,
            section = "size"
        },
        {
            text = "5x5",
            action = "size 5",
            width = 80,
            height = 35,
            x = 0,
            y = 0,
            section = "size"
        },
        {
            text = "6x6",
            action = "size 6",
            width = 80,
            height = 35,
            x = 0,
            y = 0,
            section = "size"
        },

        -- Game Mode Section
        {
            text = "2 Players",
            action = "mode 2player",
            width = 140,
            height = 40,
            x = 0,
            y = 0,
            section = "mode"
        },
        {
            text = "VS AI",
            action = "mode ai",
            width = 140,
            height = 40,
            x = 0,
            y = 0,
            section = "mode"
        },

        -- AI Difficulty Section
        {
            text = "Easy",
            action = "ai_easy",
            width = 100,
            height = 35,
            x = 0,
            y = 0,
            section = "difficulty"
        },
        {
            text = "Medium",
            action = "ai_medium",
            width = 100,
            height = 35,
            x = 0,
            y = 0,
            section = "difficulty"
        },
        {
            text = "Hard",
            action = "ai_hard",
            width = 100,
            height = 35,
            x = 0,
            y = 0,
            section = "difficulty"
        },

        -- Navigation
        {
            text = "Back to Menu",
            action = "back",
            width = 180,
            height = 45,
            x = 0,
            y = 0,
            section = "navigation"
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

-- Keep options layout math consistent between measurement and drawing
function Menu:updateOptionsButtonPositions()
    local centerX = self.screenWidth / 2

    -- Use the same vertical layout constants as drawOptionsInterface so text and
    -- buttons line up reliably at different resolutions
    local totalSectionsHeight = 300 -- total vertical space used by all option sections
    local startY = (self.screenHeight - totalSectionsHeight) / 2

    -- Board Size Section - 4 small buttons with 20px spacing
    local sizeButtonW, sizeButtonH, sizeSpacing = 80, 35, 20
    local sizeTotalW = 4 * sizeButtonW + 3 * sizeSpacing
    local sizeStartX = centerX - sizeTotalW / 2
    local sizeY = startY + 30

    -- Game Mode - 2 larger buttons
    local modeButtonW, modeButtonH, modeSpacing = 140, 40, 20
    local modeTotalW = 2 * modeButtonW + modeSpacing
    local modeStartX = centerX - modeTotalW / 2
    local modeY = startY + 110

    -- AI Difficulty - 3 medium buttons
    local diffButtonW, diffButtonH, diffSpacing = 100, 35, 20
    local diffTotalW = 3 * diffButtonW + 2 * diffSpacing
    local diffStartX = centerX - diffTotalW / 2
    local diffY = startY + 190

    -- Navigation
    local navY = self.gameMode == "ai" and startY + 270 or startY + 230

    -- Assign positions by section in a clear, index-free way
    local sizeIndex, modeIndex, diffIndex = 0, 0, 0
    for _, button in ipairs(self.optionsButtons) do
        if button.section == "size" then
            button.width = sizeButtonW
            button.height = sizeButtonH
            button.x = sizeStartX + sizeIndex * (sizeButtonW + sizeSpacing)
            button.y = sizeY
            sizeIndex = sizeIndex + 1
        elseif button.section == "mode" then
            button.width = modeButtonW
            button.height = modeButtonH
            button.x = modeStartX + modeIndex * (modeButtonW + modeSpacing)
            button.y = modeY
            modeIndex = modeIndex + 1
        elseif button.section == "difficulty" then
            button.width = diffButtonW
            button.height = diffButtonH
            button.x = diffStartX + diffIndex * (diffButtonW + diffSpacing)
            button.y = diffY
            diffIndex = diffIndex + 1
        elseif button.section == "navigation" then
            button.x = centerX - button.width / 2
            button.y = navY
        end
    end
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
    love.graphics.translate(screenWidth / 2, screenHeight / 6)
    love.graphics.rotate(math_sin(self.title.rotation) * 0.1)
    love.graphics.scale(self.title.scale, self.title.scale)
    love.graphics.printf(self.title.text, -screenWidth / 2, -self.largeFont:getHeight() / 2, screenWidth, "center")
    love.graphics.pop()

    if state == "menu" then
        self:drawMenuButtons()
        -- Draw instructions
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.setFont(self.smallFont)
        love.graphics.printf("Connect dots to complete boxes!\nTwo player turn-based game.",
            0, screenHeight / 4 + 60, screenWidth, "center")
    elseif state == "options" then
        self:drawOptionsInterface()
    end

    -- Draw copyright
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.setFont(self.smallFont)
    love.graphics.printf("© 2025 Jericho Crosby – Dots & Boxes", 10, screenHeight - 25, screenWidth - 20, "right")
end

function Menu:drawOptionsInterface()

    -- Use the same total height as updateOptionsButtonPositions
    local totalSectionsHeight = 300
    local startY = (self.screenHeight - totalSectionsHeight) / 2

    -- Draw section headers and buttons with proper spacing
    love.graphics.setFont(self.sectionFont)

    -- Board Size Section
    love.graphics.setColor(0.8, 0.8, 1)
    love.graphics.printf("Board Size", 0, startY + 5, self.screenWidth, "center")
    -- Buttons already positioned by updateOptionsButtonPositions

    -- Game Mode Section
    love.graphics.setColor(0.8, 0.8, 1)
    love.graphics.printf("Game Mode", 0, startY + 85, self.screenWidth, "center")

    -- AI Difficulty Section (only show if in AI mode)
    if self.gameMode == "ai" then
        love.graphics.setColor(0.8, 0.8, 1)
        love.graphics.printf("AI Difficulty", 0, startY + 165, self.screenWidth, "center")
    end

    -- Ensure buttons are placed for the current screen size
    self:updateOptionsButtonPositions()

    -- Draw the sections in a stable order so selection highlight appears behind text
    self:drawOptionSection("size")
    self:drawOptionSection("mode")
    if self.gameMode == "ai" then
        self:drawOptionSection("difficulty")
    end

    -- Navigation buttons - adjust position based on whether AI section is visible
    self:drawOptionSection("navigation")
end

function Menu:drawOptionSection(section)
    for _, button in ipairs(self.optionsButtons) do
        if button.section == section then
            if section == "difficulty" and self.gameMode ~= "ai" then
                goto continue
            end

            -- Draw the button first
            self:drawButton(button)

            -- Then draw the highlight *on top* of it
            if button.action:sub(1, 4) == "size" then
                local size = tonumber(button.action:sub(6))
                if size == self.boardSize then
                    love.graphics.setColor(0.2, 0.8, 0.2, 0.4)
                    love.graphics.rectangle("fill", button.x - 3, button.y - 3, button.width + 6, button.height + 6, 5)
                end
            elseif button.action:sub(1, 4) == "mode" then
                local mode = button.action:sub(6)
                if mode == self.gameMode then
                    love.graphics.setColor(0.2, 0.8, 0.2, 0.4)
                    love.graphics.rectangle("fill", button.x - 3, button.y - 3, button.width + 6, button.height + 6, 5)
                end
            elseif button.action:sub(1, 3) == "ai_" then
                local difficulty = button.action:sub(4)
                if difficulty == self.aiDifficulty then
                    love.graphics.setColor(0.2, 0.8, 0.2, 0.4)
                    love.graphics.rectangle("fill", button.x - 3, button.y - 3, button.width + 6, button.height + 6, 5)
                end
            end

            ::continue::
        end
    end
end

function Menu:drawMenuButtons()
    for _, button in ipairs(self.menuButtons) do
        self:drawButton(button)
    end
end

function Menu:drawButton(button)
    -- Button background with rounded corners
    love.graphics.setColor(0.25, 0.25, 0.4, 0.9)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 8, 8)

    -- Button border
    love.graphics.setColor(0.6, 0.6, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 8, 8)

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
        -- Skip AI difficulty buttons if not in AI mode
        if state == "options" and button.section == "difficulty" and self.gameMode ~= "ai" then
            goto continue
        end

        if x >= button.x and x <= button.x + button.width and
            y >= button.y and y <= button.y + button.height then
            return button.action
        end

        ::continue::
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
