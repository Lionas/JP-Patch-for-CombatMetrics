local wm = GetWindowManager()
local dx = 1/GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE) -- get scale factor 1440=1080/0.75 (my ui scale when I made the UI) 
local fontsize = 14

local CMX = CMX
if CMX == nil then CMX = {} end
if CMX.UI == nil then CMX.UI = {} end
local _


CMX.defaults.UI = {
	["CMX_LiveReport"] = {BOTTOM,BOTTOM,0,-120},
	["CMX_Report"] = {CENTER,CENTER,0,-75},
	["ReportScale"] = GuiRoot:GetHeight()/1080,
	["CMX_LiveReportSettings"] = {["layout"]="Compact", ["scale"]=(GuiRoot:GetHeight()/1080), ["bg"]= true, ["dps"] = true, ["hps"] = true, ["idps"] = true, ["ihps"] = true, ["time"] = true},
	["LRMenuItem"] = "dmgout",
	["CLSelection"] = {
		["dmgout"] = true,
		["healout"] = false,
		["dmgin"] = false,
		["healin"] = false,
		["buff"] = false,
		["resource"] = false,
		["stats"] = false,
		},
	}
 
--Slash Commands 

function CMX.UI.Slash(extra)
	CMX.UI:ToggleReport()
end

SLASH_COMMANDS["/cmx"] = CMX.UI.Slash

	 --[[ 
	 Useful UI functions from FTC (made by Atropos)
	 * A handy chaining function for quickly setting up UI elements
	 * Allows us to reference methods to set properties without calling the specific object
	 ]]-- 

function CMX.UI.Chain( object )
	
	-- Setup the metatable
	local T = {}
	setmetatable( T , { __index = function( self , func )
		
		-- Know when to stop chaining
		if func == "__END" then	return object end
		
		-- Otherwise, add the method to the parent object
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })
	
	-- Return the metatable
	return T
end

--[[ 
 * Retrieve requested font, size, and style
 * --------------------------------
 * Called at control creation
 * --------------------------------
 ]]-- 
function CMX.UI:Font( font , fontsize, shadow, scale)
	
	local font = ( CMX.UI.Fonts[font] ~= nil ) and CMX.UI.Fonts[font] or font
	fontsize = (fontsize or 14)*(scale or 1)
	local shadow = shadow and '|soft-shadow-thick' or ''

	-- Return font
	return font..'|'..fontsize..shadow
end

--[[ 
 * Top Level Window
 ]]-- 

