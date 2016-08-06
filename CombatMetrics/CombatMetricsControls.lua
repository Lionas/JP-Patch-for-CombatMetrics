local wm = GetWindowManager()
local height = 20
local fontsize = GetString(SI_COMBAT_METRICS_FONT_SIZE)
local dx = GuiRoot:GetHeight()/1080 -- get scale factor 1440=1080/0.75 (my ui scale when I made the UI) 
local _

-- Create reusable Control element. 
function CMX.UI:CreateStatLabel( id, label, size, parent, anchor, align, color, scale)
	if not (size>0) then end
	if #align ~= 2 then end
	if color == nil then color = {1,1,1,1} end
	local statlabel 	= CMX.UI:Control(   	"CMX_Report_Statlabel_"..id, 			parent, 	{size,height}, 			anchor, 				false, scale )
	statlabel.label 	= CMX.UI:Label( 		"CMX_Report_Statlabel_"..id.."Label",	statlabel, 	{size-10,height}, 		{CENTER,CENTER,0,0}, 	CMX.UI:Font("esobold", fontsize+1, true, scale), color, {align[1],align[2]}, label, false, scale )
	--statlabel.backdrop	= CMX.UI:Backdrop(		"CMX_Report_Statlabel_"..id.."BG",		statlabel,	{"inherit"},	{CENTER,CENTER,0,0},	{0.3,0.3,0,.2}, {1,1,1,1}, {1,1,1*scale} ,nil, false, 1 )
	return statlabel
end


function CMX.UI:CreateStatControl( id, value, size, parent, anchor, align, color, scale)
	if not (size>0) then end
	if color == nil then color = {1,1,1,1} end
	local stat 			= CMX.UI:Control(   	"CMX_Report_Stat_"..id, 			parent, 		{size,height}, 			anchor, 				false, scale )
	stat.value 			= CMX.UI:Label( 		"CMX_Report_Stat_"..id.."Value", 	stat, 			{size-10,height}, 		{CENTER,CENTER,0,0}, 	CMX.UI:Font("standard",fontsize+1,true, scale), color, {align or 2,1}, value, false, scale )
	--stat.backdrop		= CMX.UI:Backdrop(		"CMX_Report_Stat_"..id.."BG",		stat,			{"inherit"},		{CENTER,CENTER,0,0},	{0.3,0.3,0,.2}, {1,1,1,1}, {1,1,1*scale} ,nil, false, 1 )
	return stat
end

function CMX.UI:CreateUnitControl( id, label, value, barwidth, parent, anchor, color, utype, highlight, unitid, scale)
	local unititem 		= CMX.UI:Control(   	"CMX_Report_Units_"..id, 			parent, 		{390,height}, 													anchor, 							false, scale )
	unititem.backdrop	= CMX.UI:Backdrop(		"CMX_Report_Units_"..id.."BG",		unititem,		{CMX_Report_Units_header_Label:GetWidth()/scale*barwidth,height-3}, 	{LEFT,LEFT,0,0},					color, {0,0.0,0.0,0}, {1,1,1} ,nil, false, scale )
	unititem.highlight	= CMX.UI:Backdrop(		"CMX_Report_Units_"..id.."HL",		unititem,		"inherit", 														{CENTER,CENTER,0,0},				{0.8,0.8,1,0.5}, {1,1,1,0}, {1,1,1*scale} ,nil, not highlight, 1 )
	local namestyle = utype=="boss" and CMX.UI:Font("esobold",fontsize,true, scale) or CMX.UI:Font("standard",fontsize,true, scale)
	local namecolor = (utype=="boss" and {1,.8,.3,1}) or {1,1,1,1}  --(utype=="group" and {.7,1,.7,1}) or (utype=="pet" and {1,1,.5,1})
	unititem.label 		= CMX.UI:Label( 		"CMX_Report_Units_"..id.."Label", 	unititem, 		{CMX_Report_Units_header_Label:GetWidth()/scale-2,height}, 			{LEFT,LEFT,2,0}, 					namestyle, namecolor, {0,1}, label, false, scale )
	unititem.percent 	= CMX.UI:Label( 		"CMX_Report_Units_"..id.."percent", unititem, 		{CMX_Report_Units_header_Label2:GetWidth()/scale,height}, 			{LEFT,RIGHT,2,0,unititem.label}, 	CMX.UI:Font("standard",fontsize,true, scale), {1,1,1,1}, {2,1}, tostring(zo_round(barwidth*1000)/10).." %", false, scale )
	unititem.value 		= CMX.UI:Label( 		"CMX_Report_Units_"..id.."Value", 	unititem, 		{CMX_Report_Units_header_Label3:GetWidth()/scale-2,height}, 		{LEFT,RIGHT,2,0,unititem.percent}, 				CMX.UI:Font("standard",fontsize,true, scale), {1,1,1,1}, {2,1}, value, false, scale )
	unititem.id = unitid
	unititem:SetMouseEnabled( true )
	unititem:SetHandler( "OnMouseUp", function( self, button, upInside, ctrl, alt, shift ) CMX.UI:AddSelection ( "unit", id, unitid, shift, ctrl, button) end )
	return unititem
end

function CMX.UI:CreateBuffControl( id, label, count, barwidth, parent, anchor, color, highlight, icon, buffid, scale)
	local buffitem 		= CMX.UI:Control(   	"CMX_Report_Buffs_"..id, 			parent, 		{CMX_Report_Buffs_header:GetWidth()/scale,height}, 					anchor, 							false, scale )
	buffitem.icon		= CMX.UI:Texture(   	"CMX_Report_Buffs_"..id.."Icon",	buffitem,		{height-2,height-2},  											{LEFT,LEFT,0,0},  					icon, false, scale )
	buffitem.backdrop	= CMX.UI:Backdrop(		"CMX_Report_Buffs_"..id.."BG",		buffitem,		{(CMX_Report_Buffs_header_Label:GetWidth()/scale)*barwidth,height-2},{LEFT,RIGHT,2,0,buffitem.icon}, color, {0,0.0,0.0,0}, {1,1,1} ,nil, false, scale )
	buffitem.highlight	= CMX.UI:Backdrop(		"CMX_Report_Buffs_"..id.."HL",		buffitem,		"inherit", 														{CENTER,CENTER,0,0},				{0.8,0.8,1,0.5}, {1,1,1,0}, {1,1,1*scale} ,nil, not highlight, 1 )
	buffitem.label 		= CMX.UI:Label( 		"CMX_Report_Buffs_"..id.."Label", 	buffitem, 		{CMX_Report_Buffs_header_Label:GetWidth()/scale-2,height}, 		{LEFT,LEFT,2,0,buffitem.backdrop}, 	CMX.UI:Font("standard",fontsize,true, scale), {1,1,1,1}, {0,1}, label, false, scale )
	buffitem.count 		= CMX.UI:Label( 		"CMX_Report_Buffs_"..id.."Count", 	buffitem, 		{CMX_Report_Buffs_header_Label2:GetWidth()/scale,height}, 			{LEFT,RIGHT,2,0,buffitem.label}, 	CMX.UI:Font("standard",fontsize,true, scale), {1,1,1,1}, {2,1}, count, false, scale )
	buffitem.uptime 	= CMX.UI:Label( 		"CMX_Report_Buffs_"..id.."Uptime", 	buffitem, 		{CMX_Report_Buffs_header_Label3:GetWidth()/scale,height}, 			{LEFT,RIGHT,2,0,buffitem.count}, 	CMX.UI:Font("standard",fontsize,true, scale), {1,1,1,1}, {2,1}, tostring(zo_round(barwidth*1000)/10).." %", false, scale )
	buffitem.id = buffid
	buffitem:SetMouseEnabled( true )
	buffitem:SetHandler( "OnMouseUp", function( self, button, upInside, ctrl, alt, shift ) CMX.UI:AddSelection ( "buff", id, buffid, shift, ctrl, button) end )
	return buffitem
end

function CMX.UI:CreateResourceControl( id, label, count, barwidth, value, parent, anchor, color, highlight, resid, scale)
	local resourceitem 		= CMX.UI:Control(   	"CMX_Report_Resources_"..id, 			parent, 		{CMX_Report_Resources_header:GetWidth()/scale,height}, 					anchor, 							false, scale )
	resourceitem.backdrop	= CMX.UI:Backdrop(		"CMX_Report_Resources_"..id.."BG",		resourceitem,		{(CMX_Report_Resources_header_Label:GetWidth()/scale)*barwidth,height-2},{LEFT,LEFT,0,0}, color, {0,0.0,0.0,0}, {1,1,1} ,nil, false, scale )
	resourceitem.highlight	= CMX.UI:Backdrop(		"CMX_Report_Resources_"..id.."HL",		resourceitem,		"inherit", 														{CENTER,CENTER,0,0},				{0.8,0.8,1,0.5}, {1,1,1,0}, {1,1,1*scale} ,nil, not highlight, 1 )
	resourceitem.label 		= CMX.UI:Label( 		"CMX_Report_Resources_"..id.."Label", 	resourceitem, 		{CMX_Report_Resources_header_Label:GetWidth()/scale-2,height}, 		{LEFT,LEFT,2,0,resourceitem.backdrop}, 	CMX.UI:Font("standard",fontsize,true, scale), {1,1,1,1}, {0,1}, label, false, scale )
	resourceitem.count 		= CMX.UI:Label( 		"CMX_Report_Resources_"..id.."Count", 	resourceitem, 		{CMX_Report_Resources_header_Label2:GetWidth()/scale,height}, 			{LEFT,RIGHT,2,0,resourceitem.label}, 	CMX.UI:Font("standard",fontsize,true, scale), {1,1,1,1}, {2,1}, count, false, scale )
	resourceitem.value 	= CMX.UI:Label( 		"CMX_Report_Resources_"..id.."value", 	resourceitem, 		{CMX_Report_Resources_header_Label3:GetWidth()/scale,height}, 			{LEFT,RIGHT,2,0,resourceitem.count}, 	CMX.UI:Font("standard",fontsize,true, scale), {1,1,1,1}, {2,1}, value, false, scale )
	if resid~= nil then 
		resourceitem.id = resid
		resourceitem:SetMouseEnabled( true )
		resourceitem:SetHandler( "OnMouseUp", function( self, button, upInside, ctrl, alt, shift ) CMX.UI:AddSelection ( "resource", id, resid, shift, ctrl, button) end )
	end
	return resourceitem
end

function CMX.UI:CreateAbilityControl( id, label, values, barwidth, parent, anchor, color, highlight, icon, abilityid, scale)
	if #values ~= 7 then return end 
	local ability 		= CMX.UI:Control(   	"CMX_Report_Abilities_"..id, 			parent, 	{CMX_Report_Abilities_header:GetWidth()/scale,height}, 			anchor, 							false, scale )
	ability.icon		= CMX.UI:Texture(   	"CMX_Report_Abilities_"..id.."Icon",	ability,	{height-2,height-2},  										{LEFT,LEFT,0,0},  					icon, false, scale )
	ability.backdrop	= CMX.UI:Backdrop(		"CMX_Report_Abilities_"..id.."BG",		ability,	{(CMX_Report_Abilities_header_Label:GetWidth()/scale)*barwidth,height-2}, 	{LEFT,RIGHT,0,0,ability.icon},		color, {0,0.0,0.0,0}, {1,1,1} ,nil, false, scale )
	ability.highlight	= CMX.UI:Backdrop(		"CMX_Report_Abilities_"..id.."HL",		ability,	"inherit", 													{CENTER,CENTER,0,0},				{0.8,0.8,1,0.5}, {1,1,1,0}, {1,1,1*scale} ,nil, not highlight, 1 )
	ability.label 		= CMX.UI:Label( 		"CMX_Report_Abilities_"..id.."Label", 	ability, 	{CMX_Report_Abilities_header_Label:GetWidth()/scale-2,height}, 	{LEFT,LEFT,2,0,ability.backdrop}, 	CMX.UI:Font("standard",fontsize, true, scale), {1,1,1,1}, {0,1}, label, false, scale )
	ability.percent 	= CMX.UI:Label( 		"CMX_Report_Abilities_"..id.."percent", ability, 	{CMX_Report_Abilities_header_percent:GetWidth()/scale,height}, 	{LEFT,RIGHT,4,0,ability.label}, 	CMX.UI:Font("standard",fontsize, true, scale), {1,1,1,1}, {2,1}, tostring(zo_round(barwidth*1000)/10).." %", false, scale )
	ability.vps 		= CMX.UI:Label( 		"CMX_Report_Abilities_"..id.."vps", 	ability, 	{CMX_Report_Abilities_header_vps:GetWidth()/scale,height}, 		{LEFT,RIGHT,2,0,ability.percent}, 	CMX.UI:Font("standard",fontsize, true, scale), {1,1,1,1}, {2,1}, values[7], false, scale )
	ability.amt 		= CMX.UI:Label( 		"CMX_Report_Abilities_"..id.."amt", 	ability, 	{CMX_Report_Abilities_header_amt:GetWidth()/scale,height}, 		{LEFT,RIGHT,2,0,ability.vps}, 		CMX.UI:Font("standard",fontsize, true, scale), {1,1,1,1}, {2,1}, values[1], false, scale )
	ability.crits 		= CMX.UI:Label( 		"CMX_Report_Abilities_"..id.."crits", 	ability, 	{CMX_Report_Abilities_header_crits:GetWidth()/scale,height}, 		{LEFT,RIGHT,2,0,ability.amt}, 		CMX.UI:Font("standard",fontsize, true, scale), {1,1,1,1}, {2,1}, values[2], false, scale )
	ability.hits 		= CMX.UI:Label( 		"CMX_Report_Abilities_"..id.."hits", 	ability, 	{CMX_Report_Abilities_header_hits:GetWidth()/scale,height}, 		{LEFT,RIGHT,0,0,ability.crits}, 	CMX.UI:Font("standard",fontsize, true, scale), {1,1,1,1}, {0,1}, "/"..values[3], false, scale )
	ability.ratio 		= CMX.UI:Label( 		"CMX_Report_Abilities_"..id.."ratio", 	ability, 	{CMX_Report_Abilities_header_ratio:GetWidth()/scale,height}, 		{LEFT,RIGHT,2,0,ability.hits}, 		CMX.UI:Font("standard",fontsize, true, scale), {1,1,1,1}, {2,1}, values[4], false, scale )
	ability.avg 		= CMX.UI:Label( 		"CMX_Report_Abilities_"..id.."avg", 	ability, 	{CMX_Report_Abilities_header_avg:GetWidth()/scale,height}, 		{LEFT,RIGHT,2,0,ability.ratio}, 	CMX.UI:Font("standard",fontsize, true, scale), {1,1,1,1}, {2,1}, values[5], false, scale )
	ability.max 		= CMX.UI:Label( 		"CMX_Report_Abilities_"..id.."max", 	ability, 	{CMX_Report_Abilities_header_max:GetWidth()/scale,height}, 		{LEFT,RIGHT,2,0,ability.avg}, 		CMX.UI:Font("standard",fontsize, true, scale), {1,1,1,1}, {2,1}, values[6], false, scale )
	ability.id = abilityid
	ability:SetMouseEnabled( true )
	ability:SetHandler( "OnMouseUp", function( self, button, upInside, ctrl, alt, shift ) CMX.UI:AddSelection ( "ability", id, abilityid, shift, ctrl, button) end )
	return ability
end

