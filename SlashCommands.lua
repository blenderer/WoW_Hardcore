
local function extract_arguments(args)
	local first = nil
	local second = nil
	for substring in args:gmatch("%S+") do
		if first == nil then
			first = substring
		else
			second = substring
		end
	end
	if first == nil then
		Hardcore:Print("Wrong syntax: Missing first argument")
		return
	end
	if second == nil or _G.ach then
		Hardcore:Print("Wrong syntax: Missing second argument")
		return
	end

	-- return both first and second arguments
	return first, second
end

local function short_crypto_hash(str)
	local hash = 5381
	for i = 1, #str do
		hash = hash * 33 + str:byte( i )
	end
	return hash
end

local function get_short_code(suffix)
	local str = UnitName("player"):sub(1,5) .. UnitLevel("player") .. suffix
	return short_crypto_hash(str)
end


local function long_cryto_hash( str )

	local a = 0
	local b = 0
	local dictionary = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 /:"
	
	for i = 1, #str do
		x, y = string.find( dictionary, str:sub(i,i), 1, true )
		if x == nil then
			x = #dictionary
		end
		for i=1, 17 do
			a = (a * (-6) + b + 0x74FA - x) % 4096
			b = (math.floor(b / 3) + a + 0x81BE - x) % 4096
		end
	end
	return (a * 4096) + b
end

local function get_long_code( date_str )
	local str = UnitName("player") .. UnitLevel("player") .. date_str
	return long_cryto_hash(str)
end

local function SlashCmd_Deprecated()	
	Hardcore:Print("This command is deprecated.")
end

local function SlashCmd_AppealAchievementCode(args)
	local code = nil
	local ach_num = nil
	code, ach_num = extract_arguments(args)

	if _G.achievements[_G.id_a[ach_num]] == nil then
		Hardcore:Print("Wrong syntax: achievement isn't found for " .. ach_num)
		return
	end

	if tostring(short_crypto_hash(ach_num)):sub(1,10) == tostring(tonumber(code)):sub(1,10) then
		for i,v in ipairs(Hardcore_Character.achievements) do
			if v == _G.id_a[ach_num] then
				return
			end
		end

		local function OnOkayClick()				
			table.insert(Hardcore_Character.achievements, _G.achievements[_G.id_a[ach_num]].name)
			_G.achievements[_G.id_a[ach_num]]:Register(failure_function_executor, Hardcore_Character)
			Hardcore:Print("Appealed " .. _G.achievements[_G.id_a[ach_num]].name .. " challenge!")
			StaticPopup_Hide("ConfirmAchievementAppeal")
		end
	
		local function OnCancelClick()
			Hardcore:Print("Opting out of Appeal for Achievement: " .. _G.achievements[_G.id_a[ach_num]].name)
			StaticPopup_Hide("ConfirmAchievementAppeal")
		end

		local text = "You have requested to appeal the achievement '".._G.achievements[_G.id_a[ach_num]].name.."'."

		if ach_num == "47" then -- Insane in the Membrane
			text = text .. "  This achievement will flag you for PvP, and you may be killed."
		end

		text = text .. "  Do you want to proceed?"
	
		StaticPopupDialogs["ConfirmAchievementAppeal"] = {
			text = text,
			button1 = OKAY,
			button2 = CANCEL,
			OnAccept = OnOkayClick,
			OnCancel = OnCancelClick,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		}
		
		local dialog = StaticPopup_Show("ConfirmAchievementAppeal")

	else
		Hardcore:Print("Incorrect code. Double check with a moderator." .. short_crypto_hash(ach_num) .. " " .. code)
	end
end

