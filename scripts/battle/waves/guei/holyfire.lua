local HolyFire, super = Class(Wave)

function HolyFire:init()
    super.init(self)

    self.time = 200/30
    self.enemies = self:getAttackers()
	self.sameattack = #self.enemies
	self.ratio = 1
	if #Game.battle.enemies == 2 then
		self.ratio = 1.6
	elseif #Game.battle.enemies == 3 then
		self.ratio = 2.3
	end
	self.flame_active = false
	self.btimer = 0
	self.made = false
	self.flames_made = 0
	self.stoptimerconds = 0
end

function HolyFire:onStart()
	self.flame_active = true
end

function HolyFire:onEnd()
	super.onEnd(self)
	self.flame_active = false
end

function HolyFire:update()
    -- Code here gets called every frame
    super.update(self)
	if not self.flame_active then return end
	
	if not self.made then
		self.made = true
		self.btimer = 40
	end
	for sameattacker = 0, #self.enemies-1 do
		if self.stoptimerconds == 0 then
			if MathUtils.round((self.btimer - 40) % math.ceil(24 * self.ratio))  == 10 * sameattacker then
				local dist = 135 + MathUtils.random(20)
				local dir

				if self.sameattack == 1 then
					dir = 15 + MathUtils.random(30) + (60 * MathUtils.randomInt(2))
				elseif self.sameattack == 2 then
					dir = 15 + MathUtils.random(30) + (120 * sameattacker)
				else
					dir = 15 + MathUtils.random(20) + (65 * sameattacker)
				end

				self.flames_made = self.flames_made + 1
				local bullets = 2
				if self.ratio == 1 then
					bullets = 3
				end

				local a = self:spawnBullet("guei/holyfirespawner", Game.battle.arena.x + MathUtils.lengthDirX(dist, dir), Game.battle.arena.y + MathUtils.lengthDirY(dist * 0.75, dir), bullets, self.flames_made)
				a.speedtarg = 6
				a.widthmod = 1.25
				if FRAMERATE > 30 or (FRAMERATE == 0 and FPS > 30) then
					self.stoptimerconds = self.btimer
				end
			end
		end
	end
	self.btimer = self.btimer + DTMULT
	if self.stoptimerconds ~= 0 and self.btimer >= self.stoptimerconds+0.6 then
		self.stoptimerconds = 0
	end
end

return HolyFire