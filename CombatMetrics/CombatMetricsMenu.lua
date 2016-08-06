if CMX == nil then CMX = {} end
local CMX = CMX
local _
--
-- Register with LibMenu and ESO

function CMX.MakeMenu()
    -- load the settings->addons menu library
	local menu = LibStub("LibAddonMenu-2.0")
	local set = CMX.set
	local def = CMX.defaults 

    -- the panel for the addons menu
	local panel = {
		type = "panel",
		name = "Combat Metrics",
		displayName = "Combat Metrics",
		author = "Solinur",
        version = "" .. CMX.version,
		registerForRefresh = true,
	}

    --this adds entries in the addon menu
	local options = {
		{
			type = "header",
			name = GetString(SI_COMBAT_METRICS_MENU_PROFILES)
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_AC_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_AC_TOOLTIP),
			default = def.accountwide,
			getFunc = function() return CombatMetrics_Save.Default[GetDisplayName()]['$AccountWide']["accountwide"] end,
			setFunc = function(value) CombatMetrics_Save.Default[GetDisplayName()]['$AccountWide']["accountwide"] = value ReloadUI() end,
			warning = GetString(SI_COMBAT_METRICS_MENU_UI_WARNING),
		},		
		{
			type = "custom",
		},
		{
			type = "header",
			name = GetString(SI_COMBAT_METRICS_MENU_GS_NAME)
		},
		{
			type = "slider",
			name = GetString(SI_COMBAT_METRICS_MENU_CT_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_CT_TOOLTIP),
			min = 0,
			max = 20,
			step = 1,
			default = def.timeout,
			getFunc = function() return set.timeout/1000 end,
			setFunc = function(value) set.timeout = value*1000	end,
		},
		{
			type = "slider",
			name = GetString(SI_COMBAT_METRICS_MENU_FH_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_FH_TOOLTIP),
			min = 1,
			max = 25,
			step = 1,
			default = def.fighthistory,
			getFunc = function() return set.fighthistory end,
			setFunc = function(value) set.fighthistory = value end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_UH_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_UH_TOOLTIP),
			default = def.timeheals,
			getFunc = function() return set.timeheals end,
			setFunc = function(value) set.timeheals = value	end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_MG_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_MG_TOOLTIP),
			default = def.recordgrp,
			getFunc = function() return set.recordgrp end,
			setFunc = function(value) set.recordgrp = value	CMX.UI:ControlLR() end,
		},
		{
			type = "checkbox",
			name = GetString(SI_COMBAT_METRICS_MENU_AS_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_AS_TOOLTIP),
			default = def.autoscreenshot,
			getFunc = function() return set.autoscreenshot end,
			setFunc = function(value) set.autoscreenshot = value end,
		},		
		{
			type = "slider",
			name = GetString(SI_COMBAT_METRICS_MENU_ML_NAME),
			tooltip = GetString(SI_COMBAT_METRICS_MENU_ML_TOOLTIP),
			min = 1,
			max = 120,
			step = 1,
			disabled = function() return (not set.autoscreenshot) end,
			default = def.autoscreenshotmintime,
			getFunc = function() return set.autoscreenshotmintime end,
			setFunc = function(value) set.autoscreenshotmintime = value end,
		},
		{
			type = "slider",
			name = "Scale of Fight Report Window",
			tooltip = "Adjusts the size of all elements of the Fightreport Window",
			min = 30,
			max = (math.ceil(GuiRoot:GetHeight()/75)*10) or 200,
			step = 10,
			default = def.UI.ReportScale,
			getFunc = function() return set.UI.ReportScale*100  end,
			setFunc = function(value) 
					set.UI.ReportScale = value/100 
					CMX.UI:ControlRW() 	
				end,
		},
		{
			type = "custom",
		},
		{
			type = "header",
			name = "Live Report Window",
		},
		{
			type = "checkbox",
			name = "Enable",
			tooltip = "Enable Live Report Window which shows DPS & HPS during combat",
			default = def.EnableLiveMonitor,
			getFunc = function() return set.EnableLiveMonitor end,
			setFunc = function(value) CMX.UI.ToggleLR(value) set.EnableLiveMonitor = value end,
		},
		{
			type = "dropdown",
			name = "Layout",
			tooltip = "Select the Layout of the Live Report Window",
			default = def.UI.CMX_LiveReportSettings.layout,
			choices = {"Compact", "Horizontal", "Vertical"},
			getFunc = function() return set.UI.CMX_LiveReportSettings.layout end,
			setFunc = function(value) set.UI.CMX_LiveReportSettings.layout = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not set.EnableLiveMonitor end,
		},
		{
			type = "slider",
			name = "Scale",
			tooltip = "Scale of the Live report window.",
			min = 30,
			max = 300,
			step = 10,
			default = def.UI.CMX_LiveReportSettings.scale,
			getFunc = function() return set.UI.CMX_LiveReportSettings.scale*100  end,
			setFunc = function(value) 
					set.UI.CMX_LiveReportSettings.scale = value/100 
					CMX.UI:ControlLR() 
				end,
			disabled = function() return not set.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = "Show Background",
			tooltip = "Show the Background og the Live Report Window",
			default = def.UI.CMX_LiveReportSettings.bg,
			getFunc = function() return set.UI.CMX_LiveReportSettings.bg end,
			setFunc = function(value) set.UI.CMX_LiveReportSettings.bg = value CMX_LiveReport_BG:SetHidden(not value) end,
			disabled = function() return not set.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = "Show DPS",
			width = "half",
			tooltip = "Show DPS you deal in Live Report Window",
			default = def.UI.CMX_LiveReportSettings.dps,
			getFunc = function() return set.UI.CMX_LiveReportSettings.dps end,
			setFunc = function(value) set.UI.CMX_LiveReportSettings.dps = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not set.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = "Show HPS",
			width = "half",
			tooltip = "Show HPS you cast in Live Report Window",
			default = def.UI.CMX_LiveReportSettings.hps,
			getFunc = function() return set.UI.CMX_LiveReportSettings.hps end,
			setFunc = function(value) set.UI.CMX_LiveReportSettings.hps = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not set.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = "Show Incoming DPS",
			width = "half",
			tooltip = "Show DPS you receive in Live Report Window",
			default = def.UI.CMX_LiveReportSettings.idps,
			getFunc = function() return set.UI.CMX_LiveReportSettings.idps end,
			setFunc = function(value) set.UI.CMX_LiveReportSettings.idps = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not set.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = "Show Incoming HPS",
			width = "half",
			tooltip = "Show HPS you receive in Live Report Window",
			default = def.UI.CMX_LiveReportSettings.ihps,
			getFunc = function() return set.UI.CMX_LiveReportSettings.ihps end,
			setFunc = function(value) set.UI.CMX_LiveReportSettings.ihps = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not set.EnableLiveMonitor end,
		},
		{
			type = "checkbox",
			name = "Show Time",
			width = "half",
			tooltip = "Show Time you have been dealing damage in Live Report Window",
			default = def.UI.CMX_LiveReportSettings.time,
			getFunc = function() return set.UI.CMX_LiveReportSettings.time end,
			setFunc = function(value) set.UI.CMX_LiveReportSettings.time = value CMX.UI:RefreshLRWindow() end,
			disabled = function() return not set.EnableLiveMonitor end,
		},
		{
			type = "custom",
			width = "half",
			
		},
		{
			type = "custom",
		},
		{
			type = "header",
			name = "Stream Combat Log to chat",
		},
		{
			type = "checkbox",
			name = "Enable",
			tooltip = "Streams Damage and Heal Events to chat window",
			default = def.EnableChatLog,
			getFunc = function() return set.EnableChatLog end,
			setFunc = function(value) if value then CMX.getCombatLog() end set.EnableChatLog = value end,
		},
		{
			type = "checkbox",
			name = "Show damage",
			tooltip = "Show damage you deal in chat stream",
			default = def.EnableChatLogDmgOut,
			getFunc = function() return set.EnableChatLogDmgOut end,
			setFunc = function(value) set.EnableChatLogDmgOut = value end,
			disabled = function() return not set.EnableChatLog end,
		},
		{
			type = "checkbox",
			name = "Show heals",
			tooltip = "Show heals you cast in chat stream",
			default = def.EnableChatLogHealOut,
			getFunc = function() return set.EnableChatLogHealOut end,
			setFunc = function(value) set.EnableChatLogHealOut = value end,
			disabled = function() return not set.EnableChatLog end,
		},
		{
			type = "checkbox",
			name = "Show Incoming damage",
			tooltip = "Show damage you receive in chat stream",
			default = def.EnableChatLogDmgIn,
			getFunc = function() return set.EnableChatLogDmgIn end,
			setFunc = function(value) set.EnableChatLogDmgIn = value end,
			disabled = function() return not set.EnableChatLog end,
		},
		{
			type = "checkbox",
			name = "Show Incoming heal",
			tooltip = "Show heals you receive in chat stream",
			default = def.EnableChatLogHealIn,
			getFunc = function() return set.EnableChatLogHealIn end,
			setFunc = function(value) set.EnableChatLogHealIn = value end,
			disabled = function() return not set.EnableChatLog end,
		},
		{
			type = "custom",
		},
		{
			type = "header",
			name = "Debug options",
		},
		{
			type = "checkbox",
			name = "Show Fight Recap",
			tooltip = "Print Combat Results to the system chat window",
			default = def.debuginfo.fightsummary,
			getFunc = function() return set.debuginfo.fightsummary end,
			setFunc = function(value) set.debuginfo.fightsummary = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Show ability IDs",
			tooltip = "Show ability ids in the fight report window",
			default = def.debuginfo.ids,
			getFunc = function() return set.debuginfo.ids end,
			setFunc = function(value) set.debuginfo.ids = value	end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Show Fight Calculation Info",
			tooltip = "Print Info about the calculation timings to the system chat window",
			default = def.debuginfo.calculationtime,
			getFunc = function() return set.debuginfo.calculationtime end,
			setFunc = function(value) set.debuginfo.calculationtime = value	end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Show Buff Info",
			tooltip = "Print Buff events to the system chat window (Spammy)",
			default = def.debuginfo.buffs,
			getFunc = function() return set.debuginfo.buffs end,
			setFunc = function(value) set.debuginfo.buffs = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Show used Skill Info",
			tooltip = "Print used skill events to the system chat window",
			default = def.debuginfo.skills,
			getFunc = function() return set.debuginfo.skills end,
			setFunc = function(value) set.debuginfo.skills = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Show group Info",
			tooltip = "Print group joining and leave events to the system chat window",
			default = def.debuginfo.group,
			getFunc = function() return set.debuginfo.group end,
			setFunc = function(value) set.debuginfo.group = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Show miscellaneous debug Info",
			tooltip = "Print some other events to the system chat window",
			default = def.debuginfo.misc,
			getFunc = function() return set.debuginfo.misc end,
			setFunc = function(value) set.debuginfo.misc = value end,
			width = "half",
		},
	}

	menu:RegisterAddonPanel("CMX_Options", panel)
	menu:RegisterOptionControls("CMX_Options", options)
end