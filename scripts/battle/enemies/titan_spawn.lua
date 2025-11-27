local TitanSpawn, super = Class(EnemyBattler, "titan_spawn")

function TitanSpawn:init()
    super.init(self)

    self.name = "Titan Spawn"
    self:setActor("titan_spawn")

    self.max_health = 3000
    self.health = 3000
    self.attack = 18
    self.defense = 0
    self.money = 0

    self.disable_mercy = true

    self.tired = false
    self.tired_percentage = -1

    self.can_freeze = false

    self.waves = {
		"debugging/darkshape_test"
	}

    self.text = {
        "* You hear your heart beating in \nyour ears.",
        "* When did you start being \nyourself?",
        "* It sputtered in a voice like \ncrushed glass."
    }
    if Game:hasPartyMember("ralsei") then
        table.insert(self.text, "* Ralsei mutters to himself to \nstay calm.")
    end

	self.low_health_text = nil
	self.tired_text = nil
	self.spareable_text = nil

    self:getAct("Check").description = "Consider\nstrategy"
    self:registerAct("Brighten", "Powerup\nlight", "all", 4)
    self:registerAct("DualHeal", "Heal\nparty", {"susie", "ralsei"}, 16)
    self:registerAct("Banish",   "Defeat\nenemy",  nil,   64)

    self.dualhealcount = 0
end

function TitanSpawn:getGrazeTension()
    return 0
end

function TitanSpawn:getSpareText(battler, success)
    return "* But, it was not something that\ncan understand MERCY."
end

function TitanSpawn:isXActionShort(battler)
    return true
end

-- note about damage to PARTY: if ShadowMantle is equipped, then the next happens:
-- damage = round(damage * 0.5)
-- (data.win of chapter 4, scr_damage, line 86)
-- (adding this to not forget to add it to bullet code)
function TitanSpawn:getAttackDamage(damage, battler, points)
    if battler.chara:checkWeapon("blackshard") or battler.chara:checkWeapon("twistedswd") then
        local dmg = super.getAttackDamage(self, damage, battler, points)
        return math.ceil(dmg * 10)
    end
    return super.getAttackDamage(self, damage, battler, points)
end

function TitanSpawn:onShortAct(battler, name)
    if name == "Standard" then
        return "* " .. battler.chara:getName() .. " tried to ACT, but failed!"
    end
    return nil
end

