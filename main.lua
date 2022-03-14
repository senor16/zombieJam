-- Afficher les traces dans la console
io.stdout:setvbuf("no")
-- Pour faire du pixel art
love.graphics.setDefaultFilter("nearest")

local screen = {}

function love.load()
    screen.width = love.graphics.getWidth()
    screen.height = love.graphics.getHeight()
end

function love.update(dt)
    
end

function love.draw()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
