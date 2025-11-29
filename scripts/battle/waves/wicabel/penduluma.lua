local CornerPendulums, super = Class(Wave)

function CornerPendulums:init()
    super.init(self)

    self.time = 200/30
    self.enemies = self:getAttackers()
	self.sameattack = #self.enemies

	self.btimer = 99
	
	self.pendulums = {}
end

function CornerPendulums:update()
    super.update(self)
	
	local arena = Game.battle.arena
	if self.btimer >= 105 then
		self.btimer = 0
		local side = Utils.randomSign()
		local vmirror = 1
		local xx
		if side == 1 then
			xx = arena.right
		elseif side == -1 then
			xx = arena.left
		end
		local selfoverlap = 0
		for _, bullet in ipairs(self.pendulums) do
			if MathUtils.sign(bullet.x - arena.x) == -side then
				selfoverlap = selfoverlap + 1
			end
		end
		if selfoverlap > 0 then
			vmirror = TableUtils.pick({1, -1, -1})
		elseif #Game.battle:getActiveEnemies() <= 1 then
			vmirror = TableUtils.pick({1, -1})
		end
		local yy, tilt
		if vmirror == 1 then
			yy = arena.bottom - 16 + (selfoverlap * 16)
			tilt = 80 + (selfoverlap * 30)
		elseif vmirror == -1 then
			if #Game.battle:getActiveEnemies() <= 1 then
				yy = arena.top + 16 - (selfoverlap * 16)
				tilt = 80 + (selfoverlap * 30)
			else
				yy = arena.top + 16 - ((selfoverlap - 1) * 16)
				tilt = 80 + ((selfoverlap - 1) * 30)
			end
		end
		local pendulum = self:spawnBullet("wicabel/cornerpendulum", xx, yy)
		pendulum.side = side
		local shaftdist
		if vmirror == 1 then
			shaftdist = MathUtils.dist(pendulum.x, pendulum.y, pendulum.swingpoint_x, pendulum.swingpoint_y)
			pendulum.x = pendulum.swingpoint_x + MathUtils.lengthDirX(shaftdist, math.rad(270 - (tilt * side)))
			pendulum.y = pendulum.swingpoint_y + MathUtils.lengthDirY(shaftdist, math.rad(270 - (tilt * side)))
			pendulum.physics.speed_y = -3
		elseif vmirror == -1 then
			pendulum.vertical_mirroring = -1
			pendulum.swingpoint_y = arena.bottom + 16 + 16
			pendulum.swingdistance = MathUtils.dist(pendulum.x, pendulum.y, pendulum.swingpoint_x, pendulum.swingpoint_y)
			shaftdist = MathUtils.dist(pendulum.x, pendulum.y, pendulum.swingpoint_x, pendulum.swingpoint_y)
			pendulum.x = pendulum.swingpoint_x + MathUtils.lengthDirX(shaftdist, math.rad(90 + (tilt * side)))
			pendulum.y = pendulum.swingpoint_y + MathUtils.lengthDirY(shaftdist, math.rad(90 + (tilt * side)))
			pendulum.physics.speed_y = 3
		end
		table.insert(self.pendulums, pendulum)
		self.btimer = 0
	end
	self.btimer = self.btimer + DTMULT
end

function CornerPendulums:getEnemyRatio()
    local enemies = #Game.battle:getActiveEnemies()
    if enemies <= 1 then
        return 1
    elseif enemies == 2 then
        return 1.6
    elseif enemies >= 3 then
        return 2.3
    end
end

function CornerPendulums:draw()
    super.draw(self)
	love.graphics.stencil(function()
        local last_shader = love.graphics.getShader()
        love.graphics.setShader(Kristal.Shaders["Mask"])
		love.graphics.translate(Game.battle.arena.left, Game.battle.arena.top)
		Game.battle.arena:drawMask()
		love.graphics.translate(-Game.battle.arena.left, -Game.battle.arena.top)
        love.graphics.setShader(last_shader)
    end, "replace", 1)
	love.graphics.stencil(function()
        local last_shader = love.graphics.getShader()
        love.graphics.setShader(Kristal.Shaders["Mask"])
		for _, bullet in ipairs(self.pendulums) do
			if bullet and not bullet:isRemoved() then
				local xx, yy = bullet:localToScreenPos(0, 0)
				love.graphics.translate(xx, yy)
				bullet:draw()
				love.graphics.translate(-xx, -yy)
			end
		end
        love.graphics.setShader(last_shader)
    end, "decrement", 1, true)
    love.graphics.setStencilTest("greater", 0)
	for _, bullet in ipairs(self.pendulums) do
		if bullet and not bullet:isRemoved() then
			bullet:drawMasked()
		end
	end
    love.graphics.setStencilTest()
end

return CornerPendulums