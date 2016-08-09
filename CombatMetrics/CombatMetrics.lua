--aliases

local wm = GetWindowManager()
local em = GetEventManager()
local _


-- namespace for thg addon
if CMX == nil then CMX = {} end
 
-- Basic values
CMX.name = "CombatMetrics"
CMX.version = "0.6.1"

-- default values for saved variables
-- see http://wiki.esoui.com/AddOn_Quick_Questions#How_do_I_save_settings_on_the_local_machine.3F
CMX.defaults = {
	accountwide = false,
	timeout = 3000, 
	fighthistory = 15,
	chunksize = 300,
	saveddata = {},
	timeheals = false,
	recordgrp = true,
	debuginfo = {["fightsummary"] = false, ["ids"] = false, ["calculationtime"] = false, ["buffs"] = false, ["skills"] = false, ["group"] = false, ["misc"] = false,},
	autoscreenshot = false,
	autoscreenshotmintime = 30,
	EnableLiveMonitor = true, 
	EnableChatLog = false,
	EnableChatLogDmgOut = true,
	EnableChatLogHealOut = false,
	EnableChatLogDmgIn = false,
	EnableChatLogHealIn = false,
}
 
	--[[ 
	 * Append Table 2 to Table 1
	 * --------------------------------
	 * Called by Default Vars
	 * --------------------------------
	 ]]--  
function CMX:JoinTables(t1,t2)
	local t1 = t1 or {}
	local t2 = t2 or {}
	for k,v in pairs(t2) do t1[k]=v end
	return t1
end
  
 	--[[ 
	 * Add Table 2 to Table 1
	 * --------------------------------
	 * Called by Default Vars
	 * --------------------------------
	 ]]--  
function CMX:AddTables(resulttable,tables)
	local result=resulttable
	if tables == nil or result == nil then return end
	for i,j in pairs(tables) do
		for k,v in pairs(j) do 
			if result[k] == nil and v~=nil then 
				if type(v) == "table" then 
					result[k] = {}
					CMX:AddTables(result[k],{v}) 
				else result[k]=v
				end 
			elseif type(v) == "table" then 
				CMX:AddTables(result[k],{v})
			elseif type(v) == "number" then 
				if string.sub(k, 1, 3)  == "max" then 
					result[k]=math.max(result[k],v)
				elseif k == "dtype" then
					result[k]=v
				else
					result[k]=result[k]+v
				end
			elseif type(v) == "string" then
				if result[k]~=v then
					result[k] = result[k] or ""
				end
			end				
		end
	end
	return result
end
 
function CMX:spairs(t, order) -- from https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function CMX.newunit() -- called by CMX.calcchunk() or CMX.newfight()
	local newunittable = {
		["name"] = "",		-- name
		["utype"] = "",		-- type of unit: group, pet or boss 
		["ndmg"] = 0,		-- normal damage out
		["cdmg"] = 0,		-- critical damage out
		["tdmg"] = 0,		-- total damage out
		["sdmg"] = 0,		-- shielded damage out
		["bdmg"] = 0,		-- blocked damage out
		["nhits"] = 0,		-- normal hits out
		["chits"] = 0,		-- critical hits out
		["thits"] = 0,		-- total hits out
		["shits"] = 0,		-- shielded hits out
		["bhits"] = 0,		-- blocked hits out
		["nheal"] = 0,		-- normal healing out
		["cheal"] = 0,		-- critical healing out
		["theal"] = 0,		-- total healing out
		["nheals"] = 0,		-- normal heals out
		["cheals"] = 0,		-- critical heals out
		["theals"] = 0,		-- total heals out		
		["indmg"] = 0,		-- normal damage in
		["icdmg"] = 0,		-- critical damage in
		["itdmg"] = 0,		-- total damage in
		["isdmg"] = 0,		-- shielded damage in
		["ibdmg"] = 0,		-- blocked damage in
		["inhits"] = 0,		-- normal hits in
		["ichits"] = 0,		-- critical hits in
		["ithits"] = 0,		-- total hits in
		["ishits"] = 0,		-- shielded hits in
		["ibhits"] = 0,		-- blocked hits in
		["inheal"] = 0,		-- normal healing in
		["icheal"] = 0,		-- critical healing in
		["itheal"] = 0,		-- total healing in
		["inheals"] = 0,	-- normal heals in
		["icheals"] = 0,	-- critical heals in
		["itheals"] = 0,	-- total heals in
		["dps"] = 0,		-- dps
		["hps"] = 0,		-- hps
		["idps"] = 0,		-- incoming dps			
		["ihps"] = 0,		-- incoming hps		
		["dmgin"] = {},
		["dmgout"] = {},	
		["healin"] = {},
		["healout"] = {},
		["buffs"] = {}, 	-- buff tracking
	}
	return newunittable
end

function CMX.newfight() -- called by CMX.update
	local newfighttable = CMX.newunit()
	local newtable = {
		["char"] = CMX.playername,
		["calculating"] = false, -- start of combat in ms
		["time"] = nil,
		["date"] = nil,
		["combatstart"] = (0-CMX.set.timeout-1), -- start of combat in ms
		["combatend"] = -1,-- end of combat in ms
		["combattime"] = 0, -- total combat time
		["dpsstart"] = nil, -- start of dps in ms
		["dpsend"] = nil,  	-- end of dps in ms
		["dpstime"] = 0,	-- total dps time	
		["units"] = {},
		["log"] = {},
		["grplog"] = {},	-- log from group actions
		["grpdmg"] = 0,		-- dmg from and to the group
		["igrpdmg"] = 0,	-- dmg from and to the group
		["grpheal"] = 0,	-- heal of the group
		["gdps"] = 0,		-- group dps
		["ghps"] = 0,		-- group hps
		["igdps"] = 0,		-- incoming dps	on group
		["stats"] = {dmgavg={}, healavg ={}, dmginavg = {}, magickagains = {["name"] = "magickagps"} , staminagains = {["name"] = "staminagps"},	magickadrains = {["name"] = "magickadrps"} , staminadrains = {["name"] = "staminadrps"}},	-- stat tracking
	}
	CMX:JoinTables(newtable,newfighttable)
	newtable.group = CMX.inGroup
	return newtable
end

function CMX.createdmgability(aId, pet, dtype) -- called by CMX.update
	local emptyability =  {
		["name"] = zo_strformat("<<!aC:1>>",GetAbilityName(aId)),		-- ability name
		["pet"] = pet,
		["dtype"] = dtype or "", 
		["ndmg"] = 0,		-- normal damage out
		["cdmg"] = 0,		-- critical damage out
		["tdmg"] = 0,		-- total damage out
		["sdmg"] = 0,		-- shielded damage out
		["bdmg"] = 0,		-- blocked damage out
		["nhits"] = 0,		-- normal hits out
		["chits"] = 0,		-- critical hits out
		["thits"] = 0,		-- total hits out
		["shits"] = 0,		-- shielded hits out
		["bhits"] = 0,		-- blocked hits out
		["max"] = 0,		-- max hit
		["dps"] = 0,		-- dps or hps
		}
	return emptyability
end
function CMX.createhealability(aId, pet, dtype)
	local emptyability =  {
		["name"] = zo_strformat("<<!aC:1>>",GetAbilityName(aId)),		-- ability name
		["pet"] = pet,
		["dtype"] = dtype or "", 
		["nheal"] = 0,		-- normal healing out
		["cheal"] = 0,		-- critical healing out
		["theal"] = 0,		-- total healing out
		["nheals"] = 0,		-- normal heals out
		["cheals"] = 0,		-- critical heals out
		["theals"] = 0,		-- total heals out		
		["max"] = 0,		-- max hit
		["hps"] = 0,		-- dps or hps
		}
	return emptyability
end
function CMX.createbuff(dtype, aId)
	local emptybuff =  {
		["uptime"] = 0,		-- normal healing out
		["count"] = 0,		-- critical healing out
		["lastgain"] = nil,		-- total healing out
		["bufftype"] = dtype,   -- buff=1 or debuff=2
		["icon"] = GetAbilityIcon(aId)
		}
	return emptybuff
end

