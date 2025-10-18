-- Dots & Boxes - Love2D Game
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Board = {}
Board.__index = Board

function Board.new(size)
    local instance = setmetatable({}, Board)

    instance.size = size or 5 -- 5x5 grid of boxes (6x6 dots)
    instance.dots = {}
    instance.horizontalLines = {}
    instance.verticalLines = {}
    instance.boxes = {}
    instance.screenWidth = 800
    instance.screenHeight = 600
    instance.margin = 80
    instance.cellSize = 0
    instance.animations = {}
    instance.hoverLine = nil
    instance.invalidClickEffect = { alpha = 0, x = 0, y = 0 }

    instance:initializeGrid()

    return instance
end

function Board:setScreenSize(width, height)
    self.screenWidth = width
    self.screenHeight = height
    self.cellSize = math.min(
        (width - self.margin * 2) / (self.size),
        (height - self.margin * 2) / (self.size)
    )
    self:updateGridPositions()
end

function Board:initializeGrid()
    -- Initialize lines
    for row = 1, self.size + 1 do
        self.horizontalLines[row] = {}
        self.verticalLines[row] = {}
        for col = 1, self.size do
            self.horizontalLines[row][col] = { drawn = false, player = nil, animProgress = 0 }
        end
        for col = 1, self.size + 1 do
            self.verticalLines[row][col] = { drawn = false, player = nil, animProgress = 0 }
        end
    end

    -- Initialize boxes
    for row = 1, self.size do
        self.boxes[row] = {}
        for col = 1, self.size do
            self.boxes[row][col] = { owner = nil, animProgress = 0 }
        end
    end

    self:updateGridPositions()
end

function Board:updateGridPositions()
    self.dots = {}
    local startX = (self.screenWidth - self.size * self.cellSize) / 2
    local startY = (self.screenHeight - self.size * self.cellSize) / 2

    for row = 1, self.size + 1 do
        self.dots[row] = {}
        for col = 1, self.size + 1 do
            self.dots[row][col] = {
                x = startX + (col - 1) * self.cellSize,
                y = startY + (row - 1) * self.cellSize
            }
        end
    end
end

function Board:update(dt)
    -- Update animations
    for i = #self.animations, 1, -1 do
        local anim = self.animations[i]
        anim.progress = anim.progress + dt / anim.duration

        if anim.progress >= 1 then
            anim.progress = 1
            table.remove(self.animations, i)
        end

        if anim.type == "line" then
            local line = anim.line
            line.animProgress = anim.progress
        elseif anim.type == "box" then
            local box = anim.box
            box.animProgress = anim.progress
        end
    end

    -- Update invalid click effect
    if self.invalidClickEffect.alpha > 0 then
        self.invalidClickEffect.alpha = self.invalidClickEffect.alpha - dt * 2
        if self.invalidClickEffect.alpha < 0 then
            self.invalidClickEffect.alpha = 0
        end
    end
end

