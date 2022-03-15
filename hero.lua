local hero = newElement(100,100,10)
hero.type = "HERO"
function hero:load()
    local images= {}
    --- Add animations
    -- IDLE
    for i=0, 11 do
        if i<=9 then
            images[i] = love.graphics.newImage("vault/Hero/Animations/Idle/Idle_00"..i..".png")
        else
            images[i] = love.graphics.newImage("vault/Hero/Animations/Idle/Idle_0"..i..".png")
        end
    end
    addAnimation(self.listAnimations,"IDLE",images,1/25,true)

    -- RUN
    images={}
    for i=0, 13 do
        if i<=9 then
            images[i] = love.graphics.newImage("vault/Hero/Animations/Run/Run_00"..i..".png")
        else
            images[i] = love.graphics.newImage("vault/Hero/Animations/Run/Run_0"..i..".png")
        end
    end
    addAnimation(self.listAnimations,"RUN",images,1/25,true)

    -- SHOOT
    images={}
    for i=0, 14 do
        if i<=9 then
            images[i] = love.graphics.newImage("vault/Hero/Animations/Shoot/Shoot_00"..i..".png")
        else
            images[i] = love.graphics.newImage("vault/Hero/Animations/Shoot/Shoot_0"..i..".png")
        end
    end
    addAnimation(self.listAnimations,"SHOOT",images,1/25,true)

    -- HURT
    images={}
    for i=0, 9 do
            images[i] = love.graphics.newImage("vault/Hero/Animations/Hurt/Hurt_00"..i..".png")
    end
    addAnimation(self.listAnimations,"HURT",images,1/25,true)

    -- DEATH
    images={}
    for i=0, 14 do
        if i<=9 then
            images[i] = love.graphics.newImage("vault/Hero/Animations/Death/Death_00"..i..".png")
        else
            images[i] = love.graphics.newImage("vault/Hero/Animations/Death/Death_0"..i..".png")
        end
    end
    addAnimation(self.listAnimations,"DEATH",images,1/25,true)

    playAnimation(self,"IDLE")
end

---@param dt number
function hero:update(dt)
    -- Hero movement
    self.vx=0
    self.vy=0
    if love.keyboard.isDown("up") then
        self.vy = -self.speed*10*dt
    end
    if love.keyboard.isDown("right") then
        self.vx = self.speed*10*dt
        self.flip=1
    end
    if love.keyboard.isDown("down") then
        self.vy = self.speed*10*dt
    end
    if love.keyboard.isDown("left") then
        self.vx = -self.speed*10*dt
        self.flip=-1
    end

    if self.vx ~= 0 or self.vy~= 0 then
        playAnimation(self,"RUN")
    else
        playAnimation(self,"IDLE")
    end
    self.x = self.x+self.vx
    self.y = self.y+self.vy

    -- Hero animation
    updateAnimation(self,dt)

end

function hero:draw  ()
    if self.currentAnimation~= nil then
        love.graphics.draw(self.currentAnimation.frames[self.currentFrameInAnimation],self.x,self.y,0,self.flip,1,TILEWIDTH/2,TILEHEIGHT/2)
    end
end

return hero