function CMX.onCombatState(event, inCombat)  -- called by Event
  if inCombat ~= CMX.inCombat then     -- Check if player state changed
    CMX.inCombat = inCombat
    local timems = GetGameTimeMilliseconds()
    -- Reset timers if timeout was reached
    if inCombat then
		if CMX.set.debuginfo.misc then d("Entering combat.") end
		if CMX.set.EnableChatLog then CMX.InitializeChat() end -- update Combatlog info
		if CMX.currentfight.date == nil or CMX.currentfight.time== nil then 
			-- if (timems - (CMX.currentfight.dpsstart or (0-CMX.set.timeout)) > CMX.set.timeout) then CMX.dpsstarttime = nil end
			CMX.currentfight.combatstart = timems
			CMX.currentfight.grplog = {}
			CMX.currentfight.date = GetDateStringFromTimestamp(GetTimeStamp())
			CMX.currentfight.time = GetTimeString()
			if DoesUnitExist("boss1") then 
				CMX.currentfight.bossfight = true
				CMX.currentfight.bossname = zo_strformat("<<!aC:1>>",GetUnitName("boss1")) 
			end
			CMX.getPlayerBuffs(timems)
			CMX.currentfight.stats.currentmagicka, _, _ = GetUnitPower("player", POWERTYPE_MAGICKA) 
			CMX.currentfight.stats.currentstamina, _, _ = GetUnitPower("player", POWERTYPE_STAMINA) 		
			CMX.currentfight.stats.currentulti, _, _ = GetUnitPower("player", POWERTYPE_ULTIMATE)
			CMX.GetNewStats()		
		end	
		if CMX.set.EnableChatLog then CMX.UI.CLAddLine(timems, "combat", nil, nil, nil, "Combat Start", nil, "message", "chat") end
		em:RegisterForUpdate("CMX_update", 200, function() CMX.update() end)
	else 
		if CMX.set.debuginfo.misc then d("Exiting combat.") end
		CMX.currentfight.combatend = timems
		CMX.currentfight.combattime = zo_round((timems - CMX.currentfight.combatstart)/10)/100
		CMX.onGroupJoin()
	end
  end
end

function CMX.getPlayerBuffs(timems)
	if IsUnitInCombat("player") == false then return end
	if CMX.playerid == nil then zo_callLater(function() CMX.getPlayerBuffs(timems) end, 1000) end
	for i=1,GetNumBuffs("player") do
		local buffName, _, endTime, _, _, _, _, effectType, abilityType, _, abilityId, _ = GetUnitBuffInfo("player",i)
		if abilityType==5 and endTime>0 then 
			if CMX.playerid~=nil and CMX.currentfight.units[CMX.playerid]==nil then 
				CMX.currentfight.units[CMX.playerid] = CMX.newunit()
				CMX.currentfight.units[CMX.playerid]["name"] = CMX.playername
				CMX.currentfight.units[CMX.playerid]["buffs"][buffName] = CMX.createbuff(effectType, abilityId)
				CMX.currentfight.units[CMX.playerid]["buffs"][buffName]["count"] = 1
				CMX.currentfight.units[CMX.playerid]["buffs"][buffName]["lastgain"] = timems-200
			end
		end
	end
end


-- Combat Events Functions
	 
	 --(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId) 
	 
function CMX.onCombatEventDmg(_ , result , _ , _ , _ , abilityActionSlotType , sourceName , sourceType , targetName , targetType , hitValue , _ , damageType , _ , sourceUnitId , targetUnitId , abilityId, action)  -- called by Event
	if CMX.playerid == nil and zo_strformat("<<!aC:1>>",sourceName) == CMX.playername then CMX.playerid = sourceUnitId end 
	if CMX.playerid == nil and zo_strformat("<<!aC:1>>",targetName) == CMX.playername then CMX.playerid = targetUnitId end
	if hitValue<2 or (not (sourceUnitId > 0 and targetUnitId > 0)) or (IsUnitInCombat("player") == false and (result==ACTION_RESULT_DOT_TICK_CRITICAL or result==ACTION_RESULT_DOT_TICK) ) or targetType==2 then return end -- only record if both unitids are valid or player is in combat or a non dot damage action happens or the target is not a pet
	local timems = GetGameTimeMilliseconds()
	if CMX.currentfight.units[sourceUnitId] == nil then
		CMX.currentfight.units[sourceUnitId] = CMX.newunit()
		if CMX.groupmembers[sourceUnitId] ~= nil then CMX.currentfight.units[sourceUnitId]["utype"] = "group" end
		if CMX.bossnames[zo_strformat("<<!aC:1>>",sourceName)] ~= nil then CMX.currentfight.units[sourceUnitId]["utype"] = "boss" end
		if sourceType==2 then CMX.currentfight.units[sourceUnitId]["utype"] = "pet" end
		sourceName = sourceName or CMX.groupmembers[sourceUnitId] or ""
		CMX.currentfight.units[sourceUnitId]["name"] = zo_strformat("<<!aC:1>>",sourceName) 
	end
	if CMX.playerid == nil and zo_strformat("<<!aC:1>>",sourceName) == CMX.playername then CMX.currentfight.units[sourceUnitId]["utype"]="player" end 
	if CMX.currentfight.units[sourceUnitId] ~= nil and CMX.currentfight.units[sourceUnitId]["name"] == "Offline" then CMX.currentfight.units[sourceUnitId]["name"] = zo_strformat("<<!aC:1>>",sourceName) end 
	if CMX.currentfight.units[targetUnitId] == nil then
		CMX.currentfight.units[targetUnitId] = CMX.newunit()
		if CMX.groupmembers[targetUnitId] ~= nil then CMX.currentfight.units[targetUnitId]["utype"] = "group" end
		if CMX.bossnames[zo_strformat("<<!aC:1>>",targetName)] ~= nil then CMX.currentfight.units[targetUnitId]["utype"] = "boss" end
		if targetType==2 then CMX.currentfight.units[targetUnitId]["utype"] = "pet" end
		targetName = targetName or CMX.groupmembers[targetUnitId] or ""
		CMX.currentfight.units[targetUnitId]["name"] = zo_strformat("<<!aC:1>>",targetName) 
	end
	if CMX.playerid == nil and zo_strformat("<<!aC:1>>",targetName) == CMX.playername then CMX.currentfight.units[targetUnitId]["utype"]="player" end
	if CMX.currentfight.units[targetUnitId] ~= nil and CMX.currentfight.units[targetUnitId]["name"] == "Offline" then CMX.currentfight.units[targetUnitId]["name"] = zo_strformat("<<!aC:1>>",targetName) end 
	action = action or sourceType==2 and "pdmg" or "dmg"
	table.insert(CMX.currentfight.log,{timems, result, sourceUnitId, targetUnitId, abilityId, hitValue, damageType, action})
	if CMX.set.EnableChatLog then CMX.UI.CLAddLine(timems, result, zo_strformat("<<!aC:1>>",sourceName), zo_strformat("<<!aC:1>>",targetName), abilityId, hitValue, damageType, action, "chat") end
	
end


function CMX.onCombatEventHeal(_ , result , _ , abilityName , _ , abilityActionSlotType , sourceName , sourceType , targetName , targetType , hitValue , _ , damageType , _ , sourceUnitId , targetUnitId , abilityId)  
	if hitValue<2 or (IsUnitInCombat("player") == false and (GetGameTimeMilliseconds() - (CMX.currentfight.combatend or 0) >= 50)) or targetType == 2 then return end				-- only record in combat, don't record pet incoming heal
	action = sourceType==2 and "pheal" or "heal"
	CMX.onCombatEventDmg(nil , result , nil , abilityName , nil , abilityActionSlotType , sourceName , sourceType , targetName , targetType , hitValue , nil , damageType , nil , sourceUnitId , targetUnitId , abilityId, action)
end

function CMX.onCombatEventDmgGrp(_ , _ , _ , _ , _ , _ , _ , _ , _ , targetType , hitValue , _ , _ , _ , _ , targetUnitId , _)  -- called by Event
	if hitValue<2 or targetUnitId == nil or targetType==2 then return end
	table.insert(CMX.currentfight.grplog,{tId=targetUnitId,value=hitValue,action="dmg"})
