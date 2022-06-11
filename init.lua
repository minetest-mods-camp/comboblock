-------------------------------------------------------------------------------------
--    _________               ___.         __________.__                 __        --
--    \_   ___ \  ____   _____\_ |__   ____\______   \  |   ____   ____ |  | __    --
--    /    \  \/ /  _ \ /     \| __ \ /  _ \|    |  _/  |  /  _ \_/ ___\|  |/ /    --
--    \     \___(  <_> )  Y Y  \ \_\ (  <_> )    |   \  |_(  <_> )  \___|    <     --
--     \______  /\____/|__|_|  /___  /\____/|______  /____/\____/ \___  >__|_ \    --
--            \/             \/    \/              \/                 \/     \/    --
--                                                                                 --
--                  Orginally written/created by Pithydon/Pithy                    --
--					           Version 5.5.0.1                                     --
--                first 3 numbers version of minetest created for,                 -- 
--                   last digit mod version for MT version                         -- 
-------------------------------------------------------------------------------------

----------------------------
--        Settings        --
----------------------------
local S = minetest.get_translator(minetest.get_current_modname())
local cs = tonumber(minetest.settings:get("comboblock_scale")) or 16
local node_count = 0
local existing_node_count = 0
local to_many_nodes = false
local comboblock = {}