function CMX.UI:TopLevelWindow( name , parent , dims , anchor , hidden, scale )
	
	-- Validate arguments
	if ( name == nil or name == "" ) then return end
	parent = ( parent == nil ) and GuiRoot or parent
	if ( #dims ~= 2 ) then return end
	if ( #anchor ~= 4 and #anchor ~= 5 ) then return end
	hidden = ( hidden == nil ) and false or hidden
	scale = scale or 1
	
	-- Create the window
	local window = _G[name]
	if ( window == nil ) then window = WINDOW_MANAGER:CreateTopLevelWindow( name ) end

	-- Apply properties
	window = CMX.UI.Chain( window )
		:SetDimensions( zo_round(dims[1]*scale/dx)*dx , zo_round(dims[2]*scale/dx)*dx )
		:ClearAnchors()
		:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , zo_round(anchor[3]*scale/dx)*dx , zo_round(anchor[4]*scale/dx)*dx )
		:SetHidden( hidden )
		:SetClampedToScreen( true )
	.__END
	return window
end

--[[ 
 * Control
 ]]-- 

function CMX.UI:Control( name , parent , dims , anchor , hidden, scale )
	-- Validate arguments
	if ( name == nil or name == "" ) then return end
	parent = ( parent == nil ) and GuiRoot or parent
	if ( dims == "inherit" or #dims ~= 2 ) then dims = { parent:GetWidth() , parent:GetHeight() } end
	if ( #anchor ~= 4 and #anchor ~= 5 ) then return end
	hidden = ( hidden == nil ) and false or hidden
	scale = scale or 1
	
	-- Create the control
	local control = _G[name]
	if ( control == nil ) then control = WINDOW_MANAGER:CreateControl( name , parent , CT_CONTROL ) end
	
	-- Apply properties
	local control = CMX.UI.Chain( control )
		:SetDimensions( zo_round(dims[1]*scale/dx)*dx , zo_round(dims[2]*scale/dx)*dx )
		:ClearAnchors()
		:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , zo_round(anchor[3]*scale/dx)*dx , zo_round(anchor[4]*scale/dx)*dx )
		:SetHidden( hidden )
	.__END
	return control
end

 --[[ 
 * Backdrop
 ]]-- 
function CMX.UI:Backdrop( name , parent , dims , anchor , center , edge , edgetex , tex , hidden, scale )
	
	-- Validate arguments
	if ( name == nil or name == "" ) then return end
	parent = ( parent == nil ) and GuiRoot or parent
	if ( dims == "inherit" or #dims ~= 2 ) then dims = { parent:GetWidth() , parent:GetHeight() } end
	if ( #anchor ~= 4 and #anchor ~= 5 ) then return end
	center = ( center ~= nil and #center == 4 ) and center or { 0,0,0,0.4 }
	edge = ( edge ~= nil and #edge == 4 ) and edge or { 0,0,0,1 }
	edgetex = ( edgetex ~= nil and #edgetex == 3 ) and edgetex or {8,2,2}
	hidden = ( hidden == nil ) and false or hidden
	scale = scale or 1

	-- Create the backdrop
	local backdrop = _G[name]
	if ( backdrop == nil ) then backdrop = WINDOW_MANAGER:CreateControl( name , parent , CT_BACKDROP ) end
	
	-- Apply properties
	local backdrop = CMX.UI.Chain( backdrop )
		:SetDimensions( zo_round(dims[1]*scale/dx)*dx , zo_round(dims[2]*scale/dx)*dx )
		:ClearAnchors()
		:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , zo_round(anchor[3]*scale/dx)*dx , zo_round(anchor[4]*scale/dx)*dx )
		:SetCenterColor( center[1] , center[2] , center[3] , center[4] )
		:SetEdgeColor( edge[1] , edge[2] , edge[3] , edge[4] )
		:SetEdgeTexture("", edgetex[1] , edgetex[2] , zo_round(edgetex[3]*scale/dx)*dx )
		:SetPixelRoundingEnabled(true) 
		:SetHidden( hidden )
		--:SetCenterTexture( tex )
	.__END
	return backdrop
end 

--[[ 
 * Label
 ]]-- 
function CMX.UI:Label( name , parent , dims , anchor , font , color , align , text , hidden , scale )
	
	-- Validate arguments
	if ( name == nil or name == "" ) then return end
	parent = ( parent == nil ) and GuiRoot or parent
	if ( dims == "inherit" or #dims ~= 2 ) then dims = { parent:GetWidth() , parent:GetHeight() } end
	if ( #anchor ~= 4 and #anchor ~= 5 ) then return end
	font    = ( font == nil ) and "ZoFontGame" or font
	color   = ( color ~= nil and #color == 4 ) and color or { 1 , 1 , 1 , 1 }
	align   = ( align ~= nil and #align == 2 ) and align or { 1 , 1 }
	hidden  = ( hidden == nil ) and false or hidden
	scale = scale or 1
	
	-- Create the label
	local label = _G[name]
	if ( label == nil ) then label = WINDOW_MANAGER:CreateControl( name , parent , CT_LABEL ) end

	-- Apply properties
	local label = CMX.UI.Chain( label )
		:SetDimensions( zo_round(dims[1]*scale/dx)*dx , zo_round(dims[2]*scale/dx)*dx )
		:ClearAnchors()
		:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , zo_round(anchor[3]*scale/dx)*dx , zo_round(anchor[4]*scale/dx)*dx )
		:SetFont( font )
		:SetColor( color[1] , color[2] , color[3] , color[4] )
		:SetHorizontalAlignment( align[1] )
		:SetVerticalAlignment( align[2] )
		:SetText( text )
		:SetHidden( hidden )
	.__END
	return label
end

--[[ 
 * Texture
 ]]-- 
function CMX.UI:Texture( name , parent , dims , anchor , tex , hidden , scale )
	
	-- Validate arguments
	if ( name == nil or name == "" ) then return end
	parent = ( parent == nil ) and GuiRoot or parent
	if ( dims == "inherit" or #dims ~= 2 ) then dims = { parent:GetWidth() , parent:GetHeight() } end
	if ( #anchor ~= 4 and #anchor ~= 5 ) then return end
	if ( tex == nil ) then tex = '/esoui/art/icons/icon_missing.dds' end
	hidden = ( hidden == nil ) and false or hidden
	scale = scale or 1
	
	-- Create the texture
	local texture = _G[name]
	if ( texture == nil ) then texture = WINDOW_MANAGER:CreateControl( name , parent , CT_TEXTURE ) end

	-- Apply properties
	local texture = CMX.UI.Chain( texture )
		:SetDimensions( zo_round(dims[1]*scale/dx)*dx , zo_round(dims[2]*scale/dx)*dx )
		:ClearAnchors()
		:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , zo_round(anchor[3]*scale/dx)*dx , zo_round(anchor[4]*scale/dx)*dx )
		:SetTexture(tex)
		:SetHidden( hidden )
	.__END
	return texture
end

--[[ 
 * Button
 ]]-- 
function CMX.UI:TextButton( name , parent , dims , anchor , state , font , align , normal , pressed , mouseover , hidden , scale )
	
	-- Validate arguments
	if ( name == nil or name == "" ) then return end
	parent = ( parent == nil ) and GuiRoot or parent
	if ( dims == "inherit" or #dims ~= 2 ) then dims = { parent:GetWidth() , parent:GetHeight() } end
	if ( #anchor ~= 4 and #anchor ~= 5 ) then return end
	state = ( state ~= nil ) and state or BSTATE_NORMAL
	font = ( font == nil ) and "ZoFontGame" or font
	align = ( align ~= nil and #align == 2 ) and align or { 1 , 1 }
	normal = ( normal ~= nil and #normal == 4 ) and normal or { 1 , 1 , 1 , 1 }
	pressed = ( pressed ~= nil and #pressed == 4 ) and pressed or { 1 , 1 , 1 , 1 }
	mouseover = ( mouseover ~= nil and #mouseover == 4 ) and mouseover or { 1 , 1 , 1 , 1 }
	hidden = ( hidden == nil ) and false or hidden
	scale = scale or 1
	
	-- Create the button
	local button = _G[name]
	if ( button == nil ) then button = WINDOW_MANAGER:CreateControl( name , parent , CT_BUTTON ) end

	-- Apply properties
	local button = CMX.UI.Chain( button )
		:SetDimensions( zo_round(dims[1]*scale/dx)*dx , zo_round(dims[2]*scale/dx)*dx )
		:ClearAnchors()
		:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , zo_round(anchor[3]*scale/dx)*dx , zo_round(anchor[4]*scale/dx)*dx )
		:SetState( state )
		:SetFont( font )
		:SetNormalFontColor( normal[1] , normal[2] , normal[3] , normal[4] )
		:SetPressedFontColor( pressed[1] , pressed[2] , pressed[3] , pressed[4] )
		:SetMouseOverFontColor( mouseover[1] , mouseover[2] , mouseover[3] , mouseover[4] )
		:SetHorizontalAlignment( align[1] )
		:SetVerticalAlignment( align[2] )
		:SetHidden( hidden )
	.__END
	return button
end

function CMX.UI:IconButton( name , parent , dims , anchor , state , normal , pressed , mouseover , disabled , hidden , scale )
	
	-- Validate arguments
	if ( name == nil or name == "" ) then return end
	parent = ( parent == nil ) and GuiRoot or parent
	if ( dims == "inherit" or #dims ~= 2 ) then dims = { parent:GetWidth() , parent:GetHeight() } end
	if ( #anchor ~= 4 and #anchor ~= 5 ) then return end
	state = ( state ~= nil ) and state or BSTATE_NORMAL
	if normal == nil then return end 
	if pressed == nil then local pressed,offset = normal,{2,2} end
	if mouseover == nil then local mouseover,blendmode=normal,2 end
	hidden = ( hidden == nil ) and false or hidden
	scale = scale or 1
	
	-- Create the button
	local button = _G[name]
	if ( button == nil ) then button = WINDOW_MANAGER:CreateControl( name , parent , CT_BUTTON ) end

	-- Apply properties
	local button = CMX.UI.Chain( button )
		:SetDimensions( zo_round(dims[1]*scale/dx)*dx , zo_round(dims[2]*scale/dx)*dx )
		:ClearAnchors()
		:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , zo_round(anchor[3]*scale/dx)*dx , zo_round(anchor[4]*scale/dx)*dx )
		:SetState( state )
		:SetNormalTexture( normal )
		:SetPressedTexture( pressed )
		:SetMouseOverTexture( mouseover )
		:SetHidden( hidden )
	.__END
	
	if blendmode~=nil then button:SetMouseOverBlendMode( blendMode ) end
	if offset~=nil then button:SetPressedOffset(offset[1], offset[2]) end
	if disabled ~= nil then button:SetDisabledTexture( disabled ) end
	return button
end


-- Slider and Textbuffer Control from LibMsgWin (by Circonian)

--[[ 
 * Textbuffer (Log)
 ]]-- 
function CMX.UI:Textbuffer( parent , dims , anchor , font , maxlines , allowlinks, hidden , scale )
	
	-- Validate arguments
	parent = ( parent == nil ) and GuiRoot or parent
	if ( dims == "inherit" or #dims ~= 2 ) then dims = { parent:GetWidth() , parent:GetHeight() } end
	if ( #anchor ~= 4 and #anchor ~= 5 ) then return end
	font    = ( font == nil ) and "ZoFontGame" or font
	hidden  = ( hidden == nil ) and false or hidden
	scale = scale or 1
	
	-- Create the buffer
	local name = parent:GetName().."Buffer"
	local buffer = _G[name]
	if ( buffer == nil ) then buffer = WINDOW_MANAGER:CreateControl( name , parent , CT_TEXTBUFFER ) end

	-- Apply properties
	local buffer = CMX.UI.Chain( buffer )
		:ClearAnchors()
		:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , zo_round(anchor[3]*scale/dx)*dx , zo_round(anchor[4]*scale/dx)*dx )
		:SetDimensions( zo_round(dims[1]*scale/dx)*dx , zo_round(dims[2]*scale/dx)*dx )
		:SetFont( font )
		:SetMaxHistoryLines(maxlines)
		:SetMouseEnabled(true)
		:SetLinkEnabled(allowlinks)
		:SetHandler("OnLinkMouseUp", function(self, linkText, link, button)
				  --  ZO_PopupTooltip_SetLink(link)
				ZO_LinkHandler_OnLinkMouseUp(link, button, self) 
			end)
		:SetHandler("OnMouseWheel", function(self, delta, ctrl, alt, shift) 
				local offset = delta
				local slider = buffer:GetParent():GetNamedChild("Slider")
				if shift then
					offset = offset * math.floor((buffer:GetNumVisibleLines())/dx) -- correct for ui scale
				elseif ctrl then
					offset = offset * buffer:GetNumHistoryLines()
				end
				buffer:SetScrollPosition(math.min(buffer:GetScrollPosition() + offset, math.floor(buffer:GetNumHistoryLines()-(buffer:GetNumVisibleLines())/dx))) -- correct for ui scale
				slider:SetValue(slider:GetValue() - offset)
			end)
		:SetHidden( hidden )
	.__END

	
	buffer.slider = CMX.UI:Slider( parent:GetName().."Slider", buffer , parent , {8,dims[2]-35} , {RIGHT,RIGHT,1,-7} , true )
	
	return buffer
end

function CMX.UI:Slider( name , buffer , parent , dims , anchor , hidden , scale )
	-- Validate arguments
	if ( name == nil or name == "" ) then return end
	if ( buffer == nil) then return end	
	parent = ( parent == nil ) and GuiRoot or parent
	if ( dims == "inherit" or #dims ~= 2 ) then dims = { parent:GetWidth() , parent:GetHeight() } end
	if ( #anchor ~= 4 and #anchor ~= 5 ) then return end
	hidden = ( hidden == nil ) and false or hidden
	scale = scale or 1
	
	-- Create the slider
	local slider = _G[name]
	if ( slider == nil ) then slider = WINDOW_MANAGER:CreateControl( name , parent , CT_SLIDER ) end
	
	-- Apply properties
	local slider = CMX.UI.Chain( slider )
		:SetDimensions( zo_round(dims[1]*scale/dx)*dx , zo_round(dims[2]*scale/dx)*dx )
		:ClearAnchors()
		:SetAnchor( anchor[1] , #anchor == 5 and anchor[5] or parent , anchor[2] , zo_round(anchor[3]*scale/dx)*dx , zo_round(anchor[4]*scale/dx)*dx )
		:SetMinMax( 1 , 1 )
		:SetMouseEnabled( true )
		:SetValueStep( 1 )
		:SetValue( 1 )
		:SetHidden( true )
		:SetThumbTexture("EsoUI/Art/ChatWindow/chat_thumb.dds", "EsoUI/Art/ChatWindow/chat_thumb_disabled.dds", nil, dims[1], 20, nil, nil, 0.6875, nil)
		:SetBackgroundMiddleTexture("EsoUI/Art/ChatWindow/chat_scrollbar_track.dds", nil, -1)
		:SetHandler("OnValueChanged", function(self,value, eventReason)
				local numHistoryLines = buffer:GetNumHistoryLines()
				local sliderValue = math.max(slider:GetValue(), math.floor((buffer:GetNumVisibleLines()+1)/dx)) -- correct for ui scale
				
				if eventReason == EVENT_REASON_HARDWARE then
					buffer:SetScrollPosition(numHistoryLines-sliderValue)
				end
			end)
		
	.__END

	-- Create the buttons
	slider.scrollUp = _G[name.."ScrollUp"]
	if ( slider.scrollUp == nil ) then slider.scrollUp = WINDOW_MANAGER:CreateControlFromVirtual(name.."ScrollUp", slider, "ZO_ScrollUpButton") end
	slider.scrollUp = CMX.UI.Chain( slider.scrollUp )
		:SetDimensions( zo_round(12*scale/dx)*dx , zo_round(12*scale/dx)*dx )
		:SetAnchor(BOTTOM, slider, TOP, 0, 0)
		:SetNormalTexture("EsoUI/Art/ChatWindow/chat_scrollbar_upArrow_up.dds")
		:SetPressedTexture("EsoUI/Art/ChatWindow/chat_scrollbar_upArrow_down.dds")
		:SetMouseOverTexture("EsoUI/Art/ChatWindow/chat_scrollbar_upArrow_over.dds")
		:SetDisabledTexture("EsoUI/Art/ChatWindow/chat_scrollbar_upArrow_disabled.dds")
		:SetHandler("OnMouseDown", function(...)
				buffer:SetScrollPosition(math.min(buffer:GetScrollPosition()+1, math.floor(buffer:GetNumHistoryLines()-(buffer:GetNumVisibleLines())/dx))) -- correct for ui scale
				slider:SetValue(slider:GetValue()-1)
			end)
	.__END
	
	slider.scrollDown = _G[name.."ScrollDown"]
	if ( slider.scrollDown == nil ) then slider.scrollDown = WINDOW_MANAGER:CreateControlFromVirtual(name.."ScrollDown", slider, "ZO_ScrollDownButton") end
	slider.scrollDown = CMX.UI.Chain( slider.scrollDown )
		:SetDimensions( zo_round(12*scale/dx)*dx , zo_round(12*scale/dx)*dx )
		:SetAnchor(TOP, slider, BOTTOM, 0, 0)
		:SetNormalTexture("EsoUI/Art/ChatWindow/chat_scrollbar_downArrow_up.dds")
		:SetPressedTexture("EsoUI/Art/ChatWindow/chat_scrollbar_downArrow_down.dds")
		:SetMouseOverTexture("EsoUI/Art/ChatWindow/chat_scrollbar_downArrow_over.dds")
		:SetDisabledTexture("EsoUI/Art/ChatWindow/chat_scrollbar_downArrow_disabled.dds")
		:SetHandler("OnMouseDown", function(...)
				buffer:SetScrollPosition(buffer:GetScrollPosition()-1)
				slider:SetValue(slider:GetValue()+1)
			end)
	.__END
	
	slider.scrollEnd = _G[name.."ScrollEnd"]
	if ( slider.scrollEnd == nil ) then slider.scrollEnd = WINDOW_MANAGER:CreateControlFromVirtual(name.."ScrollEnd", slider, "ZO_ScrollEndButton") end
	slider.scrollEnd = CMX.UI.Chain( slider.scrollEnd )
		:SetDimensions( zo_round(12*scale/dx)*dx , zo_round(12*scale/dx)*dx )
		:SetAnchor(TOP, slider.scrollDown, BOTTOM, 0, 0)
		:SetHandler("OnMouseDown", function(...)
				buffer:SetScrollPosition(0)
				slider:SetValue(buffer:GetNumHistoryLines())
			end)
	.__END
	
	return slider
end

function CMX.UI.AdjustSlider(self)		
	local numHistoryLines = self:GetNamedChild("Buffer"):GetNumHistoryLines()
	local numVisHistoryLines = math.floor((self:GetNamedChild("Buffer"):GetNumVisibleLines()+1)/dx) --it seems numVisHistoryLines is getting screwed by UI Scale
	local bufferScrollPos = self:GetNamedChild("Buffer"):GetScrollPosition()
	local sliderMin, sliderMax = self:GetNamedChild("Slider"):GetMinMax()
	local sliderValue = self:GetNamedChild("Slider"):GetValue()
	
	self:GetNamedChild("Slider"):SetMinMax(numVisHistoryLines, numHistoryLines)
	
	-- If the sliders at the bottom, stay at the bottom to show new text
	if sliderValue == sliderMax then
		self:GetNamedChild("Slider"):SetValue(numHistoryLines)
	-- If the buffer is full start moving the slider up
	elseif numHistoryLines == self:GetNamedChild("Buffer"):GetMaxHistoryLines() then
		self:GetNamedChild("Slider"):SetValue(sliderValue-1)
	end -- Else the slider does not move
	
	-- If there are more history lines than visible lines show the slider
	if numHistoryLines > numVisHistoryLines then 
		self:GetNamedChild("Slider"):SetHidden(false)
		self:GetNamedChild("Slider"):SetThumbTextureHeight(math.max(20, math.floor(numVisHistoryLines/numHistoryLines*self:GetNamedChild("Slider"):GetHeight())))
	else
		-- else hide the slider
		self:GetNamedChild("Slider"):SetHidden(true)
	end
end

function CMX.UI.AddText(control, text, color)

	if not text or #color~=3 then return end
	
	local red 	= color[1] or 1
	local green = color[2] or 1
	local blue 	= color[3] or 1
	
	-- Add message first
	control:GetNamedChild("Buffer"):AddMessage(text, red, green, blue)
	-- Set new slider value & check visibility
	if control:GetNamedChild("Slider") then CMX.UI.AdjustSlider(control) end
end

function CMX.UI.ClearText(control)
	control:GetNamedChild("Buffer"):Clear()
end

function CMX.UI:SaveAnchor( control, scale )
	
	-- Get the new position
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()

	-- Save the anchors
	if ( isValidAnchor ) then CMX.set.UI[control:GetName()] = {point,relativePoint,offsetX/scale,offsetY/scale,relativeTo} end
end

function CMX.UI:AddSelection( selecttype, id, abilityid, shiftkey, controlkey, button )  -- IsShiftKeyDown() IsControlKeyDown() IsCommandKeyDown()
	if button ~= MOUSE_BUTTON_INDEX_LEFT and button ~= MOUSE_BUTTON_INDEX_RIGHT then return end
	local menuitem = selecttype == "buff" and "buff" or selecttype == "resource" and "resource" or CMX.set.UI.LRMenuItem
	if button == MOUSE_BUTTON_INDEX_RIGHT then
		CMX.UI.LastSelection[selecttype][menuitem] = nil
		CMX.UI.Selection[selecttype][menuitem] = nil
		CMX.UI:UpdateReport(CMX.set.UI.LRMenuItem, CMX.UI.Currentfightid)
		return
	end
	local sel = CMX.UI.Selection[selecttype][menuitem]
	local lastsel = CMX.UI.LastSelection[selecttype][menuitem]
	local rowcontrol = selecttype == "unit" and "CMX_Report_Units_" or selecttype == "ability" and "CMX_Report_Abilities_" or selecttype == "buff" and "CMX_Report_Buffs_" or selecttype == "resource" and "CMX_Report_Resources_"
	if sel == nil then 
		CMX.UI.Selection[selecttype][menuitem] = {[abilityid] = id}
		CMX.UI.LastSelection[selecttype][menuitem] = id
	elseif shiftkey and not controlkey and lastsel ~= nil then
		local istart = math.min(lastsel, id)
		local iend = math.max(lastsel, id)
		CMX.UI.Selection[selecttype][menuitem] = {}
		for i=istart,iend do 
			local irowcontrol = _G[rowcontrol..i]
			CMX.UI.Selection[selecttype][menuitem][irowcontrol.id] = i
		end
	elseif controlkey and not shiftkey then 
		if sel[abilityid] ~= nil then 
			CMX.UI.LastSelection[selecttype][menuitem] = nil
			CMX.UI.Selection[selecttype][menuitem][abilityid] = nil
		else 
			CMX.UI.LastSelection[selecttype][menuitem] = id
			CMX.UI.Selection[selecttype][menuitem][abilityid] = id
		end 
	elseif shiftkey and controlkey and lastsel ~= nil then 
		local istart = math.min(lastsel, id)
		local iend = math.max(lastsel, id)
		for i=istart,iend do
			local irowcontrol = _G[rowcontrol..i]
			CMX.UI.Selection[selecttype][menuitem][irowcontrol.id] = i
		end
	elseif not shiftkey and not controlkey then 
		if lastsel == id and sel[abilityid] ~= nil then 
			CMX.UI.LastSelection[selecttype][menuitem] = nil
			CMX.UI.Selection[selecttype][menuitem] = nil
		else 
			CMX.UI.LastSelection[selecttype][menuitem] = id
			CMX.UI.Selection[selecttype][menuitem] = {[abilityid] = id}
		end 
	end
	CMX.UI:UpdateReport(CMX.set.UI.LRMenuItem, CMX.UI.Currentfightid)
end 

--[[ 
 * Update the mini DPS meter
 * --------------------------------
 * Called by CMX.calcLive(index,newindex)
 * --------------------------------
 ]]--
function CMX.UI.LRUpdate(dps,hps,idps,ihps,dpstime,gdps,igdps,ghps)

	-- Bail out if there is no damage to report
	if ( CMX.currentfight.tdmg == 0 and CMX.currentfight.theal == 0 and CMX.currentfight.itdmg == 0) or CMX_LiveReport:IsHidden() then return end

	-- Retrieve data
	local livereport	= _G["CMX_LiveReport"]
	
	local showdps  = dps
	local showhps  = hps
	local showidps = idps
	local showtime = ZO_FormatTime( math.floor(dpstime) , SI_TIME_FORMAT_TIMESTAMP).."."..(math.floor((dpstime*10)+0.5)-math.floor(dpstime)*10)
	
	-- maybe add data from group
	if CMX.set.recordgrp == true and ((gdps+igdps+ghps)>0) then
		local dpsratio,hpsratio,idpsratio = 0,0,0
		if gdps>0  then dpsratio  = (math.floor(dps/gdps*1000)/10) end 
		if igdps>0 then idpsratio = (math.floor(idps/igdps*1000)/10) end 
		if ghps>0  then hpsratio  = (math.floor(hps/ghps*1000)/10) end

		showdps = zo_strformat(GetString(SI_COMBAT_METRICS_SHOW_XPS), dps, gdps, dpsratio)
		showhps = zo_strformat(GetString(SI_COMBAT_METRICS_SHOW_XPS), hps, ghps, hpsratio)
		showidps = zo_strformat(GetString(SI_COMBAT_METRICS_SHOW_XPS), idps, gidps, idpsratio)

	end
	
	-- Update the values
	livereport.damageout.label:SetText( showdps )
	livereport.healout.label:SetText( showhps )
	livereport.damagein.label:SetText( showidps )
	livereport.healin.label:SetText( ihps )
	livereport.time.label:SetText( showtime )
end

function CMX.UI:ToggleReport()
	if not SCENE_MANAGER.IsShowing("CMX_REPORT_SCENE") then 
		SCENE_MANAGER:Toggle("CMX_REPORT_SCENE")
		CMX.UI.Selection["ability"][CMX.set.UI.LRMenuItem] = nil
		CMX.UI.Selection["unit"][CMX.set.UI.LRMenuItem] = nil
		CMX.UI.Selection["buff"]["buff"] = nil		
		CMX.UI.Selection["resource"]["resource"] = nil		
		CMX.UI:UpdateReport(CMX.set.UI.LRMenuItem, #CMX.lastfights>0 and #CMX.lastfights or nil) 
		SetGameCameraUIMode(true)
		if #CMX.lastfights>0 and not CMX.inCombat and CMX.set.autoscreenshot and (CMX.set.autoscreenshotmintime ==0 or CMX.lastfights[#CMX.lastfights]["combattime"]>CMX.set.autoscreenshotmintime) then zo_callLater(TakeScreenshot, 400) end
	end
end

local function UpdateReport2()
	CMX.UI:UpdateReport()
end 

function CMX.UI.searchtable(t, field, value)
	for k,v in pairs(t) do
		if v[field]==value then return k end
	end
	return false
end

function CMX.UI:UpdateReport(menuitem, fightid)
	CMX.set.UI.LRMenuItem = menuitem or CMX.set.UI.LRMenuItem or "dmgout"
	menuitem = CMX.set.UI.LRMenuItem
	local itemlist = CMX.Statlist[menuitem]
	local menulabel = _G["CMX_Report_TitleMenuLabel"]
	if menulabel ~= nil then menulabel:SetText(itemlist.label1) end
	-- update fight selector buttons --
	if fightid == nil or fightid~=CMX.UI.Currentfightid then
		CMX.UI.Selection["ability"][CMX.set.UI.LRMenuItem] = nil
		CMX.UI.Selection["unit"][CMX.set.UI.LRMenuItem] = nil
		CMX.UI.Selection["buff"]["buff"] = nil	
		CMX.UI.Selection["resource"]["resource"] = nil	
	end
	fightid = fightid or CMX.UI.Currentfightid  --if no fightid was given, use the previous one
	if fightid==nil or fightid<0 or CMX.lastfights[fightid]==nil then
		if (not (#CMX.lastfights>0)) then return else fightid = #CMX.lastfights end
	end
	CMX.UI.Currentfightid = fightid
	local showdata = CMX.lastfights[fightid]
	CMX_Report_FightButtonBack:SetState(CMX.lastfights[CMX.UI.Currentfightid-1]~= nil and BSTATE_NORMAL or BSTATE_DISABLED, CMX.lastfights[CMX.UI.Currentfightid-1]== nil)
	CMX_Report_FightButtonFor:SetState(CMX.lastfights[CMX.UI.Currentfightid+1]~= nil and BSTATE_NORMAL or BSTATE_DISABLED, CMX.lastfights[CMX.UI.Currentfightid+1]== nil)
	CMX_Report_FightButtonEnd:SetState(CMX.lastfights[CMX.UI.Currentfightid+1]~= nil and BSTATE_NORMAL or BSTATE_DISABLED, CMX.lastfights[CMX.UI.Currentfightid+1]== nil)
	CMX_Report_FightButtonSave:SetState((CMX.lastfights[fightid]~=nil and not CMX.UI.searchtable(CMX.set.saveddata, "fightname", showdata.fightname)) and BSTATE_NORMAL or BSTATE_DISABLED, CMX.lastfights[fightid]==nil)
	CMX_Report_FightButtonDelete:SetState((CMX.lastfights[fightid]~=nil and #CMX.lastfights>0) and BSTATE_NORMAL or BSTATE_DISABLED, CMX.lastfights[fightid]==nil or #CMX.lastfights<=0)
	local fightlabel = _G["CMX_Report_FightSelectorLabel"]
	if fightlabel ~= nil then fightlabel:SetText(showdata.fightname) end
	if showdata.calculating==true then  -- if it is still calculating wait for it to finish

		if fightlabel ~= nil then fightlabel:SetText(GetString(SI_COMBAT_METRICS_CALC)) end

		zo_callLater(UpdateReport2, 500) 
		return
	end
	local totaldmg = showdata[itemlist[3][1]]
	-- Generate stats of selection
	local selectedabilities = CMX.UI.Selection["ability"][menuitem]
	local selectedunits = CMX.UI.Selection["unit"][menuitem]
	local selectedbuffs = CMX.UI.Selection["buff"]["buff"]
	local selectedresources = CMX.UI.Selection["resource"]["resource"]
	
	local scale = CMX.set.UI.CMX_LiveReportSettings.scale

	CMX_Report_Statlabel_H_2Label:SetText(GetString(SI_COMBAT_METRICS_GROUP))

	local selectiondata = nil
	if selectedunits ~= nil or selectedabilities ~= nil then 

		CMX_Report_Statlabel_H_2Label:SetText(GetString(SI_COMBAT_METRICS_SELECTION))

		selectiondata = {}
		local inc = (menuitem=="dmgin" or menuitem=="healin") and true or false
		for i = 2,12 do 
			if itemlist[i] ~= nil then  
			selectiondata[itemlist[i][1] ] =0
			end
		end 
		if selectedunits ~= nil then 
			selectiondata[menuitem] = {}
			selectiondata.utdmg = 0
			selectiondata["buffs"] = {}
			for k,v in pairs(selectedunits) do 
				selectiondata[menuitem] = CMX:AddTables(selectiondata[menuitem],{showdata.units[k][menuitem]})
				selectiondata.utdmg = showdata.units[k][itemlist[3][1]] + selectiondata.utdmg
				selectiondata["buffs"] = CMX:AddTables(selectiondata["buffs"],{showdata.units[k]["buffs"]})
				selectiondata["buffcount"] = (selectiondata["buffcount"] or 0) +1
				if selectedabilities ~= nil then
					for k2,v2 in pairs(selectedabilities) do
						for i = 2,12 do 
							local k3 = itemlist[i]
							if k3 ~= nil then
								local k4 = k3[1]
								local k5 = inc and string.sub(k4,2) or k4								
								local vadd = 0
								if showdata.units[k][menuitem][k2]~= nil then vadd = showdata.units[k][menuitem][k2][k5] end 
								selectiondata[k4] = selectiondata[k4] + (vadd or 0)
							end
						end  
					end
				else 
					for i = 2,12 do 
						local k3 = itemlist[i]
						if k3 ~= nil then selectiondata[k3[1] ] = selectiondata[k3[1] ] + (showdata.units[k][k3[1] ] or 0) end
					end
				end
			end
		else --if selectedabilities ~= nil then
			for k2,v2 in pairs(selectedabilities) do
				for i = 2,12 do 
					local k3 = itemlist[i]
					if k3 ~= nil then
						local k4 = k3[1]
						local k5 = inc and string.sub(k4,2) or k4
						local vadd = showdata[menuitem][k2][k5]
						selectiondata[k4] = selectiondata[k4] + (vadd or 0)
					end
				end
			end
		end 
	elseif selectedunits == nil then
		selectiondata = {["buffs"]={}}	
		for k,v in pairs(showdata["units"]) do
			if v[itemlist[3][1]] > 0 and (v.name ~= CMX.playername and (v.group~=true) and (menuitem=="dmgin" or menuitem=="dmgout")) or ((v.group==true) and (menuitem=="healin" or menuitem=="healout")) then 
				selectiondata["buffs"] = CMX:AddTables(selectiondata["buffs"],{v["buffs"]})
				selectiondata["buffcount"] = (selectiondata["buffcount"] or 0) +1
			end
		end
	end 
	-- update stats left --
	local ictrl,value,unit = 1,0,""
	local label1 = _G["CMX_Report_Statlabel_DmgLabel"]
	if label1 ~= nil then label1:SetText(itemlist.label1) end 
	local label2 = _G["CMX_Report_Statlabel_HitsLabel"]
	if label2 ~= nil then label2:SetText(itemlist.label2) end 
	local label3 = _G["CMX_Report_Statlabel_2_0Label"]
	if label3 ~= nil then label3:SetText(itemlist.label3) end 
	for i=1,12 do
		if i==1 then showdata.dpstime = zo_round(showdata.dpstime*100)/100 end
		local statlabel1 = _G["CMX_Report_Statlabel_"..i.."_0Label"]
		local stat1 = _G["CMX_Report_Stat_"..i.."_1Value"]
		local stat2 = _G["CMX_Report_Stat_"..i.."_2Value"]
		local stat3 = _G["CMX_Report_Stat_"..i.."_3Value"]
		if itemlist[i] ~= nil then
			if statlabel1~=nil then statlabel1:SetHidden(false) end 
			if (selectedunits ~= nil or selectedabilities ~= nil) and i>1 then 
				if stat1~=nil and itemlist[i][1] ~= nil then 
					local v = showdata[itemlist[i][1]]
					stat1:SetText( v )
					stat1:SetHidden(false)
					local v2 = selectiondata[itemlist[i][1]]
					stat2:SetText( v2 )
					stat2:SetHidden(false)
					local v3 = (tostring(zo_round(v2/v*1000)/10).." %")
					stat3:SetText( v3 )
					stat3:SetHidden(false)					
				else 
					stat1:SetHidden(true)
					stat2:SetHidden(true)
					stat3:SetHidden(true)
				end		
			else 
				if stat1~=nil and itemlist[i][1] ~= nil then 
					local v = showdata[itemlist[i][1]]
					stat1:SetText( v )
					stat1:SetHidden(false)
				else stat1:SetHidden(true)
				end			
				if stat2~=nil and itemlist[i][2] ~= nil then 
					local v = showdata[itemlist[i][2]]
					stat2:SetText( v )
					stat2:SetHidden(false)
				else stat2:SetHidden(true)
				end
				if stat3~=nil and itemlist[i][3] ~= nil then 
					local v = showdata[ itemlist[i][3][2] ]==0 and "0 %" or (tostring(zo_round(showdata[ itemlist[i][3][1] ]/showdata[ itemlist[i][3][2] ]*1000)/10).." %") -- % ratio 
					stat3:SetText( v)
					stat3:SetHidden(false)
				elseif stat3~=nil then stat3:SetHidden(true)
				end
			end
		else
			if statlabel1~=nil then statlabel1:SetHidden(true) end 
			stat1:SetHidden(true)
			stat2:SetHidden(true)
			if stat3~=nil then stat3:SetHidden(true) end
		end 
	end 
	-- update stats right --
	for i=1,3 do
		local v1 = showdata.stats[CMX.Statlist.general[i][1] ] or 0
		local v2 = showdata.stats[CMX.Statlist.general[i][2] ] or 0
		local stat1 = _G["CMX_Report_Stat_r"..i.."_1Value"]
		local stat2 = _G["CMX_Report_Stat_r"..i.."_2Value"]
		stat1:SetText(v1)
		stat2:SetText(v2)
	end
	for i=1,6 do
		local j=i+3
		local v1 = 0
		local v2 = showdata.stats["max"..CMX.offstatlist[i] ]
		if showdata.stats[itemlist.avgstat[1] ]["t"..CMX.offstatlist[i] ] == nil then
			v1 = v2
		else
			v1 = zo_round(showdata.stats[itemlist.avgstat[1] ]["t"..CMX.offstatlist[i] ] / showdata[itemlist.avgstat[((i==3 or i==6) and 3) or 2] ])
		end
		if i==3 or i==6 then 
			v1 = tostring(zo_round(GetCriticalStrikeChance(v1, true)*10)/10).."%" 
			v2 = tostring(zo_round(GetCriticalStrikeChance(v2, true)*10)/10).."%" 
		end
		local stat1 = _G["CMX_Report_Stat_r"..(j).."_1Value"]
		local stat2 = _G["CMX_Report_Stat_r"..(j).."_2Value"]
		stat1:SetText(v1)
		stat2:SetText(v2)
	end
	for i=1,3 do
		local j=i+9
		local v2 = showdata.stats["max"..CMX.defstatlist[i] ]
		local v1 = 0
		if showdata.stats.dmginavg["t"..CMX.defstatlist[i] ] == nil then 
			v1 = v2
		else
			v1 = zo_round(showdata.stats.dmginavg["t"..CMX.defstatlist[i] ] /showdata[(i==3 and "ithits") or "itdmg"])
		end
		local stat1 = _G["CMX_Report_Stat_r"..(j).."_1Value"]
		local stat2 = _G["CMX_Report_Stat_r"..(j).."_2Value"]
		stat1:SetText(v1)
		stat2:SetText(v2)
	end
	
	-- reset units and abilities --
	local contr = 0
	for i=1,CMX.UI.units do
		contr = _G["CMX_Report_Units_"..i]
		contr:SetHidden(true)
	end 
	for i=1,CMX.UI.buffs do
		contr = _G["CMX_Report_Buffs_"..i]
		contr:SetHidden(true)
	end 
	for i=1,CMX.UI.abilities do
		contr = _G["CMX_Report_Abilities_"..i]
		contr:SetHidden(true)
	end 
	for i=1,CMX.UI.resources do
		contr = _G["CMX_Report_Resources_"..i]
		contr:SetHidden(true)
	end 
	-- update units --
	CMX_Report_Units_Panel:SetHidden(false)
	CMX_Report_Units_header_Label:SetText(itemlist.targetlabel)
	CMX_Report_Units_header_Label3:SetText(itemlist.label3)
	contr = nil
	local currentanchor = {TOPLEFT,TOPLEFT,0,1,CMX_Report_Units_PanelScrollChild}
	ictrl = 1
	for k,v in CMX:spairs(showdata["units"], function(t,a,b) return t[a][itemlist[3][1] ]>t[b][itemlist[3][1] ] end) do
		if v[itemlist[3][1]] > 0 then
			local color = {0.8,0,0,0.6} 
			local highlight = false
			if selectedunits ~= nil then highlight = selectedunits[k] ~= nil end
			local dbug = CMX.set.debuginfo.ids and (" (" .. k .. ")") or ""
			local newunit = CMX.UI:CreateUnitControl( ictrl, v["name"]..dbug, v[itemlist[2][1] ], (v[itemlist[3][1] ]/totaldmg), CMX_Report_Units_PanelScrollChild, currentanchor, color, v["utype"], highlight, k, scale)
			currentanchor = {TOPLEFT,BOTTOMLEFT,0,1,newunit}
			ictrl = ictrl+1
		end
	end 
	CMX.UI.units = ictrl-1	
	-- update buffs --
	contr = nil
	local currentanchor = {TOPLEFT,TOPLEFT,0,1,CMX_Report_Buffs_PanelScrollChild}
	ictrl = 1
	local buffdata
	if CMX.Resourceselection == "buffsout" then 
		buffdata=selectiondata
	else 
		buffdata=showdata
	end
	for k,v in CMX:spairs(buffdata["buffs"], function(t,a,b) return t[a]["uptime"]>t[b]["uptime"] end) do
		if v.uptime > 0 then
			local color = v.bufftype==BUFF_EFFECT_TYPE_BUFF and {0,0.6,0,0.6} or {0.75,0,0.6,0.6}
			local highlight = false
			if selectedbuffs ~= nil then highlight = selectedbuffs[k] ~= nil end
			local newunit = CMX.UI:CreateBuffControl( ictrl, k, v.count, (v.uptime/((showdata.dpsend-showdata.dpsstart)*(buffdata.buffcount or 1))), CMX_Report_Buffs_PanelScrollChild, currentanchor, color, highlight, v.icon, k, scale)
			currentanchor = {TOPLEFT,BOTTOMLEFT,0,1,newunit}
			ictrl = ictrl+1
		end
	end 
	CMX.UI.buffs = ictrl-1
	-- update resources --
	if CMX.Resourceselection == "magicka" or CMX.Resourceselection == "stamina" then
		contr = nil
		local currentanchor = {TOPLEFT,TOPLEFT,0,1,CMX_Report_Resources_PanelScrollChild}
		ictrl = 1
		local color = CMX.Resourceselection == "magicka" and {0.35,0.56,.7,1} or {0.42,.6,0.3,1}
		for k,v in CMX:spairs(showdata.stats[CMX.Resourceselection.."gains"], function(t,a,b) return (t[a][1] or 0)>(t[b][1] or 0) end) do
			if (v[2] or 0) > 0 then

				local label = k > 0 and zo_strformat("<<!aC:1>>",GetAbilityName(k)) or GetString(SI_COMBAT_METRICS_BASE_REG)

				local highlight = false
				if selectedresources ~= nil then highlight = selectedresources[k] ~= nil end
				local newunit = CMX.UI:CreateResourceControl( ictrl, label, v[2], (v[1]*1000/((showdata.dpsend-showdata.dpsstart)*showdata.stats[CMX.Resourceselection.."gps"])), math.floor(v[1]*1000/(showdata.dpsend-showdata.dpsstart)), CMX_Report_Resources_PanelScrollChild, currentanchor, color, highlight, k, scale)
				currentanchor = {TOPLEFT,BOTTOMLEFT,0,1,newunit}
				ictrl = ictrl+1
			end
		end 
		currentanchor[4] = 8
		local septext = CMX.UI:Label( 		"CMX_Report_Resources_SepText", 	CMX_Report_Resources_PanelScrollChild, 		{35,fontsize}, 		currentanchor, 	CMX.UI:Font("standard",fontsize,true, scale), {1,1,1,1}, {0,1}, GetString(SI_COMBAT_METRICS_DRAIN), false, scale )
		local separator = CMX.UI:Backdrop("CMX_Report_Resources_Sep",		septext,		{currentanchor[5]:GetWidth()-50;1}, {BOTTOMLEFT,BOTTOMRIGHT,2,0}, {0,0,0,0}, {.5,.5,.5,1}, {1,1,2} ,nil, false, scale )
		currentanchor = {TOPLEFT,BOTTOMLEFT,0,5,septext}
		local color = CMX.Resourceselection == "magicka" and {0.42,.3,.6,1} or {0.4,0.45,0.05,1}
		for k,v in CMX:spairs(showdata.stats[CMX.Resourceselection.."drains"], function(t,a,b) return (t[a][1] or 0)>(t[b][1] or 0) end) do
			if (v[2] or 0) > 0 then

				local label = k > 0 and zo_strformat("<<!aC:1>>",GetAbilityName(k)) or GetString(SI_COMBAT_METRICS_UNKNOWN)

				local highlight = false
				if selectedresources ~= nil then highlight = selectedresources[k] ~= nil end
				local newunit = CMX.UI:CreateResourceControl( ictrl, label, v[2], (v[1]*1000/((showdata.dpsend-showdata.dpsstart)*showdata.stats[CMX.Resourceselection.."drps"])), math.floor(v[1]*1000/(showdata.dpsend-showdata.dpsstart)), CMX_Report_Resources_PanelScrollChild, currentanchor, color, highlight, k, scale)
				currentanchor = {TOPLEFT,BOTTOMLEFT,0,1,newunit}
				ictrl = ictrl+1
			end
		end 
		CMX.UI.resources = ictrl-1
	end
	-- update abilities --
	CMX_Report_Abilities_Panel:SetHidden(false)
	ictrl = 1
	currentanchor = {TOPLEFT,TOPLEFT,0,1,CMX_Report_Abilities_PanelScrollChild}

	local critblock = menuitem=="dmgin" and GetString(SI_COMBAT_METRICS_BLOCKS) or GetString(SI_COMBAT_METRICS_CRITS) 

	CMX_Report_Abilities_header_crits:SetText(critblock)

	local dmgheal = (menuitem=="dmgin" or menuitem=="dmgout") and GetString(SI_COMBAT_METRICS_DAMAGE) or GetString(SI_COMBAT_METRICS_HEALING)

	CMX_Report_Abilities_header_amt:SetText(dmgheal)
	if selectedunits ~= nil then 
		showdata = selectiondata 
		totaldmg = showdata.utdmg
	end
	local statitems = itemlist.statitems
	for k,v in CMX:spairs(showdata[menuitem], function(t,a,b) return t[a][statitems[1] ]>t[b][statitems[1] ] end) do
		if v[statitems[1] ]>0 then 
			local color = {0.95,0.90,0.15,0.6}
			local critratio = tostring(zo_round(v[statitems[4] ]/v[statitems[5] ]*1000)/10).." %"
			local avg = zo_round(v[statitems[1] ]/v[statitems[5] ])
			local dot = ((GetAbilityDuration(k)>0 or IsAbilityPassive(k)) and (menuitem=="dmgin" or menuitem=="dmgout") and " *" ) or (GetAbilityDuration(k)>0 and " *" ) or ""
			local pet = v.pet and " (pet)" or ""
			local dbug = CMX.set.debuginfo.ids and (" (" .. k .. ")") or ""
			local icon = GetAbilityIcon(k)
			local highlight = false
			local color = v.dtype and CMX.UI.dmgcolors[v.dtype] or ""
			if selectedabilities ~= nil then 
				highlight = selectedabilities[k] ~= nil 
			end
			local newability = CMX.UI:CreateAbilityControl( ictrl, color..(v.name or zo_strformat("<<!aC:1>>",GetAbilityName(k)))..dot..pet..dbug.."|r", {v[statitems[1] ],v[statitems[4] ],v[statitems[5] ],critratio,avg,v[statitems[3] ],v[statitems[2] ]}, (v[statitems[1] ]/totaldmg), CMX_Report_Abilities_PanelScrollChild, currentanchor, color, highlight, icon, k, scale)
			currentanchor = {TOPLEFT,BOTTOMLEFT,0,1,newability}
			ictrl = ictrl+1
		end
	end 
	CMX.UI.abilities = ictrl-1
	CMX.UI.UpdateCL()
end

function CMX.UI:PosttoChat(mode)
	local data = {}
	if CMX.currentfight.dpsstart == nil then 
		if #CMX.lastfights == 0 then return end
		data = CMX.lastfights[#CMX.lastfights]
	else 
		data = CMX.currentfight
	end
	local output = ""
	local dpstime = ZO_FormatTime( math.floor(data.dpstime) , SI_TIME_FORMAT_TIMESTAMP).."."..(math.floor(((data.dpstime)*10)+0.5)-math.floor(data.dpstime)*10)
	if mode == "DPST" or mode == "DPSS" or mode == "DPSM" or mode == "SmartDPS" then
		local dps,dmg,maxdmg,units,name = 0,0,0,0,""
		local bdps,bdmg,maxbdmg,bunits,bossname = 0,0,0,0,""		
		for k,v in pairs(data["units"]) do
			if (data.bossfight == true and v.utype=="boss" and v.tdmg>0) then 
				bdps = bdps + math.floor(v.tdmg*1000/(data.dpsend-data.dpsstart))
				bdmg = bdmg + v.tdmg
				bunits = bunits + 1 
				if v.tdmg>maxbdmg then 
					bossname = v.name
					maxbdmg = v.tdmg
				end
			end
			if v.tdmg>0 and v.utype~="group" and v.utype~="pet" then
				dps = dps + math.floor(v.tdmg*1000/(data.dpsend-data.dpsstart))
				dmg = dmg + v.tdmg
				units = units + 1
				if v.tdmg>maxdmg then 
					name = v.name
					maxdmg = v.tdmg
				end
			end
		end
		name = (data.bossfight and bossname) or name

		if units == 1 or mode == "DPSS" then 
			output 	= zo_strformat("<<!aC:1>>", name) .." - DPS: " .. math.floor(1000*(maxbdmg>0 and maxbdmg or maxdmg)/(data.dpsend-data.dpsstart)) .. " (" .. (maxbdmg>0 and maxbdmg or maxdmg) .. " in ".. dpstime .. "s)"
		elseif bunits >0 and mode == "SmartDPS" then
			output 	= zo_strformat("<<!aC:1>>", name) ..(bunits>1 and " (+"..(bunits-1)..")" or " ").. "- Boss DPS: " .. bdps .. " (" .. bdmg .. " in " .. dpstime .. "s)"
		elseif units >1 and (mode == "SmartDPS" or mode == "DPSM" ) then
			output 	= zo_strformat("<<!aC:1>>", name) .." (+"..(units-1)..")".. " - DPS: " .. dps .. " (" .. dmg .. " Damage in " .. dpstime .. "s)"
		elseif mode == "DPST" then 
			output 	= zo_strformat("<<!aC:1>>", name) .." (".. dpstime .. "s) - Total DPS (+"..(units-1).."): " .. dps .. " (" .. dmg .. " Damage), DPS: " .. math.floor(1000*(maxdmg)/(data.dpsend-data.dpsstart)) .. " (" .. maxdmg .. " Damage)" 
		end
	elseif mode == "HPS" then 
		local thps = data.hps
		local theal = data.theal
		output = dpstime .. "s - HPS: " .. thps .. " (" .. theal .. " in " .. dpstime .. "s)"
	end
	-- Determine appropriate channel
	local channel = IsUnitGrouped('player') and "/p " or "/say "

	-- Print output to chat
	CHAT_SYSTEM.textEntry:SetText( channel .. output )
	CHAT_SYSTEM:Maximize()
	CHAT_SYSTEM.textEntry:Open()
	CHAT_SYSTEM.textEntry:FadeIn()
end

function CMX.UI.UpdateCL(page)
	if CMX_Report_Combatlog:IsHidden()==true then return end -- Bail out if the log is hidden
	local sel = CMX.UI.Selection
	local sel2 = CMX.set.UI.CLSelection
	local fightdata = CMX.lastfights[CMX.UI.Currentfightid]
	if fightdata==nil then return end
	CMX_Report_Combatlog_LogWindowBuffer:SetMaxHistoryLines(#fightdata.log)
	CMX.UI.ClearText(CMX_Report_Combatlog_LogWindow)
	local maxpage = math.ceil(#fightdata.log/1000)
	page = page or 1
	page = page<=maxpage and page or 1
	local writtenlines = 0
	sel.unit["all"] = {}
	local selunits = 0
	for k,v in pairs({"healin", "healout", "dmgin", "dmgout"}) do
		if sel.unit[v] ~= nil then 
			for k,v in pairs(sel.unit[v]) do
				sel.unit["all"][k]=v
				selunits = selunits + 1
			end
		end
	end
	for k,v in pairs(fightdata.log) do 
		local timems, result, sourceUnitId, targetUnitId, abilityId, hitValue, damagetype, action = unpack(v)
		local filter,filter2 = false,false
		filter = (filter or (action=="healself" and (sel2["healin"] or sel2["healout"])) or sel2[action] or action == "message")
		if filter and (action == "healin" or action == "healout" or action == "dmgin" or action == "dmgout") then 
			if sel.unit[action] == nil then 
				filter2 = true
			elseif (sel.unit[action][targetUnitId] ~= nil and (action == "healout" or action == "dmgout")) or (sel.unit[action][sourceUnitId]~= nil and (action == "healin" or action == "dmgin")) then
				filter2 = true
			else filter2 = false
			end
			if sel.ability[action] == nil then 
				filter2 = filter2
			elseif sel.ability[action][abilityId] ~= nil then
				filter2 = filter2
			else filter2 = false
			end
		elseif filter and action == "healself" then 
			if sel.ability["healin"] == nil then 
				filter2 = true
			elseif sel.ability["healin"][abilityId] ~= nil then
				filter2 = true
			else filter2 = false
			end
			if sel.ability["healout"] == nil then 
				filter2 = true
			elseif sel.ability["healout"][abilityId] ~= nil then
				filter2 = true
			else filter2 = false
			end
		elseif filter and action == "buff" then 
			local ability = CMX.CustomAbilityName[abilityId] or zo_strformat("<<!aC:1>>",GetAbilityName(abilityId))
			if sel.buff.buff == nil and selunits==0 then 
				filter2 = true
			elseif (sel.buff.buff ~= nil and sel.buff.buff[ability]~= nil and selunits==0) or (sel.buff.buff == nil and sel.unit["all"][targetUnitId]~= nil) then
				filter2 = true
			elseif sel.buff.buff~=nil and sel.buff.buff[ability] ~= nil and selunits~=0 and sel.unit["all"][targetUnitId] ~= nil then
				filter2 = true
			else filter2 = false
			end		
		elseif filter and (action == "stats" or action == "resource") then
			if sel.resource.resource == nil then 
				filter2 = true
			elseif sel.resource.resource[abilityId or 0] ~= nil then
				filter2 = true
			else filter2 = false
			end		
		elseif filter and (action == "resource") then
			filter2 = true	
		elseif filter and action == "message" and sel2["stats"] then
			filter2 = true
		end
		if filter == true and filter2==true then 
			local sourcename,targetname = nil,nil
			if action == "dmgout" or action == "healout" or action == "dmgin" or action == "healin" then
				sourcename = fightdata.units[sourceUnitId]["name"]
				targetname = fightdata.units[targetUnitId]["name"]
			end 
			writtenlines = writtenlines + 1
			if writtenlines >= (page-1)*1000 and writtenlines < page*1000 then 
				CMX.UI.CLAddLine(timems-math.min(fightdata.dpsstart or fightdata.combatstart,fightdata.combatstart), result, sourcename, targetname, abilityId, hitValue, damagetype, action, "log")
			end
		end
	end
	
	maxpage = math.ceil(writtenlines/1000)
	CMX.UI.CLPage(page,((maxpage>1 and maxpage) or 1))
	
	buffer = CMX_Report_Combatlog_LogWindowBuffer
	slider = CMX_Report_Combatlog_LogWindowSlider
	local offset = buffer:GetNumHistoryLines()
	buffer:SetScrollPosition(math.min(buffer:GetScrollPosition() + offset, math.floor(buffer:GetNumHistoryLines()-(buffer:GetNumVisibleLines())/dx))) -- correct for ui scale
	slider:SetValue(slider:GetValue() - offset)
end

function CMX.UI.CLAddLine(timems, result, sourcename, targetname, abilityId, hitValue, damagetype, action, context)
	local scale = CMX.set.UI.ReportScale
	-- local target, action2, source, skillcolor = "","","",""
	if context == "chat" and (sourcename==nil or targetname==nil or abilityId ==nil) and (action ~= "message") then return end 
	if context == "chat" then
		action = (action == "message" and action) or (((targetname==CMX.playername) and (sourcename==CMX.playername)) and "healself") or ((targetname==CMX.playername) and action.."in") or action.."out"
		timems = CMX.currentfight.combatstart<0 and 0 or timems-CMX.currentfight.combatstart
		if not ((action == "healself" and (CMX.set.EnableChatLogHealOut or CMX.set.EnableChatLogHealIn)) or (action == "dmgout" and CMX.set.EnableChatLogDmgOut) or (action == "healout" and CMX.set.EnableChatLogHealOut) or (action == "dmgin" and CMX.set.EnableChatLogDmgIn) or (action == "healin" and CMX.set.EnableChatLogHealIn) or (action == "message")) then return end
	end
	local icon,aname,text,color = "","","error",{1,1,1}
	if abilityId ~= nil then 
		icon = zo_iconFormat(GetAbilityIcon(abilityId), fontsize*scale, fontsize*scale).." " 
		aname = CMX.CustomAbilityName[abilityId] or zo_strformat("<<!aC:1>>",GetAbilityName(abilityId))
	else 
		icon = "" 
	end
	local timetext = "|ccccccc["..string.format("%.3f",timems/1000).."]|r "

	--ACTION_RESULT_BLOCKED_DAMAGE or 
	if action == "dmgout" then 
		local source = "|cffffffYou |r"
		local action2 = (result==ACTION_RESULT_CRITICAL_DAMAGE or result==ACTION_RESULT_DOT_TICK_CRITICAL) and "|cFFCC99critically|r hit " or "hit "
		local target = "|cffdddd"..targetname
		local dmgcolor = CMX.UI.dmgcolors[damagetype]
		local ability = (result==ACTION_RESULT_DAMAGE_SHIELDED and "s shield:|r " or result==ACTION_RESULT_BLOCKED_DAMAGE and "s block|r with " or "|r with ")..icon..dmgcolor..aname.."|r".." for |cffffff"..hitValue.."."
		color = {1.0,0.6,0.6}
		text = timetext..source..action2..target..ability
	elseif action == "healout" then
		local source = "|cffffffYou |r"
		local action2 = (result==ACTION_RESULT_CRITICAL_HEAL or result==ACTION_RESULT_HOT_TICK_CRITICAL) and "|c55FF55critically|r heal " or "heal "
		local target = "|cddffdd"..targetname.."|r "
		local dmgcolor = CMX.UI.dmgcolors.heal
		local ability = "with "..icon..dmgcolor..aname.."|r".." for |cffffff"..hitValue.."."	
		color = {0.6,1.0,0.6}
		text = timetext..source..action2..target..ability
	elseif action == "dmgin" then
		local source = "|cffdddd"..sourcename.."|r "
		local action2 = (result==ACTION_RESULT_CRITICAL_DAMAGE or result==ACTION_RESULT_DOT_TICK_CRITICAL) and "|cFFCC99critically|r hits " or "hits "
		local target = "|cffffffyou"
		local dmgcolor = CMX.UI.dmgcolors[damagetype]
		local ability = (result==ACTION_RESULT_DAMAGE_SHIELDED and "r shield:|r " or result==ACTION_RESULT_BLOCKED_DAMAGE and "r block|r with " or "|r with ")..icon..dmgcolor..aname.."|r".." for |cffffff"..hitValue.."."
		color = {0.8,0.4,0.4}
		text = timetext..source..action2..target..ability
	elseif action == "healin" then
		local source = "|cddffdd"..sourcename.."|r "
		local action2 = (result==ACTION_RESULT_CRITICAL_HEAL or result==ACTION_RESULT_HOT_TICK_CRITICAL) and "|c55FF55critically|r heals " or "heals "
		local target = "|cffffffyou |r"
		local dmgcolor = CMX.UI.dmgcolors.heal
		local ability = "with "..icon..dmgcolor..aname.."|r".." for |cffffff"..hitValue.."."
		color = {0.4,0.8,0.4}
		text = timetext..source..action2..target..ability
	elseif action == "healself" then 
		local source = "|cffffffYou |r"
		local action2 = (result==ACTION_RESULT_CRITICAL_HEAL or result==ACTION_RESULT_HOT_TICK_CRITICAL) and "|c55FF55critically|r heal " or "heal "
		local target = "|cffffffyourself |r"
		local dmgcolor = CMX.UI.dmgcolors.heal
		local ability = " with "..icon..dmgcolor..aname.."|r".." for |cffffff"..hitValue.."."
		color = {0.8,1.0,0.6}
		text = timetext..source..action2..target..ability
	elseif action == "buff" then 
		local source = "|cffffffYou |r"
		local changetype = result == EFFECT_RESULT_GAINED and "gained " or result == EFFECT_RESULT_FADED and "lost "
		local ability = icon..CMX.UI.buffcolors[damagetype]..aname.."|r."
		color = {0.8,0.8,0.8}
		text = timetext..source..changetype..ability
	elseif action == "resource" and hitValue ~= nil then 
		local source = "|cffffffYou |r"
		local action2 = (hitValue>0 and "|c00cc00gained|r ") or (hitValue==0 and "|cffffffgained no|r ") or "|cff3333lost|r " 
		local amount = hitValue~=0 and "|cffffff"..tostring(math.abs(hitValue)).."|r " or ""
		local resource = (damagetype == POWERTYPE_MAGICKA and GetString(SI_COMBAT_METRICS_MAGICKA)) or (damagetype == POWERTYPE_STAMINA and GetString(SI_COMBAT_METRICS_STAMINA)) or (damagetype == POWERTYPE_ULTIMATE and GetString(SI_COMBAT_METRICS_ULTIMATE))
		local ability = abilityId and zo_strformat("<<!aC:1>>",GetAbilityName(abilityId)) or GetString(SI_COMBAT_METRICS_BASE_REG)
		color = (damagetype == POWERTYPE_MAGICKA and {0.7,0.7,1}) or (damagetype == POWERTYPE_STAMINA and {0.7,1,0.7}) or (damagetype == POWERTYPE_ULTIMATE and {1,1,0.7})
		text = timetext..source..action2..amount..resource.."|cffffff("..ability..").|r"
	elseif action == "resource" and hitValue == nil then return 
	elseif action == "stats" then 
		local stat = CMX.UI.statnames[damagetype]
		local percent = ""
		local resultstring = result
		local value = hitValue
		if damagetype=="spellcrit" or damagetype=="weaponcrit" then 
			value = string.format("%.1f",zo_round(GetCriticalStrikeChance(hitValue, true)*10)/10)
			resultstring = string.format("%.1f",zo_round(GetCriticalStrikeChance(result, false)*10)/10)
			percent = "%"
		end
		local diff = result>0 and " |c00cc00(+"..resultstring..percent..")|r" or " |cff3333("..resultstring..percent..")|r" 
		color = {0.8,0.8,0.8}
		text = timetext..stat.."changed to "..value..percent..diff
	elseif action == "message" then 
		if result == "weapon swap" then 
			color = {.6,.6,.6}
			text = timetext.."Weapon Swap"
		elseif result == "combat" then 
			color = {.7,.7,.7}
			text = hitValue
		else return
		end
	end
	if context == "log" then
		CMX.UI.AddText(CMX_Report_Combatlog_LogWindow, text, color)
	elseif context == "chat" and CMX.ChatContainer and CMX.ChatWindow then
		CMX.ChatContainer:AddMessageToWindow(CMX.ChatWindow, text, unpack(color))
	end
end

function CMX.UI:Initialize()
	-- Fonts
	CMX.UI.Fonts        = {
	["meta"]        = "FoundryTacticalCombat/lib/fonts/Metamorphous.otf",
	["standard"]    = GetString(SI_COMBAT_METRICS_STD_FONT),
	["esobold"]     = GetString(SI_COMBAT_METRICS_ESO_FONT),
	["antique"]     = "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
	["handwritten"] = "EsoUI/Common/Fonts/Handwritten_Bold.otf",
	["trajan"]      = "EsoUI/Common/Fonts/TrajanPro-Regular.otf",
	["futura"]      = "EsoUI/Common/Fonts/FuturaStd-CondensedLight.otf",
	["futurabold"]  = "EsoUI/Common/Fonts/FuturaStd-Condensed.otf",
	["chat"]		= "ZoFontChat"
	}
	
	CMX.UI.dmgcolors={ 
		[DAMAGE_TYPE_NONE] 		= "|cE6E6E6", 
		[DAMAGE_TYPE_GENERIC] 	= "|cE6E6E6", 
		[DAMAGE_TYPE_PHYSICAL] 	= "|cf4f2e8", 
		[DAMAGE_TYPE_FIRE] 		= "|cff6600", 
		[DAMAGE_TYPE_SHOCK] 	= "|cffff66", 
		[DAMAGE_TYPE_OBLIVION] 	= "|cd580ff", 
		[DAMAGE_TYPE_COLD] 		= "|cb3daff", 
		[DAMAGE_TYPE_EARTH] 	= "|cbfa57d", 
		[DAMAGE_TYPE_MAGIC] 	= "|c9999ff", 
		[DAMAGE_TYPE_DROWN] 	= "|ccccccc", 
		[DAMAGE_TYPE_DISEASE] 	= "|cc48a9f", 
		[DAMAGE_TYPE_POISON] 	= "|c9fb121", 
		["heal"]				= "|c55ff55",
	}
	CMX.UI.buffcolors={ 
		[BUFF_EFFECT_TYPE_BUFF]		= "|c00cc00",
		[BUFF_EFFECT_TYPE_DEBUFF]	= "|cff3333",
	}

	CMX.UI.statnames={
		["spellpower"]	= "|c8888ff"..GetString(SI_COMBAT_METRICS_STAT_SPELL_POWER).."|r ", 			--|c8888ff
		["spellcrit"]	= "|c8888ff"..GetString(SI_COMBAT_METRICS_STAT_SPELL_CRIT).."|r ",
		["maxmagicka"]	= "|c8888ff"..GetString(SI_COMBAT_METRICS_STAT_MAX_MAGICKA).."|r ",
		["weaponpower"]	= "|c88ff88"..GetString(SI_COMBAT_METRICS_STAT_WEAPON_POWER).."|r ",			--|c88ff88
		["weaponcrit"]	= "|c88ff88"..GetString(SI_COMBAT_METRICS_STAT_WEAPON_CRIT).."|r ",
		["maxstamina"]	= "|c88ff88"..GetString(SI_COMBAT_METRICS_STAT_MAX_STAMINA).."|r ",
		["physres"]		= "|cffff88"..GetString(SI_COMBAT_METRICS_STAT_PHYSICAL_RESISTANCE).."|r ",	--|cffff88
		["spellres"]	= "|cffff88"..GetString(SI_COMBAT_METRICS_STAT_SPELL_RESISTANCE).."|r ",
		["critres"]		= "|cffff88"..GetString(SI_COMBAT_METRICS_STAT_CRITICAL_RESISTANCE).."|r ",
	}	
	
	-- Array to select what to show on Stats section of Detailed report
	
	CMX.Statlist = {
		dmgout = {	
			{"dpstime","combattime",nil},
			{"dps","gdps",{"dps","gdps"}},
			{"tdmg","grpdmg",{"tdmg","grpdmg"}},
			{"ndmg",nil,{"ndmg","tdmg"}},
			{"cdmg",nil,{"cdmg","tdmg"}},
			nil,
			nil,
			{"thits",nil,nil},
			{"nhits",nil,
			{"nhits","thits"}},
			{"chits",nil,{"chits","thits"}},
			nil,
			nil,
			label1=GetString(SI_COMBAT_METRICS_DAMAGE), 
			label2=GetString(SI_COMBAT_METRICS_HIT), 
			label3=GetString(SI_COMBAT_METRICS_DPS), 
			statitems={"tdmg","dps","max","chits","thits"},
			avgstat={"dmgavg","tdmg","thits"},
			targetlabel=GetString(SI_COMBAT_METRICS_TARGET)
		},
		healout = {	
			{"dpstime","combattime",nil},
			{"hps","ghps",{"hps","ghps"}},
			{"theal","grpheal",{"theal","grpheal"}},
			{"nheal",nil,{"nheal","theal"}},
			{"cheal",nil,{"cheal","theal"}},
			nil,
			nil,
			{"theals",nil,nil},
			{"nheals",nil,{"nheals","theals"}},
			{"cheals",nil,{"cheals","theals"}},
			nil,
			nil,
			label1=GetString(SI_COMBAT_METRICS_HEALING), 
			label2=GetString(SI_COMBAT_METRICS_HEALS), 
			label3=GetString(SI_COMBAT_METRICS_HPS),
			statitems={"theal","hps","max","cheals","theals"},
			avgstat={"healavg","theal","theals"},
			targetlabel=GetString(SI_COMBAT_METRICS_TARGET)
		},
		dmgin = {	
			{"dpstime","combattime",nil},
			{"idps","igdps",{"idps","igdps"}},
			{"itdmg","igrpdmg",{"itdmg","igrpdmg"}},
			{"indmg",nil,{"indmg","itdmg"}},
			{"icdmg",nil,{"icdmg","itdmg"}},
			{"ibdmg",nil,{"ibdmg","itdmg"}},
			{"isdmg",nil,{"isdmg","itdmg"}},
			{"ithits",nil,nil},
			{"inhits",nil,{"inhits","ithits"}},
			{"ichits",nil,{"ichits","ithits"}},
			{"ibhits",nil,{"ibhits","ithits"}},
			{"ishits",nil,{"ishits","ithits"}},
			label1=GetString(SI_COMBAT_METRICS_INC_DAMAGE), 
			label2=GetString(SI_COMBAT_METRICS_INC_HITS), 
			label3=GetString(SI_COMBAT_METRICS_INC_DPS),
			statitems={"tdmg","dps","max","bhits","thits"},
			avgstat={"dmgavg","tdmg","thits"},
			targetlabel=GetString(SI_COMBAT_METRICS_SOURCE)
		},
		healin = {	
			{"dpstime","combattime",nil},
			{"ihps","ghps",{"ihps","ghps"}},
			{"itheal","grpheal",{"itheal","grpheal"}},
			{"inheal",nil,{"inheal","itheal"}},
			{"icheal",nil,{"icheal","itheal"}},
			nil,
			nil,
			{"itheals",nil,nil},
			{"inheals",nil,
			{"inheals","itheals"}},
			{"icheals",nil,{"icheals","itheals"}},
			nil,
			nil,
			label1=GetString(SI_COMBAT_METRICS_INC_HEALING), 
			label2=GetString(SI_COMBAT_METRICS_INC_HEALS), 
			label3=GetString(SI_COMBAT_METRICS_INC_HPS),
			statitems={"theal","hps","max","cheals","theals"},
			avgstat={"healavg","theal","theals"},
			targetlabel=GetString(SI_COMBAT_METRICS_SOURCE)
		},
		general = {	
			{"magickagps","magickadrps"},
			{"staminagps","staminadrps"},
			{"ultigps","ultidrps"},
		}
		
	}
	--CMX.set.UI.LRMenuItem = "dmgout"
	
	CMX.UI.Selection = {
		["ability"]		= {}, 
		["unit"] 		= {},
		["buff"] 		= {},
		["resource"] 	= {},
		
		}
		
	CMX.UI.LastSelection = {
		["ability"] 	= {}, 
		["unit"] 		= {},
		["buff"] 		= {},
		["resource"] 	= {},
		}
	
	CMX.UI.units = 0
	CMX.UI.abilities = 0 
	CMX.UI.buffs = 0 
	CMX.UI.resources = 0
	CMX.UI.Currentfightid = nil
	CMX.UI.CLCurrentPage = 1
	CMX.Resourceselection = "stats"

	-- Create core controls
	CMX.UI:ControlLR()
	CMX.UI:ControlRW()
	for k,v in pairs(CMX.set.UI.CLSelection) do
		local control = _G["CMX_Report_Combatlog_TitleMenu_"..k.."_BG"]
		control:SetCenterColor( 0 , 0 , 0 , v and 0 or 0.8 )
		control:SetEdgeColor( 1 , 1 , 1 , v and 1 or .5 )	
	end

	-- Reference the CMX_UI layer as a scene fragment
	CMX.UI.fragment = ZO_HUDFadeSceneFragment:New(CMX_LiveReport)

	-- Add the fragment to select scenes
	if CMX.set.EnableLiveMonitor then 
		SCENE_MANAGER:GetScene("hud"):AddFragment( CMX.UI.fragment )
		SCENE_MANAGER:GetScene("hudui"):AddFragment( CMX.UI.fragment )
		SCENE_MANAGER:GetScene("siegeBar"):AddFragment( CMX.UI.fragment )
	end

end