local function SlashCmd_AppealPassiveAchievementCode(args)
	local code = nil
	local ach_num = nil
	code, ach_num = extract_arguments(args)

	if tostring(short_crypto_hash(ach_num)):sub(1,10) == tostring(tonumber(code)):sub(1,10) then
		for i,v in ipairs(Hardcore_Character.passive_achievements) do
			if v == _G.id_pa[ach_num] then
				return
			end
		end
		table.insert(Hardcore_Character.passive_achievements, _G.passive_achievements[_G.id_pa[ach_num]].name)
		Hardcore:Print("Appealed " .. _G.passive_achievements[_G.id_pa[ach_num]].name .. " challenge!")
	else
		Hardcore:Print("Incorrect code. Double check with a moderator." .. short_crypto_hash(ach_num) .. " " .. code)
	end
end

local function SlashCmd_AppealTradePartners(args)
	local code = nil
	code, _ = extract_arguments(args)

	if tostring(short_crypto_hash(-1)):sub(1,10) == tostring(tonumber(code)):sub(1,10) then
		Hardcore_Character.trade_partners = {}
		Hardcore:Print("Appealed Trade partners")
	else
		Hardcore:Print("Incorrect code. Double check with a moderator." .. short_crypto_hash(-1) .. " " .. code)
	end
end

local function SlashCmd_AppealDuoTrio(args)
	local code = nil
	local ach_num = nil
	code, ach_num = extract_arguments(args)

	if tostring(short_crypto_hash(-1)):sub(1,10) == tostring(tonumber(code)):sub(1,10) then
	  if Hardcore_Character.party_mode == "Failed Duo" then
		  Hardcore_Character.party_mode = "Duo"
		  Hardcore:Print("Appealed Duo status")
	  end
	  if Hardcore_Character.party_mode == "Failed Trio" then
		  Hardcore_Character.party_mode = "Trio"
		  Hardcore:Print("Appealed Trio status")
	  end
	else
	  Hardcore:Print("Incorrect code. Double check with a moderator." .. short_crypto_hash(-1) .. " " .. code)
	end
end

local function SlashCmd_AppealDuoPartner(args)
	local code = nil
	local partner = nil
	code, partner = extract_arguments(args)

	if tostring(short_crypto_hash(partner)):sub(1,10) == tostring(tonumber(code)):sub(1,10) then
		Hardcore_Character.team[1] = partner
		Hardcore:Print("Appealed Duo partner to: " .. partner)
	  end
	else
	  Hardcore:Print("Incorrect code. Double check with a moderator." .. short_crypto_hash(partner) .. " " .. code)
	end
end

local function SlashCmd_AppealTrioPartner(args)
	local code = nil
	local partner = nil
	code, partner = extract_arguments(args)

	if tostring(short_crypto_hash(partner)):sub(1,10) == tostring(tonumber(code)):sub(1,10) then
		Hardcore_Character.team[2] = partner
		Hardcore:Print("Appealed Trio partner to: " .. partner)
	  end
	else
	  Hardcore:Print("Incorrect code. Double check with a moderator." .. short_crypto_hash(partner) .. " " .. code)
	end
end

local function SlashCmd_ShowAppeals( args )

	-- DEBUG CODE:
	-- Allow the player to see appeals
	-- This is a debug function, and should be removed before release

	local usage = "Usage: /hc ShowAppeals"
	
	-- iterate through Hardcore_Character.appeals and print the date of each death
	Hardcore:Print("Appeals:")
	for i,v in ipairs(Hardcore_Character.appeals) do
		Hardcore:Print( i .. ": death - \"" .. v.death .. "\"" )
	end

end

local function SlashCmd_ShowDeaths( args )

	-- DEBUG CODE:
	-- Allow the player to see the date of deaths, so they may be appealed
	-- This is a debug function, and should be removed before release

	local usage = "Usage: /hc ShowDeaths"
	
	-- iterate through Hardcore_Character.deaths and print the date of each death
	Hardcore:Print("Deaths:")
	for i,v in ipairs(Hardcore_Character.deaths) do
		Hardcore:Print( i .. ": \"" .. v.player_dead_trigger .. "\"" )
	end