function Board:draw()
    -- Draw boxes with animation
    for row = 1, self.size do
        for col = 1, self.size do
            local box = self.boxes[row][col]
            if box.owner then
                local alpha = 0.3 + box.animProgress * 0.3
                love.graphics.setColor(box.color[1], box.color[2], box.color[3], alpha)
                local dot = self.dots[row][col]
                love.graphics.rectangle("fill", dot.x, dot.y, self.cellSize, self.cellSize)

                -- Draw owner symbol with animation
                if box.animProgress > 0 then
                    love.graphics.setColor(box.color[1], box.color[2], box.color[3], box.animProgress)
                    local centerX = dot.x + self.cellSize / 2
                    local centerY = dot.y + self.cellSize / 2
                    local scale = 0.5 + box.animProgress * 0.5
                    love.graphics.printf(box.owner, centerX - 10, centerY - 10, 20, "center")
                end
            end
        end
    end

    -- Draw horizontal lines with animation
    for row = 1, self.size + 1 do
        for col = 1, self.size do
            local line = self.horizontalLines[row][col]
            local startDot = self.dots[row][col]
            local endDot = self.dots[row][col + 1]

            if line.drawn then
                local progress = line.animProgress or 1
                local drawToX = startDot.x + (endDot.x - startDot.x) * progress
                local drawToY = startDot.y + (endDot.y - startDot.y) * progress

                love.graphics.setColor(line.color[1], line.color[2], line.color[3])
                love.graphics.setLineWidth(3)
                love.graphics.line(startDot.x, startDot.y, drawToX, drawToY)
            else
                -- Draw faint available lines
                love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
                love.graphics.setLineWidth(1)
                love.graphics.line(startDot.x, startDot.y, endDot.x, endDot.y)

                -- Highlight hovered line
                if self.hoverLine and self.hoverLine.type == "h" and
                   self.hoverLine.row == row and self.hoverLine.col == col then
                    love.graphics.setColor(1, 1, 1, 0.5)
                    love.graphics.setLineWidth(2)
                    love.graphics.line(startDot.x, startDot.y, endDot.x, endDot.y)
                    love.graphics.setLineWidth(1)
                end
            end
        end
    end

    -- Draw vertical lines with animation
    for row = 1, self.size do
        for col = 1, self.size + 1 do
            local line = self.verticalLines[row][col]
            local startDot = self.dots[row][col]
            local endDot = self.dots[row + 1][col]

            if line.drawn then
                local progress = line.animProgress or 1
                local drawToX = startDot.x + (endDot.x - startDot.x) * progress
                local drawToY = startDot.y + (endDot.y - startDot.y) * progress

                love.graphics.setColor(line.color[1], line.color[2], line.color[3])
                love.graphics.setLineWidth(3)
                love.graphics.line(startDot.x, startDot.y, drawToX, drawToY)
            else
                -- Draw faint available lines
                love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
                love.graphics.setLineWidth(1)
                love.graphics.line(startDot.x, startDot.y, endDot.x, endDot.y)

                -- Highlight hovered line
                if self.hoverLine and self.hoverLine.type == "v" and
                   self.hoverLine.row == row and self.hoverLine.col == col then
                    love.graphics.setColor(1, 1, 1, 0.5)
                    love.graphics.setLineWidth(2)
                    love.graphics.line(startDot.x, startDot.y, endDot.x, endDot.y)
                    love.graphics.setLineWidth(1)
                end
            end
        end
    end

    -- Draw dots
    love.graphics.setColor(1, 1, 1)
    for row = 1, self.size + 1 do
        for col = 1, self.size + 1 do
            local dot = self.dots[row][col]
            love.graphics.circle("fill", dot.x, dot.y, 4)
        end
    end

    -- Draw invalid click effect
    if self.invalidClickEffect.alpha > 0 then
        love.graphics.setColor(1, 0, 0, self.invalidClickEffect.alpha)
        love.graphics.circle("line", self.invalidClickEffect.x, self.invalidClickEffect.y, 20)
    end

    love.graphics.setLineWidth(1)
end

function Board:handleClick(x, y, player, color)
    -- Update hover line
    self.hoverLine = nil

    -- Check if click is near any line
    local clickedLine = self:getLineAtPosition(x, y)

    if not clickedLine then
        -- Invalid click - show effect
        self.invalidClickEffect.x = x
        self.invalidClickEffect.y = y
        self.invalidClickEffect.alpha = 1
        return false
    end

    local line = clickedLine.line
    if line.drawn then
        return false -- Line already drawn
    end

    -- Draw the line with animation
    line.drawn = true
    line.player = player
    line.color = color
    line.animProgress = 0

    table.insert(self.animations, {
        type = "line",
        line = line,
        progress = 0,
        duration = 0.3
    })

    return self:checkForCompletedBoxes(player, color)
end