end

function CMX.onCombatEventHealGrp(_ , _ , _ , _ , _ , _ , _ , _ , _ , targetType , hitValue , _ , _ , _ , _ , targetUnitId , _)  -- called by Event
	if targetType==2 or hitValue<2 or (IsUnitInCombat("player") == false and (GetGameTimeMilliseconds() - (CMX.currentfight.combatend or 0) >= 50)) and targetUnitId ~= nil then return end
	table.insert(CMX.currentfight.grplog,{tId=targetUnitId,value=hitValue,action="heal"})
end

-- get bosses

function CMX.onBossesChanged(_) -- called by Event
	CMX.bosses=0
	CMX.bossnames={}
	for i = 1, 6 do
		local unitTag = 'boss' .. i
		if DoesUnitExist(unitTag) then 
			CMX.bosses=i 
			local name=zo_strformat("<<!aC:1>>",GetRawUnitName(unitTag))
			CMX.bossnames[name]=true
		else return
		end
	end
end

-- get Buffs/Dbuffs

--onEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)

function CMX.onEffectChanged(_, changeType, _, _, _, _, _, _, _, _, effectType, abilityType, _, unitName, unitId, abilityId)
	if (changeType~=1 and changeType~=2) or (effectType==1 and abilityType~=5) or (effectType==2 and abilityType==1) or (IsUnitInCombat("player") == false) or unitName=="Offline" then return end
	if CMX.currentfight.units[unitId] == nil then
		CMX.currentfight.units[unitId] = CMX.newunit()
		if CMX.playerid == nil and zo_strformat("<<!aC:1>>",unitName) == CMX.playername then CMX.playerid = unitId end
		if CMX.groupmembers[unitId] ~= nil then CMX.currentfight.units[unitId]["utype"] = "group" end
		if CMX.bossnames[zo_strformat("<<!aC:1>>",unitName)] ~= nil then CMX.currentfight.units[unitId]["utype"] = "boss" end
		if targetType==2 then CMX.currentfight.units[unitId]["utype"] = "pet" end
		unitName = unitName or CMX.groupmembers[unitId] or ""
		CMX.currentfight.units[unitId]["name"] = zo_strformat("<<!aC:1>>",unitName) 
	end
	if changeType>2 or (effectType==1 and abilityType~=5) or (effectType==2 and abilityType==1) or (IsUnitInCombat("player") == false) then return end
	if CMX.set.debuginfo.buffs then d(changeType..","..GetAbilityName(abilityId)..", ET:"..effectType..","..abilityType) end
	local timems = GetGameTimeMilliseconds()
	table.insert(CMX.currentfight.log,{timems, changeType, nil, unitId, abilityId, 0, effectType, "buff"})
	CMX.GetNewStats(timems)
end

function CMX.onGroupEffectChanged(_, _,  _, _, unitTag, _, _, _, _, _, _, _, _, unitName, unitId, _) -- Get Name Tag and Id of members in group
	if unitId==nil or unitName==nil then return end
	if (CMX.groupmembers[unitId] ~= nil and CMX.groupmembers[unitName] ~= nil) then return end
	if string.sub(unitTag, 1, 5)  == "group" then
		unitName = zo_strformat("<<!aC:1>>",unitName)
		CMX.groupmembers[unitId] = unitName
		CMX.groupmembers[unitName] = unitId
		if unitId > 0 and unitName ~= nil and CMX.currentfight.units[unitId] ~= nil then 
			CMX.currentfight.units[unitId]["name"] = zo_strformat("<<!aC:1>>",unitName) 
			CMX.currentfight.units[unitId]["utype"] = "group" 
		end
	end
	--d(changeType..", ".. effectName..", ".. unitTag..", ".. unitName..", ".. abilityId)
end

function CMX.onGroupJoin(_, _)
	if CMX.inGroup == IsUnitGrouped("player") then return end
	if CMX.set.debuginfo.group then d("player is now "..(IsUnitGrouped("player") and "" or "not").."in group") end
	CMX.inGroup = IsUnitGrouped("player")
	CMX.CombatEvents = CMX:GroupEvents(CMX.inGroup) --register or deregister events for group damage
end

function CMX.onGroupLeave(_, characterName, _, isLocalPlayer, _, _) 
	local unitName = zo_strformat("<<!aC:1>>",characterName)
	if isLocalPlayer then 
		CMX.groupmembers = {}
		CMX.inGroup = IsUnitGrouped("player")
		CMX.CombatEvents = CMX:GroupEvents(CMX.inGroup)
	elseif CMX.groupmembers[unitName] ~= nil then
		local id = CMX.groupmembers[unitName]
		CMX.groupmembers["unitName"] = nil
		CMX.groupmembers[id] = nil
		if CMX.set.debuginfo then d("Player left, updated group") end
	end
end