function CMX.UI:CreateFightListItem(id, values, anchor, issaved, scale)
	local name = (issaved and "FightListSavedItem") or "FightListItem"
	local parent = (issaved and CMX_Report_FightListSaved_PanelScrollChild) or CMX_Report_FightList_PanelScrollChild
	local fightlistitem 	= CMX.UI:Control(   	"CMX_Report_"..name..id.."", 		parent, 	{928,height}, 	anchor, 	false, scale )
	fightlistitem.selector	= CMX.UI:Control(		"CMX_Report_"..name..id.."_Sel",	fightlistitem,							{(CMX_Report_FightList_header:GetWidth()-CMX_Report_FightList_header_Label7:GetWidth()-8)/scale,height},	{LEFT,LEFT,0,0}, 		false, scale )
	fightlistitem.backdrop	= CMX.UI:Backdrop(		"CMX_Report_"..name..id.."_BG2",	fightlistitem.selector,	"inherit",	{LEFT,LEFT,0,0},						{1,1,1,.1}, {1,1,1,0}, {1,1,1*scale} ,nil, true, 1 )
	fightlistitem.label 	= CMX.UI:Label( 		"CMX_Report_"..name..id.."_Label", 	fightlistitem, 	{CMX_Report_FightList_header_Label:GetWidth()/scale,height}, 		{LEFT,LEFT,4,0}, 						CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {0,1}, values[1], false, scale )
	fightlistitem.label2 	= CMX.UI:Label( 		"CMX_Report_"..name..id.."_Label2",	fightlistitem, 	{CMX_Report_FightList_header_Label2:GetWidth()/scale,height}, 		{LEFT,RIGHT,8,0,fightlistitem.label}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, values[2], false, scale )
	fightlistitem.label3 	= CMX.UI:Label( 		"CMX_Report_"..name..id.."_Label3",	fightlistitem, 	{CMX_Report_FightList_header_Label3:GetWidth()/scale,height}, 		{LEFT,RIGHT,8,0,fightlistitem.label2},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, values[3], false, scale )
	fightlistitem.label4 	= CMX.UI:Label( 		"CMX_Report_"..name..id.."_Label4",	fightlistitem, 	{CMX_Report_FightList_header_Label4:GetWidth()/scale,height}, 		{LEFT,RIGHT,8,0,fightlistitem.label3},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, values[4], false, scale )
	fightlistitem.label5 	= CMX.UI:Label( 		"CMX_Report_"..name..id.."_Label5",	fightlistitem, 	{CMX_Report_FightList_header_Label5:GetWidth()/scale,height}, 		{LEFT,RIGHT,8,0,fightlistitem.label4},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, values[5], false, scale )
	fightlistitem.label6 	= CMX.UI:Label( 		"CMX_Report_"..name..id.."_Label6",	fightlistitem, 	{CMX_Report_FightList_header_Label6:GetWidth()/scale,height}, 		{LEFT,RIGHT,8,0,fightlistitem.label5},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, values[6], false, scale )
	fightlistitem.deletelog	= CMX.UI:IconButton( 	"CMX_Report_"..name..id.."ButtonDelete" , 	fightlistitem, 	{height,height},{LEFT,RIGHT,((CMX_Report_FightList_header_Label7:GetWidth()-height/scale)/2)/2+8,0,fightlistitem.label6} , BSTATE_NORMAL , "CombatMetrics/icons/deletelogiconup.dds" , "CombatMetrics/icons/deletelogicondown.dds", "CombatMetrics/icons/deletelogiconover.dds" , "CombatMetrics/icons/deletelogicondisabled.dds" , false, scale )
	fightlistitem.delete	= CMX.UI:IconButton( 	"CMX_Report_"..name..id.."ButtonDeleteLog" , 	fightlistitem, 	{height,height},{LEFT,RIGHT,3,0,fightlistitem.deletelog} , BSTATE_NORMAL , "CombatMetrics/icons/deleteiconup.dds" , "CombatMetrics/icons/deleteicondown.dds", "CombatMetrics/icons/deleteiconover.dds" , "CombatMetrics/icons/deleteicondisabled.dds" , false, scale )
	fightlistitem.selector:SetMouseEnabled(true)
	local state = false
	if issaved then 
		state = (#CMX.set.saveddata[id]["log"]>0)
	else 
		state = (#CMX.lastfights[id]["log"]>0)
	end
	fightlistitem.deletelog:SetState( state and BSTATE_NORMAL or BSTATE_DISABLED )
	fightlistitem.selector:SetHandler( "OnMouseUp", function( self, button, upInside, ctrl, alt, shift ) CMX.UI:LoadItem(id, issaved) end )
	fightlistitem.selector:SetHandler( "OnMouseEnter", function() fightlistitem.backdrop:SetHidden(false) end )
	fightlistitem.selector:SetHandler( "OnMouseExit", function() fightlistitem.backdrop:SetHidden(true) end )
	fightlistitem.deletelog:SetHandler( "OnMouseUp", function( self, button, upInside, ctrl, alt, shift ) CMX.UI:DeleteItemLog(id, issaved) end )
	fightlistitem.deletelog.data = {tooltipText = GetString(SI_COMBAT_METRICS_DELETE_COMBAT_LOG)}
	fightlistitem.deletelog:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	fightlistitem.deletelog:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	fightlistitem.delete:SetHandler( "OnMouseUp", function( self, button, upInside, ctrl, alt, shift ) CMX.UI:DeleteItem(id, issaved) end )
	fightlistitem.delete.data = {tooltipText = GetString(SI_COMBAT_METRICS_DELETE_FIGHT)}
	fightlistitem.delete:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	fightlistitem.delete:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	return fightlistitem
end

function CMX.SaveFight(fightid)
	if CMX.set.saveddata[#CMX.set.saveddata]~=nil and CMX.set.saveddata[#CMX.set.saveddata]["fightname"]==CMX.lastfights[fightid]["fightname"] then return end --bail out if fight is already saved
	if CMX.UI:CheckSaveLimit(#CMX.lastfights[fightid]["log"]) then 
		table.insert(CMX.set.saveddata, CMX.lastfights[fightid]) 
		CMX.UI:UpdateReport()
	else 
		assert(false, GetString(SI_COMBAT_METRICS_STORAGE_FULL)) 
	end
end

function CMX.UI:LoadItem(id, issaved)
	if issaved and not (CMX.UI.searchtable(CMX.lastfights, "fightname", CMX.set.saveddata[id]["fightname"])) then
		table.insert(CMX.lastfights, CMX.set.saveddata[id])
		CMX.UI:UpdateReport(CMX.set.UI.LRMenuItem, #CMX.lastfights)
	else
		CMX.UI:UpdateReport(CMX.set.UI.LRMenuItem, (issaved and (CMX.UI.searchtable(CMX.lastfights, "fightname", CMX.set.saveddata[id]["fightname"])) or id))
	end
	CMX.UI.Selection["ability"][CMX.set.UI.LRMenuItem] = nil
	CMX.UI.Selection["unit"][CMX.set.UI.LRMenuItem] = nil
	CMX.UI.Selection["buff"]["buff"] = nil	
	CMX.ToggleFightList()
end

function CMX.UI:DeleteItem(id, issaved)
	if issaved then
		table.remove(CMX.set.saveddata, id)
	else
		table.remove(CMX.lastfights, id)
		if #CMX.lastfights==0 then CMX.UI.ControlRW() end
	end
	CMX.ToggleFightList(true)
end

function CMX.UI:DeleteItemLog(id, issaved)
	if issaved then
		CMX.set.saveddata[id]["log"]={}
	else
		CMX.lastfights[id]["log"]={}
	end
	CMX.ToggleFightList(true)
end

function CMX.UI.ToggleLR(value)
	CMX_LiveReport:SetHidden(not value)
	if value then
		SCENE_MANAGER:GetScene("hud"):AddFragment( CMX.UI.fragment )
		SCENE_MANAGER:GetScene("hudui"):AddFragment( CMX.UI.fragment )
		SCENE_MANAGER:GetScene("siegeBar"):AddFragment( CMX.UI.fragment )
	else
		SCENE_MANAGER:GetScene("hud"):RemoveFragment( CMX.UI.fragment )
		SCENE_MANAGER:GetScene("hudui"):RemoveFragment( CMX.UI.fragment )
		SCENE_MANAGER:GetScene("siegeBar"):RemoveFragment( CMX.UI.fragment )
	end
end

function CMX.UI:ControlLR()

--[[ Small Live DPS Report Window ]]--
	local scale = CMX.set.UI.CMX_LiveReportSettings.scale
	local group = CMX.set.recordgrp
	
	local LR 		= CMX.UI:TopLevelWindow(   	"CMX_LiveReport", 				nil, 		{270,48}, 			CMX.set.UI.CMX_LiveReport, 		not CMX.set.EnableLiveMonitor, scale )
	LR.backdrop     = CMX.UI:Backdrop(			"CMX_LiveReport_BG",			LR,			{"inherit"},		{CENTER,CENTER,0,0},			{0,0,0,0.4}, {0,0,0,0.5}, {1,1,2*scale}, nil, (not CMX.set.UI.CMX_LiveReportSettings.bg), 1 )
	LR.backdrop:SetExcludeFromResizeToFitExtents(true)
	LR:SetMovable( true )
	LR:SetMouseEnabled( true )
	LR:SetHandler( "OnMouseUp", function( self ) CMX.UI:SaveAnchor( self, scale ) end )
	LR:SetResizeToFitDescendents(true)
	
	LR.damageout		= CMX.UI:Control(   "CMX_LiveReport_DmgOut", 			LR, 			{(group and 135 or 75),24}, 		{TOPLEFT,TOPLEFT,0,0,LR}, 				false, scale )
	LR.damageout.label	= CMX.UI:Label( 	"CMX_LiveReport_DmgOutLabel", 		LR.damageout,	{(group and 105 or 45),24}, 		{RIGHT,RIGHT,0,0}, 						CMX.UI:Font("standard",(fontsize-2),true, scale), {1,1,1,1}, {0,1}, "0", false, scale )
	LR.damageout.icon  	= CMX.UI:Texture(   "CMX_LiveReport_DmgOutIcon",		LR.damageout,	{24,24},  		{LEFT,LEFT,0,-1},  						'/esoui/art/icons/poi/poi_battlefield_complete.dds', false, scale )

	LR.healout			= CMX.UI:Control(   "CMX_LiveReport_HealOut", 			LR, 			{(group and 135 or 75),24}, 		{LEFT,RIGHT,0,0,LR.damageout}, 			false, scale )
	LR.healout.label	= CMX.UI:Label( 	"CMX_LiveReport_HealOutLabel", 		LR.healout, 	{(group and 105 or 45),24}, 		{RIGHT,RIGHT,0,0}, 						CMX.UI:Font("standard",(fontsize-2),true, scale), {1,1,1,1}, {0,1}, "0", false, scale )
	LR.healout.icon    	= CMX.UI:Texture(   "CMX_LiveReport_HealOutIcon",		LR.healout,		{20,20},  		{LEFT,LEFT,3,0},  						'/esoui/art/buttons/gamepad/pointsplus_up.dds', false, scale )
	
	LR.damagein			= CMX.UI:Control(   "CMX_LiveReport_DmgIn", 			LR, 			{(group and 135 or 75),24}, 		{TOPLEFT,BOTTOMLEFT,0,0,LR.damageout}, 	false, scale )
	LR.damagein.label	= CMX.UI:Label( 	"CMX_LiveReport_DmgInLabel", 		LR.damagein,	{(group and 105 or 45),24}, 		{RIGHT,RIGHT,0,0}, 						CMX.UI:Font("standard",(fontsize-2),true, scale), {1,1,1,1}, {0,1}, "0", false, scale )
	LR.damagein.icon   	= CMX.UI:Texture(   "CMX_LiveReport_DmgInIcon",			LR.damagein,	{24,24},  		{LEFT,LEFT,0,-1},  						'/esoui/art/icons/heraldrycrests_weapon_shield_01.dds', false, scale )

	LR.healin			= CMX.UI:Control(   "CMX_LiveReport_HealIn", 			LR, 			{75,24}, 		{LEFT,RIGHT,0,0,LR.damagein}, 			false, scale )
	LR.healin.label		= CMX.UI:Label( 	"CMX_LiveReport_HealInLabel", 		LR.healin, 		{45,24}, 		{RIGHT,RIGHT,0,0}, 						CMX.UI:Font("standard",(fontsize-2),true, scale), {1,1,1,1}, {0,1}, "0", false, scale )
	LR.healin.icon		= CMX.UI:Texture(   "CMX_LiveReport_HealInIcon",		LR.healin,		{20,20},  		{LEFT,LEFT,3,0},  						'/esoui/art/buttons/gamepad/xbox/nav_xbone_dpad.dds', false, scale )

	LR.time				= CMX.UI:Control(   "CMX_LiveReport_Time", 				LR, 			{60,24}, 		{LEFT,RIGHT,0,0,LR.healin}, 			false, scale )
	LR.time.label		= CMX.UI:Label( 	"CMX_LiveReport_TimeLabel", 		LR.time, 		{36,24}, 		{RIGHT,RIGHT,0,0}, 						CMX.UI:Font("standard",(fontsize-2),true, scale), {1,1,1,1}, {0,1}, "0:00" , false, scale )
	LR.time.icon    	= CMX.UI:Texture(   "CMX_LiveReport_TimeIcon",			LR.time,		{21,21},		{LEFT,LEFT,2,0},						'/esoui/art/tutorial/timer_icon.dds', false, scale )
	
	setLR = CMX.set.UI.CMX_LiveReportSettings
	CMX.UI:RefreshLRWindow()
end

function CMX.UI:ControlRW()
--[[ Big Detailed Reoprt Window]]--
	local scale = CMX.set.UI.ReportScale
	local hidereport = CMX_Report==nil or CMX_Report:IsHidden()
	local RW 			= CMX.UI:TopLevelWindow("CMX_Report", 						nil, 		{940,750}, 				CMX.set.UI.CMX_Report, 				hidereport, scale )
	RW:SetMouseEnabled( true )
	RW:SetMovable( true )
	RW.backdrop			= CMX.UI:Backdrop(		"CMX_Report_BG",					RW,			"inherit",				{CENTER,CENTER,0,0},            {0.02,0.02,0.02,0.95}, {0,0,0,1}, {1,1,2*scale}, nil, false, 1 )
	RW:SetHandler( "OnMouseUp", function( self ) CMX.UI:SaveAnchor( self, scale ) end )
	
	--SCENE_MANAGER:RegisterTopLevel(RW,false)
	local fragment = ZO_SimpleSceneFragment:New(RW)
	--local scene = SCENE_MANAGER:GetScene("hudui")
	local scene = ZO_Scene:New("CMX_REPORT_SCENE", SCENE_MANAGER)
	scene:AddFragment(fragment)

-- Title Bar
	local title 		= CMX.UI:Control(   	"CMX_Report_Title", 				RW, 				{940,40}, 		{TOPLEFT,TOPLEFT,0,1}, 					false, scale )
	--title.label 		= CMX.UI:Label( 		"CMX_Report_TitleLabel", 			title, 				{300,38}, 		{LEFT,LEFT,8,0}, 				CMX.UI:Font("standard",24,true, scale), {1,1,1,1}, {0,1}, GetString(SI_COMBAT_METRICS_FIGHT_REPORT), false, scale )
	title.backdrop		= CMX.UI:Backdrop(		"CMX_Report_Title_Sep",				title,				{932,2}, 		{TOP,BOTTOM,0,4},				{0,0,0,0}, {1,1,1,1}, {1,1,2} ,nil, false, scale )
	local fightselector = CMX.UI:Control(   	"CMX_Report_FightSelector", 		title, 				{590,40}, 		{TOPLEFT,TOPLEFT,4,1}, 					false, scale )
	fightselector.label = CMX.UI:Label( 		"CMX_Report_FightSelectorLabel", 	title, 				{352,38}, 		{LEFT,LEFT,8,0}, 				CMX.UI:Font("standard",18,true, scale), {1,1,1,1}, {0,1}, GetString(SI_COMBAT_METRICS_FIGHT_REPORT), false, scale )
	
	fightselector.buttonback 	= CMX.UI:IconButton( "CMX_Report_FightButtonBack" , fightselector , 	{32,32} , 		{LEFT,RIGHT,8,0,fightselector.label} , BSTATE_DISABLED , "CombatMetrics/icons/leftarrowup.dds" , "CombatMetrics/icons/leftarrowdown.dds", "CombatMetrics/icons/leftarrowover.dds" , "CombatMetrics/icons/leftarrowdisabled.dds" , false, scale )
	fightselector.buttonback:SetMouseEnabled( true )
	fightselector.buttonback:SetHandler( "OnMouseUp", function() if fightselector.buttonback:GetState() == BSTATE_DISABLED then return else CMX.UI:UpdateReport(CMX.set.UI.LRMenuItem, CMX.UI.Currentfightid-1) end end)
	fightselector.buttonback.data = {tooltipText = GetString(SI_COMBAT_METRICS_PREVIOUS_FIGHT)}
	fightselector.buttonback:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	fightselector.buttonback:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	fightselector.buttonforward = CMX.UI:IconButton( "CMX_Report_FightButtonFor" , 	fightselector , 	{32,32} , 		{LEFT,RIGHT,6,0,fightselector.buttonback } , BSTATE_DISABLED , "CombatMetrics/icons/rightarrowup.dds" , "CombatMetrics/icons/rightarrowdown.dds", "CombatMetrics/icons/rightarrowover.dds" , "CombatMetrics/icons/rightarrowdisabled.dds" , false, scale ) 
	fightselector.buttonforward:SetMouseEnabled( true )
	fightselector.buttonforward:SetHandler( "OnMouseUp", function() if fightselector.buttonforward:GetState() == BSTATE_DISABLED then return else CMX.UI:UpdateReport(CMX.set.UI.LRMenuItem, CMX.UI.Currentfightid+1) end end)
	fightselector.buttonforward.data = {tooltipText = GetString(SI_COMBAT_METRICS_NEXT_FIGHT)}
	fightselector.buttonforward:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	fightselector.buttonforward:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	fightselector.buttonend 	= CMX.UI:IconButton( "CMX_Report_FightButtonEnd" , 	fightselector , 	{32,32} , 		{LEFT,RIGHT,6,0,fightselector.buttonforward} , BSTATE_DISABLED , "CombatMetrics/icons/endarrowup.dds" , "CombatMetrics/icons/endarrowdown.dds", "CombatMetrics/icons/endarrowover.dds" ,  "CombatMetrics/icons/endarrowdisabled.dds" , false, scale ) 
	fightselector.buttonend:SetMouseEnabled( true )
	fightselector.buttonend:SetHandler( "OnMouseUp", function() if fightselector.buttonend:GetState() == BSTATE_DISABLED then return else CMX.UI:UpdateReport(CMX.set.UI.LRMenuItem, #CMX.lastfights) end end)	
	fightselector.buttonend.data = {tooltipText = GetString(SI_COMBAT_METRICS_MOST_RECENT_FIGHT)}
	fightselector.buttonend:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	fightselector.buttonend:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	fightselector.buttonload 	= CMX.UI:IconButton( "CMX_Report_FightButtonLoad" , fightselector , 	{32,32} , 		{LEFT,RIGHT,6,0,fightselector.buttonend} , CMX.set.saveddata == nil and BSTATE_DISABLED or BSTATE_NORMAL , "CombatMetrics/icons/loadiconup.dds" , "CombatMetrics/icons/loadicondown.dds", "CombatMetrics/icons/loadiconover.dds" , "CombatMetrics/icons/loadicondisabled.dds" , false, scale )
	fightselector.buttonload:SetMouseEnabled( true )
	fightselector.buttonload:SetHandler( "OnMouseUp", function() if fightselector.buttonload:GetState() == BSTATE_DISABLED then return else CMX.ToggleFightList() end end)
	fightselector.buttonload.data = {tooltipText = GetString(SI_COMBAT_METRICS_LOAD_FIGHT)}
	fightselector.buttonload:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	fightselector.buttonload:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	fightselector.buttonsave 	= CMX.UI:IconButton( "CMX_Report_FightButtonSave" , fightselector , 	{32,32} , 		{LEFT,RIGHT,6,0,fightselector.buttonload} , BSTATE_DISABLED , "CombatMetrics/icons/saveiconup.dds" , "CombatMetrics/icons/saveicondown.dds", "CombatMetrics/icons/saveiconover.dds" , "CombatMetrics/icons/saveicondisabled.dds" , false, scale ) 
	fightselector.buttonsave:SetMouseEnabled( true )
	fightselector.buttonsave:SetHandler( "OnMouseUp", function() if fightselector.buttonsave:GetState() == BSTATE_DISABLED then return else CMX.SaveFight(CMX.UI.Currentfightid) end end)	
	fightselector.buttonsave.data = {tooltipText = GetString(SI_COMBAT_METRICS_SAVE_FIGHT)}
	fightselector.buttonsave:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	fightselector.buttonsave:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	fightselector.buttondelete 	= CMX.UI:IconButton( "CMX_Report_FightButtonDelete" , fightselector , 	{32,32} , 		{LEFT,RIGHT,6,0,fightselector.buttonsave} , BSTATE_DISABLED , "CombatMetrics/icons/deleteiconup.dds" , "CombatMetrics/icons/deleteicondown.dds", "CombatMetrics/icons/deleteiconover.dds" , "CombatMetrics/icons/deleteicondisabled.dds" , false, scale ) 
	fightselector.buttondelete:SetMouseEnabled( true )
	fightselector.buttondelete:SetHandler( "OnMouseUp", 
		function() 
			if fightselector.buttondelete:GetState() == BSTATE_DISABLED then return 
			else 
				table.remove(CMX.lastfights,CMX.UI.Currentfightid)
				if #CMX.lastfights == 0 then CMX.UI.Controls() else CMX.UI:UpdateReport(CMX.set.UI.LRMenuItem, math.min(CMX.UI.Currentfightid,#CMX.lastfights)) end
			end 
		end
	)	
	fightselector.buttondelete.data = {tooltipText = GetString(SI_COMBAT_METRICS_DELETE_FIGHT)}
	fightselector.buttondelete:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	fightselector.buttondelete:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	local titlemenu 	= CMX.UI:Control(   	"CMX_Report_TitleMenu", 			RW, 				{332,38}, 		{TOPRIGHT,TOPRIGHT,-4,1}, 				false, scale )
	titlemenu.label		= CMX.UI:Label( 		"CMX_Report_TitleMenuLabel", 		titlemenu, 			{120,38}, 		{TOPLEFT,TOPLEFT,0,0}, 				CMX.UI:Font("standard",20,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_DAMAGE) , false, scale )
	local titlemenu1	= CMX.UI:Control(   	"CMX_Report_TitleMenu1", 			titlemenu, 			{38,38}, 		{TOPLEFT,TOPRIGHT,12,0,titlemenu.label}, 					false, scale )
	titlemenu1.icon 	= CMX.UI:Texture(   	"CMX_Report_TitleMenu1Icon",		titlemenu1,			{30,30},  		{CENTER,CENTER,0,0},  			'/esoui/art/icons/heraldrycrests_weapon_axe_02.dds', false, scale )
	titlemenu1.icon:SetColor(1,0.8,0.8,CMX.set.UI.LRMenuItem == "dmgout" and 1 or 0.2)
	titlemenu1:SetMouseEnabled( true )
	titlemenu1:SetHandler( "OnMouseUp", function() CMX.UI.SelectCategory("dmgout", 1) end)
	titlemenu1.data = {tooltipText = GetString(SI_COMBAT_METRICS_DAMAGE_CAUSED)}
	titlemenu1:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	titlemenu1:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	local titlemenu2	= CMX.UI:Control(   	"CMX_Report_TitleMenu2", 			titlemenu, 			{38,38}, 		{TOPLEFT,TOPRIGHT,0,0,titlemenu1}, 				false, scale )
	titlemenu2.icon 	= CMX.UI:Texture(   	"CMX_Report_TitleMenu2Icon",		titlemenu2,			{30,30},  		{CENTER,CENTER,0,0},  			'/esoui/art/buttons/gamepad/gp_plus_large.dds', false, scale )
	titlemenu2.icon:SetColor(0.8,1,0.8,CMX.set.UI.LRMenuItem == "healout" and 1 or 0.2)
	titlemenu2:SetMouseEnabled( true )
	titlemenu2:SetHandler( "OnMouseUp", function() CMX.UI.SelectCategory("healout", 2) end)
	titlemenu2.data = {tooltipText = GetString(SI_COMBAT_METRICS_HEALING_DONE)}
	titlemenu2:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	titlemenu2:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	local titlemenu3	= CMX.UI:Control(   	"CMX_Report_TitleMenu3", 			titlemenu, 			{38,38}, 		{TOPLEFT,TOPRIGHT,0,0,titlemenu2}, 				false, scale )
	titlemenu3.icon 	= CMX.UI:Texture(   	"CMX_Report_TitleMenu3Icon",		titlemenu3,			{30,30},  		{CENTER,CENTER,0,0},  			'/esoui/art/icons/heraldrycrests_weapon_shield_01.dds', false, scale )
	titlemenu3.icon:SetColor(0.8,0.8,1,CMX.set.UI.LRMenuItem == "dmgin" and 1 or 0.2)
	titlemenu3:SetMouseEnabled( true )
	titlemenu3:SetHandler( "OnMouseUp", function() CMX.UI.SelectCategory("dmgin", 3) end)
	titlemenu3.data = {tooltipText = GetString(SI_COMBAT_METRICS_DAMAGE_RECEIVED)}
	titlemenu3:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	titlemenu3:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	local titlemenu4	= CMX.UI:Control(   	"CMX_Report_TitleMenu4", 			titlemenu, 			{38,38}, 		{TOPLEFT,TOPRIGHT,0,0,titlemenu3}, 				false, scale )
	titlemenu4.icon 	= CMX.UI:Texture(   	"CMX_Report_TitleMenu4Icon",		titlemenu4,			{38,38}, 		{CENTER,CENTER,0,0},  			'/esoui/art/hud/gamepad/gp_radialicon_invitegroup_down.dds', false, scale )
	titlemenu4.icon:SetColor(1,1,0.8,CMX.set.UI.LRMenuItem == "healin" and 1 or 0.2)
	titlemenu4:SetMouseEnabled( true )
	titlemenu4:SetHandler( "OnMouseUp", function() CMX.UI.SelectCategory("healin", 4) end)
	titlemenu4.data = {tooltipText = GetString(SI_COMBAT_METRICS_HEALING_RECIVED)}
	titlemenu4:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	titlemenu4:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	local titlemenu5	= CMX.UI:Control(   	"CMX_Report_TitleMenu5", 			titlemenu, 			{38,38}, 		{TOPLEFT,TOPRIGHT,10,0,titlemenu4}, 			false, scale )
	titlemenu5.icon 	= CMX.UI:Texture(   	"CMX_Report_TitleMenu5Icon",		titlemenu5,			{30,30},  		{CENTER,CENTER,0,0},  			'esoui/art/guild/gamepad/gp_guild_menuicon_roster.dds', false, scale )
	titlemenu5.icon:SetColor(1,1,1,.2)
	titlemenu5:SetMouseEnabled( true )
	titlemenu5:SetHandler( "OnMouseUp", function() CMX.UI:ToggleLog(titlemenu5.icon) end)
	titlemenu5.data = {tooltipText = GetString(SI_COMBAT_METRICS_TOGGLE_COMBAT_LOG)}
	titlemenu5:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	titlemenu5:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
		
-- Fights list
	
	local fightlist 			= CMX.UI:Control(   	"CMX_Report_FightList", 				RW, 			{932,693}, 		{TOPLEFT,BOTTOMLEFT,4,12,title},	true, scale )
	fightlist:SetDrawTier(DT_MEDIUM)
	fightlist.backdrop			= CMX.UI:Backdrop(		"CMX_Report_FightList_BG",				fightlist,			"inherit",		{CENTER,CENTER,0,0},					{0.08,0.08,0.08,0.98}, {1,1,1,0.5}, {1,1,2*scale} ,nil, false, 1 )
	
	fightlist.header 			= CMX.UI:Control(   	"CMX_Report_FightList_header", 			fightlist, 			{928,height+4}, {TOPLEFT,TOPLEFT,0,0}, 						false, scale )
	fightlist.header.backdrop	= CMX.UI:Backdrop(		"CMX_Report_FightList_header_BG2",		fightlist.header,	{920,1},		{TOP,BOTTOM,2,0},							{0,0,0,0}, {1,1,1,1}, {1,1,1} ,nil, false, scale )
	fightlist.header.label 		= CMX.UI:Label( 		"CMX_Report_FightList_header_Label", 	fightlist.header, 	{438,height}, 	{LEFT,LEFT,4,0}, 							CMX.UI:Font("standard",fontsize+2,true, scale), {1,1,1,1}, {0,1}, GetString(SI_COMBAT_METRICS_RECENT_FIGHT), false, scale )
	fightlist.header.label2 	= CMX.UI:Label( 		"CMX_Report_FightList_header_Label2",	fightlist.header, 	{60,height}, 	{LEFT,RIGHT,8,0,fightlist.header.label}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_DURATION), false, scale )
	fightlist.header.label3 	= CMX.UI:Label( 		"CMX_Report_FightList_header_Label3",	fightlist.header, 	{75,height}, 	{LEFT,RIGHT,8,0,fightlist.header.label2},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_DPS), false, scale )
	fightlist.header.label4 	= CMX.UI:Label( 		"CMX_Report_FightList_header_Label4",	fightlist.header, 	{75,height}, 	{LEFT,RIGHT,8,0,fightlist.header.label3},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_HPS), false, scale )
	fightlist.header.label5 	= CMX.UI:Label( 		"CMX_Report_FightList_header_Label5",	fightlist.header, 	{75,height}, 	{LEFT,RIGHT,8,0,fightlist.header.label4},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_INC_DPS), false, scale )
	fightlist.header.label6 	= CMX.UI:Label( 		"CMX_Report_FightList_header_Label6",	fightlist.header, 	{75,height}, 	{LEFT,RIGHT,8,0,fightlist.header.label5},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_INC_HPS), false, scale )
	--fightlist.header.label7 	= CMX.UI:Label( 		"CMX_Report_FightList_header_Label7",	fightlist.header, 	{60,height}, 	{LEFT,RIGHT,8,0,fightlist.header.label6},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_SHOW), false, scale )
	fightlist.header.label7 	= CMX.UI:Label( 		"CMX_Report_FightList_header_Label7",	fightlist.header, 	{60,height}, 	{LEFT,RIGHT,8,0,fightlist.header.label6},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_DELETE), false, scale )
	
	
	fightlist.panel = CMX_Report_FightList_Panel or wm:CreateControlFromVirtual("CMX_Report_FightList_Panel", 	fightlist, "ZO_ScrollContainer")
	fightlist.panel:ClearAnchors()
	fightlist.panel:SetAnchor(TOPLEFT,fightlist.header.backdrop,BOTTOMLEFT,0,1)
	--fightlist.panel:SetDimensions(929*scale,(335-height+4)*scale)
	fightlist.panel:SetAnchor(BOTTOMRIGHT,fightlist,BOTTOMRIGHT,-3,-7-((693/2)+height+4)*scale)
	fightlist.scroll = GetControl(fightlist.panel, "ScrollChild")
	fightlist.scroll:SetResizeToFitPadding(0, 20)
	
	fightlist.panel.backdrop	= CMX.UI:Backdrop(		"CMX_Report_FightList_Panel_BG2",		fightlist.panel,	{920,1},		{TOP,BOTTOM,-1.5,0},							{0,0,0,0}, {.5,.5,.5,1}, {1,1,1} ,nil, false, scale )
	

	fightlist.header2 			= CMX.UI:Control(   	"CMX_Report_FightListSaved_header", 		fightlist, 			{928,height+4}, {TOP,BOTTOM,0,1,fightlist.panel.backdrop}, 						false, scale )
	fightlist.header2.backdrop	= CMX.UI:Backdrop(		"CMX_Report_FightListSaved_header_BG2",		fightlist.header2,	{920,1},		{TOP,BOTTOM,0,0},							{0,0,0,0}, {1,1,1,1}, {1,1,1} ,nil, false, scale )
	fightlist.header2.label 	= CMX.UI:Label( 		"CMX_Report_FightListSaved_header_Label", 	fightlist.header2, 	{438,height}, 	{LEFT,LEFT,4,0}, 							CMX.UI:Font("standard",fontsize+2,true, scale), {1,1,1,1}, {0,1}, GetString(SI_COMBAT_METRICS_SAVED_FIGHTS), false, scale )
	fightlist.header2.label2 	= CMX.UI:Label( 		"CMX_Report_FightListSaved_header_Label2",	fightlist.header2, 	{60,height}, 	{LEFT,RIGHT,8,0,fightlist.header2.label}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_DURATION), false, scale )
	fightlist.header2.label3 	= CMX.UI:Label( 		"CMX_Report_FightListSaved_header_Label3",	fightlist.header2, 	{75,height}, 	{LEFT,RIGHT,8,0,fightlist.header2.label2},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_DPS), false, scale )
	fightlist.header2.label4 	= CMX.UI:Label( 		"CMX_Report_FightListSaved_header_Label4",	fightlist.header2, 	{75,height}, 	{LEFT,RIGHT,8,0,fightlist.header2.label3},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_HPS), false, scale )
	fightlist.header2.label5 	= CMX.UI:Label( 		"CMX_Report_FightListSaved_header_Label5",	fightlist.header2, 	{75,height}, 	{LEFT,RIGHT,8,0,fightlist.header2.label4},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_INC_DPS), false, scale )
	fightlist.header2.label6 	= CMX.UI:Label( 		"CMX_Report_FightListSaved_header_Label6",	fightlist.header2, 	{75,height}, 	{LEFT,RIGHT,8,0,fightlist.header2.label5},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_INC_HPS), false, scale )
	fightlist.header2.label7 	= CMX.UI:Label( 		"CMX_Report_FightListSaved_header_Label7",	fightlist.header2, 	{60,height}, 	{LEFT,RIGHT,8,0,fightlist.header2.label6},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_DELETE), false, scale )
	
	fightlist.panel2 = CMX_Report_FightListSaved_Panel or wm:CreateControlFromVirtual("CMX_Report_FightListSaved_Panel", 	fightlist, "ZO_ScrollContainer")
	fightlist.panel2:ClearAnchors()
	fightlist.panel2:SetAnchor(TOPLEFT,fightlist.header2,BOTTOMLEFT,0,1)
	fightlist.panel2:SetAnchor(BOTTOMRIGHT,fightlist,BOTTOMRIGHT,-3,-3)
	fightlist.scroll2 = GetControl(fightlist.panel2, "ScrollChild")
	fightlist.scroll2:SetResizeToFitPadding(0, 20)	
	
	
