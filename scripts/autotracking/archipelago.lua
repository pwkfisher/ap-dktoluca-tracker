-- this is an example/default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via their ids
-- it will also keep track of the current index of on_item messages in CUR_INDEX
-- addition it will keep track of what items are local items and which one are remote using the globals LOCAL_ITEMS and GLOBAL_ITEMS
-- this is useful since remote items will not reset but local items might
-- if you run into issues when touching A LOT of items/locations here, see the comment about Tracker.AllowDeferredLogicUpdate in autotracking.lua
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/tab_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/visibility_mapping.lua")

CUR_INDEX = -1
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

-- resets an item to its initial state
function resetItem(item_code, item_type)
	local obj = Tracker:FindObjectForCode(item_code)
	if obj then
		item_type = item_type or obj.Type
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("resetItem: resetting item %s of type %s", item_code, item_type))
		end
		if item_type == "toggle" or item_type == "toggle_badged" then
			obj.Active = false
		elseif item_type == "progressive" or item_type == "progressive_toggle" then
			obj.CurrentStage = 0
			obj.Active = false
		elseif item_type == "consumable" then
			obj.AcquiredCount = 0
		elseif item_type == "custom" then
			-- your code for your custom lua items goes here
		elseif item_type == "static" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("resetItem: tried to reset static item %s", item_code))
		elseif item_type == "composite_toggle" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format(
				"resetItem: tried to reset composite_toggle item %s but composite_toggle cannot be accessed via lua." ..
				"Please use the respective left/right toggle item codes instead.", item_code))
		elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("resetItem: unknown item type %s for code %s", item_type, item_code))
		end
	elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("resetItem: could not find item object for code %s", item_code))
	end
end

-- advances the state of an item
function incrementItem(item_code, item_type)
	local obj = Tracker:FindObjectForCode(item_code)
	if obj then
		item_type = item_type or obj.Type
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("incrementItem: code: %s, type %s", item_code, item_type))
		end
		if item_type == "toggle" or item_type == "toggle_badged" then
			obj.Active = true
		elseif item_type == "progressive" or item_type == "progressive_toggle" then
			if obj.Active then
				obj.CurrentStage = obj.CurrentStage + 1
			else
				obj.Active = true
			end
		elseif item_type == "consumable" then
			obj.AcquiredCount = obj.AcquiredCount + obj.Increment
		elseif item_type == "custom" then
			-- your code for your custom lua items goes here
		elseif item_type == "static" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("incrementItem: tried to increment static item %s", item_code))
		elseif item_type == "composite_toggle" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format(
				"incrementItem: tried to increment composite_toggle item %s but composite_toggle cannot be access via lua." ..
				"Please use the respective left/right toggle item codes instead.", item_code))
		elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("incrementItem: unknown item type %s for code %s", item_type, item_code))
		end
	elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("incrementItem: could not find object for code %s", item_code))
	end
end

-- apply everything needed from slot_data, called from onClear
function apply_slot_data(slot_data)
-- put any code here that slot_data should affect (toggling setting items for example)
end

