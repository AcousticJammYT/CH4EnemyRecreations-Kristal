local CornerPendulum, super = Class(Bullet)

function CornerPendulum:init(x, y)
    super.init(self, x, y, "battle/bullets/wicabel/pendulum_ball")
	
	self.x = self.x + 16
	self.y = self.y + 16
    self:setScale(1)
    self.sprite:setOriginExact(16, 16)
    self.collider = CircleCollider(self, 0, 0, 16)

	self.side = 1
	self.alpha = 0
    self.swingtarget_x = self.x
    self.swingtarget_y = self.y
    self.swingpoint_x = self.swingtarget_x
    self.swingpoint_y = Game.battle.arena.top - 16 + 16
	self.swingdistance = MathUtils.dist(self.x, self.y, self.swingpoint_x, self.swingpoint_y)
	self.vertical_mirroring = 1
    self.collidable = false
	self.destroy_on_hit = false
	self.damage = 65
end

function CornerPendulum:update()
    super.update(self)

	self.alpha = self.alpha + 0.1 * DTMULT
	if self.alpha >= 1.5 then
		self.collidable = true
	end
	
	local shaftdir = -MathUtils.angle(self.x, self.y, self.swingpoint_x, self.swingpoint_y)
	local accel, swingdir
	
	if self.vertical_mirroring == 1 then
		if shaftdir < math.rad(90) or shaftdir > math.rad(270) then
			swingdir = shaftdir - math.rad(90)
		else
			swingdir = shaftdir + math.rad(90)
		end
		accel = MathUtils.lengthDirY(0.5, swingdir)
	elseif self.vertical_mirroring == -1 then
		if shaftdir < math.rad(90) or shaftdir > math.rad(270) then
			swingdir = shaftdir + math.rad(90)
		else
			swingdir = shaftdir - math.rad(90)
		end	
		accel = -MathUtils.lengthDirY(0.5, swingdir)
	end
	self.physics.speed_x = self.physics.speed_x + MathUtils.lengthDirX(accel*DTMULT, swingdir)
	self.physics.speed_y = self.physics.speed_y + MathUtils.lengthDirY(accel*DTMULT, swingdir)
	
	if swingdir < self.physics.direction - math.rad(180) then
		swingdir = swingdir + math.rad(360)
	end
	if swingdir > self.physics.direction + math.rad(180) then
		swingdir = swingdir - math.rad(360)
	end	
	if self.physics.direction > swingdir - math.rad(90) and self.physics.direction < swingdir + math.rad(90) then
		self.physics.direction = swingdir
	else
		self.physics.direction = swingdir - math.rad(180)
	end
	self.x = self.swingpoint_x - MathUtils.lengthDirX(self.swingdistance, shaftdir)
	self.y = self.swingpoint_y - MathUtils.lengthDirY(self.swingdistance, shaftdir)
	self.sprite.rotation = MathUtils.angle(self.swingpoint_x, self.swingpoint_y, self.x, self.y) - math.rad(90)
	
	local direction = math.deg(self.physics.direction)
	if (self.x >= self.swingtarget_x and (direction > 330 or direction < 30) and self.side == 1)
	or (self.x <= self.swingtarget_x and (direction > 150 or direction < 210) and self.side == -1) then
		self.x = self.swingtarget_x
		self.y = self.swingtarget_y
		self:remove()
	end
end

function CornerPendulum:draw()
    super.draw(self)
end

function CornerPendulum:drawMasked()
	local shaftdir = -MathUtils.angle(self.x, self.y, self.swingpoint_x, self.swingpoint_y)
    Draw.setColor(ColorUtils.hexToRGB("#777777"))
	local x1 = self.x + MathUtils.lengthDirX(3, shaftdir - math.rad(90)) - 16
	local y1 = self.y + MathUtils.lengthDirY(3, shaftdir - math.rad(90)) - 16
	local x2 = self.x + MathUtils.lengthDirX(3, shaftdir + math.rad(90)) - 16
	local y2 = self.y + MathUtils.lengthDirY(3, shaftdir + math.rad(90)) - 16
	local x3 = self.swingpoint_x + MathUtils.lengthDirX(3, shaftdir + math.rad(90)) - 16
	local y3 = self.swingpoint_y + MathUtils.lengthDirY(3, shaftdir + math.rad(90)) - 16
	local x4 = self.swingpoint_x + MathUtils.lengthDirX(3, shaftdir - math.rad(90)) - 16
	local y4 = self.swingpoint_y + MathUtils.lengthDirY(3, shaftdir - math.rad(90)) - 16
	love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
	love.graphics.polygon("fill", x1, y1, x3, y3, x4, y4)
    Draw.setColor(COLORS.white)
end

return CornerPendulum