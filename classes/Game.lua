-- Dots & Boxes - Love2D Game
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local ipairs = ipairs
local math_random = math.random
local table_insert = table.insert

local Board = require("classes/Board")

local Game = {}
Game.__index = Game

function Game.new()
    local instance = setmetatable({}, Game)

    instance.board = nil
    instance.screenWidth = 800
    instance.screenHeight = 600
    instance.currentPlayer = 1
    instance.playerScores = { 0, 0 }
    instance.playerColors = {
        { 0.9, 0.3, 0.3 }, -- Red
        { 0.3, 0.3, 0.9 }  -- Blue
    }
    instance.playerNames = { "Player 1", "Player 2" }
    instance.gameOver = false
    instance.winner = nil
    instance.moveHistory = {}
    instance.gameMode = "2player"    -- "2player" or "ai"
    instance.aiDifficulty = "medium" -- "easy", "medium", "hard"
    instance.showDebug = false
    instance.lastAIMoveTime = 0
    instance.aiMoveDelay = 0.5 -- seconds between AI moves

    -- Add screen shake effect
    instance.screenShake = {
        intensity = 0,
        duration = 0,
        timer = 0,
        active = false
    }

    return instance
end

function Game:updateScreenShake(dt)
    if self.screenShake.active then
        self.screenShake.timer = self.screenShake.timer + dt
        if self.screenShake.timer >= self.screenShake.duration then
            self.screenShake.active = false
            self.screenShake.intensity = 0
        end
    end
end

function Game:triggerScreenShake()
    self.screenShake.intensity = 10
    self.screenShake.duration = 0.3
    self.screenShake.timer = 0
    self.screenShake.active = true
end

function Game:setScreenSize(width, height)
    self.screenWidth = width
    self.screenHeight = height
    if self.board then
        self.board:setScreenSize(width, height)
    end
end

function Game:startNewGame(boardSize, gameMode, aiDifficulty)
    self.board = Board.new(boardSize or 5)
    self.board:setScreenSize(self.screenWidth, self.screenHeight)
    self.currentPlayer = 1
    self.playerScores = { 0, 0 }
    self.gameOver = false
    self.winner = nil
    self.moveHistory = {}
    self.gameMode = gameMode or "2player"
    self.aiDifficulty = aiDifficulty or "medium"
    self.lastAIMoveTime = 0

    if self.gameMode == "ai" and self.currentPlayer == 2 then
        self.lastAIMoveTime = love.timer.getTime() - self.aiMoveDelay
    end
end

function Game:update(dt)
    if self.board then
        self.board:update(dt)

        -- Update screen shake
        self:updateScreenShake(dt)
        -- Update hover effect
        if not self.gameOver and (self.gameMode == "2player" or self.currentPlayer == 1) then
            local x, y = love.mouse.getPosition()
            self.board:updateHover(x, y)
        end

        -- AI move
        if not self.gameOver and self.gameMode == "ai" and self.currentPlayer == 2 then
            local currentTime = love.timer.getTime()
            if currentTime - self.lastAIMoveTime >= self.aiMoveDelay then
                self:makeAIMove()
                self.lastAIMoveTime = currentTime
            end
        end
    end
end

function Game:draw()
    if not self.board then return end

    -- Apply screen shake if active
    local offsetX, offsetY = 0, 0
    if self.screenShake.active then
        local progress = self.screenShake.timer / self.screenShake.duration
        local currentIntensity = self.screenShake.intensity * (1 - progress)
        offsetX = love.math.random(-currentIntensity, currentIntensity)
        offsetY = love.math.random(-currentIntensity, currentIntensity)
    end

    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)

    -- Draw board
    self.board:draw()

    -- Draw UI
    self:drawUI()

    -- Draw game over screen if game ended
    if self.gameOver then
        self:drawGameOver()
    end

    -- Draw debug info
    if self.showDebug then
        self:drawDebugInfo()
    end

    love.graphics.pop()
end

function Game:drawUI()

    -- Draw current player indicator with animation
    love.graphics.setColor(self.playerColors[self.currentPlayer][1],
        self.playerColors[self.currentPlayer][2],
        self.playerColors[self.currentPlayer][3])

    if self.gameMode == "ai" and self.currentPlayer == 2 then
        love.graphics.print("AI's Turn", 20, 20)
    else
        love.graphics.print(self.playerNames[self.currentPlayer] .. "'s Turn", 20, 20)
    end

    -- Draw scores with player colors
    love.graphics.setColor(self.playerColors[1])
    love.graphics.print(self.playerNames[1] .. ": " .. self.playerScores[1], 20, 50)

    love.graphics.setColor(self.playerColors[2])
    if self.gameMode == "ai" then
        love.graphics.print("AI: " .. self.playerScores[2], 20, 80)
    else
        love.graphics.print(self.playerNames[2] .. ": " .. self.playerScores[2], 20, 80)
    end

    -- Draw game mode
    love.graphics.setColor(1, 1, 1)
    local modeText = self.gameMode == "ai" and "Mode: VS AI (" .. self.aiDifficulty .. ")" or "Mode: 2 Players"
    love.graphics.print(modeText, 20, 110)

    -- Draw instructions
    love.graphics.setColor(1, 1, 1, 0.7)
    local instructions = "R - Restart   U - Undo   ESC - Menu"
    if self.gameMode == "ai" then
        instructions = instructions .. "   F1 - Debug"
    end
    love.graphics.print(instructions, 20, self.screenHeight - 30)