-- Stats Area
	local genstats 		= CMX.UI:Control(   	"CMX_Report_Stats", 			RW, 		{660,372}, 	{TOPLEFT,BOTTOMLEFT,4,12,title}, 				false, scale )
	genstats.backdrop	= CMX.UI:Backdrop(		"CMX_Report_Stats_BG",			genstats,	"inherit",	{CENTER,CENTER,0,0},			{0,0,.1,0.1}, {1,1,1,0.5}, {1,1,2*scale} ,nil, false, 1 )
	
	genstats.left  		= CMX.UI:Control(   	"CMX_Report_Stats_Leftpanel", 	genstats, 	{375,372}, 	{TOPLEFT,TOPLEFT,0,0}, 				false, scale )
	genstats.lrsep		= CMX.UI:Backdrop(		"CMX_Report_Stats_LRSep",		genstats.left,	{1,364},{LEFT,RIGHT,0,0},				{0,0,0,0}, {1,1,1,1}, {1,1,1} ,nil, false, scale )
	
	
	local genstatlabel1_1	= CMX.UI:CreateStatLabel( 	"1_1", GetString(SI_COMBAT_METRICS_ACTIVE_TIME),	98,	genstats.left, 					{TOPLEFT,TOPLEFT,4,4}, 						{2,1}, 	nil, scale)
	local genstat1_1		= CMX.UI:CreateStatControl( "1_1", GetString(SI_COMBAT_METRICS_ZERO_SEC), 			82,	genstatlabel1_1,				{LEFT,RIGHT,0,0,genstatlabel1_1}, 			nil, 	{1,.8,.5,1}, scale)	--DPS/GDPS	
	local genstatlabel1_2	= CMX.UI:CreateStatLabel( 	"1_2", GetString(SI_COMBAT_METRICS_IN_COMBAT),	98,	genstats.left, 					{LEFT,RIGHT,4,0,genstat1_1}, 				{2,1}, 	nil, scale)
	local genstat1_2		= CMX.UI:CreateStatControl( "1_2", GetString(SI_COMBAT_METRICS_ZERO_SEC), 			82,	genstatlabel1_2,				{LEFT,RIGHT,0,0,genstatlabel1_2}, 			nil, 	nil, scale)	--DPS/GDPS	
	genstatlabel1_1.backdrop= CMX.UI:Backdrop(		"CMX_Report_Stats_Sep_1",		genstatlabel1_1,	{367,1},	{TOPLEFT,BOTTOMLEFT,0,1},					{0,0,0,0}, {.5,.5,.5,.5}, {1,1,1} ,nil, false, scale )
	
	local genstatlabelH_1	= CMX.UI:CreateStatLabel( 	"H_1", GetString(SI_COMBAT_METRICS_PLAYER),		98,	genstats.left, 					{TOPLEFT,BOTTOMLEFT,120,8,genstatlabel1_1},	{1,1}, nil, scale)
	genstatlabelH_1.backdrop= CMX.UI:Backdrop(		"CMX_Report_Stats_BG_1",		genstatlabelH_1,	{93,306},	{TOP,TOP,0,0},								{0.1,0.1,.3,.2}, 	{1,1,1,0}, 		{1,1,1} ,nil, false, scale )
	genstatlabelH_1.sep		= CMX.UI:Backdrop(		"CMX_Report_Stats_Sep_2",		genstatlabelH_1,	{86,1},		{TOP,BOTTOM,0,1},							{0,0,0,0}, 			{.5,.5,.5,.6}, 	{1,1,1} ,nil, false, scale )
	local genstatlabelH_2	= CMX.UI:CreateStatLabel( 	"H_2", GetString(SI_COMBAT_METRICS_GROUP), 		98,	genstats.left, 					{LEFT,RIGHT,0,0,genstatlabelH_1}, 			{1,1}, 				{1,.8,.5,1}, scale)
	genstatlabelH_2.backdrop= CMX.UI:Backdrop(		"CMX_Report_Stats_BG_2",		genstatlabelH_2,	{93,306},	{TOP,TOP,0,0},								{0.2,0.2,0.1,.15}, 	{1,1,1,0}, 		{1,1,1} ,nil, false, scale )
	genstatlabelH_2.sep		= CMX.UI:Backdrop(		"CMX_Report_Stats_Sep_3",		genstatlabelH_2,	{86,1},		{TOP,BOTTOM,0,1},							{0,0,0,0}, 			{.5,.5,.5,.6}, 	{1,1,1} ,nil, false, scale )
	local genstatlabelH_3	= CMX.UI:CreateStatLabel( 	"H_3", "%", 			52, genstats.left, 					{LEFT,RIGHT,0,0,genstatlabelH_2}, 			{1,1}, 				{1,.8,.5,1}, scale)
	genstatlabelH_3.sep		= CMX.UI:Backdrop(		"CMX_Report_Stats_Sep_4",		genstatlabelH_3,	{47,1},		{TOP,BOTTOM,0,1},							{0,0,0,0}, 			{.5,.5,.5,.6}, 	{1,1,1} ,nil, false, scale )
	
	local genstatlabel2_0	= CMX.UI:CreateStatLabel( 	"2_0", GetString(SI_COMBAT_METRICS_DPS_C), 		120,	genstats.left, 					{TOPRIGHT,BOTTOMLEFT,0,4,genstatlabelH_1}, 	{2,1}, nil, scale)
	local genstat2_1		= CMX.UI:CreateStatControl( "2_1", "0", 			98,	genstatlabel2_0, 				{LEFT,RIGHT,0,0,genstatlabelDPS}, nil, nil, scale) --DPS
	genstat2_1.value:SetFont( CMX.UI:Font("esobold",17,true, scale) )
	local genstat2_2		= CMX.UI:CreateStatControl( "2_2", "0", 			98,	genstatlabel2_0,				{LEFT,RIGHT,0,0,genstat2_1}, 	nil, {1,.8,.5,1}, scale)	--GDPS
	local genstat2_3		= CMX.UI:CreateStatControl( "2_3", "0 %", 			52,	genstatlabel2_0,				{LEFT,RIGHT,0,0,genstat2_2}, 	nil, {1,.8,.5,1}, scale)	--DPS/GDPS	
	
	local genstatlabelDmg	= CMX.UI:CreateStatLabel( 	"Dmg", GetString(SI_COMBAT_METRICS_DAMAGE), 		369,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,8,genstatlabel2_0}, 	{0,1}, nil, scale)
	genstatlabelDmg.label:SetColor(.8,.8,.7,1)
	genstatlabelDmg.backdrop= CMX.UI:Backdrop(		"CMX_Report_Stats_Sep_5",		genstatlabelDmg,	{367,1},	{TOPLEFT,BOTTOMLEFT,0,1},		{0,0,0,0}, {.5,.5,.5,.6}, {1.9,1.9,1.9} ,nil, false, scale )
	
	local genstatlabel3_0	= CMX.UI:CreateStatLabel( 	"3_0", GetString(SI_COMBAT_METRICS_TOTAL), 		120,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,4,genstatlabelDmg}, 	{2,1}, nil, scale)
	local genstat3_1		= CMX.UI:CreateStatControl( "3_1", "0", 			98,	genstatlabel3_0, 				{LEFT,RIGHT,0,0,genstatlabel3_0}, nil, nil, scale) 				--Total Damage
	local genstat3_2		= CMX.UI:CreateStatControl( "3_2", "0", 			98,	genstatlabel3_0,				{LEFT,RIGHT,0,0,genstat3_1}, 	nil, {1,.8,.5,1}, scale)	--Total Group Damage
	local genstat3_3		= CMX.UI:CreateStatControl( "3_3", "0 %", 			52,	genstatlabel3_0,				{LEFT,RIGHT,0,0,genstat3_2}, 	nil, {1,.8,.5,1}, scale)	--Damage/Group Damage	
	
	local genstatlabel4_0	= CMX.UI:CreateStatLabel( 	"4_0", GetString(SI_COMBAT_METRICS_NORMAL), 		120,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,0,genstatlabel3_0}, 	{2,1}, 	nil, scale)
	local genstat4_1		= CMX.UI:CreateStatControl( "4_1", "0", 			98,	genstatlabel4_0, 				{LEFT,RIGHT,0,0,genstatlabel4_0}, 			nil, 	nil, scale) 				--Normal Damage
	local genstat4_2		= CMX.UI:CreateStatControl( "4_2", "", 				98,	genstatlabel4_0,				{LEFT,RIGHT,0,0,genstat4_1}, 				nil, 	{1,.8,.5,1}, scale)	--
	local genstat4_3		= CMX.UI:CreateStatControl( "4_3", "0 %", 			52,	genstatlabel4_0,				{LEFT,RIGHT,0,0,genstat4_2}, 				nil, 	nil, scale	)				--Normal Damage/Total Damage	
	
	local genstatlabel5_0	= CMX.UI:CreateStatLabel( 	"5_0", GetString(SI_COMBAT_METRICS_CRITICAL), 	120,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,0,genstatlabel4_0}, 	{2,1}, 	nil, scale)
	local genstat5_1		= CMX.UI:CreateStatControl( "5_1", "0", 			98,	genstatlabel5_0, 				{LEFT,RIGHT,0,0,genstatlabel5_0}, 			nil, 	nil, scale) 				--Critical Damage
	local genstat5_2		= CMX.UI:CreateStatControl( "5_2", "", 				98,	genstatlabel5_0,				{LEFT,RIGHT,0,0,genstat5_1}, 				nil, 	{1,.8,.5,1}, scale)	--
	local genstat5_3		= CMX.UI:CreateStatControl( "5_3", "0 %", 			52,	genstatlabel5_0,				{LEFT,RIGHT,0,0,genstat5_2}, 				nil, 	nil, scale 	)				--Critical Damage/Total Damage	
	
	local genstatlabel6_0	= CMX.UI:CreateStatLabel( 	"6_0", GetString(SI_COMBAT_METRICS_BLOCKED), 		120,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,0,genstatlabel5_0}, 	{2,1}, 	nil, scale)
	local genstat6_1		= CMX.UI:CreateStatControl( "6_1", "", 				98,	genstatlabel6_0, 				{LEFT,RIGHT,0,0,genstatlabel6_0}, 			nil, 	nil, scale) 				--Shielded Damage
	local genstat6_2		= CMX.UI:CreateStatControl( "6_2", "", 				98,	genstatlabel6_0,				{LEFT,RIGHT,0,0,genstat6_1}, 				nil, 	{1,.8,.5,1}, scale)	--
	local genstat6_3		= CMX.UI:CreateStatControl( "6_3", "", 				52,	genstatlabel6_0,				{LEFT,RIGHT,0,0,genstat6_2}, 				nil, 	nil, scale)	--Shielded Damage/Total Damage	
	
	local genstatlabel7_0	= CMX.UI:CreateStatLabel( 	"7_0", GetString(SI_COMBAT_METRICS_SHIELDED), 	120,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,0,genstatlabel6_0}, 	{2,1}, 	nil, scale)
	local genstat7_1		= CMX.UI:CreateStatControl( "7_1", "", 				98,	genstatlabel7_0, 				{LEFT,RIGHT,0,0,genstatlabel7_0},		 	nil, 	nil, scale) 				--Shielded Damage
	local genstat7_2		= CMX.UI:CreateStatControl( "7_2", "", 				98,	genstatlabel7_0,				{LEFT,RIGHT,0,0,genstat7_1}, 				nil, 	{1,.8,.5,1}, scale)	--
	local genstat7_3		= CMX.UI:CreateStatControl( "7_3", "", 				52,	genstatlabel7_0,				{LEFT,RIGHT,0,0,genstat7_2}, 				nil, 	nil,scale)	--Shielded Damage/Total Damage	
	
	local genstatlabelHits	= CMX.UI:CreateStatLabel( 	"Hits", GetString(SI_COMBAT_METRICS_HITS), 		369,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,10,genstatlabel7_0}, 	{0,1}, nil, scale)
	genstatlabelHits.label:SetColor(.8,.8,.7,1)
	genstatlabelHits.backdrop= CMX.UI:Backdrop(		"CMX_Report_Stats_Sep_6",		genstatlabelHits,	{367,1},	{TOPLEFT,BOTTOMLEFT,0,1},		{0,0,0,0}, {.5,.5,.5,.6}, {1.9,1.9,1.9} ,nil, false, scale )
	
	local genstatlabel8_0	= CMX.UI:CreateStatLabel( 	"8_0", GetString(SI_COMBAT_METRICS_TOTAL), 		120,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,4,genstatlabelHits}, 	{2,1}, 	nil, scale)
	local genstat8_1		= CMX.UI:CreateStatControl( "8_1", "0", 			98,	genstatlabel8_0, 				{LEFT,RIGHT,0,0,genstatlabel8_0}, 			nil, 	nil, scale) 				--Total Hits
	local genstat8_2		= CMX.UI:CreateStatControl( "8_2", "0", 			98,	genstatlabel8_0,				{LEFT,RIGHT,0,0,genstat8_1}, 				nil, 	{1,.8,.5,1}, scale)	--Total Group Hits
	local genstat8_3		= CMX.UI:CreateStatControl( "8_3", "0 %", 			52,	genstatlabel8_0,				{LEFT,RIGHT,0,0,genstat8_2}, 				nil, 	{1,.8,.5,1}, scale)	--Hits/Group Hits	
	
	local genstatlabel9_0	= CMX.UI:CreateStatLabel( 	"9_0", GetString(SI_COMBAT_METRICS_NORMAL), 		120,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,0,genstatlabel8_0}, 	{2,1}, 	nil, scale)
	local genstat9_1		= CMX.UI:CreateStatControl( "9_1", "0", 			98,	genstatlabel9_0, 				{LEFT,RIGHT,0,0,genstatlabel9_0}, 			nil, 	nil, scale) 				--Normal Hits
	local genstat9_2		= CMX.UI:CreateStatControl( "9_2", "", 				98,	genstatlabel9_0,				{LEFT,RIGHT,0,0,genstat9_1}, 				nil, 	{1,.8,.5,1}, scale)	--
	local genstat9_3		= CMX.UI:CreateStatControl( "9_3", "0 %", 			52,	genstatlabel9_0,				{LEFT,RIGHT,0,0,genstat9_2}, 				nil, 	nil, scale 	)				--Normal Hits/Total Hits	
	
	local genstatlabel10_0	= CMX.UI:CreateStatLabel( 	"10_0", GetString(SI_COMBAT_METRICS_CRITICAL), 	120,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,0,genstatlabel9_0}, 	{2,1}, 	nil, scale)
	local genstat10_1		= CMX.UI:CreateStatControl( "10_1", "0", 			98,	genstatlabel10_0, 				{LEFT,RIGHT,0,0,genstatlabel10_0}, 			nil, 	nil, scale) 				--Critical Hits
	local genstat10_2		= CMX.UI:CreateStatControl( "10_2", "", 			98,	genstatlabel10_0,				{LEFT,RIGHT,0,0,genstat10_1}, 				nil, 	{1,.8,.5,1}, scale)	--
	local genstat10_3		= CMX.UI:CreateStatControl( "10_3", "0 %", 			52,	genstatlabel10_0,				{LEFT,RIGHT,0,0,genstat10_2}, 				nil, 	nil, scale 	)				--Critical Hits/Total Hits	
	
	local genstatlabel11_0	= CMX.UI:CreateStatLabel( 	"11_0", GetString(SI_COMBAT_METRICS_BLOCKED), 	120,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,0,genstatlabel10_0}, 	{2,1}, 	nil, scale)
	local genstat11_1		= CMX.UI:CreateStatControl( "11_1", "", 			98,	genstatlabel11_0, 				{LEFT,RIGHT,0,0,genstatlabel11_0}, 			nil,	 nil, scale) 				--Shielded Hits
	local genstat11_2		= CMX.UI:CreateStatControl( "11_2", "", 			98,	genstatlabel11_0,				{LEFT,RIGHT,0,0,genstat11_1}, 				nil, 	{1,.8,.5,1}, scale)	--
	local genstat11_3		= CMX.UI:CreateStatControl( "11_3", "", 			52,	genstatlabel11_0,				{LEFT,RIGHT,0,0,genstat11_2}, 				nil, 	nil, scale)	--Shielded Hits/Total Hits	
	
	local genstatlabel12_0	= CMX.UI:CreateStatLabel( 	"12_0", GetString(SI_COMBAT_METRICS_SHIELDED), 	120,genstats.left, 					{TOPLEFT,BOTTOMLEFT,0,0,genstatlabel11_0}, 	{2,1}, nil, scale)
	local genstat12_1		= CMX.UI:CreateStatControl( "12_1", "", 			98,	genstatlabel12_0, 				{LEFT,RIGHT,0,0,genstatlabel12_0}, 			nil, 	nil, scale) 				--Shielded Hits
	local genstat12_2		= CMX.UI:CreateStatControl( "12_2", "", 			98,	genstatlabel12_0,				{LEFT,RIGHT,0,0,genstat12_1}, 				nil, 	{1,.8,.5,1}, scale)	--
	local genstat12_3		= CMX.UI:CreateStatControl( "12_3", "", 			52,	genstatlabel12_0,				{LEFT,RIGHT,0,0,genstat12_2}, 				nil, 	nil, scale)	--Shielded Hits/Total Hits	
	
	genstats.right  		= CMX.UI:Control(   	"CMX_Report_Stats_Rightpanel", 	genstats, 			{284,372}, 	{TOPRIGHT,TOPRIGHT,0,0}, 		false, scale )
	--genstats.right.backdrop	= CMX.UI:Backdrop(		"CMX_Report_Stats_Rightpanel_BG",			genstats.right,		"inherit",	{CENTER,CENTER,0,0},				{.6,0,0,.5}, {1,1,1,0}, {1,1,2*scale} ,nil, false, 1 )
	
	
	local rstatlabelRes	= CMX.UI:CreateStatLabel( 	"Res", GetString(SI_COMBAT_METRICS_RESOURCES), 		100,genstats.right, 			{TOPLEFT,TOPLEFT,4,4}, 				{0,1}, nil, scale)
	rstatlabelRes.label:SetColor(.8,.8,.7,1)
	local rstatlabelRes2= CMX.UI:CreateStatLabel( 	"Res2", GetString(SI_COMBAT_METRICS_REGS), 			84,genstats.right, 				{LEFT,RIGHT,0,0,rstatlabelRes}, 	{2,1}, nil, scale)
	local rstatlabelRes3= CMX.UI:CreateStatLabel( 	"Res3", GetString(SI_COMBAT_METRICS_DRAINS), 			84,genstats.right, 				{LEFT,RIGHT,0,0,rstatlabelRes2}, 	{2,1}, nil, scale)
	rstatlabelRes.backdrop= CMX.UI:Backdrop(		"CMX_Report_Stats_Sep_R1",		rstatlabelRes,	{276,1},	{TOPLEFT,BOTTOMLEFT,0,1},		{0,0,0,0}, {.5,.5,.5,.6}, {1.9,1.9,1.9} ,nil, false, scale )
	
	local rstatlabel1_0		= CMX.UI:CreateStatLabel( 	"r1_0", GetString(SI_COMBAT_METRICS_MAGICKA_C), 	100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,4,rstatlabelRes}, 	{2,1}, 	{0.7,0.7,1,1}, scale)
	local rstat1_1			= CMX.UI:CreateStatControl( "r1_1", "0", 			84,	rstatlabel1_0, 				{LEFT,RIGHT,0,0,rstatlabel1_0}, 			nil, 	{0.7,0.7,1,1}, scale) 	--Magicka Reg
	local rstat1_2			= CMX.UI:CreateStatControl( "r1_2", "0", 			84,	rstatlabel1_0,				{LEFT,RIGHT,0,0,rstat1_1}, 					nil, 	{0.7,0.7,1,1}, scale)	--Magicka Drain
	
	local rstatlabel2_0		= CMX.UI:CreateStatLabel( 	"r2_0", GetString(SI_COMBAT_METRICS_STAMINA_C), 	100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,4,rstatlabel1_0}, 	{2,1}, 	{0.7,1,0.7,1}, scale)
	local rstat2_1			= CMX.UI:CreateStatControl( "r2_1", "0", 			84,	rstatlabel2_0, 				{LEFT,RIGHT,0,0,rstatlabel2_0}, 			nil, 	{0.7,1,0.7,1}, scale) 	--Stamina Reg
	local rstat2_2			= CMX.UI:CreateStatControl( "r2_2", "0", 			84,	rstatlabel2_0,				{LEFT,RIGHT,0,0,rstat2_1}, 					nil, 	{0.7,1,0.7,1}, scale)	--Stamina Drain

	local rstatlabel3_0		= CMX.UI:CreateStatLabel( 	"r3_0", GetString(SI_COMBAT_METRICS_ULTIMATE_C), 	100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,4,rstatlabel2_0}, 	{2,1}, 	{1,1,0.7,1}, scale)
	local rstat3_1			= CMX.UI:CreateStatControl( "r3_1", "0", 			84,	rstatlabel3_0, 				{LEFT,RIGHT,0,0,rstatlabel3_0}, 			nil, 	{1,1,0.7,1}, scale) 	--Stamina Reg
	local rstat3_2			= CMX.UI:CreateStatControl( "r3_2", "0", 			84,	rstatlabel3_0,				{LEFT,RIGHT,0,0,rstat3_1}, 					nil, 	{1,1,0.7,1}, scale)	--Stamina Drain
	
	local rstatlabelStat	= CMX.UI:CreateStatLabel( 	"Stat", GetString(SI_COMBAT_METRICS_STATS), 		100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,12,rstatlabel3_0}, 	{0,1}, nil, scale)
	rstatlabelStat.label:SetColor(.8,.8,.7,1)
	local rstatlabelStat2= CMX.UI:CreateStatLabel( 	"Stat2", GetString(SI_COMBAT_METRICS_AVE), 			84,genstats.right, 				{LEFT,RIGHT,0,0,rstatlabelStat}, 	{2,1}, nil, scale)
	local rstatlabelStat3= CMX.UI:CreateStatLabel( 	"Stat3", GetString(SI_COMBAT_METRICS_MAX), 			84,genstats.right, 				{LEFT,RIGHT,0,0,rstatlabelStat2}, 	{2,1}, nil, scale)
	rstatlabelStat.backdrop= CMX.UI:Backdrop(		"CMX_Report_Stats_Sep_R2",		rstatlabelStat,	{276,1},	{TOPLEFT,BOTTOMLEFT,0,1},		{0,0,0,0}, {.5,.5,.5,.6}, {1.9,1.9,1.9} ,nil, false, scale )
	
	local rstatlabel4_0		= CMX.UI:CreateStatLabel( 	"r4_0", GetString(SI_COMBAT_METRICS_MAX_MAGICKA_C), 	100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,5,rstatlabelStat}, 	{2,1}, 	{0.7,0.7,1,1}, scale)
	local rstat4_1			= CMX.UI:CreateStatControl( "r4_1", "0", 			84,	rstatlabel4_0, 				{LEFT,RIGHT,0,0,rstatlabel4_0}, 			nil, 	{0.7,0.7,1,1}, scale) 				--Magicka Avg
	local rstat4_2			= CMX.UI:CreateStatControl( "r4_2", "0", 			84,	rstatlabel4_0,				{LEFT,RIGHT,0,0,rstat4_1}, 					nil, 	{0.7,0.7,1,1}, scale)				--Magicka Max
	
	local rstatlabel5_0		= CMX.UI:CreateStatLabel( 	"r5_0", GetString(SI_COMBAT_METRICS_SPELL_DMG_C), 	100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,4,rstatlabel4_0}, 	{2,1}, 	{0.7,0.7,1,1}, scale)
	local rstat5_1			= CMX.UI:CreateStatControl( "r5_1", "0", 			84,	rstatlabel5_0, 				{LEFT,RIGHT,0,0,rstatlabel5_0}, 			nil, 	{0.7,0.7,1,1}, scale) 				--Spell Dmg Avg
	local rstat5_2			= CMX.UI:CreateStatControl( "r5_2", "0", 			84,	rstatlabel5_0,				{LEFT,RIGHT,0,0,rstat5_1}, 					nil, 	{0.7,0.7,1,1}, scale)				--Spell Dmg Max

	local rstatlabel6_0		= CMX.UI:CreateStatLabel( 	"r6_0", GetString(SI_COMBAT_METRICS_SPELL_CRIT_C), 	100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,4,rstatlabel5_0}, 	{2,1}, 	{0.7,0.7,1,1}, scale)
	local rstat6_1			= CMX.UI:CreateStatControl( "r6_1", "0 %", 			84,	rstatlabel6_0, 				{LEFT,RIGHT,0,0,rstatlabel6_0}, 			nil, 	{0.7,0.7,1,1}, scale) 				--Spellcrit Avg
	local rstat6_2			= CMX.UI:CreateStatControl( "r6_2", "0 %", 			84,	rstatlabel6_0,				{LEFT,RIGHT,0,0,rstat6_1}, 					nil, 	{0.7,0.7,1,1}, scale)				--Spellcrit Max
	
	local rstatlabel7_0		= CMX.UI:CreateStatLabel( 	"r7_0", GetString(SI_COMBAT_METRICS_MAX_STAMINA_C), 	100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,14,rstatlabel6_0}, 	{2,1}, 	{0.7,1,0.7,1}, scale)
	local rstat7_1			= CMX.UI:CreateStatControl( "r7_1", "0", 			84,	rstatlabel7_0, 				{LEFT,RIGHT,0,0,rstatlabel7_0}, 			nil, 	{0.7,1,0.7,1}, scale) 				--Stamina Avg
	local rstat7_2			= CMX.UI:CreateStatControl( "r7_2", "0", 			84,	rstatlabel7_0,				{LEFT,RIGHT,0,0,rstat7_1}, 					nil, 	{0.7,1,0.7,1}, scale)				--Stamina Max
	
	local rstatlabel8_0		= CMX.UI:CreateStatLabel( 	"r8_0", GetString(SI_COMBAT_METRICS_WEAPON_DMC_C), 100,genstats.right, 				{TOPLEFT,BOTTOMLEFT,0,4,rstatlabel7_0}, 	{2,1}, 	{0.7,1,0.7,1}, scale)
	local rstat8_1			= CMX.UI:CreateStatControl( "r8_1", "0", 			84,	rstatlabel8_0, 				{LEFT,RIGHT,0,0,rstatlabel8_0}, 			nil, 	{0.7,1,0.7,1}, scale) 				--Weapon Dmg Avg
	local rstat8_2			= CMX.UI:CreateStatControl( "r8_2", "0", 			84,	rstatlabel8_0,				{LEFT,RIGHT,0,0,rstat8_1}, 					nil, 	{0.7,1,0.7,1}, scale)				--Weapon Dmg Max
	
	local rstatlabel9_0		= CMX.UI:CreateStatLabel( 	"r9_0", GetString(SI_COMBAT_METRICS_WEAPON_CRIT_C),  100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,4,rstatlabel8_0}, 	{2,1}, 	{0.7,1,0.7,1}, scale)
	local rstat9_1			= CMX.UI:CreateStatControl( "r9_1", "0 %", 			84,	rstatlabel9_0, 				{LEFT,RIGHT,0,0,rstatlabel9_0}, 			nil, 	{0.7,1,0.7,1}, scale) 				--Weaponcrit Avg
	local rstat9_2			= CMX.UI:CreateStatControl( "r9_2", "0 %", 			84,	rstatlabel9_0,				{LEFT,RIGHT,0,0,rstat9_1}, 					nil, 	{0.7,1,0.7,1}, scale)				--Weaponcrit Max
	
	local rstatlabel10_0	= CMX.UI:CreateStatLabel( 	"r10_0", GetString(SI_COMBAT_METRICS_PHYSICAL_RES_C), 	100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,14,rstatlabel9_0}, 	{2,1}, 	{1,0.7,0.7,1}, scale)
	local rstat10_1			= CMX.UI:CreateStatControl( "r10_1", "0", 			84,	rstatlabel10_0, 				{LEFT,RIGHT,0,0,rstatlabel10_0}, 				nil, 	{1,0.7,0.7,1}, scale) 				--Stamina Avg
	local rstat10_2			= CMX.UI:CreateStatControl( "r10_2", "0", 			84,	rstatlabel10_0,				{LEFT,RIGHT,0,0,rstat10_1}, 						nil, 	{1,0.7,0.7,1}, scale)				--Stamina Max
	
	local rstatlabel11_0	= CMX.UI:CreateStatLabel( 	"r11_0", GetString(SI_COMBAT_METRICS_SPELL_RES_C), 	100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,4,rstatlabel10_0}, 	{2,1}, 	{1,0.7,0.7,1}, scale)
	local rstat11_1			= CMX.UI:CreateStatControl( "r11_1", "0", 			84,	rstatlabel11_0, 			{LEFT,RIGHT,0,0,rstatlabel11_0}, 			nil, 	{1,0.7,0.7,1}, scale) 				--Weapon Dmg Avg
	local rstat11_2			= CMX.UI:CreateStatControl( "r11_2", "0", 			84,	rstatlabel11_0,				{LEFT,RIGHT,0,0,rstat11_1}, 				nil, 	{1,0.7,0.7,1}, scale)				--Weapon Dmg Max
	
	local rstatlabel12_0	= CMX.UI:CreateStatLabel( 	"r12_0", GetString(SI_COMBAT_METRICS_CRITICAL_RES_C), 	100,genstats.right, 			{TOPLEFT,BOTTOMLEFT,0,4,rstatlabel11_0}, 	{2,1}, 	{1,0.7,0.7,1}, scale)
	local rstat12_1			= CMX.UI:CreateStatControl( "r12_1", "0", 		84,	rstatlabel12_0, 			{LEFT,RIGHT,0,0,rstatlabel12_0}, 					nil, 	{1,0.7,0.7,1}, scale) 				--Weaponcrit Avg
	local rstat12_2			= CMX.UI:CreateStatControl( "r12_2", "0", 		84,	rstatlabel12_0,				{LEFT,RIGHT,0,0,rstat12_1}, 						nil, 	{1,0.7,0.7,1}, scale)				--Weaponcrit Max

	--
	
	local combatlog 			= CMX.UI:Control(   	"CMX_Report_Combatlog", 					RW, 						{660,372}, 				{TOPLEFT,BOTTOMLEFT,4,12,title}, 				true, scale )
	combatlog.backdrop			= CMX.UI:Backdrop(		"CMX_Report_Combatlog_BG",					combatlog,					"inherit",				{CENTER,CENTER,0,0},			{0,0,.1,0.1}, {1,1,1,0.5}, {1,1,2*scale} ,nil, false, 1 )
	combatlog.title 			= CMX.UI:Control(   	"CMX_Report_Combatlog_Title", 				combatlog, 					{652,height+6}, 		{TOPLEFT,TOPLEFT,4,2}, 			false, scale )
	combatlog.title.label 		= CMX.UI:Label( 		"CMX_Report_Combatlog_TitleLabel", 			combatlog.title, 			{120,height+6}, 		{LEFT,LEFT,4,0}, 				CMX.UI:Font("standard",fontsize+2,true, scale), {1,1,1,1}, {0,1}, GetString(SI_COMBAT_METRICS_COMBAT_LOG), false, scale )
	combatlog.title.backdrop	= CMX.UI:Backdrop(		"CMX_Report_Combatlog_Title_Sep",			combatlog.title,			{650,1}, 				{TOP,BOTTOM,0,1},				{0,0,0,0}, {1,1,1,1}, {1,1,1} ,nil, false, scale )
	
	combatlog.pagemenu			= CMX.UI:Control(   	"CMX_Report_Combatlog_PageMenu", 			combatlog, 					{(22+4)*10,22+4}, 		{LEFT,RIGHT,2,0,combatlog.title.label}, 		false, scale )
	
	combatlog.pagemenu.l		= CMX.UI:Control(   	"CMX_Report_Combatlog_PageMenul", 			combatlog.pagemenu, 		{22,22}, 			{LEFT,LEFT,2,0,combatlog.pagemenu}, 				false, scale )
	
	combatlog.pagemenu.l.backdrop	= CMX.UI:Backdrop(	"CMX_Report_Combatlog_PageMenul_BG",		combatlog.pagemenu.l,		"inherit", 			{CENTER,CENTER,0,0},			{0,0,0,0.8}, {1,1,1,0.4}, {1,1,1*scale} ,nil, false, 1 )
	combatlog.pagemenu.l.icon 	= CMX.UI:Texture(   	"CMX_Report_Combatlog_PageMenul_Icon",		combatlog.pagemenu.l,		"inherit",  		{CENTER,CENTER,0,0},  			'CombatMetrics/icons/leftarrowover.dds', false, 1 )
	combatlog.pagemenu.l.backdrop:SetDrawLayer(DL_OVERLAY)
	combatlog.pagemenu.l:SetMouseEnabled( true )
	combatlog.pagemenu.l:SetHandler( "OnMouseUp", function() CMX.UI.UpdateCL(CMX.UI.CLCurrentPage-1) end)
	combatlog.pagemenu.l.data = {tooltipText = GetString(SI_COMBAT_METRICS_GOTO_PREVIOUS)}
	combatlog.pagemenu.l:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	combatlog.pagemenu.l:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	for i=1,5 do
		combatlog.pagemenu[i]	= CMX.UI:Control(   	"CMX_Report_Combatlog_PageMenu"..i, 			combatlog.pagemenu, 		{22,22}, 			{LEFT,RIGHT,2,0,i==1 and combatlog.pagemenu.l or combatlog.pagemenu[i-1]}, 				false, scale )
		combatlog.pagemenu[i]["no"]= CMX.UI:Label( 		"CMX_Report_Combatlog_PageMenu"..i.."_Label", 	combatlog.pagemenu[i], 		"inherit", 		    {CENTER,CENTER,0,0}, 				CMX.UI:Font("standard",fontsize,true, scale), {1,1,1,1}, {1,1}, i, false, 1 )
		combatlog.pagemenu[i]["backdrop"]	= CMX.UI:Backdrop(	"CMX_Report_Combatlog_PageMenu"..i.."_BG",	combatlog.pagemenu[i],		"inherit", 			{CENTER,CENTER,0,0},			{0,0,0,0.8}, {1,1,1,0.4}, {1,1,1*scale} ,nil, false, 1 )
		combatlog.pagemenu[i]["backdrop"]:SetDrawLayer(DL_OVERLAY)
		combatlog.pagemenu[i]:SetMouseEnabled( true )
		combatlog.pagemenu[i]:SetHandler( "OnMouseUp", function() CMX.UI.UpdateCL(CMX.UI.CLCurrentPage-1+i) end)
		combatlog.pagemenu[i].data = {tooltipText = zo_strformat(GetString(SI_COMBAT_METRICS_PAGE), i)}
		combatlog.pagemenu[i]:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		combatlog.pagemenu[i]:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	end
		
	combatlog.pagemenu.r	= CMX.UI:Control(   	"CMX_Report_Combatlog_PageMenur", 			combatlog.pagemenu, 		{22,22}, 			{LEFT,RIGHT,2,0,combatlog.pagemenu[5]}, 				false, scale )
	combatlog.pagemenu.r.icon 	= CMX.UI:Texture(   	"CMX_Report_Combatlog_PageMenur_Icon",	combatlog.pagemenu.r,		"inherit",  		{CENTER,CENTER,0,0},  			'CombatMetrics/icons/rightarrowover.dds', false, 1 )	
	combatlog.pagemenu.r.backdrop	= CMX.UI:Backdrop(	"CMX_Report_Combatlog_PageMenur_BG",	combatlog.pagemenu.r,		"inherit", 			{CENTER,CENTER,0,0},			{0,0,0,0.8}, {1,1,1,0.4}, {1,1,1*scale} ,nil, false, 1 )
	combatlog.pagemenu.r.backdrop:SetDrawLayer(DL_OVERLAY)
	combatlog.pagemenu.r:SetMouseEnabled( true )
	combatlog.pagemenu.r:SetHandler( "OnMouseUp", function() CMX.UI.UpdateCL(CMX.UI.CLCurrentPage+5) end)
	combatlog.pagemenu.r.data = {tooltipText = GetString(SI_COMBAT_METRICS_GOTO_NEXT)}
	combatlog.pagemenu.r:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	combatlog.pagemenu.r:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	
	combatlog.titlemenu 		= CMX.UI:Control(   	"CMX_Report_Combatlog_TitleMenu", 			combatlog, 					{200,height+6}, 		{TOPRIGHT,TOPRIGHT,-4,2}, 		false, scale )
	
	combatlog.titlemenu.healin		= CMX.UI:Control(   	"CMX_Report_Combatlog_TitleMenu_healin", 			combatlog.titlemenu, 		{22,22}, 				{RIGHT,RIGHT,-2,0,combatlog.titlemenu}, 				false, scale )
	combatlog.titlemenu.healin.icon 	= CMX.UI:Texture(   	"CMX_Report_Combatlog_TitleMenu_healinIcon",		combatlog.titlemenu.healin,		{22,22},  				{CENTER,CENTER,0,0},  			'/esoui/art/hud/gamepad/gp_radialicon_invitegroup_down.dds', false, scale )
	combatlog.titlemenu.healin.backdrop	= CMX.UI:Backdrop(	"CMX_Report_Combatlog_TitleMenu_healin_BG",		combatlog.titlemenu.healin,		"inherit", 				{CENTER,CENTER,0,0},			{0,0,0,0.8}, {1,1,1,0.4}, {1,1,1*scale} ,nil, false, 1 )
	combatlog.titlemenu.healin.backdrop:SetDrawLayer(DL_OVERLAY)
	combatlog.titlemenu.healin:SetMouseEnabled( true )
	combatlog.titlemenu.healin:SetHandler( "OnMouseUp", function() CMX.UI.CLFilter("healin", CMX_Report_Combatlog_TitleMenu_healin_BG) end)
	combatlog.titlemenu.healin.data = {tooltipText = GetString(SI_COMBAT_METRICS_TOGGLE_HEAL)}
	combatlog.titlemenu.healin:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	combatlog.titlemenu.healin:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	combatlog.titlemenu.dmgin		= CMX.UI:Control(   	"CMX_Report_Combatlog_TitleMenu_dmgin", 			combatlog.titlemenu, 		{22,22}, 				{RIGHT,LEFT,-4,0,combatlog.titlemenu.healin}, 				false, scale )
	combatlog.titlemenu.dmgin.icon 	= CMX.UI:Texture(   	"CMX_Report_Combatlog_TitleMenu_dmginIcon",		combatlog.titlemenu.dmgin,		{18,18},  				{CENTER,CENTER,0,0},  			'/esoui/art/icons/heraldrycrests_weapon_shield_01.dds', false, scale )
	combatlog.titlemenu.dmgin.backdrop	= CMX.UI:Backdrop(	"CMX_Report_Combatlog_TitleMenu_dmgin_BG",		combatlog.titlemenu.dmgin,		"inherit", 				{CENTER,CENTER,0,0},			{0,0,0,0.8}, {1,1,1,0.4}, {1,1,1*scale} ,nil, false, 1 )
	combatlog.titlemenu.dmgin.backdrop:SetDrawLayer(DL_OVERLAY)
	combatlog.titlemenu.dmgin:SetMouseEnabled( true )
	combatlog.titlemenu.dmgin:SetHandler( "OnMouseUp", function() CMX.UI.CLFilter("dmgin", CMX_Report_Combatlog_TitleMenu_dmgin_BG) end)
	combatlog.titlemenu.dmgin.data = {tooltipText = GetString(SI_COMBAT_METRICS_TOGGLE_DAMAGE)}
	combatlog.titlemenu.dmgin:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	combatlog.titlemenu.dmgin:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	combatlog.titlemenu.healout		= CMX.UI:Control(   	"CMX_Report_Combatlog_TitleMenu_healout", 			combatlog.titlemenu, 		{22,22}, 				{RIGHT,LEFT,-4,0,combatlog.titlemenu.dmgin}, 				false, scale )
	combatlog.titlemenu.healout.icon 	= CMX.UI:Texture(   	"CMX_Report_Combatlog_TitleMenu_healoutIcon",		combatlog.titlemenu.healout,		{18,18},  				{CENTER,CENTER,0,0},  			'/esoui/art/buttons/gamepad/gp_plus_large.dds', false, scale )
	combatlog.titlemenu.healout.backdrop	= CMX.UI:Backdrop(	"CMX_Report_Combatlog_TitleMenu_healout_BG",		combatlog.titlemenu.healout,		"inherit", 				{CENTER,CENTER,0,0},			{0,0,0,0.8}, {1,1,1,0.4}, {1,1,1*scale} ,nil, false, 1 )
	combatlog.titlemenu.healout.backdrop:SetDrawLayer(DL_OVERLAY)
	combatlog.titlemenu.healout:SetMouseEnabled( true )
	combatlog.titlemenu.healout:SetHandler( "OnMouseUp", function() CMX.UI.CLFilter("healout", CMX_Report_Combatlog_TitleMenu_healout_BG) end)
	combatlog.titlemenu.healout.data = {tooltipText = GetString(SI_COMBAT_METRICS_TOGGLE_YOUR_HEAL)}
	combatlog.titlemenu.healout:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	combatlog.titlemenu.healout:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	combatlog.titlemenu.dmgout		= CMX.UI:Control(   	"CMX_Report_Combatlog_TitleMenu_dmgout", 			combatlog.titlemenu, 		{22,22}, 				{RIGHT,LEFT,-4,0,combatlog.titlemenu.healout}, 				false, scale )
	combatlog.titlemenu.dmgout.icon 	= CMX.UI:Texture(   	"CMX_Report_Combatlog_TitleMenu_dmgoutIcon",		combatlog.titlemenu.dmgout,		{18,18},  				{CENTER,CENTER,0,0},  			'/esoui/art/icons/heraldrycrests_weapon_axe_02.dds', false, scale )
	combatlog.titlemenu.dmgout.backdrop	= CMX.UI:Backdrop(	"CMX_Report_Combatlog_TitleMenu_dmgout_BG",		combatlog.titlemenu.dmgout,		"inherit", 				{CENTER,CENTER,0,0},			{0,0,0,0}, {1,1,1,1}, {1,1,1*scale} ,nil, false, 1 )
	combatlog.titlemenu.dmgout.backdrop:SetDrawLayer(DL_OVERLAY)
	combatlog.titlemenu.dmgout:SetMouseEnabled( true )
	combatlog.titlemenu.dmgout:SetHandler( "OnMouseUp", function() CMX.UI.CLFilter("dmgout", CMX_Report_Combatlog_TitleMenu_dmgout_BG) end)
	combatlog.titlemenu.dmgout.data = {tooltipText = GetString(SI_COMBAT_METRICS_TOGGLE_YOUR_DAMAGE)}
	combatlog.titlemenu.dmgout:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	combatlog.titlemenu.dmgout:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	combatlog.titlemenu.buff		= CMX.UI:Control(   	"CMX_Report_Combatlog_TitleMenu_buff", 			combatlog.titlemenu, 		{22,22}, 				{RIGHT,LEFT,-14,0,combatlog.titlemenu.dmgout}, 				false, scale )
	combatlog.titlemenu.buff.icon 	= CMX.UI:Texture(   	"CMX_Report_Combatlog_TitleMenu_buffIcon",		combatlog.titlemenu.buff,		{20,20},  				{CENTER,CENTER,0,0},  			'/esoui/art/icons/alchemy/crafting_alchemy_trait_unstoppable_match.dds', false, scale )
	combatlog.titlemenu.buff.backdrop	= CMX.UI:Backdrop(	"CMX_Report_Combatlog_TitleMenu_buff_BG",		combatlog.titlemenu.buff,		"inherit", 				{CENTER,CENTER,0,0},			{0,0,0,0.8}, {1,1,1,0.4}, {1,1,1*scale} ,nil, false, 1 )
	combatlog.titlemenu.buff.backdrop:SetDrawLayer(DL_OVERLAY)
	combatlog.titlemenu.buff:SetMouseEnabled( true )
	combatlog.titlemenu.buff:SetHandler( "OnMouseUp", function() CMX.UI.CLFilter("buff", CMX_Report_Combatlog_TitleMenu_buff_BG) end)
	combatlog.titlemenu.buff.data = {tooltipText = GetString(SI_COMBAT_METRICS_TOGGLE_BUFF_EVENTS)}
	combatlog.titlemenu.buff:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	combatlog.titlemenu.buff:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	combatlog.titlemenu.resource		= CMX.UI:Control(   	"CMX_Report_Combatlog_TitleMenu_resource", 			combatlog.titlemenu, 		{22,22}, 				{RIGHT,LEFT,-14,0,combatlog.titlemenu.buff}, 				false, scale )
	combatlog.titlemenu.resource.icon 	= CMX.UI:Texture(   	"CMX_Report_Combatlog_TitleMenu_resourceIcon",		combatlog.titlemenu.resource,		{20,20},  				{CENTER,CENTER,0,0},  			'/esoui/art/tutorial/staticon_magicka.dds', false, scale )
	combatlog.titlemenu.resource.backdrop	= CMX.UI:Backdrop(	"CMX_Report_Combatlog_TitleMenu_resource_BG",		combatlog.titlemenu.resource,		"inherit", 				{CENTER,CENTER,0,0},			{0,0,0,0.8}, {1,1,1,0.4}, {1,1,1*scale} ,nil, false, 1 )
	combatlog.titlemenu.resource.backdrop:SetDrawLayer(DL_OVERLAY)
	combatlog.titlemenu.resource:SetMouseEnabled( true )
	combatlog.titlemenu.resource:SetHandler( "OnMouseUp", function() CMX.UI.CLFilter("resource", CMX_Report_Combatlog_TitleMenu_resource_BG) end)
	combatlog.titlemenu.resource.data = {tooltipText = GetString(SI_COMBAT_METRICS_TOGGLE_RESOURCE_EVENTS)}
	combatlog.titlemenu.resource:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	combatlog.titlemenu.resource:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	combatlog.titlemenu.stats		= CMX.UI:Control(   	"CMX_Report_Combatlog_TitleMenu_stats", 			combatlog.titlemenu, 		{22,22}, 				{RIGHT,LEFT,-4,0,combatlog.titlemenu.resource}, 				false, scale )
	combatlog.titlemenu.stats.icon 	= CMX.UI:Texture(   	"CMX_Report_Combatlog_TitleMenu_statsIcon",		combatlog.titlemenu.stats,		{20,20},  				{CENTER,CENTER,0,0},  			'EsoUI/Art/Campaign/campaignBrowser_hiPop.dds', false, scale )
	combatlog.titlemenu.stats.backdrop	= CMX.UI:Backdrop(	"CMX_Report_Combatlog_TitleMenu_stats_BG",		combatlog.titlemenu.stats,		"inherit", 				{CENTER,CENTER,0,0},			{0,0,0,0.8}, {1,1,1,0.4}, {1,1,1*scale} ,nil, false, 1 )
	combatlog.titlemenu.stats.backdrop:SetDrawLayer(DL_OVERLAY)
	combatlog.titlemenu.stats:SetMouseEnabled( true )
	combatlog.titlemenu.stats:SetHandler( "OnMouseUp", function() CMX.UI.CLFilter("stats", CMX_Report_Combatlog_TitleMenu_stats_BG) end)
	combatlog.titlemenu.stats.data = {tooltipText = GetString(SI_COMBAT_METRICS_TOGGLE_STATS_CHANGE_EVENTS)}
	combatlog.titlemenu.stats:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	combatlog.titlemenu.stats:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	combatlog.titlemenu.stats.icon:SetTextureRotation(-1.570796, .5, .5)

	combatlog.logwindow			= CMX.UI:Control(   	"CMX_Report_Combatlog_LogWindow", 			combatlog, 					{652,372-(height+12)}, 	{TOPLEFT,BOTTOMLEFT,0,4,combatlog.title}, 		false, scale )	
	combatlog.logbuffer 		= CMX.UI:Textbuffer( 												combatlog.logwindow , 		"inherit" , 			{LEFT,LEFT,0,0}, 			CMX.UI:Font("standard",fontsize,false, scale) , 100 , false, false, 1 )
	--combatlog.logwindow.backdrop	= CMX.UI:Backdrop(	"CMX_Report_Combatlog_LogWindow_BG",		combatlog.logbuffer,		"inherit", 				{CENTER,CENTER,0,0},			{0,0,0,0}, {1,0,0,1}, {1,1,1} ,nil, false, 1 )
	