end

local function SlashCmd_AppealDeath( args )

	local usage = "Usage: /hc AppealDeath <code> \"date\""
	local code = nil
	local quoted_args = {}

	-- Check and retrieve code and command
	for substring in args:gmatch("%S+") do
		if code == nil then
			code = substring
		end
	end
	if code == nil then
		Hardcore:Print("Wrong syntax: Missing <code> argument")
		Hardcore:Print(usage)
		return
	end
	
	-- Retrieve arguments in quotes, chuck away the code and command and space between
	for arg in args:gmatch('[^\"]+') do
		table.insert( quoted_args, arg )
	end
	table.remove( quoted_args, 1 )		-- Remove the code and command
	table.remove( quoted_args, 2 )		-- Remove the empty space		

	if #quoted_args < 1 then
		Hardcore:Print("Wrong syntax: supply date string in quotes" )
		Hardcore:Print(usage)
		return
	else
		-- Look for the death with matching date
		local death_date = quoted_args[1]
		local death_found = false
		local index = 0
		for i,v in ipairs( Hardcore_Character.deaths ) do
			if Hardcore_Character.deaths[ i ].player_dead_trigger == death_date then
				death_found = true
				index = i
			end
		end
		
		-- If a matching death is found, proceed
		if death_found == true then
		
			-- Check if the hash code is correct
			local appeal_code = get_long_code( Hardcore_Character.deaths[ index ].player_dead_trigger )

			-- DEBUG CODE
			-- Hardcore:Print("Appeal code: " .. appeal_code)
			
			-- if the triplet doesn't match, refuse the appeal code
			if tonumber( code ) ~= tonumber( appeal_code ) then
				Hardcore:Print("Incorrect code. Double check with a moderator/developer." )
				return
			end

			-- Check if the appeal already exists in the table
			if Hardcore_Character.appeals then
				for i,v in ipairs( Hardcore_Character.appeals ) do
					if Hardcore_Character.appeals[ i ].death == Hardcore_Character.deaths[ index ].player_dead_trigger then
						Hardcore:Print("Appeal already exists for " .. Hardcore_Character.deaths[ index ].player_dead_trigger)
						return
					end
				end
			end
			
			-- Appeal the death
			Hardcore:Print("Appealed death on " .. Hardcore_Character.deaths[ index ].player_dead_trigger)
			if not Hardcore_Character.appeals then
				Hardcore_Character.appeals = {}
			end
			table.insert( Hardcore_Character.appeals, {["death"] = Hardcore_Character.deaths[ index ].player_dead_trigger} )
			return
		else
			Hardcore:Print( "Death on " .. quoted_args[1] .. " not found!" )
			return
		end
	end
end