end

function Game:drawGameOver()
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)

    local font = love.graphics.newFont(40)
    love.graphics.setFont(font)

    if self.winner then
        love.graphics.setColor(self.playerColors[self.winner])
        if self.gameMode == "ai" and self.winner == 2 then
            love.graphics.printf("AI Wins!", 0, self.screenHeight / 2 - 50, self.screenWidth, "center")
        else
            love.graphics.printf(self.playerNames[self.winner] .. " Wins!", 0, self.screenHeight / 2 - 50,
                self.screenWidth, "center")
        end
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game Over - Tie!", 0, self.screenHeight / 2 - 50, self.screenWidth, "center")
    end

    -- Draw final score
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(self.playerScores[1] .. " - " .. self.playerScores[2],
        0, self.screenHeight / 2 + 10, self.screenWidth, "center")

    local smallFont = love.graphics.newFont(20)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Click to return to menu", 0, self.screenHeight / 2 + 60, self.screenWidth, "center")
end

function Game:drawDebugInfo()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Debug Info:", self.screenWidth - 200, 20)
    love.graphics.print("Moves: " .. #self.moveHistory, self.screenWidth - 200, 40)
    love.graphics.print("Available: " .. #self.board:getAvailableMoves(), self.screenWidth - 200, 60)

    if self.gameMode == "ai" and self.currentPlayer == 2 then
        love.graphics.print("AI Thinking...", self.screenWidth - 200, 80)
    end
end

function Game:handleClick(x, y)
    if self.gameOver then return true end

    -- Don't process clicks during AI turn
    if self.gameMode == "ai" and self.currentPlayer == 2 then return false end

    if self.board then
        -- First check if it's a valid move
        local clickedLine = self.board:getLineAtPosition(x, y)
        if not clickedLine or clickedLine.line.drawn then
            self.board.invalidClickEffect.x = x
            self.board.invalidClickEffect.y = y
            self.board.invalidClickEffect.alpha = 1
            self:triggerScreenShake() -- Add this line
            return false
        end

        local completedBox = self.board:handleClick(x, y, self.currentPlayer, self.playerColors[self.currentPlayer])

        if completedBox then
            -- Record the move
            table_insert(self.moveHistory, {
                type = "line",
                player = self.currentPlayer,
                completedBox = true
            })

            -- Player completed a box, they get another turn
            self.playerScores[self.currentPlayer] = self.playerScores[self.currentPlayer] + 1
            -- Check if they can complete more boxes
            if not self.board:checkForAdditionalMoves(self.currentPlayer, self.playerColors[self.currentPlayer]) then
                self:switchPlayer()
            end
        else
            -- Record the move
            table_insert(self.moveHistory, {
                type = "line",
                player = self.currentPlayer,
                completedBox = false
            })

            -- No box completed, switch players
            self:switchPlayer()
        end

        -- Check if game is over
        if self.board:isGameComplete() then
            self.gameOver = true
            if self.playerScores[1] > self.playerScores[2] then
                self.winner = 1
            elseif self.playerScores[2] > self.playerScores[1] then
                self.winner = 2
            else
                self.winner = nil -- Tie
            end
        end

        return true
    end

    return false
end

function Game:makeAIMove()
    if not self.board or self.gameOver then return end

    local availableMoves = self.board:getAvailableMoves()
    if #availableMoves == 0 then return end

    local selectedMove

    if self.aiDifficulty == "easy" then
        -- Easy AI: random move
        selectedMove = availableMoves[math_random(#availableMoves)]
    elseif self.aiDifficulty == "medium" then
        -- Medium AI: prefers moves that complete boxes, otherwise random
        local completingMoves = {}
        local otherMoves = {}

        for _, move in ipairs(availableMoves) do
            local completionCount = self.board:getBoxCompletionCount(move)
            if completionCount > 0 then
                table_insert(completingMoves, move)
            else
                table_insert(otherMoves, move)
            end
        end

        if #completingMoves > 0 then
            selectedMove = completingMoves[math_random(#completingMoves)]
        else
            selectedMove = otherMoves[math_random(#otherMoves)]
        end
    else -- hard
        -- Hard AI: tries to avoid giving opponent completing moves
        local completingMoves = {}
        local safeMoves = {}

        for _, move in ipairs(availableMoves) do
            local completionCount = self.board:getBoxCompletionCount(move)
            if completionCount > 0 then
                table_insert(completingMoves, move)
            else
                -- Check if this move would give opponent a completing move
                local givesOpponentMove = false

                -- Simulate the move
                if move.type == "h" then
                    self.board.horizontalLines[move.row][move.col].drawn = true

                    -- Check adjacent boxes
                    if move.row > 1 then
                        local top = self.board.horizontalLines[move.row - 1][move.col].drawn
                        local left = self.board.verticalLines[move.row - 1][move.col].drawn
                        local right = self.board.verticalLines[move.row - 1][move.col + 1].drawn
                        if top and left and right and not self.board.boxes[move.row - 1][move.col].owner then
                            givesOpponentMove = true
                        end
                    end

                    if move.row <= self.board.size then
                        local bottom = self.board.horizontalLines[move.row + 1][move.col].drawn
                        local left = self.board.verticalLines[move.row][move.col].drawn
                        local right = self.board.verticalLines[move.row][move.col + 1].drawn
                        if bottom and left and right and not self.board.boxes[move.row][move.col].owner then
                            givesOpponentMove = true
                        end
                    end

                    self.board.horizontalLines[move.row][move.col].drawn = false
                else -- vertical
                    self.board.verticalLines[move.row][move.col].drawn = true

                    -- Check adjacent boxes
                    if move.col > 1 then
                        local left = self.board.verticalLines[move.row][move.col - 1].drawn
                        local top = self.board.horizontalLines[move.row][move.col - 1].drawn
                        local bottom = self.board.horizontalLines[move.row + 1][move.col - 1].drawn
                        if left and top and bottom and not self.board.boxes[move.row][move.col - 1].owner then
                            givesOpponentMove = true
                        end
                    end

                    if move.col <= self.board.size then
                        local right = self.board.verticalLines[move.row][move.col + 1].drawn
                        local top = self.board.horizontalLines[move.row][move.col].drawn
                        local bottom = self.board.horizontalLines[move.row + 1][move.col].drawn
                        if right and top and bottom and not self.board.boxes[move.row][move.col].owner then
                            givesOpponentMove = true
                        end
                    end

                    self.board.verticalLines[move.row][move.col].drawn = false
                end

                if not givesOpponentMove then
                    table_insert(safeMoves, move)
                end
            end
        end

        if #completingMoves > 0 then
            selectedMove = completingMoves[math_random(#completingMoves)]
        elseif #safeMoves > 0 then
            selectedMove = safeMoves[math_random(#safeMoves)]
        else
            selectedMove = availableMoves[math_random(#availableMoves)]
        end
    end

    -- Make the selected move
    if selectedMove then
        local completedBox = self.board:makeMove(selectedMove, self.currentPlayer, self.playerColors[self.currentPlayer])

        -- Record the move
        table_insert(self.moveHistory, {
            type = "line",
            player = self.currentPlayer,
            move = selectedMove,
            completedBox = completedBox
        })

        if completedBox then
            -- AI completed a box, gets another turn
            self.playerScores[self.currentPlayer] = self.playerScores[self.currentPlayer] + 1

            -- Check for additional moves
            if not self.board:checkForAdditionalMoves(self.currentPlayer, self.playerColors[self.currentPlayer]) then
                self:switchPlayer()
            end
        else
            self:switchPlayer()
        end

        -- Check if game is over
        if self.board:isGameComplete() then
            self.gameOver = true
            if self.playerScores[1] > self.playerScores[2] then
                self.winner = 1
            elseif self.playerScores[2] > self.playerScores[1] then
                self.winner = 2
            else
                self.winner = nil
            end
        end
    end
end

function Game:switchPlayer()
    self.currentPlayer = self.currentPlayer == 1 and 2 or 1
end

function Game:isGameOver()
    return self.gameOver
end

function Game:undoMove()
    if #self.moveHistory > 0 and not self.gameOver then
        local lastMove = self.moveHistory[#self.moveHistory]

        -- Only allow undoing your own moves in AI mode
        if self.gameMode == "ai" and lastMove.player ~= 1 then
            return
        end

        self.board:undoLastMove(self.moveHistory)

        -- Update scores
        self.playerScores = { 0, 0 }
        for row = 1, self.board.size do
            for col = 1, self.board.size do
                if self.board.boxes[row][col].owner then
                    self.playerScores[self.board.boxes[row][col].owner] =
                        self.playerScores[self.board.boxes[row][col].owner] + 1
                end
            end
        end

        -- Switch back to the player who made the move
        self.currentPlayer = lastMove.player
    end
end

function Game:toggleDebug()
    self.showDebug = not self.showDebug
end

return Game