-- Info window
	local rightpanel 		 	= CMX.UI:Control(   "CMX_Report_ExtraPanel", 				RW, 				{268,372}, 		{TOPLEFT,TOPRIGHT,4,0,genstats}, 				false, scale )
	rightpanel.header		 	= CMX.UI:Control(   "CMX_Report_ExtraPanel_header", 		rightpanel, 				{268,2*height}, {TOPLEFT,TOPLEFT,0,0}, 				false, scale ) --Panel for buffs and Resources
	rightpanel.header.backdrop	= CMX.UI:Backdrop(	"CMX_Report_ExtraPanel_header_Box1",		rightpanel.header,	{67,2*height},	{LEFT,LEFT,0,0,rightpanel.header},				{0,0,0,0}, {1,1,1,0.5}, {1,1,2} ,nil, false, scale )
	rightpanel.header.backdrop:SetMouseEnabled( true )
	rightpanel.header.backdrop:SetHandler( "OnMouseUp", function() CMX.UI.SelectExtraPanel("buffs", rightpanel.header.backdrop) end)
	rightpanel.header.label  	= CMX.UI:Label( 	"CMX_Report_ExtraPanel_header_Box1Label", 	rightpanel.header.backdrop, 	{67,2*height}, 	{CENTER,CENTER,0,0,rightpanel.header.backdrop}, CMX.UI:Font("esobold",fontsize-1,true, scale), {1,1,1,1}, {1,1}, GetString(SI_COMBAT_METRICS_DEBUFF), false, scale )
	rightpanel.header.backdrop2	= CMX.UI:Backdrop(	"CMX_Report_ExtraPanel_header_Box2",	rightpanel.header,	{67,2*height},	{LEFT,RIGHT,0,0,rightpanel.header.backdrop},	{0,0,0,0}, {1,1,1,0.2}, {1,1,2} ,nil, false, scale )
	rightpanel.header.label2  	= CMX.UI:Label( 	"CMX_Report_ExtraPanel_header_Box2Label", 	rightpanel.header.backdrop2, 	{67,2*height}, 	{CENTER,CENTER,0,0,rightpanel.header.backdrop2}, CMX.UI:Font("esobold",fontsize-1,true, scale), {1,1,1,0.2}, {1,1}, GetString(SI_COMBAT_METRICS_DEBUFF_OUT), false, scale )
	rightpanel.header.backdrop2:SetMouseEnabled( true )
	rightpanel.header.backdrop2:SetHandler( "OnMouseUp", function() CMX.UI.SelectExtraPanel("buffsout", rightpanel.header.backdrop2) end)
	rightpanel.header.backdrop3	= CMX.UI:Backdrop(	"CMX_Report_ExtraPanel_header_Box3",	rightpanel.header,	{67,2*height},	{LEFT,RIGHT,0,0,rightpanel.header.backdrop2},	{0,0,0,0}, {1,1,1,0.2}, {1,1,2} ,nil, false, scale )
	rightpanel.header.label3  	= CMX.UI:Label( 	"CMX_Report_ExtraPanel_header_Box3Label", 	rightpanel.header.backdrop3, 	{67,2*height}, 	{CENTER,CENTER,0,0,rightpanel.header.backdrop3}, CMX.UI:Font("esobold",fontsize-1,true, scale), {1,1,1,0.2}, {1,1}, GetString(SI_COMBAT_METRICS_MAGICKA_PM), false, scale )	
	rightpanel.header.backdrop3:SetMouseEnabled( true )
	rightpanel.header.backdrop3:SetHandler( "OnMouseUp", function() CMX.UI.SelectExtraPanel("magicka", rightpanel.header.backdrop3) end)
	rightpanel.header.backdrop4	= CMX.UI:Backdrop(	"CMX_Report_ExtraPanel_header_Box4",	rightpanel.header,	{67,2*height},	{LEFT,RIGHT,0,0,rightpanel.header.backdrop3},	{0,0,0,0}, {1,1,1,0.2}, {1,1,2} ,nil, false, scale )
	rightpanel.header.label4  	= CMX.UI:Label( 	"CMX_Report_ExtraPanel_header_Box4Label", 	rightpanel.header.backdrop4, 	{67,2*height}, 	{CENTER,CENTER,0,0,rightpanel.header.backdrop4}, CMX.UI:Font("esobold",fontsize-1,true, scale), {1,1,1,0.2}, {1,1}, GetString(SI_COMBAT_METRICS_STAMINA_PM), false, scale )	
	rightpanel.header.backdrop4:SetMouseEnabled( true )
	rightpanel.header.backdrop4:SetHandler( "OnMouseUp", function() CMX.UI.SelectExtraPanel("stamina", rightpanel.header.backdrop4) end)
	
	
	local buffs 			= CMX.UI:Control(   	"CMX_Report_Buffs", 				RW, 			{268,372-(2*height)}, 		{TOPLEFT,BOTTOMLEFT,0,0,rightpanel.header}, 		false, scale )
	buffs.backdrop			= CMX.UI:Backdrop(		"CMX_Report_Buffs_BG",				buffs,			"inherit",		{CENTER,CENTER,0,0},					{0,.1,0,0.1}, {1,1,1,0.5}, {1,1,2*scale} ,nil, false, 1 )
	buffs.header 			= CMX.UI:Control(   	"CMX_Report_Buffs_header", 			buffs, 			{260,height+4}, {TOPLEFT,TOPLEFT,4,2}, 					false, scale )
	buffs.header.backdrop	= CMX.UI:Backdrop(		"CMX_Report_Buffs_header_BG2",		buffs.header,	{260,1},		{TOP,BOTTOM,0,0},						{0,0,0,0}, {1,1,1,1}, {1,1,1} ,nil, false, scale )
	buffs.header.icon  		= CMX.UI:Control( 		"CMX_Report_Buffs_header_Icon", 	buffs.header, 	{height-2,height},{LEFT,LEFT,0,-1}, 							false, scale )
	buffs.header.label 		= CMX.UI:Label( 		"CMX_Report_Buffs_header_Label", 	buffs.header, 	{168-(height-2),height}, 	{LEFT,RIGHT,2,0,buffs.header.icon}, CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {0,1}, GetString(SI_COMBAT_METRICS_BUFF), false, scale )
	buffs.header.label2 	= CMX.UI:Label( 		"CMX_Report_Buffs_header_Label2",	buffs.header, 	{30,height}, 	{LEFT,RIGHT,2,0,buffs.header.label}, 			CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {1,1}, GetString(SI_COMBAT_METRICS_SHARP), false, scale )
	buffs.header.label3 	= CMX.UI:Label( 		"CMX_Report_Buffs_header_Label3",	buffs.header, 	{45,height}, 	{LEFT,RIGHT,2,0,buffs.header.label2},			CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_UPTIME), false, scale )
	buffs.panel = CMX_Report_Buffs_Panel or wm:CreateControlFromVirtual("CMX_Report_Buffs_Panel", 	buffs, "ZO_ScrollContainer")
	buffs.panel:ClearAnchors()
	buffs.panel:SetAnchor(TOPLEFT,buffs.header,BOTTOMLEFT,0,1)
	buffs.panel:SetAnchor(BOTTOMRIGHT,buffs,BOTTOMRIGHT,-3,-3)
	buffs.scroll = GetControl(buffs.panel, "ScrollChild")
	buffs.scroll:SetResizeToFitPadding(0, 20)
	
	local resourcestats	  			= CMX.UI:Control(   		"CMX_Report_Resources", 	rightpanel, 							{268,372-(2*height)}, 		{TOPLEFT,BOTTOMLEFT,0,0,rightpanel.header}, 		true, scale )
	resourcestats.backdrop			= CMX.UI:Backdrop(			"CMX_Report_Resources_BG",	resourcestats,						"inherit",		{CENTER,CENTER,0,0},					{0,0,0,0.1}, {1,1,1,0.5}, {1,1,2*scale} ,nil, false, 1 )
	-- /script CMX.UI.SelectRightPanel()
	
	resourcestats.header 			= CMX.UI:Control(   	"CMX_Report_Resources_header", 			resourcestats, 			{260,height+4}, {TOPLEFT,TOPLEFT,4,2}, 							false, scale )
	resourcestats.header.backdrop	= CMX.UI:Backdrop(		"CMX_Report_Resources_header_BG2",		resourcestats.header,	{260,1},		{TOP,BOTTOM,0,0},								{0,0,0,0}, {1,1,1,1}, {1,1,1} ,nil, false, scale )
	resourcestats.header.label 		= CMX.UI:Label( 		"CMX_Report_Resources_header_Label", 	resourcestats.header, 	{160,height}, 	{LEFT,LEFT,0,-1}, 								CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {0,1}, GetString(SI_COMBAT_METRICS_SOURCE), false, scale )
	resourcestats.header.label2 	= CMX.UI:Label( 		"CMX_Report_Resources_header_Label2",	resourcestats.header, 	{30,height}, 	{LEFT,RIGHT,2,0,resourcestats.header.label}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_SHARP), false, scale )
	resourcestats.header.label3 	= CMX.UI:Label( 		"CMX_Report_Resources_header_Label3",	resourcestats.header, 	{55,height}, 	{LEFT,RIGHT,2,0,resourcestats.header.label2},	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_PM_SEC), false, scale )
	

	resourcestats.panel = CMX_Report_Resources_Panel or wm:CreateControlFromVirtual("CMX_Report_Resources_Panel", 	resourcestats, "ZO_ScrollContainer")
	resourcestats.panel:ClearAnchors()
	resourcestats.panel:SetAnchor(TOPLEFT,resourcestats.header,BOTTOMLEFT,0,1)
	resourcestats.panel:SetAnchor(BOTTOMRIGHT,resourcestats,BOTTOMRIGHT,-3,-3)
	resourcestats.scroll = GetControl(resourcestats.panel, "ScrollChild")
	resourcestats.scroll:SetResizeToFitPadding(0, 20)	
	
	