local function SlashHandler(msg, editbox)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

	if cmd == "levels" then
		Hardcore:Levels()

	elseif cmd == "alllevels" then
		Hardcore:Levels(true)

	elseif cmd == "show" then
		if Hardcore_Settings.use_alternative_menu then
			Hardcore_Frame:Show()
		else
			ShowMainMenu(Hardcore_Character, Hardcore_Settings, Hardcore.DKConvert)
		end

	elseif cmd == "hide" then
		-- they can click the hide button, dont really need a command for this
		Hardcore_Frame:Hide()

	elseif cmd == "debug" then
		local debug = Hardcore:ToggleDebug()
		Hardcore:Print("Debugging set to " .. tostring(debug))

	elseif cmd == "alerts" then
		Hardcore_Toggle_Alerts()
		if Hardcore_Settings.notify then
			Hardcore:Print("Alerts enabled.")
		else
			Hardcore:Print("Alerts disabled.")
		end

	elseif cmd == "monitor" then
		Hardcore_Settings.monitor = not Hardcore_Settings.monitor
		if Hardcore_Settings.monitor then
			Hardcore:Print("Monitoring malicious users enabled.")
		else
			Hardcore:Print("Monitoring malicious users disabled.")
		end

	elseif cmd == "quitachievement" then
		local achievement_to_quit = ""
		for substring in args:gmatch("%S+") do
			achievement_to_quit = substring
		end
		if _G.achievements ~= nil and _G.achievements[achievement_to_quit] ~= nil then
			for i, achievement in ipairs(Hardcore_Character.achievements) do
				if achievement == achievement_to_quit then
					Hardcore:Print("Successfuly quit " .. achievement .. ".")
					--failure_function_executor.Fail(achievement)
					Hardcore:GetFailFunction().Fail(achievement)
				end
			end
		end

	elseif cmd == "dk" then
		-- sacrifice your current lvl 55 char to allow for making DK
		local dk_convert_option = ""
		for substring in args:gmatch("%S+") do
			dk_convert_option = substring
		end
		Hardcore:DKConvert(dk_convert_option)

	elseif cmd == "griefalert" then
		local grief_alert_option = ""
		for substring in args:gmatch("%S+") do
			grief_alert_option = substring
		end
		Hardcore:SetGriefAlertCondition(grief_alert_option)

	elseif cmd == "pronoun" then
		local pronoun_option = ""
		for substring in args:gmatch("%S+") do
			pronoun_option = substring
		end
		Hardcore:SetPronoun(pronoun_option)

	elseif cmd == "gpronoun" then
		local gpronoun_option = ""
		for substring in args:gmatch("%S+") do
			gpronoun_option = substring
		end
		Hardcore:SetGlobalPronoun(gpronoun_option)

	-- Alert debug code
	elseif cmd == "alert" and debug == true then
		local head, tail = "", {}
		for substring in args:gmatch("%S+") do
			if head == "" then
				head = substring
			else
				table.insert(tail, substring)
			end
		end

		local style, message = head, table.concat(tail, " ")
		local styleConfig
		if ALERT_STYLES[style] then
			styleConfig = ALERT_STYLES[style]
		else
			styleConfig = ALERT_STYLES.hc_red
		end

		Hardcore:ShowAlertFrame(styleConfig, message)
	
	-- appeal slash commands

	elseif cmd == "ExpectAchievementAppeal" then
		SlashCmd_Deprecated()

	elseif cmd == "AppealAchievement" then
		SlashCmd_Deprecated()
		
	elseif cmd == "AppealAchievementCode" then
		SlashCmd_AppealAchievementCode(args)

	elseif cmd == "AppealDungeonCode" then
		DungeonTrackerHandleAppealCode(args)

	elseif cmd == "AppealPassiveAchievementCode" then
		SlashCmd_AppealPassiveAchievementCode(args)
		
	elseif cmd == "SetRank" then
		SlashCmd_Deprecated()

	elseif cmd == "AppealTradePartners" then
		SlashCmd_AppealTradePartners(args)

	elseif cmd == "AppealDuoTrio" then
		SlashCmd_AppealDuoTrio(args)
	
	elseif cmd == "AppealDuoPartner" then
		SlashCmd_AppealDuoPartner(args)
	
	elseif cmd == "AppealTrioPartner" then
		SlashCmd_AppealTrioPartner(args)
	
	elseif cmd == "AppealDeath" then
		SlashCmd_AppealDeath(args)

	-- DEBUG
	elseif cmd == "ShowDeaths" then
		SlashCmd_ShowDeaths(args)

	elseif cmd == "ShowAppeals" then
		SlashCmd_ShowAppeals(args)

	else
		-- If not handled above, display some sort of help message
		Hardcore:Print("|cff00ff00Syntax:|r/hardcore [command] [options]")
		Hardcore:Print("|cff00ff00Commands:|r show hide levels alllevels alerts monitor griefalert dk")
	end
end

SLASH_HARDCORE1, SLASH_HARDCORE2 = "/hardcore", "/hc"
SlashCmdList["HARDCORE"] = SlashHandler