-- called right after an AP slot is connected
function onClear(slot_data)
	-- use bulk update to pause logic updates until we are done resetting all items/locations
	Tracker.BulkUpdate = true	
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
	end
	CUR_INDEX = -1
	-- reset locations
	for _, mapping_entry in pairs(LOCATION_MAPPING) do
		for _, location_table in ipairs(mapping_entry) do
			if location_table then
				local location_code = location_table[1]
				if location_code then
					if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
						print(string.format("onClear: clearing location %s", location_code))
					end
					if location_code:sub(1, 1) == "@" then
						local obj = Tracker:FindObjectForCode(location_code)
						if obj then
							obj.AvailableChestCount = obj.ChestCount
						elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
							print(string.format("onClear: could not find location object for code %s", location_code))
						end
					else
						-- reset hosted item
						local item_type = location_table[2]
						resetItem(location_code, item_type)
					end
				elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
					print(string.format("onClear: skipping location_table with no location_code"))
				end
			elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
				print(string.format("onClear: skipping empty location_table"))
			end
		end
	end
	-- reset items
	for _, mapping_entry in pairs(ITEM_MAPPING) do
		for _, item_table in ipairs(mapping_entry) do
			if item_table then
				local item_code = item_table[1]
				local item_type = item_table[2]
				if item_code then
					resetItem(item_code, item_type)
				elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
					print(string.format("onClear: skipping item_table with no item_code"))
				end
			elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
				print(string.format("onClear: skipping empty item_table"))
			end
		end
	end

	PLAYER_ID = Archipelago.PlayerNumber or -1
	TEAM_NUMBER = Archipelago.TeamNumber or 0

	if slot_data["lost_world_rocks"] then
        Tracker:FindObjectForCode("lostworldrocksrequired").AcquiredCount = slot_data["lost_world_rocks"]
	end
	if slot_data["krock_boss_tokens"] then
		Tracker:FindObjectForCode("bosstokensrequired").AcquiredCount = slot_data["krock_boss_tokens"]
	end
	if slot_data["dk_coin_checks"] == 1 then
		Tracker:FindObjectForCode("dkcoinchecks").Active = true
	end
	if slot_data["kong_checks"] == 1 then
		Tracker:FindObjectForCode("kongchecks").Active = true
	end
	if slot_data["banana_checks"] == 1 then
		Tracker:FindObjectForCode("bananasanity").Active = true
	end
	if slot_data["coin_checks"] == 1 then
		Tracker:FindObjectForCode("coinsanity").Active = true
	end
	if slot_data["balloon_checks"] == 1 then
		Tracker:FindObjectForCode("balloonsanity").Active = true
	end

	if slot_data["required_galleon_levels"] then
		if slot_data["required_galleon_levels"] == 1 then
			Tracker:FindObjectForCode("ggbossaccess").AcquiredCount = 1
		elseif slot_data["required_galleon_levels"] == 2 then
			Tracker:FindObjectForCode("ggbossaccess").AcquiredCount = 2
		elseif slot_data["required_galleon_levels"] == 3 then
			Tracker:FindObjectForCode("ggbossaccess").AcquiredCount = 3
		elseif slot_data["required_galleon_levels"] == 4 then
			Tracker:FindObjectForCode("ggbossaccess").AcquiredCount = 4
		elseif slot_data["required_galleon_levels"] == 5 then
			Tracker:FindObjectForCode("ggbossaccess").AcquiredCount = 5
		end
	end

	if slot_data["required_cauldron_levels"] then
		if slot_data["required_cauldron_levels"] == 1 then
			Tracker:FindObjectForCode("ccbossaccess").AcquiredCount = 1
		elseif slot_data["required_cauldron_levels"] == 2 then
			Tracker:FindObjectForCode("ccbossaccess").AcquiredCount = 2
		elseif slot_data["required_cauldron_levels"] == 3 then
			Tracker:FindObjectForCode("ccbossaccess").AcquiredCount = 3
		elseif slot_data["required_cauldron_levels"] == 4 then
			Tracker:FindObjectForCode("ccbossaccess").AcquiredCount = 4
		elseif slot_data["required_cauldron_levels"] == 5 then
			Tracker:FindObjectForCode("ccbossaccess").AcquiredCount = 5
		end
	end

	if slot_data["required_quay_levels"] then
		if slot_data["required_quay_levels"] == 1 then
			Tracker:FindObjectForCode("kqbossaccess").AcquiredCount = 1
		elseif slot_data["required_quay_levels"] == 2 then
			Tracker:FindObjectForCode("kqbossaccess").AcquiredCount = 2
		elseif slot_data["required_quay_levels"] == 3 then
			Tracker:FindObjectForCode("kqbossaccess").AcquiredCount = 3
		elseif slot_data["required_quay_levels"] == 4 then
			Tracker:FindObjectForCode("kqbossaccess").AcquiredCount = 4
		elseif slot_data["required_quay_levels"] == 5 then
			Tracker:FindObjectForCode("kqbossaccess").AcquiredCount = 5
		elseif slot_data["required_quay_levels"] == 5 then
			Tracker:FindObjectForCode("kqbossaccess").AcquiredCount = 5
		end
	end

	if slot_data["required_kremland_levels"] then
		if slot_data["required_kremland_levels"] == 1 then
			Tracker:FindObjectForCode("kkbossaccess").AcquiredCount = 1
		elseif slot_data["required_kremland_levels"] == 2 then
			Tracker:FindObjectForCode("kkbossaccess").AcquiredCount = 2
		elseif slot_data["required_kremland_levels"] == 3 then
			Tracker:FindObjectForCode("kkbossaccess").AcquiredCount = 3
		elseif slot_data["required_kremland_levels"] == 4 then
			Tracker:FindObjectForCode("kkbossaccess").AcquiredCount = 4
		elseif slot_data["required_kremland_levels"] == 5 then
			Tracker:FindObjectForCode("kkbossaccess").AcquiredCount = 5
		elseif slot_data["required_kremland_levels"] == 5 then
			Tracker:FindObjectForCode("kkbossaccess").AcquiredCount = 5
		end
	end

	if slot_data["required_gulch_levels"] then
		if slot_data["required_gulch_levels"] == 1 then
			Tracker:FindObjectForCode("glgbossaccess").AcquiredCount = 1
		elseif slot_data["required_gulch_levels"] == 2 then
			Tracker:FindObjectForCode("glgbossaccess").AcquiredCount = 2
		elseif slot_data["required_gulch_levels"] == 3 then
			Tracker:FindObjectForCode("glgbossaccess").AcquiredCount = 3
		elseif slot_data["required_gulch_levels"] == 4 then
			Tracker:FindObjectForCode("glgbossaccess").AcquiredCount = 4
		elseif slot_data["required_gulch_levels"] == 5 then
			Tracker:FindObjectForCode("glgbossaccess").AcquiredCount = 5
		elseif slot_data["required_gulch_levels"] == 5 then
			Tracker:FindObjectForCode("glgbossaccess").AcquiredCount = 5
		end
	end

	if slot_data["required_keep_levels"] then
		if slot_data["required_keep_levels"] == 1 then
			Tracker:FindObjectForCode("krkbossaccess").AcquiredCount = 1
		elseif slot_data["required_keep_levels"] == 2 then
			Tracker:FindObjectForCode("krkbossaccess").AcquiredCount = 2
		elseif slot_data["required_keep_levels"] == 3 then
			Tracker:FindObjectForCode("krkbossaccess").AcquiredCount = 3
		elseif slot_data["required_keep_levels"] == 4 then
			Tracker:FindObjectForCode("krkbossaccess").AcquiredCount = 4
		elseif slot_data["required_keep_levels"] == 5 then
			Tracker:FindObjectForCode("krkbossaccess").AcquiredCount = 5
		elseif slot_data["required_keep_levels"] == 5 then
			Tracker:FindObjectForCode("krkbossaccess").AcquiredCount = 5
		end
	end

	if slot_data["required_krock_levels"] == 1 then
		Tracker:FindObjectForCode("tfkbossaccess").AcquiredCount = 1
	end
	
    if slot_data["goal"] then
        if slot_data["goal"] == 1 then
            Tracker:FindObjectForCode("goal").CurrentStage = 0
        elseif slot_data["goal"] == 2 then
            Tracker:FindObjectForCode("goal").CurrentStage = 1
        elseif slot_data["goal"] == 3 then
            Tracker:FindObjectForCode("goal").CurrentStage = 2
        end
    end
	if slot_data["logic"] then
        if slot_data["logic"] == 0 then
            Tracker:FindObjectForCode("logic").CurrentStage = 0
        elseif slot_data["logic"] == 1 then
            Tracker:FindObjectForCode("logic").CurrentStage = 1
        elseif slot_data["logic"] == 2 then
            Tracker:FindObjectForCode("logic").CurrentStage = 2
        end
    end

	if slot_data["level_connections"] then
		local level_connection_data = slot_data["level_connections"]
		for LevelArea, LevelCode in pairs(BOSS_MAPPING) do
			for LevelMap, Area in pairs(level_connection_data) do
				if Area == LevelArea then
					-- Perform actions based on LevelMap and LevelCode
					if LevelMap == "Barbos' Barrier: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 6
					elseif LevelMap == "Bleak's House: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 5
					elseif LevelMap == "KAOS Karnage: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 4
					elseif LevelMap == "Squirt's Showdown: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 3
					elseif LevelMap == "Arich's Ambush: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 2
					elseif LevelMap == "Belcha's Barn: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 1
					else
						print(LevelMap .. " -> No matching LevelCode found")
					end
				end
			end
		end
		for LevelArea, LevelCode in pairs(LEVEL_MAPPING) do
			for LevelMap, Area in pairs(level_connection_data) do
				if Area == LevelArea then
					-- Perform actions based on LevelMap and LevelCode
					if LevelMap == "Lakeside Limbo: Map" or LevelMap == "Doorstop Dash: Map" or LevelMap == "Tidal Trouble: Map" or LevelMap == "Skidda's Row: Map" or LevelMap == "Murky Mill: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 1
					elseif LevelMap == "Barrel Shield Bust-Up: Map" or LevelMap == "Riverside Race: Map" or LevelMap == "Squeals on Wheels: Map" or LevelMap == "Springin' Spiders: Map" or LevelMap == "Bobbing Barrel Brawl: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 2
					elseif LevelMap == "Bazza's Blockade: Map" or LevelMap == "Rocket Barrel Ride: Map" or LevelMap == "Kreeping Klasps: Map" or LevelMap == "Tracker Barrel Trek: Map" or LevelMap == "Fish Food Frenzy: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 3
					elseif LevelMap == "Fire-Ball Frenzy: Map" or LevelMap == "Demolition Drain-Pipe: Map" or LevelMap == "Ripsaw Rage: Map" or LevelMap == "Blazing Bazukas: Map" or LevelMap == "Low-G Labyrinth: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 4
					elseif LevelMap == "Krevice Kreepers: Map" or LevelMap == "Tearaway Toboggan: Map" or LevelMap == "Barrel Drop Bounce: Map" or LevelMap == "Krac-Shot Krock: Map" or LevelMap == "Lemguin Lunge: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 5
					elseif LevelMap == "Buzzer Barrage: Map" or LevelMap == "Kong-Fused Cliffs: Map" or LevelMap == "Floodlit Fish: Map" or LevelMap == "Pot Hole Panic: Map" or LevelMap == "Ropey Rumpus: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 6
					elseif LevelMap == "Konveyor Rope Klash: Map" or LevelMap == "Creepy Caverns: Map" or LevelMap == "Lightning Look-Out: Map" or LevelMap == "Koindozer Klamber: Map" or LevelMap == "Poisonous Pipeline: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 7						
					elseif LevelMap == "Stampede Sprint: Map" or LevelMap == "Criss Kross Cliffs: Map" or LevelMap == "Tyrant Twin Tussle: Map" or LevelMap == "Swoopy Salvo: Map" or LevelMap == "Rocket Rush: Map" then
						Tracker:FindObjectForCode(LevelCode).CurrentStage = 8
					else
					print(LevelMap .. " -> No matching LevelCode found")
					end
				end
			end
		end
	end


	apply_slot_data(slot_data)
	LOCAL_ITEMS = {}
	GLOBAL_ITEMS = {}
	-- manually run snes interface functions after onClear in case we need to update them (i.e. because they need slot_data)
	if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
		-- add snes interface functions here
	end
	Tracker.BulkUpdate = false

	

	if Archipelago.PlayerNumber>-1 then
		print (string.format("Current slot data is", PLAYER_ID, TEAM_NUMBER))
		EVENT_ID="dkc2_current_map_"..TEAM_NUMBER.."_"..PLAYER_ID
		CLEARCOUNT_ID="dkc2_clear_count_"..TEAM_NUMBER.."_"..PLAYER_ID
		print(string.format("SET NOTIFY %s",EVENT_ID))
		print(string.format("LEVELS SEEN %s",CLEARCOUNT_ID))
		Archipelago:SetNotify({EVENT_ID})
		Archipelago:SetNotify({CLEARCOUNT_ID})
	end

	Tracker:FindObjectForCode("tab_switch").Active = 1