function TitanSpawn:onAct(battler, name)
	if name == "Check" then
        if Game:getTension() >= 64 then
            return {
                "* TITAN SPAWN - AT 30 DF 200\n* A shard of fear. Appears \nin places of deep dark.",
                "* The atmosphere feels tense...\n* (You can use [color:yellow]BANISH[color:reset]!)"
            }
        else
            return {
                "* TITAN SPAWN - AT 30 DF 200\n* A shard of fear. Appears \nin places of deep dark.",
                "* Expose it to LIGHT... and gather COURAGE to gain TP.",
                "* Then, \"[color:yellow]BANISH[color:reset]\" it!",
            }
        end
    elseif name == "Brighten" then
        for _,party in ipairs(Game.battle.party) do
            party:flash()
        end
        Assets.playSound("boost")
        local bx, by = Game.battle:getSoulLocation()
        local soul = Sprite("effects/soulshine", bx + 5.5, by)
        soul:play(1 / 30, false, function() soul:remove() end)
        soul:setOrigin(0.5)
        soul:setScale(2, 2)
        Game.battle:addChild(soul)
		Game.battle.encounter.light_radius = 63
        return "* "..battler.chara:getName().."'s SOUL shone brighter!"
    elseif name == "DualHeal" then
        self.dualhealcount = self.dualhealcount + 1
        Game.battle:startActCutscene(function(cutscene)
            local susie = Game.battle:getPartyBattler("susie")
            local ralsei = Game.battle:getPartyBattler("ralsei")
            local canproceed = false
            local hashealed = false
            Game.battle.timer:after(7 / 30, function()
                susie:setAnimation("heal_charge") -- Susie starts the animation with the effects
                Assets.playSound("boost")
                battler:flash()
                susie:flash()
                ralsei:flash()
                local bx, by = Game.battle:getSoulLocation()
                local soul = Sprite("effects/soulshine", bx + 5.5, by)
                soul:play(1 / 30, false, function() soul:remove() end)
                soul:setOrigin(0.5)
                soul:setScale(2, 2)
                Game.battle:addChild(soul)
            end)
            Game.battle.timer:after(24 / 30, function()
                ralsei:setAnimation("battle/spell_ready") -- Ralsei starts the animation after a pause
                canproceed = true
            end)
            cutscene:text("* Your SOUL shined its power on\nRALSEI and SUSIE!")
            cutscene:wait(function() return canproceed == true end)
            susie:setAnimation("heal_end_short", function() susie:setAnimation("battle/idle") end)
            ralsei:setAnimation("battle/spell", function()
                for _,party in ipairs(Game.battle.party) do
                    local healnum = MathUtils.round((susie.chara:getStat("magic") + ralsei.chara:getStat("magic")) * 6)
                    Game.battle:applyHealBonuses(healnum, "susie") -- ralsei or susie??? Maybe needs 2 heal bonus appliers?????
                    local healmultiplier = 1.5
                    if self.dualhealcount == 2 then
                        healmultiplier = 1
                    elseif self.dualhealcount == 3 then
                        healmultiplier = 0.8
                    elseif self.dualhealcount == 4 then
                        healmultiplier = 0.3
                    elseif self.dualhealcount > 4 then
                        healmultiplier = 0.2
                    end
                    party:heal(MathUtils.round(healnum * healmultiplier))
                end
                hashealed = true
            end)
            if self.dualhealcount < 4 then
                cutscene:text("* Susie and Susie cast DUAL HEAL!\nEffectiveness of DUAL HEAL has\nlowered!")
            else
                cutscene:text("* Susie and Susie cast DUAL HEAL!")
            end
            cutscene:wait(function() return hashealed == true end)
        end)
        return
    elseif name == "Banish" then
        battler:setAnimation("act")
        Game.battle:startCutscene(function(cutscene)
            cutscene:text("* "..battler.chara:getName().."'s SOUL emitted a brilliant \nlight!")
            battler:flash()

            local bx, by = battler:getRelativePos(battler.width/2 + 4, battler.height/2 + 4)

            local soul = Game.battle:addChild(TitanSpawnPurifySoul(bx, by))
            soul.color = Game:getPartyMember(Game.party[1].id).soul_color or { 1, 0, 0 }
            soul.layer = 501

            local wait = function() return soul.t >= 500 end
            cutscene:wait(wait)
            cutscene:after(function()
                if #Game.battle.enemies == 0 then
                    Game.battle:setState("VICTORY")
                end
            end)
        end)
        return
    elseif name == "Standard" then
        Game.battle:startActCutscene(function(cutscene)
            cutscene:text("* "..battler.chara:getName().." tried to \"[color:yellow]ACT[color:reset]\"...\n* But, the enemy couldn't understand!")
        end)
        return
    end
    return super.onAct(self, battler, name)
end

function TitanSpawn:getEnemyDialogue()
    return false
end

function TitanSpawn:update()
    super.update(self)
end

function TitanSpawn:onSpared()
	local recruit = RecruitMessage("purified", 500, self.y - 40)
	recruit.start_x = 500
	Game.battle:addChild(recruit)
end

function TitanSpawn:onHurt(damage, battler)
	super.onHurt(self, damage, battler)

    Assets.stopAndPlaySound("spawn_weaker")
end

function TitanSpawn:onDefeat(damage, battler)
    self:onDefeatFatal(damage, battler)
end

function TitanSpawn:freeze()
    self:onDefeat()
end

function TitanSpawn:getEncounterText()
	if Game:getTension() < 64 and MathUtils.randomInt(100) < 4 then
		return "* Smells like adrenaline."
    elseif Game:getTension() >= 64 then 
		return "* The atmosphere feels tense...\n* (You can use [color:yellow]BANISH[color:reset]!)"
	else
		return super.getEncounterText(self)
	end
end

return TitanSpawn