local Utility = require("Utility")

local AutoUseItems = {}

AutoUseItems.optionDeward = Menu.AddOption({"Item Specific"}, "Deward", "Auto use quelling blade, iron talen, or battle fury to deward")
AutoUseItems.optionIronTalon = Menu.AddOption({"Item Specific"}, "Iron Talon", "Auto use iron talen to remove creep's HP")
AutoUseItems.optionHeal = Menu.AddOption({"Item Specific"}, "Heal", "Auto use magic wand(stick) or faerie fire if HP is low")
AutoUseItems.optionSheepstick = Menu.AddOption({"Item Specific"}, "Sheepstick", "Auto use sheepstick on enemy hero once available")
AutoUseItems.optionOrchid = Menu.AddOption({"Item Specific"}, "Orchid & Bloodthorn", "Auto use orchid or bloodthorn on enemy hero once available")

function AutoUseItems.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero then return end

    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return end
    if NPC.IsChannellingAbility(myHero) then return end
    if NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return end

    if Menu.IsEnabled(AutoUseItems.optionDeward) then
    	AutoUseItems.deward(myHero)
    end

    if Menu.IsEnabled(AutoUseItems.optionIronTalon) then
    	AutoUseItems.item_iron_talon(myHero)
    end

    if Menu.IsEnabled(AutoUseItems.optionHeal) then
    	AutoUseItems.heal(myHero)
    end

    if Menu.IsEnabled(AutoUseItems.optionSheepstick) then
    	AutoUseItems.item_sheepstick(myHero)
    end

    if Menu.IsEnabled(AutoUseItems.optionOrchid) then
    	AutoUseItems.item_orchid(myHero)
    end

end

-- Auto use quelling blade, iron talen, or battle fury to deward
function AutoUseItems.deward(myHero)
	local item1 = NPC.GetItem(myHero, "item_quelling_blade", true)
	local item2 = NPC.GetItem(myHero, "item_iron_talon", true)
	local item3 = NPC.GetItem(myHero, "item_bfury", true)

	local item = nil
	if item1 and Ability.IsCastable(item1, 0) then item = item1 end
	if item2 and Ability.IsCastable(item2, 0) then item = item2 end
	if item3 and Ability.IsCastable(item3, 0) then item = item3 end
	if not item then return end

	local range = 450
	local wards = NPC.GetUnitsInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
	for i, npc in ipairs(wards) do
		if NPC.GetUnitName(npc) == "npc_dota_observer_wards" or NPC.GetUnitName(npc) == "npc_dota_sentry_wards" then
			Ability.CastTarget(item, npc)
			return
		end
	end
end

-- Auto use iron talon to remove creep's HP
function AutoUseItems.item_iron_talon(myHero)
	local item = NPC.GetItem(myHero, "item_iron_talon", true)
	if not item or not Ability.IsCastable(item, 0) then return end

	local range = 350
	local creeps = NPC.GetUnitsInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
	if not creeps or #creeps <= 0 then return end

	local maxHp = 0
	local target = nil
	local ratio = 0.5
	for i, npc in ipairs(creeps) do
		local tmpHp = Entity.GetHealth(npc)
		if tmpHp > maxHp and NPC.IsCreep(npc) 
			and (not NPC.IsAncient(npc)) and (not NPC.IsRoshan(npc)) 
			and tmpHp > ratio*Entity.GetMaxHealth(npc) then
			maxHp = tmpHp
			target = npc
		end
	end

	if target then Ability.CastTarget(item, target) end
end

-- Auto use magic wand(stick) or faerie fire if HP is low
function AutoUseItems.heal(myHero)
	local item1 = NPC.GetItem(myHero, "item_magic_stick", true)
	local item2 = NPC.GetItem(myHero, "item_magic_wand", true)
	local item3 = NPC.GetItem(myHero, "item_faerie_fire", true)

	local item = nil
	if item1 and Ability.IsCastable(item1, 0) and Item.GetCurrentCharges(item1)>0 then item = item1 end
	if item2 and Ability.IsCastable(item2, 0) and Item.GetCurrentCharges(item2)>0 then item = item2 end
	if item3 and Ability.IsCastable(item3, 0) then item = item3 end
	if not item then return end

	local HpThreshold = 200
	if Entity.GetHealth(myHero) <= HpThreshold then
		Ability.CastNoTarget(item)
	end
end

-- Auto use sheepstick on enemy hero once available
-- Doesn't use on enemy who is lotus orb protected or AM with aghs.
function AutoUseItems.item_sheepstick(myHero)
	local item = NPC.GetItem(myHero, "item_sheepstick", true)
	if not item or not Ability.IsCastable(item, NPC.GetMana(myHero)) then return end

	local range = 800
	local enemyAround = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
	for i, enemy in ipairs(enemyAround) do
		if Utility.IsEligibleEnemy(enemy) and not Utility.IsLotusProtected(enemy) then
			Ability.CastTarget(item, enemy)
			return
		end
	end
end

-- Auto use orchid or bloodthorn on enemy hero once available
-- Doesn't use on enemy who is lotus orb protected or AM with aghs.
function AutoUseItems.item_orchid(myHero)
	local item1 = NPC.GetItem(myHero, "item_orchid", true)
	local item2 = NPC.GetItem(myHero, "item_bloodthorn", true)

	local item = nil
	if item1 and Ability.IsCastable(item1, NPC.GetMana(myHero)) then item = item1 end
	if item2 and Ability.IsCastable(item2, NPC.GetMana(myHero)) then item = item2 end
	if not item then return end

	local range = 900
	local enemyAround = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
	for i, enemy in ipairs(enemyAround) do
		if Utility.IsEligibleEnemy(enemy) and not NPC.IsSilenced(enemy) and not Utility.IsLotusProtected(enemy) then
			Ability.CastTarget(item, enemy)
			return
		end
	end
end

return AutoUseItems