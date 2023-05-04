
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
		debug = not debug
		Hardcore:Print("Debugging set to " .. tostring(debug))
		-- expand the mobs to allow for anti-grief testing in elwynn
		GRIEFING_MOBS = {
			["Anvilrage Overseer"] = 1,
			["Infernal"] = 1,
			["Teremus the Devourer"] = 1,
			["Volchan"] = 1,
			["Twilight Fire Guard"] = 1,
			["Hakkari Oracle"] = 1,
			["Forest Spider"] = 1,
			["Mangy Wolf"] = 1,
			["Searing Ghoul"] = 1,
		}
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
			Hardcore:Monitor("Monitoring malicious users enabled.")
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
					failure_function_executor.Fail(achievement)
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
	elseif cmd == "ExpectAchievementAppeal" then
		Hardcore:Print("Allowing a hc mod to appeal achievements.")
		expecting_achievement_appeal = true
		C_Timer.After(60.0, function() -- one minute to receive achievement appeal
			expecting_achievement_appeal = false
			Hardcore:Print("No longer allowing a hc mod to appeal achievements.")
		end)
	elseif cmd == "AppealAchievement" then
		if MOD_CHAR_NAMES[UnitName("player")] == nil then
			return
		end -- character must be moderator
		local target = nil
		local achievement_to_appeal = nil
		for substring in args:gmatch("%S+") do
			if target == nil then
				target = substring
			elseif achievement == nil then
				achievement_to_appeal = substring
				break
			end
		end
		if target == nil then
			Hardcore:Print("Wrong syntax: target is nil")
			return
		end

		if achievement_to_appeal == nil then
			Hardcore:Print("Wrong syntax: achievement is nil")
			return
		end

		if _G.achievements[achievement_to_appeal] == nil then
			Hardcore:Print("Wrong syntax: achievement isn't found for " .. achievement_to_appeal)
			return
		end

		if CTL then
			local commMessage = COMM_COMMANDS[9] .. COMM_COMMAND_DELIM .. achievement_to_appeal
			Hardcore:Print("Appealing " .. achievement_to_appeal .. " for " .. target)
			CTL:SendAddonMessage("ALERT", COMM_NAME, commMessage, "WHISPER", target)
		end
	elseif cmd == "AppealAchievementCode" then
		local code = nil
		local ach_num = nil
		for substring in args:gmatch("%S+") do
		  if code == nil then
			code = substring
		  else
			ach_num = substring
		  end
		end
		if code == nil then
			Hardcore:Print("Wrong syntax: Missing first argument")
			return
		end
		if ach_num == nil or _G.ach then
			Hardcore:Print("Wrong syntax: Missing second argument")
			return
		end

		if _G.achievements[_G.id_a[ach_num]] == nil then
			Hardcore:Print("Wrong syntax: achievement isn't found for " .. ach_num)
			return
		end

		if tostring(GetCode(ach_num)):sub(1,10) == tostring(tonumber(code)):sub(1,10) then
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
		  Hardcore:Print("Incorrect code. Double check with a moderator." .. GetCode(ach_num) .. " " .. code)
		end
	elseif cmd == "AppealDungeonCode" then
		DungeonTrackerHandleAppealCode( args )
	elseif cmd == "AppealPassiveAchievementCode" then
		local code = nil
		local ach_num = nil
		for substring in args:gmatch("%S+") do
		  if code == nil then
			code = substring
		  else
			ach_num = substring
		  end
		end
		if code == nil then
			Hardcore:Print("Wrong syntax: Missing first argument")
			return
		end
		if ach_num == nil or _G.ach then
			Hardcore:Print("Wrong syntax: Missing second argument")
			return
		end

		if _G.passive_achievements[_G.id_pa[ach_num]] == nil then
			Hardcore:Print("Wrong syntax: achievement isn't found for " .. ach_num)
			return
		end

		if tostring(GetCode(ach_num)):sub(1,10) == tostring(tonumber(code)):sub(1,10) then
		  for i,v in ipairs(Hardcore_Character.passive_achievements) do
		    if v == _G.id_pa[ach_num] then
		      return
		    end
		  end
		  table.insert(Hardcore_Character.passive_achievements, _G.passive_achievements[_G.id_pa[ach_num]].name)
		  Hardcore:Print("Appealed " .. _G.passive_achievements[_G.id_pa[ach_num]].name .. " challenge!")
		else
		  Hardcore:Print("Incorrect code. Double check with a moderator." .. GetCode(ach_num) .. " " .. code)
		end
	elseif cmd == "SetRank" then
		local code = nil
		local ach_num = nil
		local rank = nil
		local iters = 0
		for substring in args:gmatch("%S+") do
		  if iters == 0 then
			code = substring
		  elseif iters == 1 then
			ach_num = substring
		  elseif iters == 2 then
			rank = substring
		  end
		  iters = iters + 1
		end
		if code == nil then
			Hardcore:Print("Wrong syntax: Missing first argument")
			return
		end
		if ach_num == nil or _G.ach then
			Hardcore:Print("Wrong syntax: Missing second argument")
			return
		end
		if rank == nil then
			Hardcore:Print("Wrong syntax: Missing third argument")
			return
		end

		if tostring(GetCode(-1)):sub(1,10) == tostring(tonumber(code)):sub(1,10) then
		  Hardcore_Settings.rank_type = rank
		  Hardcore:Print("Set rank to " .. rank)
		else
		  Hardcore:Print("Incorrect code. Double check with a moderator." .. GetCode(-1) .. " " .. code)
		end
	elseif cmd == "AppealTradePartners" then
		local code = nil
		local ach_num = nil
		local iters = 0
		for substring in args:gmatch("%S+") do
		  if iters == 0 then
			code = substring
		  elseif iters == 1 then
			ach_num = substring
		  end
		  iters = iters + 1
		end
		if code == nil then
			Hardcore:Print("Wrong syntax: Missing first argument")
			return
		end
		if ach_num == nil or _G.ach then
			Hardcore:Print("Wrong syntax: Missing second argument")
			return
		end

		if tostring(GetCode(-1)):sub(1,10) == tostring(tonumber(code)):sub(1,10) then
		  Hardcore_Character.trade_partners = {}
		  Hardcore:Print("Appealed Trade partners")
		else
		  Hardcore:Print("Incorrect code. Double check with a moderator." .. GetCode(-1) .. " " .. code)
		end
	elseif cmd == "AppealDuoTrio" then
		local code = nil
		local ach_num = nil
		local iters = 0
		for substring in args:gmatch("%S+") do
		  if iters == 0 then
			code = substring
		  elseif iters == 1 then
			ach_num = substring
		  end
		  iters = iters + 1
		end
		if code == nil then
			Hardcore:Print("Wrong syntax: Missing first argument")
			return
		end
		if ach_num == nil or _G.ach then
			Hardcore:Print("Wrong syntax: Missing second argument")
			return
		end

		if tostring(GetCode(-1)):sub(1,10) == tostring(tonumber(code)):sub(1,10) then
		  if Hardcore_Character.party_mode == "Failed Duo" then
			  Hardcore_Character.party_mode = "Duo"
			  Hardcore:Print("Appealed Duo status")
		  end
		  if Hardcore_Character.party_mode == "Failed Trio" then
			  Hardcore_Character.party_mode = "Trio"
			  Hardcore:Print("Appealed Trio status")
		  end
		else
		  Hardcore:Print("Incorrect code. Double check with a moderator." .. GetCode(-1) .. " " .. code)
		end
	else
		-- If not handled above, display some sort of help message
		Hardcore:Print("|cff00ff00Syntax:|r/hardcore [command] [options]")
		Hardcore:Print("|cff00ff00Commands:|r show hide levels alllevels alerts monitor griefalert dk")
	end
end

SLASH_HARDCORE1, SLASH_HARDCORE2 = "/hardcore", "/hc"
SlashCmdList["HARDCORE"] = SlashHandler