end





-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
	end
	if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
		return
	end
	if index <= CUR_INDEX then
		return
	end
	local is_local = player_number == Archipelago.PlayerNumber
	CUR_INDEX = index;
	local mapping_entry = ITEM_MAPPING[item_id]
	if not mapping_entry then
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("onItem: could not find item mapping for id %s", item_id))
		end
		return
	end
	for _, item_table in pairs(mapping_entry) do
		if item_table then
			local item_code = item_table[1]
			local item_type = item_table[2]
			if item_code then
				incrementItem(item_code, item_type)
				-- keep track which items we touch are local and which are global
				if is_local then
					if LOCAL_ITEMS[item_code] then
						LOCAL_ITEMS[item_code] = LOCAL_ITEMS[item_code] + 1
					else
						LOCAL_ITEMS[item_code] = 1
					end
				else
					if GLOBAL_ITEMS[item_code] then
						GLOBAL_ITEMS[item_code] = GLOBAL_ITEMS[item_code] + 1
					else
						GLOBAL_ITEMS[item_code] = 1
					end
				end
			elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
				print(string.format("onClear: skipping item_table with no item_code"))
			end
		elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("onClear: skipping empty item_table"))
		end
	end
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
		print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
	end
	-- track local items via snes interface
	if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
		-- add snes interface functions for local item tracking here
	end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("called onLocation: %s, %s", location_id, location_name))
	end
	if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
		return
	end
	local mapping_entry = LOCATION_MAPPING[location_id]
	if not mapping_entry then
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("onLocation: could not find location mapping for id %s", location_id))
		end
		return
	end
	for _, location_table in pairs(mapping_entry) do
		if location_table then
			local location_code = location_table[1]
			if location_code then
				local obj = Tracker:FindObjectForCode(location_code)
				if obj then
					if location_code:sub(1, 1) == "@" then
						obj.AvailableChestCount = obj.AvailableChestCount - 1
					else
						-- increment hosted item
						local item_type = location_table[2]
						incrementItem(location_code, item_type)
					end
				elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
					print(string.format("onLocation: could not find object for code %s", location_code))
				end
			elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
				print(string.format("onLocation: skipping location_table with no location_code"))
			end
		elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("onLocation: skipping empty location_table"))
		end
	end