function Board:getLineAtPosition(x, y)
    -- Check horizontal lines
    for row = 1, self.size + 1 do
        for col = 1, self.size do
            local line = self.horizontalLines[row][col]
            if not line.drawn then
                local startDot = self.dots[row][col]
                local endDot = self.dots[row][col + 1]
                if self:isPointNearLine(x, y, startDot.x, startDot.y, endDot.x, endDot.y) then
                    return { type = "h", row = row, col = col, line = line }
                end
            end
        end
    end

    -- Check vertical lines
    for row = 1, self.size do
        for col = 1, self.size + 1 do
            local line = self.verticalLines[row][col]
            if not line.drawn then
                local startDot = self.dots[row][col]
                local endDot = self.dots[row + 1][col]
                if self:isPointNearLine(x, y, startDot.x, startDot.y, endDot.x, endDot.y) then
                    return { type = "v", row = row, col = col, line = line }
                end
            end
        end
    end

    return nil
end

function Board:updateHover(x, y)
    self.hoverLine = self:getLineAtPosition(x, y)
end

function Board:isPointNearLine(px, py, x1, y1, x2, y2)
    local threshold = 10

    -- Check if point is within bounding box of line
    if px < math.min(x1, x2) - threshold or px > math.max(x1, x2) + threshold or
        py < math.min(y1, y2) - threshold or py > math.max(y1, y2) + threshold then
        return false
    end

    -- Calculate distance from point to line
    local A = px - x1
    local B = py - y1
    local C = x2 - x1
    local D = y2 - y1

    local dot = A * C + B * D
    local len_sq = C * C + D * D
    local param = -1

    if len_sq ~= 0 then
        param = dot / len_sq
    end

    local xx, yy

    if param < 0 then
        xx = x1
        yy = y1
    elseif param > 1 then
        xx = x2
        yy = y2
    else
        xx = x1 + param * C
        yy = y1 + param * D
    end

    local dx = px - xx
    local dy = py - yy
    local distance = math.sqrt(dx * dx + dy * dy)

    return distance <= threshold
end

function Board:checkForCompletedBoxes(player, color)
    local completedBox = false

    for row = 1, self.size do
        for col = 1, self.size do
            if not self.boxes[row][col].owner then
                -- Check all four sides of the box
                local top = self.horizontalLines[row][col].drawn
                local bottom = self.horizontalLines[row + 1][col].drawn
                local left = self.verticalLines[row][col].drawn
                local right = self.verticalLines[row][col + 1].drawn

                if top and bottom and left and right then
                    self.boxes[row][col].owner = player
                    self.boxes[row][col].color = color
                    self.boxes[row][col].animProgress = 0

                    table.insert(self.animations, {
                        type = "box",
                        box = self.boxes[row][col],
                        progress = 0,
                        duration = 0.5
                    })

                    completedBox = true
                end
            end
        end
    end

    return completedBox
end

function Board:checkForAdditionalMoves(player, color)
    -- Check if there are any boxes that can be completed with one move
    for row = 1, self.size do
        for col = 1, self.size do
            if not self.boxes[row][col].owner then
                local top = self.horizontalLines[row][col].drawn
                local bottom = self.horizontalLines[row + 1][col].drawn
                local left = self.verticalLines[row][col].drawn
                local right = self.verticalLines[row][col + 1].drawn

                local missingSides = 0
                if not top then missingSides = missingSides + 1 end
                if not bottom then missingSides = missingSides + 1 end
                if not left then missingSides = missingSides + 1 end
                if not right then missingSides = missingSides + 1 end

                if missingSides == 1 then
                    return true
                end
            end
        end
    end

    return false
end

function Board:isGameComplete()
    local totalLines = (self.size + 1) * self.size * 2 -- Total horizontal + vertical lines
    local drawnLines = 0

    -- Count drawn horizontal lines
    for row = 1, self.size + 1 do
        for col = 1, self.size do
            if self.horizontalLines[row][col].drawn then
                drawnLines = drawnLines + 1
            end
        end
    end

    -- Count drawn vertical lines
    for row = 1, self.size do
        for col = 1, self.size + 1 do
            if self.verticalLines[row][col].drawn then
                drawnLines = drawnLines + 1
            end
        end
    end

    return drawnLines == totalLines
end