function CMX.onSlotUpdate(_, slot)
	if slot<=2 then return end
	local timems = GetGameTimeMilliseconds()
	local cost,powerType = GetSlotAbilityCost(slot)
	local aId = GetSlotBoundId(slot)
	if (powerType~=0 and powerType~=6) then return end
	table.insert(CMX.lastabilities,{timems, aId, -cost, powerType})
	if #CMX.lastabilities>18 then table.remove(CMX.lastabilities,1) end
	if CMX.set.debuginfo.skills then d("Slot used: "..timems..", "..aId..", "..cost..", "..powerType..", "..#CMX.lastabilities) end
end

function CMX.onBaseResourceChanged (_,unitTag,_,powerType,powerValue,_,_) 
	if unitTag~="player" then return end
	local timenow = GetGameTimeMilliseconds()
	local powerValueChange
	local aId=nil
 	if powerType==POWERTYPE_MAGICKA then
		powerValueChange = powerValue - (CMX.currentfight.stats.currentmagicka or powerValue)
		CMX.currentfight.stats.currentmagicka = powerValue
		if powerValueChange<0 then 
			if CMX.set.debuginfo.skills then d("Skill cost: "..powerValueChange) end
			for i=0,#CMX.lastabilities-1 do
				local ratio = powerValueChange/CMX.lastabilities[#CMX.lastabilities-i][3]
				if CMX.set.debuginfo.skills and powerType == CMX.lastabilities[#CMX.lastabilities-i][4] then d("Ratio: "..ratio) end
				local goodratio = ratio>=1 and ratio<=1.02
				if (powerValueChange == CMX.lastabilities[#CMX.lastabilities-i][3] or goodratio) and powerType == CMX.lastabilities[#CMX.lastabilities-i][4] then 
					_, aId, _, _ = unpack(CMX.lastabilities[#CMX.lastabilities-i])
					table.remove(CMX.lastabilities,#CMX.lastabilities-i)
					break
				end
			end
		end
		if aId == nil and powerValueChange ~= GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP) then return end
	elseif powerType==POWERTYPE_STAMINA then
		powerValueChange = powerValue - (CMX.currentfight.stats.currentstamina or powerValue)
		CMX.currentfight.stats.currentstamina = powerValue
		if powerValueChange<0 then 
			for i=0,#CMX.lastabilities-1 do
				local ratio = powerValueChange/CMX.lastabilities[#CMX.lastabilities-i][3]
				if CMX.set.debuginfo.skills and powerType == CMX.lastabilities[#CMX.lastabilities-i][4] then d("Ratio: "..ratio) end
				local goodratio = ratio>=1 and ratio<=1.02
				if (powerValueChange == CMX.lastabilities[#CMX.lastabilities-i][3] or goodratio) and powerType == CMX.lastabilities[#CMX.lastabilities-i][4] then 
					_, aId, _, _ = unpack(CMX.lastabilities[#CMX.lastabilities-i])
					table.remove(CMX.lastabilities,#CMX.lastabilities-i)
					break
				end
			end
		end
		if aId == nil and powerValueChange ~= GetPlayerStat(STAT_STAMINA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP) then return end
	elseif powerType==POWERTYPE_ULTIMATE then
		powerValueChange = powerValue - (CMX.currentfight.stats.currentulti or powerValue)
		CMX.currentfight.stats.currentulti = powerValue
		if powerValueChange == 0 then return end
	end
	if (powerType~=0 and powerType~=6 and powerType~= 10) or (IsUnitInCombat("player") == false) then return end 
	-- if CMX.set.debuginfo then d(eventCode..",u"..unitTag..",i"..powerIndex..",t"..powerType..",v"..powerValue..",m"..powerMax..",em"..powerEffectiveMax) end
	table.insert(CMX.currentfight.log,{timenow, nil, nil, nil, aId, powerValueChange, powerType, "resource"})
end

--(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId) 

function CMX.onResourceChanged (_, result, _, _, _, _, _, _, targetName, _, powerValueChange, powerType, _, _, _, targetUnitId, abilityId) 
	if CMX.playerid == nil and zo_strformat("<<!aC:1>>",targetName) == CMX.playername then CMX.playerid = targetUnitId end
	targetName = zo_strformat("<<!aC:1>>",targetName)
	local timenow = GetGameTimeMilliseconds()
	if (powerType~=0 and powerType~=6) or (IsUnitInCombat("player") == false) or powerValueChange<1 or targetName~=CMX.playername then return end 
	-- if CMX.set.debuginfo then d(eventCode..",u"..unitTag..",i"..powerIndex..",t"..powerType..",v"..powerValue..",m"..powerMax..",em"..powerEffectiveMax) end
	if result==ACTION_RESULT_POWER_DRAIN then powerValueChange = -powerValueChange end
	table.insert(CMX.currentfight.log,{timenow, nil, nil, nil, abilityId, powerValueChange, powerType, "resource"})
end

 
function CMX.GetStats()
	local spellpower 	= GetPlayerStat(STAT_SPELL_POWER, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP)
	local spellcrit 	= GetPlayerStat(STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP)
	local maxmagicka 	= GetPlayerStat(STAT_MAGICKA_MAX, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP)
	
	local weaponpower 	= GetPlayerStat(STAT_POWER, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP)
	local weaponcrit 	= GetPlayerStat(STAT_CRITICAL_STRIKE, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP)
	local maxstamina 	= GetPlayerStat(STAT_STAMINA_MAX, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP)
	
	local physres 		= GetPlayerStat(STAT_PHYSICAL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP)
	local spellres		= GetPlayerStat(STAT_SPELL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP)
	local critres		= GetPlayerStat(STAT_CRITICAL_RESISTANCE, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP)
	
	return {["spellpower"]=spellpower, ["spellcrit"]=spellcrit, ["maxmagicka"]=maxmagicka, ["weaponpower"]=weaponpower, ["weaponcrit"]=weaponcrit, ["maxstamina"]=maxstamina, ["physres"]=physres, ["spellres"]=spellres, ["critres"]=critres}
end

function CMX.GetNewStats(timems)
	for k,v in pairs(CMX.GetStats()) do
		if CMX.currentfight.stats["current"..k] == nil or CMX.currentfight.stats["max"..k] == nil then 
			CMX.currentfight.stats["current"..k] = v 
			CMX.currentfight.stats["max"..k] = v 
		elseif CMX.currentfight.stats["current"..k] ~= v and timems ~= nil and CMX.inCombat then 
			table.insert(CMX.currentfight.log,{timems, v - CMX.currentfight.stats["current"..k], nil, nil, nil, v, k, "stats"})
			CMX.currentfight.stats["current"..k] = v
			CMX.currentfight.stats["max"..k] = math.max(CMX.currentfight.stats["max"..k] or v, v)
		end
	end
end

function CMX.onWeaponSwap(_, isHotbarSwap)
	if not isHotbarSwap then return end
	local timems = GetGameTimeMilliseconds()
	if CMX.inCombat then table.insert(CMX.currentfight.log,{timems, "weapon swap", nil, nil, nil, nil, nil, "message"}) end
	CMX.GetNewStats(timems)
end

--[[
function CMX.test()
	local i=0
	while i<5 do
		i=i+1
		d(i)
	end
end--]]

function CMX.calcLive(index,newindex) -- called by CMX.update
	for i=index,newindex do 
		-- {GetGameTimeMilliseconds(), result, sourceUnitId, targetUnitId, abilityId, hitValue, damageType, action}
		local timems, result, sId, tId, _, value, _, action = unpack(CMX.currentfight.log[i])
		local target = tId~=nil and CMX.currentfight.units[tId]["name"] or ""
		local source = sId~=nil and CMX.currentfight.units[sId]["name"] or ""
		if action == "dmg" or action == "pdmg" then --Damage
			if tId==sId	and target == CMX.playername then									--don't count damage to yourself 							
			elseif source == CMX.playername or action == "pdmg" then 											--outgoing dmg
				CMX.currentfight.tdmg = CMX.currentfight.tdmg + value
				CMX.currentfight.units[tId]["tdmg"] = CMX.currentfight.units[tId]["tdmg"] + value
				CMX.currentfight.dpsstart = CMX.currentfight.dpsstart or timems
				CMX.currentfight.dpsend = timems
				CMX.currentfight.log[i][8] = action.."out"
			elseif target == CMX.playername	then						 					--incoming dmg
				if result == ACTION_RESULT_DAMAGE_SHIELDED then
					CMX.currentfight.isdmg = CMX.currentfight.isdmg + value
				else 
					CMX.currentfight.itdmg = CMX.currentfight.itdmg + value
				end
				CMX.currentfight.log[i][8] = action.."in"
			end
		elseif action == "heal" then
			if source == CMX.playername or action == "pheal" then --outgoing heal
				CMX.currentfight.theal = CMX.currentfight.theal + value
				if CMX.set.timeheals then CMX.currentfight.dpsstart = CMX.currentfight.dpsstart or timems end
				CMX.currentfight.dpsend = CMX.set.timeheals and timems or CMX.currentfight.dpsend
				CMX.currentfight.log[i][8] = action.."out"
			end
			if target == CMX.playername then --incoming heals
				CMX.currentfight.itheal = CMX.currentfight.itheal + value
				CMX.currentfight.log[i][8] = (CMX.currentfight.log[i][8]=="healout" and "healself") or "healin" 
			end
		end
	end
	if CMX.inGroup and CMX.set.recordgrp then
		local iend = #CMX.currentfight.grplog
		if iend > 1 then
			for i=1,iend do 
				local i2 = iend+1-i
				local line = CMX.currentfight.grplog[i2]
				local id,value,action = line.tId,line.value,line.action
				if (action=="heal" and (CMX.groupmembers[id] ~= nil)) then --only identified events are removed. The others might be identified later.
					CMX.currentfight.grpheal = CMX.currentfight.grpheal+value
					table.remove(CMX.currentfight.grplog,i2)
				elseif CMX.groupmembers[id] == nil and CMX.currentfight.units[id] ~= nil and action=="dmg" then
					CMX.currentfight.grpdmg = CMX.currentfight.grpdmg+value
					table.remove(CMX.currentfight.grplog,i2)
				elseif CMX.groupmembers[id] ~= nil and action=="dmg" then
					CMX.currentfight.igrpdmg = CMX.currentfight.igrpdmg+value
					table.remove(CMX.currentfight.grplog,i2) 
				end
			end
		end
	end
	if CMX.currentfight.dpsend == nil or CMX.currentfight.dpsstart == nil then return end
	CMX.currentfight.dpstime = math.max((CMX.currentfight.dpsend-CMX.currentfight.dpsstart)/1000,1)
	CMX.currentfight.dps = math.floor(CMX.currentfight.tdmg/CMX.currentfight.dpstime+0.5)
	CMX.currentfight.hps = math.floor(CMX.currentfight.theal/CMX.currentfight.dpstime+0.5)
	CMX.currentfight.idps = math.floor(CMX.currentfight.itdmg/CMX.currentfight.dpstime+0.5)
	CMX.currentfight.ihps = math.floor(CMX.currentfight.itheal/CMX.currentfight.dpstime+0.5)
	CMX.currentfight.gdps = math.floor(CMX.currentfight.grpdmg/CMX.currentfight.dpstime+0.5)
	CMX.currentfight.igdps = math.floor(CMX.currentfight.igrpdmg/CMX.currentfight.dpstime+0.5)
	CMX.currentfight.ghps = math.floor(CMX.currentfight.grpheal/CMX.currentfight.dpstime+0.5)	
	CMX.UI.LRUpdate(CMX.currentfight.dps,CMX.currentfight.hps,CMX.currentfight.idps,CMX.currentfight.ihps,CMX.currentfight.dpstime,CMX.currentfight.gdps,CMX.currentfight.igdps,CMX.currentfight.ghps)
end

function CMX.update()
	local index = CMX.currentindex or 0
	local newindex = #CMX.currentfight.log or 0
	--reset data
	if newindex == 0 then return end
	local endtime = CMX.currentfight.combatend or CMX.currentfight.dpsend or 0
	if (newindex>0 and CMX.inCombat==false and index == newindex and CMX.currentfight.dpsstart~=nil and CMX.currentfight.combatend>0 and (GetGameTimeMilliseconds() > (CMX.currentfight.combatend + CMX.set.timeout) or not CMX_Report:IsHidden() ) ) then
		if CMX.currentfight.tdmg>0 or CMX.currentfight.theal>0 or CMX.currentfight.itdmg>0 then
			table.insert(CMX.lastfights,CMX.currentfight)
			if CMX.set.fighthistory < #CMX.lastfights then table.remove(CMX.lastfights,1) end
			CMX.calcfight=#CMX.lastfights
			CMX.calcFull()
			if CMX.set.debuginfo.fightsummary then 
				d("Time: "..CMX.currentfight.dpstime.."s - Events: "..newindex)
				d("Dmg: "..CMX.currentfight.tdmg.." (DPS: "..CMX.currentfight.dps..")")
				d("Heal: "..CMX.currentfight.theal.." (HPS: "..CMX.currentfight.hps..")")
				d("IncDmg: "..CMX.currentfight.itdmg.." (Sh: "..CMX.currentfight.isdmg..", (IncDPS: "..CMX.currentfight.idps..")")
				d("IncHeal: "..CMX.currentfight.itheal.." (IncHPS: "..CMX.currentfight.ihps..")")
				if CMX.inGroup and CMX.set.recordgrp then
					d("GrpDmg: "..CMX.currentfight.grpdmg.." (DPS: "..CMX.currentfight.gdps..")")
					d("GrpHeal: "..CMX.currentfight.grpheal.." (HPS: "..CMX.currentfight.ghps..")")
					d("GrpIncDmg: "..CMX.currentfight.igrpdmg.." (IncDPS: "..CMX.currentfight.igdps..")")
				end
			end
		end
		if CMX.set.debuginfo.calculationtime then d("CMX: resetting...") end
		if CMX.set.EnableChatLog then CMX.UI.CLAddLine(CMX.currentfight.combatend, "combat", nil, nil, nil, "Combat End", nil, "message", "chat") end
		CMX.currentindex = 0
		CMX.currentfight = CMX.newfight()
		em:UnregisterForUpdate("CMX_update")
		if (not CMX_Report:IsHidden()) then CMX.UI:UpdateReport(nil, #CMX.lastfights) end
		return
	elseif (index == newindex) then return 
	elseif (newindex > index) then
		CMX.calcLive(index+1,newindex)
		CMX.currentindex = newindex
	end 
end

function CMX.calcFull() -- called by CMX.update or on user interaction
	CMX.cindex = 0
	CMX.lastfights[CMX.calcfight]["calculating"] = true
	CMX.calcChunk()
end

function CMX.calcChunk() -- called by CMX.calcFull or itself
	em:UnregisterForUpdate("CMX_chunk")
	--[[
	if CMX.inCombat then 
		em:RegisterForUpdate("CMX_chunk", 1000, function() CMX.calcChunk() end) -- bail out if in combat and check again in a second. 
		return 
	end	--]]
	local scalcms = GetGameTimeMilliseconds()
	local data = {}
	if CMX.calcfight > 0 and CMX.calcfight <= CMX.set.fighthistory and CMX.lastfights[CMX.calcfight]~=nil and CMX.lastfights[CMX.calcfight]["dpsstart"]~=nil then
		data = CMX.lastfights[CMX.calcfight]
	else CMX.lastfights[CMX.calcfight]["calculating"] = false return end
	local istart = CMX.cindex
	local iend = math.min(istart+CMX.set.chunksize, #data.log)
	for i=istart+1,iend do
		local timems, result, sId, tId, aId, value, dtype, action = unpack(data.log[i])
		local targetdata, sourcedata = {},{}
		--outgoing dmg
		if timems>(data.combatstart-500) and (action == "dmgout" or action == "pdmgout") then
			targetdata = data.units[tId]
			local pet = action == "pdmgout"
			if targetdata.dmgout[aId] == nil then targetdata.dmgout[aId] = CMX.createdmgability(aId, pet, dtype) end --ability stats
			if (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DOT_TICK) then 						--normal hits
				targetdata.ndmg = targetdata.ndmg + value
				targetdata.nhits = targetdata.nhits + 1	
				targetdata.dmgout[aId]["ndmg"] = targetdata.dmgout[aId]["ndmg"] + value
				targetdata.dmgout[aId]["nhits"] = targetdata.dmgout[aId]["nhits"] + 1
			elseif (result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK_CRITICAL) then  	--critical hits
				targetdata.cdmg = targetdata.cdmg + value
				targetdata.chits = targetdata.chits + 1	
				targetdata.dmgout[aId]["cdmg"] = targetdata.dmgout[aId]["cdmg"] + value
				targetdata.dmgout[aId]["chits"] = targetdata.dmgout[aId]["chits"] + 1
			elseif result == ACTION_RESULT_BLOCKED_DAMAGE then													--blocked hits
				targetdata.bdmg = targetdata.bdmg + value
				targetdata.bhits = targetdata.bhits + 1	
				targetdata.dmgout[aId]["bdmg"] = targetdata.dmgout[aId]["bdmg"] + value
				targetdata.dmgout[aId]["bhits"] = targetdata.dmgout[aId]["bhits"] + 1
			elseif result == ACTION_RESULT_DAMAGE_SHIELDED then													--shielded hits 
				targetdata.sdmg = targetdata.sdmg + value
				targetdata.shits = targetdata.shits + 1
				targetdata.dmgout[aId]["sdmg"] = targetdata.dmgout[aId]["sdmg"] + value
				targetdata.dmgout[aId]["shits"] = targetdata.dmgout[aId]["shits"] + 1
			end
			if targetdata.dmgout[aId] ~= nil then 
				targetdata.dmgout[aId]["tdmg"] = targetdata.dmgout[aId]["tdmg"] + value
				targetdata.dmgout[aId]["thits"] = targetdata.dmgout[aId]["thits"] + 1
				targetdata.dmgout[aId]["max"] = math.max(targetdata.dmgout[aId]["max"],value)
				targetdata.dmgout[aId]["dps"] = math.floor(targetdata.dmgout[aId]["tdmg"]/data.dpstime+0.5)
			end 
			targetdata.tdmg = targetdata.ndmg + targetdata.cdmg + targetdata.bdmg
			targetdata.dps = math.floor(targetdata.tdmg/data.dpstime+0.5)
			targetdata.thits = targetdata.nhits + targetdata.chits + targetdata.bhits + targetdata.shits
			data.units[tId] = targetdata
			for k,v in pairs(CMX.offstatlist) do 
				data.stats.dmgavg["t"..v] = (data.stats.dmgavg["t"..v] or 0) + ((((v=="spellcrit" or v=="weaponcrit") and 1) or value) * data.stats["current"..v]) -- sum up stats multplied by value, later this is divided by value to get a weighted average
			end 
		end
		--outgoing heal
		if timems>(data.combatstart-500) and (action == "healout" or action == "healself" or action == "phealout") then
			targetdata = data.units[tId]
			local pet = action == "phealout"
			if targetdata.healout[aId] == nil then targetdata.healout[aId] = CMX.createhealability(aId, pet, dtype) end
			if (result == ACTION_RESULT_HOT_TICK or result == ACTION_RESULT_HEAL)  then														--normal heals 
				targetdata.nheal = targetdata.nheal + value
				targetdata.nheals = targetdata.nheals + 1
				targetdata.healout[aId]["nheal"] = targetdata.healout[aId]["nheal"] + value
				targetdata.healout[aId]["nheals"] = targetdata.healout[aId]["nheals"] + 1
			elseif (result == ACTION_RESULT_CRITICAL_HEAL or result == ACTION_RESULT_HOT_TICK_CRITICAL) then									--critical heals 
				targetdata.cheal = targetdata.cheal + value
				targetdata.cheals = targetdata.cheals + 1 --ability stats
				targetdata.healout[aId]["cheal"] = targetdata.healout[aId]["cheal"] + value
				targetdata.healout[aId]["cheals"] = targetdata.healout[aId]["cheals"] + 1
			end
			if targetdata.healout[aId] ~= nil then 
				targetdata.healout[aId]["theal"] = targetdata.healout[aId]["theal"] + value
				targetdata.healout[aId]["theals"] = targetdata.healout[aId]["theals"] + 1
				targetdata.healout[aId]["max"] = math.max(targetdata.healout[aId]["max"],value)
				targetdata.healout[aId]["hps"] = math.floor(targetdata.healout[aId]["theal"]/data.dpstime+0.5)
			end 
			targetdata.theal = targetdata.nheal + targetdata.cheal
			targetdata.hps = math.floor(targetdata.theal/data.dpstime+0.5)
			targetdata.theals = targetdata.nheals + targetdata.cheals
			data.units[tId] = targetdata
			for k,v in pairs(CMX.offstatlist) do 
				data.stats.healavg["t"..v] = (data.stats.healavg["t"..v] or 0) + ((((v=="spellcrit" or v=="weaponcrit") and 1) or value) * data.stats["current"..v]) -- sum up stats multplied by value, later this is divided by value to get a weighted average
			end 
		end
		--incoming dmg 
		if timems>(data.combatstart-500) and (action == "dmgin") then
			sourcedata = data.units[sId]
			local pet = false
			if sourcedata.dmgin[aId] == nil then sourcedata.dmgin[aId] = CMX.createdmgability(aId, pet, dtype) end
			if result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DOT_TICK then
				sourcedata.indmg = sourcedata.indmg + value
				sourcedata.inhits = sourcedata.inhits + 1
				sourcedata.dmgin[aId]["ndmg"] = sourcedata.dmgin[aId]["ndmg"] + value
				sourcedata.dmgin[aId]["nhits"] = sourcedata.dmgin[aId]["nhits"] + 1
			elseif result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK_CRITICAL then
				sourcedata.icdmg = sourcedata.icdmg + value
				sourcedata.ichits = sourcedata.ichits + 1
				sourcedata.dmgin[aId]["cdmg"] = sourcedata.dmgin[aId]["cdmg"] + value
				sourcedata.dmgin[aId]["chits"] = sourcedata.dmgin[aId]["chits"] + 1
			elseif result == ACTION_RESULT_BLOCKED_DAMAGE then
				sourcedata.ibdmg = sourcedata.ibdmg + value
				sourcedata.ibhits = sourcedata.ibhits + 1
				sourcedata.dmgin[aId]["bdmg"] = sourcedata.dmgin[aId]["bdmg"] + value
				sourcedata.dmgin[aId]["bhits"] = sourcedata.dmgin[aId]["bhits"] + 1
			elseif result == ACTION_RESULT_DAMAGE_SHIELDED  then
				sourcedata.isdmg = sourcedata.isdmg + value
				sourcedata.ishits = sourcedata.ishits + 1
				sourcedata.dmgin[aId]["sdmg"] = sourcedata.dmgin[aId]["sdmg"] + value
				sourcedata.dmgin[aId]["shits"] = sourcedata.dmgin[aId]["shits"] + 1
			end
			if sourcedata.dmgin[aId] ~= nil then 
				sourcedata.dmgin[aId]["tdmg"] = sourcedata.dmgin[aId]["tdmg"] + value
				sourcedata.dmgin[aId]["thits"] = sourcedata.dmgin[aId]["thits"] + 1
				sourcedata.dmgin[aId]["max"] = math.max(sourcedata.dmgin[aId]["max"],value)
				sourcedata.dmgin[aId]["dps"] = math.floor(sourcedata.dmgin[aId]["tdmg"]/data.dpstime+0.5)
			end 
			sourcedata.itdmg = sourcedata.indmg + sourcedata.icdmg + sourcedata.ibdmg + sourcedata.isdmg
			sourcedata.idps = math.floor(sourcedata.itdmg/data.dpstime+0.5)
			sourcedata.ithits = sourcedata.inhits + sourcedata.ichits + sourcedata.ibhits + sourcedata.ishits
			data.units[sId] = sourcedata
			for k,v in pairs(CMX.defstatlist) do 
				data.stats.dmginavg["t"..v] = (data.stats.dmginavg["t"..v] or 0) + (((v=="critres" and 1) or value) * data.stats["current"..v]) -- sum up stats multplied by value, later this is divided by value to get a weighted average
			end 
		end
		--incoming heal 
		if timems>(data.combatstart-500) and (action == "healin" or action == "healself") then	
			sourcedata = data.units[sId]
			local pet = false
			if sourcedata.healin[aId] == nil then sourcedata.healin[aId] = CMX.createhealability(aId, pet, dtype) end --ability stats
			if (result == ACTION_RESULT_HOT_TICK or result == ACTION_RESULT_HEAL) then
				sourcedata.inheal = sourcedata.inheal + value
				sourcedata.inheals = sourcedata.inheals + 1
				sourcedata.healin[aId]["nheal"] = sourcedata.healin[aId]["nheal"] + value
				sourcedata.healin[aId]["nheals"] = sourcedata.healin[aId]["nheals"] + 1
			elseif (result == ACTION_RESULT_CRITICAL_HEAL or result == ACTION_RESULT_HOT_TICK_CRITICAL) then
				sourcedata.icheal = sourcedata.icheal + value
				sourcedata.icheals = sourcedata.icheals + 1
				sourcedata.healin[aId]["cheal"] = sourcedata.healin[aId]["cheal"] + value
				sourcedata.healin[aId]["cheals"] = sourcedata.healin[aId]["cheals"] + 1
			end
			if sourcedata.healin[aId] ~= nil then 
				sourcedata.healin[aId]["theal"] = sourcedata.healin[aId]["theal"] + value
				sourcedata.healin[aId]["theals"] = sourcedata.healin[aId]["theals"] + 1
				sourcedata.healin[aId]["max"] = math.max(sourcedata.healin[aId]["max"],value)
				sourcedata.healin[aId]["hps"] = math.floor(sourcedata.healin[aId]["theal"]/data.dpstime+0.5)
			end 
			sourcedata.itheal = sourcedata.inheal + sourcedata.icheal
			sourcedata.ihps = math.floor(sourcedata.itheal/data.dpstime+0.5)
			sourcedata.itheals = sourcedata.inheals + sourcedata.icheals
			data.units[sId] = sourcedata
		end
		if timems>(data.combatstart-500) and (action=="buff" and dtype~=BUFF_EFFECT_TYPE_NOT_AN_EFFECT and data.dpsstart~=nil) then
			targetdata = data.units[tId]
			local name = CMX.CustomAbilityName[aId] or zo_strformat("<<!aC:1>>",GetAbilityName(aId))
			if targetdata.buffs[name] == nil then targetdata.buffs[name] = CMX.createbuff(dtype, aId) end
			if result == EFFECT_RESULT_GAINED and timems<data.dpsend then
				targetdata.buffs[name]["count"] = targetdata.buffs[name]["count"] +1
				targetdata.buffs[name]["lastgain"] = math.max(timems, data.dpsstart)
			elseif result == EFFECT_RESULT_FADED then
				if timems <= data.dpsstart and targetdata.buffs[name]["lastgain"] ~= nil then 
					targetdata.buffs[name]["count"] = math.max(targetdata.buffs[name]["count"]-1,0)
					targetdata.buffs[name]["lastgain"] = nil
				elseif targetdata.buffs[name]["lastgain"] ~= nil then
					targetdata.buffs[name]["uptime"] = targetdata.buffs[name]["uptime"] + (math.min(timems,data.dpsend) - math.max(targetdata.buffs[name]["lastgain"]))
					targetdata.buffs[name]["lastgain"] = nil
				end
			end
			data.units[tId] = targetdata
		end
		if timems>(data.combatstart-500) and (action == "resource") then
			local diff, powerType =  value, dtype
			if powerType==POWERTYPE_MAGICKA then
				if diff>0 then 
					data.stats.magickagain = diff + ( data.stats.magickagain or 0 )
					data.stats.magickagains[aId or 0] = data.stats.magickagains[aId or 0] and {diff + ( data.stats.magickagains[aId or 0][1]),1 + ( data.stats.magickagains[aId or 0][2])} or {diff,1}
				elseif diff<0 then 
					data.stats.magickadrain = -diff + ( data.stats.magickadrain or 0 )
					data.stats.magickadrains[aId or 0] = data.stats.magickadrains[aId or 0] and {-diff + ( data.stats.magickadrains[aId or 0][1]),1 + ( data.stats.magickadrains[aId or 0][2])} or {-diff,1}
				end
			elseif powerType==POWERTYPE_STAMINA then
				if diff>0 then 
					data.stats.staminagain = diff + ( data.stats.staminagain or 0 )
					data.stats.staminagains[aId or 0] = data.stats.staminagains[aId or 0] and {diff + ( data.stats.staminagains[aId or 0][1]),1 + ( data.stats.staminagains[aId or 0][2])} or {diff,1}
				elseif diff<0 then 
					data.stats.staminadrain = -diff + ( data.stats.staminadrain or 0 )
					data.stats.staminadrains[aId or 0] = data.stats.staminadrains[aId or 0] and {-diff + ( data.stats.staminadrains[aId or 0][1]),1 + ( data.stats.staminadrains[aId or 0][2])} or {-diff,1}
				end
			elseif powerType==POWERTYPE_ULTIMATE then
				if diff>0 then 
					data.stats.ultigain = diff + ( data.stats.ultigain or 0 )
				elseif diff<0 then 
					data.stats.ultidrain = -diff + ( data.stats.ultidrain or 0 )
				end
			end
		end
		if timems>(data.combatstart-500) and (action == "stats") then
			local diff, newvalue, stat = result, value, dtype
			data.stats["current"..stat] = value
			-- if CMX.set.debuginfo then d(dtype..":"..value) end
		end
		-- global values
	end	
	if iend >= #data.log then
		if CMX.set.debuginfo.calculationtime then d("Start end routine") end
		data.stats.magickagps = zo_round((data.stats.magickagain or 0) / data.dpstime)
		data.stats.magickadrps = zo_round((data.stats.magickadrain or 0) / data.dpstime)
		data.stats.staminagps = zo_round((data.stats.staminagain or 0) / data.dpstime)
		data.stats.staminadrps = zo_round((data.stats.staminadrain or 0) / data.dpstime)
		data.stats.ultigps = zo_round((data.stats.ultigain or 0)*100 / data.dpstime)/100
		data.stats.ultidrps = zo_round((data.stats.ultidrain or 0)*100 / data.dpstime)/100
		for k,v in pairs(data.units) do
			if v.name == "Offline" then 
				data.units[k] = nil
			else
				for k,v in pairs(data.units[k]["buffs"]) do
					if v.lastgain ~= nil and data.dpsstart ~= nil then 
						v.uptime = math.min(v.uptime + (data.dpsend - math.min(math.max(v.lastgain, data.dpsstart),data.dpsend)),data.dpsend-data.dpsstart)
					end
				end 
			end 
		end 
		local bigunitname = "Unkown"
		if CMX.set.debuginfo.calculationtime then d("Start boss routine") end
		if data.bossfight == true then
			for k,v in pairs(data.units) do
				if data.units[k]~=nil then bigunitname = data.units[k]["name"] end
				if CMX.set.debuginfo.calculationtime then d("Boss:"..bigunitname) end
				if data.units[k]["name"]==data.bossname and data.units[k]["tdmg"]>0 then break end
			end
		else		
			for k,v in CMX:spairs(data.units, function(t,a,b) return (data.units[a]["tdmg"]>data.units[b]["tdmg"] and data.units[a]["name"]~=CMX.playername and data.units[a]["utype"]~="group" and data.units[a]["utype"]~="pet") end) do
				if data.units[k]~=nil then bigunitname = data.units[k]["name"] end
				if CMX.set.debuginfo.calculationtime then d(bigunitname) end
				break
			end
		end
		if CMX.set.debuginfo.calculationtime then d("End boss routine") end
		data.fightname = data.fightname or (data.date .." ".. data.time .." - ".. bigunitname)
		local sumunits = CMX.newunit()
		sumunits = CMX:AddTables(sumunits,data.units)
		sumunits.buffs = {}
		sumunits.buffs = CMX:JoinTables(sumunits.buffs,data.units[CMX.playerid]["buffs"]) 
		CMX.lastfights[CMX.calcfight] = CMX:JoinTables(data,sumunits)
		CMX.lastfights[CMX.calcfight]["calculating"] = false
		if CMX.set.debuginfo.calculationtime then d("Chunktime End:"..GetGameTimeMilliseconds()-scalcms) end
		return
	else
		CMX.cindex = iend
		CMX.lastfights[CMX.calcfight] = data
		em:RegisterForUpdate("CMX_chunk", 80, function() CMX.calcChunk() end)
	end
	local chunktime = GetGameTimeMilliseconds()-scalcms
	
	local newchunksize = math.min((math.floor((8/25)/(chunktime+.5)*CMX.set.chunksize)+1)*25,1000)
	
	if CMX.set.debuginfo.calculationtime then d("Chunktime:"..chunktime..", new size: ".. newchunksize) end
	CMX.set.chunksize = newchunksize
	return
end

--(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId) 

function CMX.onCustomEvent(_ , result , _ , _ , _ , _ , _ , _ , unitName , targetType , _ , _ , damageType , _ , _ , unitId , abilityId)
	if zo_strformat("<<!aC:1>>",unitName) ~= CMX.playername then return end
	local changeType = result == ACTION_RESULT_EFFECT_GAINED_DURATION and 1 or result == ACTION_RESULT_EFFECT_FADED and 2 or nil
	if CMX.set.debuginfo.misc then d("Custom: "..(CMX.CustomAbilityName[abilityId] or zo_strformat("<<!aC:1>>",GetAbilityName(abilityId))).."("..(changeType==1 and "gain" or changeType==2 and "loss" or "??" )..")") end
	CMX.onEffectChanged(_, changeType, _, _, _, _, _, _, _, _, BUFF_EFFECT_TYPE_BUFF, ABILITY_TYPE_BONUS, _, unitName, unitId, abilityId)
   --CMX.onEffectChanged(_, changeType, _, effectName, _, _, _, _, _, _, effectType, abilityType, _, unitName, unitId, abilityId)
end

function CMX:RegisterEvents()
	em:RegisterForEvent(self.name.."inCombat", EVENT_PLAYER_COMBAT_STATE, self.onCombatState)
	
	em:RegisterForEvent(self.name.."bosses", EVENT_BOSSES_CHANGED, self.onBossesChanged )
	
	em:RegisterForEvent(self.name.."groupeffects", EVENT_EFFECT_CHANGED, self.onGroupEffectChanged )
	em:AddFilterForEvent(self.name.."groupeffects", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	
	em:RegisterForEvent(self.name.."effects", EVENT_EFFECT_CHANGED, self.onEffectChanged )
	em:AddFilterForEvent(self.name.."effects", EVENT_EFFECT_CHANGED)
	
	em:RegisterForEvent(self.name.."group2", EVENT_GROUP_MEMBER_JOINED, self.onGroupJoin)
	
	em:RegisterForEvent(self.name.."group3", EVENT_GROUP_MEMBER_LEFT, self.onGroupLeave)
	
	em:RegisterForEvent(self.name.."slot1", EVENT_ACTION_SLOT_ABILITY_USED, self.onSlotUpdate)
	
	em:RegisterForEvent(self.name.."base resources", EVENT_POWER_UPDATE, self.onBaseResourceChanged)
	em:AddFilterForEvent(self.name.."base resources", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
	
	em:RegisterForEvent(self.name.."weaponswap", EVENT_ACTION_SLOTS_FULL_UPDATE, self.onWeaponSwap)
	em:AddFilterForEvent(self.name.."weaponswap", EVENT_ACTION_SLOTS_FULL_UPDATE)
	
	em:RegisterForEvent(self.name.."newunit", EVENT_UNIT_CREATED, self.onGroupJoin) 
	em:RegisterForEvent(self.name.."dropunit", EVENT_UNIT_DESTROYED, self.onGroupJoin) 
	
			
	local filterno = 1
	local filters = {
		[self.onCombatEventDmg] = {
			ACTION_RESULT_DAMAGE,
			ACTION_RESULT_DOT_TICK,		
			ACTION_RESULT_BLOCKED_DAMAGE,
			ACTION_RESULT_DAMAGE_SHIELDED,
			ACTION_RESULT_CRITICAL_DAMAGE,	
			ACTION_RESULT_DOT_TICK_CRITICAL,
		},
		[self.onCombatEventHeal] = {
			ACTION_RESULT_HOT_TICK,
			ACTION_RESULT_HEAL,
			ACTION_RESULT_CRITICAL_HEAL,
			ACTION_RESULT_HOT_TICK_CRITICAL,
		},
		[self.onResourceChanged] = {
			ACTION_RESULT_POWER_ENERGIZE,
			ACTION_RESULT_POWER_DRAIN,
		},
	}
	for k,v in pairs(filters) do
		for i=1, #v do
			em:RegisterForEvent(self.name.."combat"..filterno, EVENT_COMBAT_EVENT, k)
			em:AddFilterForEvent(self.name.."combat"..filterno, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player", REGISTER_FILTER_COMBAT_RESULT , v[i], REGISTER_FILTER_IS_ERROR, false)
			filterno=filterno+1
		end	
	end
	local filters2 = {
		[self.onCustomEvent] = {
			21230,	-- Weapon/spell power enchant (Berserker)
			21578,	-- Damage shield enchant (Hardening)
			71067,	-- Trial By Fire: Shock
			71058,	-- Trial By Fire: Fire
			71019,	-- Trial By Fire: Frost
			71069,	-- Trial By Fire: Disease
			71072,	-- Trial By Fire: Poison
			49236,	-- Whitestrake's Retribution
			57170,	-- Blod Frenzy
			75726,	-- Tava's Favor
			75746,	-- Clever Alchemist
			61870,	-- Armor Master Resistance
			70352,	-- Armor Master Spell Resistance
			46539,	-- Major Force
		},
	}
	
	for k,v in pairs(filters2) do
		for i=1, #v do
			em:RegisterForEvent(self.name.."combat"..filterno, EVENT_COMBAT_EVENT, k)
			em:AddFilterForEvent(self.name.."combat"..filterno, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player", REGISTER_FILTER_COMBAT_RESULT , ACTION_RESULT_EFFECT_GAINED_DURATION, REGISTER_FILTER_ABILITY_ID, v[i], REGISTER_FILTER_IS_ERROR, false)
			filterno=filterno+1
			em:RegisterForEvent(self.name.."combat"..filterno, EVENT_COMBAT_EVENT, k)
			em:AddFilterForEvent(self.name.."combat"..filterno, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player", REGISTER_FILTER_COMBAT_RESULT , ACTION_RESULT_EFFECT_FADED, REGISTER_FILTER_ABILITY_ID, v[i], REGISTER_FILTER_IS_ERROR, false)
			filterno=filterno+1
		end	
	end
end

function CMX:GroupEvents(register)
	if CMX.set.recordgrp == false then return end
	local filterno2 = 1
	if register then 
		local filters = {
			[self.onCombatEventDmgGrp] = {
				ACTION_RESULT_DAMAGE,
				ACTION_RESULT_DOT_TICK,		
				ACTION_RESULT_BLOCKED_DAMAGE,
				ACTION_RESULT_DAMAGE_SHIELDED,
				ACTION_RESULT_CRITICAL_DAMAGE,	
				ACTION_RESULT_DOT_TICK_CRITICAL,
			},
			[self.onCombatEventHealGrp] = {
				ACTION_RESULT_HOT_TICK,
				ACTION_RESULT_HEAL,
				ACTION_RESULT_CRITICAL_HEAL,
				ACTION_RESULT_HOT_TICK_CRITICAL,
			},
		}
		for k,v in pairs(filters) do
			for i=1, #v do
				em:RegisterForEvent(self.name.."grpcombat"..filterno2, EVENT_COMBAT_EVENT, k)
				-- AddFilterForEvent(namespace, 					EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
				em:AddFilterForEvent(self.name.."grpcombat"..filterno2, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG_PREFIX, "group", REGISTER_FILTER_COMBAT_RESULT , v[i], REGISTER_FILTER_IS_ERROR, false)
				filterno2=filterno2+1
			end	
		end
	elseif (not register) then 
		for i=1, CMX.CombatEvents do
			em:UnregisterForEvent(self.name.."grpcombat"..i, EVENT_COMBAT_EVENT)
		end	
		return 0
	end
	return filterno2
end

--[[ from LUI Extended
 * Fix Combat Log window settings
 ]]--
function CMX.fixCombatLog(cc, window)
	local tabIndex = window.tab.index

	cc:SetInteractivity(tabIndex, true)
	cc:SetLocked(tabIndex, true)
	
	for category = 1, GetNumChatCategories() do
		cc:SetWindowFilterEnabled(tabIndex, category, false)
	end
end


--[[ from LUI Extended
 * Prepare Combat Log window
 ]]--
function CMX.getCombatLog()
	for k, cc in ipairs(CHAT_SYSTEM.containers) do
		for i = 1, #cc.windows do
			if cc:GetTabName(i) == "CMX Combat Log" then
				return cc, cc.windows[i]
			end
		end
	end

	-- previous lookup did not find proper window, so create it in primary container
	local cc = CHAT_SYSTEM.primaryContainer
	local window, key = cc.windowPool:AcquireObject()
	window.key = key
	
	cc:AddRawWindow(window, "CMX Combat Log")

	CMX.fixCombatLog(cc, window)

	return cc, window
end


function CMX.InitializeChat()
	if ZO_ChatWindowTabTemplate1 then 
		CMX.ChatContainer, CMX.ChatWindow = CMX.getCombatLog()
	else
		zo_callLater(CMX.InitializeChat, 200)
	end
end

-- Next we create a function that will initialize our addon
function CMX:Initialize(event, addon)
  -- filter for just CMX addon event
  if addon ~= self.name then return end
  
  em:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
  
  -- load saved variables
    
  self.set = ZO_SavedVars:NewAccountWide(self.name.."_Save", 3, nil, self.defaults)
  if not self.set.accountwide then self.set = ZO_SavedVars:New(self.name.."_Save", 3, nil, self.defaults) end
  
  
  self.InitTime=0
  if self.set.EnableChatLog then zo_callLater(self.InitializeChat, 200) end
  self.UI:Initialize()
  self:RegisterEvents()
  self.inCombat = IsUnitInCombat("player")
  self.inGroup = IsUnitGrouped("player")
  self.playername = zo_strformat("<<!aC:1>>",GetUnitName("player"))
  if self.inGroup then self.CombatEvents = self:GroupEvents(true) end
  self.lastfights={}
  self.bosses=0
  self.groupmembers={}
  self.PlayerPets={}
  self.currentfight={}
  self.offstatlist= {"maxmagicka", "spellpower", "spellcrit", "maxstamina", "weaponpower", "weaponcrit"}
  self.defstatlist= {"physres", "spellres", "critres"}
  self.lastabilities = {}
  self.bossnames={}  
  --resetfightdata
  self.currentfight = self.newfight()
  
  -- make addon options menu
  self.MakeMenu()
  
  CMX.CustomAbilityName = {
	[46539]	= "Major Force"
  }
  
end

-- register event handler function to initialize when addon is loaded
em:RegisterForEvent(CMX.name, EVENT_ADD_ON_LOADED, function(...) CMX:Initialize(...) end)