-- Unit List totalheight-600
	local units 			= CMX.UI:Control(   	"CMX_Report_Units", 				RW, 			{300,316}, 				{TOPLEFT,BOTTOMLEFT,0,4,genstats}, 	false, scale )
	units.backdrop			= CMX.UI:Backdrop(		"CMX_Report_Units_BG",				units,			"inherit",				{CENTER,CENTER,0,0},					{.1,0,0,0.1}, {1,1,1,0.5}, {1,1,2*scale}, nil, false, 1 )
	units.header 			= CMX.UI:Control(   	"CMX_Report_Units_header", 			units, 			{292,height+4}, 		{TOPLEFT,TOPLEFT,4,2}, 					false, scale )
	units.header.backdrop	= CMX.UI:Backdrop(		"CMX_Report_Units_header_BG2",		units.header,	{292,1},				{TOP,BOTTOM,0,0},						{0,0,0,0}, {1,1,1,1}, {1,1,1} ,nil, false, scale )
	units.header.label 		= CMX.UI:Label( 		"CMX_Report_Units_header_Label", 	units.header, 	{162,height}, 			{LEFT,LEFT,0,-1}, 						CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {0,1}, GetString(SI_COMBAT_METRICS_TARGET), false, scale )
	units.header.label2 	= CMX.UI:Label( 		"CMX_Report_Units_header_Label2",	units.header, 	{45,height}, 			{LEFT,RIGHT,2,0,units.header.label}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {1,1}, GetString(SI_COMBAT_METRICS_PERCENT), false, scale )
	units.header.label3 	= CMX.UI:Label( 		"CMX_Report_Units_header_Label3",	units.header, 	{73,height}, 			{LEFT,RIGHT,2,0,units.header.label2}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_DPS), false, scale )
	units.panel = CMX_Report_Units_Panel or wm:CreateControlFromVirtual("CMX_Report_Units_Panel", units, "ZO_ScrollContainer")
	units.panel:SetHidden(true)
	units.panel:ClearAnchors()
	units.panel:SetAnchor(TOPLEFT,units.header,BOTTOMLEFT,0,1)
	units.panel:SetAnchor(BOTTOMRIGHT,units,BOTTOMRIGHT,-3,-3)
	units.scroll = GetControl(units.panel, "ScrollChild")
	units.scroll:SetResizeToFitPadding(0, 20)
	
