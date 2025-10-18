-- Dots & Boxes - Love2D Game
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_pi = math.pi
local math_sin = math.sin
local math_cos = math.cos
local math_sqrt = math.sqrt
local math_random = math.random
local table_insert = table.insert

local BackgroundManager = {}
BackgroundManager.__index = BackgroundManager

function BackgroundManager.new()
    local instance = setmetatable({}, BackgroundManager)
    instance.gridParticles = {}
    instance.menuParticles = {}
    instance.time = 0
    instance:initGridParticles()
    instance:initMenuParticles()
    return instance
end

function BackgroundManager:initGridParticles()
    self.gridParticles = {}
    for _ = 1, 50 do
        table_insert(self.gridParticles, {
            x = math_random() * 1000 - 100,
            y = math_random() * 1000 - 100,
            size = math_random(1, 3),
            speed = math_random(10, 30),
            angle = math_random() * math_pi * 2
        })
    end
end

function BackgroundManager:initMenuParticles()
    self.menuParticles = {}
    for _ = 1, 30 do
        table_insert(self.menuParticles, {
            x = math_random() * 1000,
            y = math_random() * 1000,
            size = math_random(2, 5),
            speed = math_random(20, 50),
            angle = math_random() * math_pi * 2,
            pulseSpeed = math_random(0.5, 2),
            pulsePhase = math_random() * math_pi * 2
        })
    end
end

function BackgroundManager:update(dt)
    self.time = self.time + dt

    -- Update menu particles
    for _, particle in ipairs(self.menuParticles) do
        particle.x = particle.x + math_cos(particle.angle) * particle.speed * dt
        particle.y = particle.y + math_sin(particle.angle) * particle.speed * dt

        -- Wrap around screen
        if particle.x < -50 then particle.x = 1000 + 50 end
        if particle.x > 1000 + 50 then particle.x = -50 end
        if particle.y < -50 then particle.y = 1000 + 50 end
        if particle.y > 1000 + 50 then particle.y = -50 end
    end
end

function BackgroundManager:drawMenuBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Animated gradient background
    for y = 0, screenHeight, 4 do
        local progress = y / screenHeight
        local pulse = (math_sin(time * 2 + progress * 4) + 1) * 0.1

        local r = 0.1 + progress * 0.3 + pulse
        local g = 0.1 + progress * 0.2 + pulse
        local b = 0.3 + progress * 0.4 + pulse

        love.graphics.setColor(r, g, b, 0.8)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Animated particles
    love.graphics.setColor(0.4, 0.6, 0.8, 0.6)
    for _, particle in ipairs(self.menuParticles) do
        local pulse = (math_sin(particle.pulsePhase + time * particle.pulseSpeed) + 1) * 0.5
        local currentSize = particle.size * (0.7 + pulse * 0.3)
        love.graphics.circle("fill", particle.x, particle.y, currentSize)
    end

    -- Floating connecting dots
    love.graphics.setColor(0.4, 0.6, 0.8, 0.3)
    for i = 1, 8 do
        local x = (screenWidth / 9) * i
        local y = screenHeight / 2 + math_sin(time + i) * 50
        local size = 20 + math_sin(time * 0.5 + i) * 5

        -- Draw dot
        love.graphics.circle("fill", x, y, size / 2)

        -- Draw connecting lines
        if i < 8 then
            local nextX = (screenWidth / 9) * (i + 1)
            local nextY = screenHeight / 2 + math_sin(time + i + 1) * 50
            love.graphics.setLineWidth(2)
            love.graphics.line(x, y, nextX, nextY)
            love.graphics.setLineWidth(1)
        end
    end

    -- Grid pattern
    love.graphics.setColor(0.2, 0.3, 0.5, 0.1)
    local gridSize = 40
    for x = 0, screenWidth, gridSize do
        love.graphics.line(x, 0, x, screenHeight)
    end
    for y = 0, screenHeight, gridSize do
        love.graphics.line(0, y, screenWidth, y)
    end
end

function BackgroundManager:drawGameBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Dark blue gradient
    for y = 0, screenHeight, 3 do
        local progress = y / screenHeight
        local wave = math_sin(progress * 8 + time) * 0.1
        local r = 0.05 + wave
        local g = 0.1 + progress * 0.1 + wave
        local b = 0.2 + progress * 0.3 + wave

        love.graphics.setColor(r, g, b, 0.6)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Animated grid particles
    love.graphics.setColor(0.3, 0.5, 0.8, 0.4)
    for i, particle in ipairs(self.gridParticles) do
        particle.x = particle.x + math_cos(particle.angle) * particle.speed * love.timer.getDelta()
        particle.y = particle.y + math_sin(particle.angle) * particle.speed * love.timer.getDelta()

        -- Wrap around screen
        if particle.x < -50 then particle.x = screenWidth + 50 end
        if particle.x > screenWidth + 50 then particle.x = -50 end
        if particle.y < -50 then particle.y = screenHeight + 50 end
        if particle.y > screenHeight + 50 then particle.y = -50 end

        love.graphics.circle("fill", particle.x, particle.y, particle.size)

        -- Draw connections to nearby particles
        love.graphics.setColor(0.2, 0.4, 0.7, 0.2)
        for j, other in ipairs(self.gridParticles) do
            if i ~= j then
                local dx = particle.x - other.x
                local dy = particle.y - other.y
                local dist = math_sqrt(dx * dx + dy * dy)
                if dist < 100 then
                    love.graphics.line(particle.x, particle.y, other.x, other.y)
                end
            end
        end
        love.graphics.setColor(0.3, 0.5, 0.8, 0.4)
    end

    -- Subtle grid in background
    love.graphics.setColor(0.1, 0.2, 0.4, 0.15)
    local gridSize = 30
    for x = 0, screenWidth, gridSize do
        love.graphics.line(x, 0, x, screenHeight)
    end
    for y = 0, screenHeight, gridSize do
        love.graphics.line(0, y, screenWidth, y)
    end
end

return BackgroundManager