function Board:getAvailableMoves()
    local moves = {}

    -- Check horizontal lines
    for row = 1, self.size + 1 do
        for col = 1, self.size do
            if not self.horizontalLines[row][col].drawn then
                table.insert(moves, { type = "h", row = row, col = col })
            end
        end
    end

    -- Check vertical lines
    for row = 1, self.size do
        for col = 1, self.size + 1 do
            if not self.verticalLines[row][col].drawn then
                table.insert(moves, { type = "v", row = row, col = col })
            end
        end
    end

    return moves
end

function Board:getBoxCompletionCount(move)
    -- Count how many boxes would be completed by making this move
    local count = 0

    if move.type == "h" then
        -- Check box above
        if move.row > 1 then
            local top = self.horizontalLines[move.row - 1][move.col].drawn
            local left = self.verticalLines[move.row - 1][move.col].drawn
            local right = self.verticalLines[move.row - 1][move.col + 1].drawn
            if top and left and right then
                count = count + 1
            end
        end

        -- Check box below
        if move.row <= self.size then
            local bottom = self.horizontalLines[move.row + 1][move.col].drawn
            local left = self.verticalLines[move.row][move.col].drawn
            local right = self.verticalLines[move.row][move.col + 1].drawn
            if bottom and left and right then
                count = count + 1
            end
        end
    else -- vertical line
        -- Check box to the left
        if move.col > 1 then
            local left = self.verticalLines[move.row][move.col - 1].drawn
            local top = self.horizontalLines[move.row][move.col - 1].drawn
            local bottom = self.horizontalLines[move.row + 1][move.col - 1].drawn
            if left and top and bottom then
                count = count + 1
            end
        end

        -- Check box to the right
        if move.col <= self.size then
            local right = self.verticalLines[move.row][move.col + 1].drawn
            local top = self.horizontalLines[move.row][move.col].drawn
            local bottom = self.horizontalLines[move.row + 1][move.col].drawn
            if right and top and bottom then
                count = count + 1
            end
        end
    end

    return count
end

function Board:makeMove(move, player, color)
    if move.type == "h" then
        local line = self.horizontalLines[move.row][move.col]
        if not line.drawn then
            line.drawn = true
            line.player = player
            line.color = color
            line.animProgress = 0

            table.insert(self.animations, {
                type = "line",
                line = line,
                progress = 0,
                duration = 0.3
            })

            return self:checkForCompletedBoxes(player, color)
        end
    else
        local line = self.verticalLines[move.row][move.col]
        if not line.drawn then
            line.drawn = true
            line.player = player
            line.color = color
            line.animProgress = 0

            table.insert(self.animations, {
                type = "line",
                line = line,
                progress = 0,
                duration = 0.3
            })

            return self:checkForCompletedBoxes(player, color)
        end
    end

    return false
end

function Board:undoLastMove(moveHistory)
    if #moveHistory == 0 then return end

    local lastMove = moveHistory[#moveHistory]
    table.remove(moveHistory, #moveHistory)

    if lastMove.type == "h" then
        local line = self.horizontalLines[lastMove.row][lastMove.col]
        line.drawn = false
        line.player = nil
        line.color = nil
        line.animProgress = 0
    else
        local line = self.verticalLines[lastMove.row][lastMove.col]
        line.drawn = false
        line.player = nil
        line.color = nil
        line.animProgress = 0
    end

    -- Also undo any boxes completed in that move
    for row = 1, self.size do
        for col = 1, self.size do
            if self.boxes[row][col].owner == lastMove.player then
                -- Check if box is still complete
                local top = self.horizontalLines[row][col].drawn
                local bottom = self.horizontalLines[row + 1][col].drawn
                local left = self.verticalLines[row][col].drawn
                local right = self.verticalLines[row][col + 1].drawn

                if not (top and bottom and left and right) then
                    self.boxes[row][col].owner = nil
                    self.boxes[row][col].color = nil
                    self.boxes[row][col].animProgress = 0
                end
            end
        end
    end
end

return Board