-- Ability List totalheight-600
	local abilities 			= CMX.UI:Control(   "CMX_Report_Abilities", 				RW, 				{628,316}, 			{TOPRIGHT,BOTTOMRIGHT,0,4,rightpanel}, 	false, scale )
	abilities.backdrop			= CMX.UI:Backdrop(	"CMX_Report_Abilities_BG",				abilities,			"inherit",			{CENTER,CENTER,0,0},						{.1,.1,0,0.1}, {1,1,1,0.5}, {1,1,2*scale} ,nil, false, 1 )
	abilities.header			= CMX.UI:Control(   "CMX_Report_Abilities_header", 			abilities, 			{618,height+4}, 	{TOPLEFT,TOPLEFT,4,2}, 						false, scale )
	abilities.header.backdrop	= CMX.UI:Backdrop(	"CMX_Report_Abilities_header_BG",		abilities.header,	{618,1}, 			{TOP,BOTTOM,0,0},							{0,0,0,0}, {1,1,1,1}, {1,1,1} ,nil, false, scale )
	abilities.header.icon  		= CMX.UI:Control( 	"CMX_Report_Abilities_header_Icon", 	abilities.header, 	{height-2,height+2},{LEFT,LEFT,0,-1}, 							false, scale )
	abilities.header.label 		= CMX.UI:Label( 	"CMX_Report_Abilities_header_Label", 	abilities.header, 	{200-(height-2),height+2}, 	{LEFT,RIGHT,2,0,abilities.header.icon}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {0,1}, GetString(SI_COMBAT_METRICS_AVILITY), false, scale )
	abilities.header.percent 	= CMX.UI:Label( 	"CMX_Report_Abilities_header_percent", 	abilities.header, 	{35,height+2}, 		{LEFT,RIGHT,2,0,abilities.header.label}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {1,1}, GetString(SI_COMBAT_METRICS_PERCENT), false, scale )
	abilities.header.vps 		= CMX.UI:Label( 	"CMX_Report_Abilities_header_vps", 		abilities.header, 	{50,height+2}, 		{LEFT,RIGHT,2,0,abilities.header.percent}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_DPS), false, scale )
	abilities.header.amt 		= CMX.UI:Label( 	"CMX_Report_Abilities_header_amt", 		abilities.header, 	{73,height+2}, 		{LEFT,RIGHT,2,0,abilities.header.vps }, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_DAMAGE), false, scale )
	abilities.header.crits 		= CMX.UI:Label( 	"CMX_Report_Abilities_header_crits", 	abilities.header, 	{45,height+2}, 		{LEFT,RIGHT,2,0,abilities.header.amt}, 		CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_CRITS), false, scale )
	abilities.header.hits 		= CMX.UI:Label( 	"CMX_Report_Abilities_header_hits", 	abilities.header, 	{45,height+2}, 		{LEFT,RIGHT,0,0,abilities.header.crits}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {0,1}, GetString(SI_COMBAT_METRICS_PER_HITS), false, scale )
	abilities.header.ratio 		= CMX.UI:Label( 	"CMX_Report_Abilities_header_ratio", 	abilities.header, 	{35,height+2}, 		{LEFT,RIGHT,2,0,abilities.header.hits}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_CRITS_PER), false, scale )
	abilities.header.avg 		= CMX.UI:Label( 	"CMX_Report_Abilities_header_avg", 		abilities.header, 	{50,height+2}, 		{LEFT,RIGHT,2,0,abilities.header.ratio}, 	CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_AVE), false, scale )
	abilities.header.max 		= CMX.UI:Label( 	"CMX_Report_Abilities_header_max", 		abilities.header, 	{50,height+2}, 		{LEFT,RIGHT,2,0,abilities.header.avg}, 		CMX.UI:Font("standard",fontsize+1,true, scale), {1,1,1,1}, {2,1}, GetString(SI_COMBAT_METRICS_MAX), false, scale )
	abilities.panel = CMX_Report_Abilities_Panel or wm:CreateControlFromVirtual("CMX_Report_Abilities_Panel", abilities, "ZO_ScrollContainer")
	abilities.panel:SetHidden(true)
	abilities.panel:ClearAnchors()
	abilities.panel:SetAnchor(TOPLEFT,abilities.header,BOTTOMLEFT,0,1)
	abilities.panel:SetAnchor(BOTTOMRIGHT,abilities,BOTTOMRIGHT,-3,-3)
	abilities.scroll = GetControl(abilities.panel, "ScrollChild")
	abilities.scroll:SetResizeToFitPadding(0, 20)