end

-- called when a locations is scouted
function onScout(location_id, location_name, item_id, item_name, item_player)
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name,
			item_player))
	end
	-- not implemented yet :(
end

-- called when a bounce message is received
function onBounce(json)
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("called onBounce: %s", dump_table(json)))
	end
	-- your code goes here
end

function onNotify(key, value, old_value)
    print(string.format("onNotify: %s", key))
    if key:find("dkc2_clear_count_") then
        processClearCounts(value)
    else
        updateEvents(value)
    end
end

function onNotifyLaunch(key, value)
    print(string.format("onNotifyLaunch: %s", key))
    if key:find("dkc2_clear_count_") then
        processClearCounts(value)
    else
        updateEvents(value)
    end
end

function processClearCounts(clear_counts)
	world_clear_1 = 0
    world_clear_2 = 0
    world_clear_3 = 0
    world_clear_4 = 0
    world_clear_5 = 0
    world_clear_6 = 0
	world_clear_7 = 0

    if type(clear_counts) == "table" then
        for i, count in ipairs(clear_counts) do
			
            -- You can assign to individual variables if needed
            _G["world_clear_" .. i] = count
            print(string.format("World %d clear count: %d", i, count))
			if world_clear_1 > 0 then
				Tracker:FindObjectForCode("ggclears").AcquiredCount = world_clear_1
			end
			if world_clear_2 > 0 then
				Tracker:FindObjectForCode("ccclears").AcquiredCount = world_clear_2
			end
			if world_clear_3 > 0 then
				Tracker:FindObjectForCode("kqclears").AcquiredCount = world_clear_3
			end
			if world_clear_4 > 0 then
				Tracker:FindObjectForCode("kkclears").AcquiredCount = world_clear_4
			end
			if world_clear_5 > 0 then
				Tracker:FindObjectForCode("glgclears").AcquiredCount = world_clear_5
			end
			if world_clear_6 > 0 then
				Tracker:FindObjectForCode("krkclears").AcquiredCount = world_clear_6
			end
			if world_clear_7 > 0 then
				Tracker:FindObjectForCode("tfkclears").AcquiredCount = world_clear_7
			end
        end
    else
        print("Expected table for clear counts, got:", type(clear_counts))
    end
end

function updateEvents(value)
	if value ~= nil then
		print(string.format("updateEvents %x",value))
		local tabswitch = Tracker:FindObjectForCode("tab_switch")
		Tracker:FindObjectForCode("cur_level_id").CurrentStage = value
		if tabswitch.Active then
			if TAB_MAPPING[value] then
				CURRENT_ROOM = TAB_MAPPING[value]
                for str in string.gmatch(CURRENT_ROOM, "([^/]+)") do
				    print(string.format("Updating ID %x to Tab %s",value,str))
                    Tracker:UiHint("ActivateTab", str)
                end
				print(string.format("Updating ID %x to Tab %s",value,CURRENT_ROOM))
			else
				print(string.format("Failed to find ID %x",value))
			end
		end
	end
end

Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
Archipelago:AddSetReplyHandler("notify handler", onNotify)
Archipelago:AddRetrievedHandler("notify launch handler", onNotifyLaunch)