----------------------------
--       Functions        --
----------------------------
	------------------------------
	-- Group retrieval function --
	------------------------------
	--by blert2112 minetest forum
	local function registered_nodes_by_group(groupname)
		local result = {}
			for name, def in pairs(minetest.registered_nodes) do
				node_count = node_count + 1
				if def.groups[groupname] then
					result[#result+1] = name
				end
			end
		return result
	end

	----------------------------
	-- Add Lowpart and Resize --
	----------------------------
	-- Add "^[lowpart:50:" and resize to all image names 
	-- against source node for V2 (bottoms)
	function add_lowpart(tiles)                                       

		local name_split = string.split(tiles.name,"^")
		local new_name = ""
		local i = 1								
			while i <= #name_split do

				if string.sub(name_split[i],1,1) == "[" then
					if name_split[i] =="[transformR90" then                -- remove the rotate 90's
						new_name = new_name.."^[transformR180FY"..name_split[i] 
					else
						new_name = new_name.."^"..name_split[i]            -- catch coloring etc
					end
				else
					new_name = new_name..
							   "^[lowpart:50:"..name_split[i]..            -- overlay lower 50% 
							   "\\^[resize\\:"..cs.."x"..cs                -- resize image to comboblock scale
				
				end
				i=i+1
			end		
		return new_name                                             -- Output Single image eg ^[lowpart:50:default_cobble.png
	end                                                             -- Output Two or more image eg  ^[lowpart:50:default_cobble.png^[lowpart:50:cracked_cobble.png
	
	-------------------------
	-- Get Comboblock Name --
	-------------------------	
	local function cb_get_name(pla_tar,placer,node_c_name)   -- pas == pot_short_axis
		
		if not pla_tar.err then 
			local first_node_name = pla_tar[1]
			local second_node_name = node_c_name

			if pla_tar[1] == "clicked" then
				first_node_name = node_c_name
				second_node_name = pla_tar[1]
			end
												
			local output = "comboblock:"..first_node_name:split(":")[2].."_onc_"..second_node_name:split(":")[2]
				
			return output
		else
			minetest.chat_send_player(placer:get_player_name(), pla_tar.err) 
		end
	end	
	
	------------------------
	-- Comboblock Raycast --
	------------------------
	local function combo_raycast(placer)		
	-- calculation of eye position ripped from builtins 'pointed_thing_to_face_pos'
		local placer_pos = placer:get_pos()
		local eye_height = placer:get_properties().eye_height
		local eye_offset = placer:get_eye_offset()
		placer_pos.y = placer_pos.y + eye_height
		placer_pos = vector.add(placer_pos, eye_offset)
		
		-- get wielded item range 5 is engine default
		-- order tool/item range >> hand_range >> fallback 5
		local tool_range = placer:get_wielded_item():get_definition().range or nil					
		local hand_range	
			for key, val in pairs(minetest.registered_items) do								
				if key == "" then
					hand_range = val.range or nil
				end
			end
		local wield_range = tool_range or hand_range or 5
		
		-- determine ray end position
		local look_dir = placer:get_look_dir()
		look_dir = vector.multiply(look_dir, wield_range)
		local end_pos = vector.add(look_dir, placer_pos)

		-- get pointed_thing
		local ray = {}
		local ray = minetest.raycast(placer_pos, end_pos, false, false)
		local ray_pt = ray:next()
		
		return ray_pt
	end	

----------------------------
--       Main Code        --
---------------------------- 

-- moreblocks code part borrowed from Linuxdirk MT forums
-- Im directly updating these on the fly not using override_item
-- Not the best practice and maybe slower - review later

local mblocks = minetest.get_modpath("moreblocks")                  -- used to establish if moreblocks is loaded

	if mblocks ~= nil then
	minetest.debug("moreblocks present")

		for name, def in pairs(minetest.registered_nodes) do
			 local slab_name = string.sub (def.description, -6)
			if slab_name == "(8/16)" then                           -- The only way Ive found of identifying moreblocks half slabs
				def.groups.slab = 1                                 -- Add any slabs in moreblocks that are 8/16 to the slab group
				
				for index,_ in pairs (def.tiles)do                  -- Part borrowed from Linuxdirk
					if type(def.tiles[index]) == 'table' then
						def.tiles[index].align_style = 'world'
					else
						def.tiles[index] = {
							name = def.tiles[index],
							align_style = 'world'
										  }
					end
				end				
			end
		end
	end

-- creates an index of any node name in the group "slab"
local slab_index = registered_nodes_by_group("slab")

-- Calculate max permutations, this over estimates as we
-- don't mix glass and non-glass - in-built error margin
local max_perm = #slab_index*(#slab_index-1)
local existing_node_count = node_count

for _,v1 in pairs(slab_index) do
	
	-- set from v2_tiles node registration count
	if to_many_nodes then
		break
		
	else
		local v1_def = minetest.registered_nodes[v1]                 -- Makes a copy of the relevant node settings	
		local v1_groups = table.copy(v1_def.groups)                  -- Takes the above and places the groups into its own seperate copy
		local v1_tiles                                               -- v1 tiles table
			  v1_groups.not_in_creative_inventory = 1                -- Don't want comboblocks cluttering inventory
			  v1_groups.slab = nil                                   -- They aren't slabs so remove slab group
		
		if type(v1_def.tiles) ~= "table" then                        -- Check tiles are stored as table some old mods just have tiles = "texture.png"
			v1_tiles = {v1_def.tiles}                                -- construct table as {"texture.png"}
		else
			v1_tiles = table.copy(v1_def.tiles)                      -- copy of the node texture images
		end

		for i = 2, 6, 1 do 											 -- Checks for image names for each side, If not image name 
			if not v1_tiles[i] then									 -- then copy previous image name in: 1 = Top, 2 = Bottom, 3-6 = Sides
				v1_tiles[i] = v1_tiles[i-1]							 
			elseif mblocks ~= nil and i >= 5 then
				v1_tiles[i].name = v1_tiles[i].name:gsub("%^%[transformR90", "")  -- v1 R90 not needed as applied at V2 stage needed for moreblocks 
			end
		end
		
		
		for _,v2 in pairs(slab_index) do							  -- every slab has to be done with every other slab including itself 		                                               			
			
			if node_count > 32668 then                                -- Prevent registering more than the max 32768 - limit set 100 less than max	
				minetest.debug("WARNING:Comboblock - Max nodes"..
				" registered: "..(max_perm+existing_node_count)-node_count..
				" slab combos not registered")
				to_many_nodes = true                                  -- Outer loop break trigger
				break
				
			else	
								
				local v2_def = minetest.registered_nodes[v2]       -- this creates a second copy of all slabs and is identical to v1
				local v2_tiles
				
				if type(v2_def.tiles) ~= "table" then                        -- Check tiles are stored as table some old mods just have tiles = "texture.png"
					v2_tiles = {v2_def.tiles}                                -- construct table as {"texture.png"}
				else
					v2_tiles = table.copy(v2_def.tiles)                      -- copy of the node texture images
				end
				
				for i = 2, 6, 1 do 											 -- Checks for image names for each side, If not image name 
					if not v2_tiles[i] and i <= 2 then						 -- then copy previous image name in: 1 = Top, 2 = Bottom, 3-6 = Sides
						v2_tiles[i] = v2_tiles[i-1]							 
					
					elseif i >= 3 then				
						
						if not v2_tiles[i] then
							v2_tiles[i] = table.copy(v2_tiles[i-1])        	 -- must be table copy as we don't want a pointer
							v2_tiles[i].name = add_lowpart(v2_tiles[i])    	 -- only need to do this once as 4,5,6 are basically copy of 3
						else
							v2_tiles[i].name = add_lowpart(v2_tiles[i])	   	  -- If node has images specified for each slot have to add  string to the front of those   
						end
					end
				end				

				-- Register nodes --

				-- Very strange behaviour with orginal mod when placing glass and normal slabs ontop of each other. 
				-- Removed the ability to place glass slabs on non-glass slabs.
				-- Original Behaviour summary: 
				-- Normal slab on glass slab - slab appears as top slab with some strange graphic overlay, Unknown why - guess drawtype conflict with graphic
				-- Glass slab on normal slab - slab appears as top glass slab ie full glass block, Unknown why - guess drawtype conflict with graphic
				-- For example of above place "glass" slab on "obsidian glass" slab and vice versa this seemed minimal issue so left this combo okay
				-- Glass slab on Glass slab - black box inside this is due to orginal code having drawtype = normal for glassslab on glassslab combo
								 
				local v1_is_glass = string.find(string.lower(tostring(v1)), "glass")                          -- Slabs dont use drawtype "glasslike" in stairs due to nodebox requirement,  
				local v2_is_glass = string.find(string.lower(tostring(v2)), "glass")                          -- so using name string match but this pretty unreliable. 
																											  -- returns value nil if not otherwise returns integar see lua string.find	
																																																			  
				if v1_is_glass and v2_is_glass then                                                           -- glass_glass nodes so drawtype = glasslike
						minetest.register_node("comboblock:"..v1:split(":")[2].."_onc_"..v2:split(":")[2], {  -- registering the new combo node
							description = v1_def.description.." on "..v2_def.description,
							tiles = {v1_tiles[1].name.."^[resize:"..cs.."x"..cs, 
									 v2_tiles[2].name.."^[resize:"..cs.."x"..cs,
									 v1_tiles[3].name.."^[resize:"..cs.."x"..cs..v2_tiles[3].name,                      -- Stairs registers it's tiles slightly differently now
									 v1_tiles[4].name.."^[resize:"..cs.."x"..cs..v2_tiles[4].name,                      -- in a nested table structure and now makes use of 
									 v1_tiles[5].name.."^[resize:"..cs.."x"..cs..v2_tiles[5].name,                      -- align_style = "world" for most slabs....I think
									 v1_tiles[6].name.."^[resize:"..cs.."x"..cs..v2_tiles[6].name
									},
							paramtype = "light",
							paramtype2 = "facedir",
							drawtype = "glasslike",                                                            
							sounds = v1_def.sounds,
							groups = v1_groups,
							drop = v1,
							after_destruct = function(pos, oldnode)
								minetest.set_node(pos, {name = v2, param2 = oldnode.param2})
							end })
					
				elseif not v1_is_glass and not v2_is_glass then -- normal nodes	
																																										
						minetest.register_node("comboblock:"..v1:split(":")[2].."_onc_"..v2:split(":")[2], {
							description = v1_def.description.." on "..v2_def.description,					
							tiles = {v1_tiles[1].name.."^[resize:"..cs.."x"..cs, 
									 v2_tiles[2].name.."^[resize:"..cs.."x"..cs,
									 v1_tiles[3].name.."^[resize:"..cs.."x"..cs..v2_tiles[3].name,                                       -- Stairs registers it's tiles slightly differently now
									 v1_tiles[4].name.."^[resize:"..cs.."x"..cs..v2_tiles[4].name,                                       -- in a nested table structure and now makes use of 
									 v1_tiles[5].name.."^[resize:"..cs.."x"..cs..v2_tiles[5].name,                                       -- align_style = "world" for most slabs....I think
									 v1_tiles[6].name.."^[resize:"..cs.."x"..cs..v2_tiles[6].name
									},
							paramtype2 = "facedir",
							drawtype = "normal",                                                              
							sounds = v1_def.sounds,
							groups = v1_groups,
							drop = v1,
							after_destruct = function(pos, oldnode)
								minetest.set_node(pos, {name = v2, param2 = oldnode.param2})
							end })
				else 
					-- Can't have a nodetype as half "glasslike" and half "normal" :(
				end
				
				node_count = node_count+1
			end
		end-- v2_tiles for end


	-- Override all slabs registered on_place function	
		
		minetest.override_item(v1, {
			on_place = function(itemstack, placer, pointed_thing)			
						local pos = pointed_thing.under			
						local placer_pos = placer:get_pos()				
						local err_mix = S("Hmmmm... that wont work I can't mix glass slabs and none glass slabs")-- error txt for mixing glass/not glass
						local err_un = S("Hmmmm... The slab wont fit there, somethings in the way")              -- error txt for unknown/unexpected
						local pla_is_glass = string.find(string.lower(tostring(itemstack:get_name())), "glass")  -- itemstack item glass slab (trying to place item) - cant use drawtype as slabs are all type = nodebox
						local node_c = minetest.get_node({x=pos.x, y=pos.y, z=pos.z})                            -- node clicked
						local node_c_isslab = minetest.registered_nodes[node_c.name].groups.slab                 -- is node clicked in slab group					
						local node_c_is_glass = string.find(string.lower(tostring(node_c.name)), "glass")        -- is node clicked glass
			
				-- Setup Truth table				
				local pgn = "F"  -- Place is_Glass Node
				local cgn = "F"  -- Click is_Glass Node
				
				-- Check truth table variables and switch "T"
				if pla_is_glass then pgn = "T" end		
				if node_c_is_glass then cgn = "T" end		
						
				local comboblock_truthtable_rel_axis_horiz = {
				-- User clicked top/bottom surface slab and slab is Horizontal
				-- Place Glass, Click Glass
				-- [    T     ,       T   ] - top record table key spaced out
				["TT"] = {itemstack:get_name(), "clicked"},				   	-- New: Outcome Two
				["TF"] = {err = err_mix},                                 	-- New: Error Two
				["FT"] = {err = err_mix},                               	-- New: Error One
				["FF"] = {itemstack:get_name(), "clicked"}} 			  	-- New: Outcome One
			
				-- Used to identify potential half slab deep axis
				local  comboblock_param_side_offset = {
			  --xyz -- 1st axis = face dir, 2nd two used for placement
				["100"] = {"x","y","z"},
				["010"] = {"y","x","z"},
				["001"] = {"z","y","x"}}
			
				local comboblock_p2_axis = {
				["100"]  = {l = 4, r = 10, t = 22, b = 0, m = 15},  -- +X
				["-100"] = {l = 10, r = 4, t = 22, b = 0, m = 17},  -- -X
				["010"]  = {l = 4, r = 10, t = 19, b = 13, m = 0},  -- +Y
				["0-10"] = {l = 10, r = 4, t = 19, b = 13, m = 22}, -- -Y
				["001"]  = {l = 13, r = 19, t = 22, b = 0, m = 6},  -- +Z
				["00-1"] = {l = 19, r = 13, t = 22, b = 0, m = 8}}  -- -Z				
			
			
				-- clicked side for slabs can either be on node boundry or sunk in half
				-- node depth. Need to identify the clicked side and later check if it's 
				-- == 0 or not. Doing slabs this way means remaining code can effectively ignore 
				-- axis and param2 except for final placement.
				local pointed = combo_raycast(placer)
				local point = vector.subtract(pointed.intersection_point,pointed.under)
				local normal = pointed.intersection_normal
				local nor_string = tostring(math.abs(normal.x)..math.abs(normal.y)..math.abs(normal.z))
				local pot_short_axis = point[comboblock_param_side_offset[nor_string][1]]
				local node_ax_pos     = vector.add(pos,normal)
				local node_along_axis = minetest.get_node(node_ax_pos)                        				-- retrieve the node along +- axis for xyz 
				local node_ax_is_slab = minetest.registered_nodes[node_along_axis.name].groups.slab    		-- is node along axis in slab group	
				local node_ax_is_build = minetest.registered_nodes[node_along_axis.name].buildable_to       -- true/false
				local node_ax_is_glass = string.find(string.lower(tostring(node_along_axis.name)), "glass") -- is node glass
								
				if pot_short_axis == 0 then																	-- Clicked inside existing node with slab               				
					local outcome = comboblock_truthtable_rel_axis_horiz[pgn..cgn]	
					local combo_name = cb_get_name(outcome,placer,node_c.name)                     
					
					if outcome.err == nil then 																-- Cant mix glass and normal slabs
						minetest.swap_node(pos,{name=combo_name, param2=node_c.param2})
						itemstack:take_item(1)
					end					
					
				elseif node_ax_is_build then																-- Clicked surface and node along axis is_buildable								     					
					local hor = comboblock_param_side_offset[nor_string][3]
					local ver = comboblock_param_side_offset[nor_string][2]
					
					-- Switchs left/right when -/+ axis face clicked
					local multi = normal[comboblock_param_side_offset[nor_string][1]]
					local p2 = 0
					
					-- top/bot/left/right are fairly meaningless just labels
					if math.abs(point[hor]) < 0.2 and math.abs(point[ver]) < 0.2 then
						p2 = comboblock_p2_axis[tostring(normal.x..normal.y..normal.z)]["m"]
					
					elseif multi*point[hor] >= math.abs(point[ver]) then
						p2 = comboblock_p2_axis[tostring(normal.x..normal.y..normal.z)]["r"]
						
					elseif multi*-point[hor] >= math.abs(point[ver]) then
						p2 = comboblock_p2_axis[tostring(normal.x..normal.y..normal.z)]["l"]
					
					elseif point[ver] >= math.abs(point[hor]) then
						p2 = comboblock_p2_axis[tostring(normal.x..normal.y..normal.z)]["t"]						

					elseif -point[ver] >= math.abs(point[hor]) then
						p2 = comboblock_p2_axis[tostring(normal.x..normal.y..normal.z)]["b"]						

					end
					
					minetest.item_place(itemstack, placer, pointed_thing, p2)
					
				elseif node_ax_is_slab then																    -- Clicked surface and node along axis is_slab				
					-- use node_along_axis instead of node clicked 
					-- recalc our clicked glass node true/false using node_along_axis as sub
					if node_ax_is_glass then cgn = "T" end
					
					-- same process as our 1st if now but sub in node_along_axis details
					local outcome = comboblock_truthtable_rel_axis_horiz[pgn..cgn]	
					local combo_name = cb_get_name(outcome,placer,node_along_axis.name)
					
					if outcome.err == nil then 																-- Cant mix glass and normal slabs
						minetest.swap_node(node_ax_pos,{name=combo_name, param2=node_along_axis.param2})
						itemstack:take_item(1)	  
					end
					
				else													-- Last error catch										
					local name = placer:get_player_name()
					minetest.chat_send_player(name ,err_un)     		-- New:Unknown Case
				
				end	
			
			if not creative.is_enabled_for(placer:get_player_name()) then					   
				return itemstack
			end		
		end })
	end
end