end

function CMX.UI.SelectExtraPanel(page,control)
	for i=1,4 do
		local ctrl = _G["CMX_Report_ExtraPanel_header_Box"..i]
		ctrl:SetEdgeColor(1,1,1,(ctrl == control and 0.5 or 0.2))
		ctrl:GetNamedChild("Label"):SetColor(1,1,1,(ctrl == control and 1 or 0.2))
	end	
	CMX.Resourceselection = page
	local isbuffpanel = page=="buffs" or page=="buffsout" 
	CMX_Report_Resources:SetHidden(isbuffpanel)
	CMX_Report_Buffs:SetHidden(not isbuffpanel)
	CMX.UI:UpdateReport()
end

function CMX.ToggleFightList(update)
	if update or CMX_Report_FightList:IsHidden() then
		local currentanchor = {TOPLEFT,TOPLEFT,0,1,CMX_Report_FightList_PanelScrollChild} 
		local n = 0
		if #CMX.lastfights>0 then
			for k,v in ipairs(CMX.lastfights) do
				local newitem = CMX.UI:CreateFightListItem(k, {v.fightname, v.dpstime, v.dps, v.hps, v.idps, v.ihps}, currentanchor, false, scale)
				currentanchor = {TOP,BOTTOM,0,1,newitem} 
				n = n+1
			end
		end	
		local m = CMX_Report_FightList_PanelScrollChild:GetNumChildren()
		if m > n then 
			for i=n+1,m do
				local contr = CMX_Report_FightList_PanelScrollChild:GetChild(i)
				contr:SetHidden(true)
			end
		end
		n=0
		if #CMX.set.saveddata>0 then
			currentanchor = {TOPLEFT,TOPLEFT,0,1,CMX_Report_FightListSaved_PanelScrollChild}  --
			for k,v in ipairs(CMX.set.saveddata) do
				local newitem = CMX.UI:CreateFightListItem(k, {v.fightname, v.dpstime, v.dps, v.hps, v.idps, v.ihps}, currentanchor, true, scale)
				currentanchor = {TOP,BOTTOM,0,1,newitem} 
				n=n+1
			end
		end
		local m = CMX_Report_FightListSaved_PanelScrollChild:GetNumChildren()
		if m > n then 
			for i=n+1,m do
				local contr = CMX_Report_FightListSaved_PanelScrollChild:GetChild(i)
				contr:SetHidden(true)
			end
		end
		CMX_Report_FightList:SetHidden(false)
	else 
		CMX_Report_FightList:SetHidden(true)
	end
end

function CMX.UI.SelectCategory(category, id)
	for i=1,4 do
		local color1,color2,color3,_ = CMX_Report_TitleMenu:GetNamedChild(i):GetNamedChild("Icon"):GetColor()
		CMX_Report_TitleMenu:GetNamedChild(i):GetNamedChild("Icon"):SetColor(color1,color2,color3,(i==id and 1 or .2))
	end
	CMX.UI:UpdateReport(category, CMX.UI.Currentfightid)
end

function CMX.UI:RefreshLRWindow()
	local LR = CMX_LiveReport
	scale = setLR.scale
	
	local anchors = (setLR.layout == "Horizontal" and {{TOPLEFT,TOPLEFT,0,0,LR},{LEFT,RIGHT,0,0},{LEFT,RIGHT,0,0},{LEFT,RIGHT,0,0},{LEFT,RIGHT,0,0}}) or
					(setLR.layout == "Vertical" and {{TOPLEFT,TOPLEFT,0,0,LR},{TOPLEFT,BOTTOMLEFT,0,0},{TOPLEFT,BOTTOMLEFT,0,0},{TOPLEFT,BOTTOMLEFT,0,0},{TOPLEFT,BOTTOMLEFT,0,0}}) or
					{{TOPLEFT,TOPLEFT,0,0,LR},{LEFT,RIGHT,0,0},{TOPRIGHT,BOTTOMLEFT,0,0},{LEFT,RIGHT,0,0},{LEFT,RIGHT,0,0}}
	local i = 0
	local last = LR
	CMX_LiveReport_DmgOut:SetHidden(not setLR.dps)
	CMX_LiveReport_HealOut:SetHidden(not setLR.hps)
	CMX_LiveReport_DmgIn:SetHidden(not setLR.idps)
	CMX_LiveReport_HealIn:SetHidden(not setLR.ihps)
	CMX_LiveReport_Time:SetHidden(not setLR.time)
	LR:SetDimensions(1,1)
	if setLR.dps then 
		i=i+1
		local anchor = anchors[i]
		CMX_LiveReport_DmgOut:ClearAnchors()
		CMX_LiveReport_DmgOut:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , anchor[3]*scale , anchor[4]*scale )
		last = CMX_LiveReport_DmgOut
	end
	if setLR.hps then 
		i=i+1
		local anchor = anchors[i]
		anchor[5] = last
		CMX_LiveReport_HealOut:ClearAnchors()
		CMX_LiveReport_HealOut:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , anchor[3]*scale , anchor[4]*scale )
		last = CMX_LiveReport_HealOut
	end
	if setLR.idps then
		i=i+1
		local anchor = anchors[i]
		anchor[5] = last
		CMX_LiveReport_DmgIn:ClearAnchors()
		CMX_LiveReport_DmgIn:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , anchor[3]*scale , anchor[4]*scale )
		last = CMX_LiveReport_DmgIn
	end
	if setLR.ihps then
		i=i+1
		local anchor = anchors[i]
		anchor[5] = last
		CMX_LiveReport_HealIn:ClearAnchors()
		CMX_LiveReport_HealIn:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , anchor[3]*scale , anchor[4]*scale )
		last = CMX_LiveReport_HealIn
	end
	if setLR.time then
		i=i+1
		local anchor = anchors[i]
		if i==3 and setLR.layout == "Compact" then 
			anchor = anchors[5] -- don't start new line if only 2 fields have been created	
		end
		anchor[5] = last
		CMX_LiveReport_Time:ClearAnchors()
		CMX_LiveReport_Time:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , anchor[3]*scale , anchor[4]*scale )
	end
	zo_callLater(function() CMX_LiveReport_BG:SetDimensions(LR:GetWidth(),LR:GetHeight()) end, 1)
end


function CMX.UI:ToggleLog(icon)
	
	CMX_Report_Stats:SetHidden( CMX_Report_Combatlog:IsHidden() )
	CMX_Report_Combatlog:SetHidden( not CMX_Report_Combatlog:IsHidden() )
	icon:SetColor(1,1,1,(CMX_Report_Combatlog:IsHidden() and .2 or 1))
	CMX.UI.UpdateCL()
end

function CMX.UI.CLFilter(button, control)
	CMX.set.UI.CLSelection[button] = not CMX.set.UI.CLSelection[button]
	control:SetCenterColor( 0 , 0 , 0 , CMX.set.UI.CLSelection[button] and 0 or 0.8 )
	control:SetEdgeColor( 1 , 1 , 1 , CMX.set.UI.CLSelection[button] and 1 or .4 )	
	CMX.UI.UpdateCL()
end

function CMX.UI.CLPage(page,maxpage)
	local i1=math.max(page-2,1)
	local i2=math.min(i1+4)
	CMX.UI.CLCurrentPage=i1
	CMX_Report_Combatlog_PageMenu:GetNamedChild("l"):SetHidden(i1==1)
	CMX_Report_Combatlog_PageMenu:GetNamedChild("r"):SetHidden(i2>=maxpage)
	for i=i1,i2 do
		j=i-i1+1
		CMX_Report_Combatlog_PageMenu:GetNamedChild(j):SetHidden(i>maxpage)
		CMX_Report_Combatlog_PageMenu:GetNamedChild(j.."_Label"):SetText(i)
		local bg = CMX_Report_Combatlog_PageMenu:GetNamedChild(j.."_BG")
		bg:SetCenterColor( 0 , 0 , 0 , page==i and 0 or 0.8 )
		bg:SetEdgeColor( 1 , 1 , 1 , page==i and 1 or .4 )
	end
end

function CMX.UI:CheckSaveLimit(new)
	local totallines = new or 0
	for account, accountdata in pairs(CombatMetrics_Save.Default) do
		for character, chardata in pairs(accountdata) do 
			for k,v in ipairs(chardata.saveddata) do
				totallines = totallines + #v.log+250 -- get the total length of logs to etimate the used space. Tests resulted in an equivalent of 250 lines per new fight table
			end
		end
	end
	if CMX.set.debuginfo.misc then d("Saving. Space:".. math.floor(totallines/140000*100).."%") end
	return totallines < 130000	
end