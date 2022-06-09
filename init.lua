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
--=======================================================================--
--=======================================================================--
-- standard rotate and place function from stairs mod MT v5.2.0 to 
-- maintain standard stairs behaviour for slab placement (LGPLv2.1)
-- Start LGPLv2.1 code block see license.txt
local function rotate_and_place(itemstack, placer, pointed_thing)
	local p0 = pointed_thing.under
	local p1 = pointed_thing.above
	local param2 = 0

	if placer then
		local placer_pos = placer:get_pos()
		if placer_pos then
			param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
		end
		 
		local finepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
		local fpos = finepos.y % 1

		if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
				or (fpos < -0.5 and fpos > -0.999999999) then
			param2 = param2 + 20
			if param2 == 21 then
				param2 = 23
			elseif param2 == 23 then
				param2 = 21
			end
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing, param2)
end
-- End of LGPLv2.1 code block see license.txt
--=======================================================================--
--=======================================================================--

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
	---------------------
	-- Slab Place Side --
	---------------------
	function side_place(itemstack,placer,pointed_thing,node,nepos,err_mix,err_un)
			local tar_node_name = node.name                                                  -- node offset by +1/-1 along relevant axis of clicked node
			local pla_node_name = itemstack:get_name()                                       -- node the player wants to place
			local pla_is_glass = string.find(string.lower(tostring(itemstack:get_name())), "glass")
			local node_is_slab = minetest.registered_nodes[node.name].groups.slab            -- is node (relative)infront clicked slab
			local node_is_glass = string.find(string.lower(tostring(node.name)), "glass")    -- is node (relative)infront clicked glass
			local node_is_flora = minetest.get_item_group(node.name, "flora")                -- is node (relative)infront clicked flora

			
		if node_is_slab == 1 and                                                             -- Clicked a Slab
		  (node.param2 >= 20 and node.param2 <= 23) and                                      -- top slab (@ top of node space)
		   node_is_glass and                                                                 -- node is glass
		   pla_is_glass then                                                                 -- placing item is glass
					minetest.swap_node(nepos, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})					
					itemstack:take_item(1)                                                   -- Nil callbacks on swap node mnaual remove 1 item

		elseif node_is_slab == 1 and                                                         -- Clicked a Slab
		  (node.param2 >= 20 and node.param2 <= 23) and                                      -- top slab (@ top of node space)
		   not node_is_glass and                                                             -- node is not glass
		   not pla_is_glass then                                                             -- placing item is not glass
					minetest.swap_node(nepos, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})					
					itemstack:take_item(1)                                                   -- Nil callbacks on swap node mnaual remove 1 item
					
		elseif node_is_slab == 1 and                                                         -- Clicked a Slab 
			   node.param2 <= 19 and                                                          -- bottom slab (@ bottom of node space)
			   node_is_glass and                                                             -- node is glass
			   pla_is_glass then                                                             -- placing item is glass		   
					minetest.swap_node(nepos, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = node.param2})							
					itemstack:take_item(1)                                                   -- Nil callbacks on swap node mnaual remove 1 item 

		elseif node_is_slab == 1 and                                                         -- Clicked a Slab 
			   node.param2 <= 19 and                                                          -- bottom slab (@ bottom of node space)
			   not node_is_glass and                                                         -- node is not glass
			   not pla_is_glass then                                                         -- placing item is not glass		   
					minetest.swap_node(nepos, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = node.param2})							
					itemstack:take_item(1)                                                   -- Nil callbacks on swap node mnaual remove 1 item 
					
		elseif node_is_slab == nil and                                                       -- Clicked not a slab                                                               
			   tar_node_name == "air" then                                                   -- Node to side is air
					rotate_and_place(itemstack, placer, pointed_thing)                       -- do stairs mod place function                       

		elseif node_is_slab == nil and                                                       -- Clicked not a slab                                                               
			   node_is_flora > 0 then                                                        -- Node to side is air
					rotate_and_place(itemstack, placer, pointed_thing)                       -- do stairs mod place function 

	--Below here feedback to player you cant mix glass slabs and none glass slabs so they know this is feature
		elseif node_is_slab == 1 and                                                         -- Clicked a Slab
		  (node.param2 >= 0 and node.param2 <= 23) and                                       -- Any slab in any orientation (redundant check?)
		   node_is_glass and                                                                 -- node is glass
		   not pla_is_glass then                                                             -- placing item is not glass
					minetest.chat_send_player(placer:get_player_name(), err_mix)				

		elseif node_is_slab == 1 and                                                         -- Clicked a Slab
		  (node.param2 >= 0 and node.param2 <= 23) and                                       -- Any slab in any orientation (redundant check?)
		   not node_is_glass and                                                             -- node is not glass
		   pla_is_glass then                                                                 -- placing item is not glass
					minetest.chat_send_player(placer:get_player_name(), err_mix)


					
	-- Last error catch to account for the unknown/unexpected				
		else                                                                                 
			 minetest.chat_send_player(placer:get_player_name(), err_un)
		end
	end
	
	------------------------------------
	-- Get Comboblock Name and Param2 --
	------------------------------------	
	local function cb_get_name_p2(t_b,pla_tar,placer) 
		local output
		
		if not pla_tar.err then
			if t_b > 0 then	
				local first_node_name = pla_tar[1][1]
				local second_node_name = pla_tar[2][1]								
				local param2 = pparam2
				
				if pla_tar[2][2] == "a" then -- use node_a.param2 when tile in space above ie were we are placing
					param2 = node_a.param2
				end 
													
				output = {"comboblock:"..first_node_name:split(":")[2].."_onc_"..second_node_name:split(":")[2], param2}
				
			else -- tb < 0
				local first_node_name = pla_tar[2][1]
				local second_node_name = pla_tar[1][1]								
				local param2 = pparam2
				
				-- flip to bottom node names when clicking bottom
				if pla_tar[2][2] == "a" then
					first_node_name = node_b.name
					param2 = node_b.param2 			-- use node_b.param2 when tile in space below ie were we are placing
				
				elseif pla_tar[1][2] == "a" then
					second_node_name = node_b.name
				end
				
				output = {"comboblock:"..first_node_name:split(":")[2].."_onc_"..second_node_name:split(":")[2], param2}		
			end
			return output
		else
			minetest.chat_send_player(placer:get_player_name(), pla_tar.err) 
		end
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
						local pos1 = pointed_thing.above				
						local exact_pos = minetest.pointed_thing_to_face_pos(placer,pointed_thing)
						local fpos = exact_pos.y % 1
						local pparam2 = minetest.dir_to_facedir(vector.subtract(pos,pos1))
						local placer_pos = placer:get_pos()				
						local player_n = placer:get_player_name()
						local err_mix = S("Hmmmm... that wont work I can't mix glass slabs and none glass slabs")-- error txt for mixing glass/not glass
						local err_un = S("Hmmmm... The slab wont fit there, somethings in the way")              -- error txt for unknown/unexpected
						local pla_is_glass = string.find(string.lower(tostring(itemstack:get_name())), "glass")  -- itemstack item glass slab (trying to place item) - cant use drawtype as slabs are all type = nodebox
						local node_c = minetest.get_node({x=pos.x, y=pos.y, z=pos.z})                            -- node clicked
						local node_c_isslab = minetest.registered_nodes[node_c.name].groups.slab                 -- is node clicked in slab group					

			if fpos == 0.5 then

				local node_c_is_glass = string.find(string.lower(tostring(node_c.name)), "glass")        -- is node clicked glass
				
				local node_a = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})                          -- node above clicked node
				local node_a_isslab = minetest.registered_nodes[node_a.name].groups.slab                 -- is node above in slab group
				local node_a_is_glass = string.find(string.lower(tostring(node_a.name)), "glass")        -- is node above glass
				local node_a_is_flora = minetest.get_item_group(node_a.name, "flora")                    -- is node above flora
				
				local node_b = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})                          -- node below clicked node
				local node_b_isslab = minetest.registered_nodes[node_b.name].groups.slab                 -- is node below in slab group					
				local node_b_is_glass = string.find(string.lower(tostring(node_b.name)), "glass")        -- is node below glass	
				local node_b_is_flora = minetest.get_item_group(node_b.name, "flora")                    -- is node below flora				
				local t_b = exact_pos.y - pos.y                                                          -- work out if clicked bottom or top side of slab	

			
				-- Setup Truth tables
				
				-- Note 1: Truth tables are "top" surface click centric, the function
				-- cb_get_name_p2 flips and changes values as needed for bottom
				-- surface clicked - This was easier than duplicating truth tables.
				-- If theres a problem with a bottom placement it maybe function related
				-- not test table config related.
				
				-- Note 2: It wasn't until I built up the outcomes for test tables that the 
				-- sameness between slab_other_orient and nil_slab became apparent.
				
				local pgn = "F"  -- Place is_Glass Node
				local cgn = "F"  -- Click is_Glass Node
				local agn = "F"  -- Above is_Glass Node
				local ap2 = "F"  -- Above Glass P2 value - Not Horizontal Slab at bottom
				local bgn = "F"  -- Below is_Glass Node 
				local bp2 = "F"  -- Below Glass P2 value
				
				-- Check truth table variables and switch "T"
				if pla_is_glass then pgn = "T" end		
				if node_c_is_glass then cgn = "T" end		
				if node_a_is_glass then agn = "T" end
				if node_b_is_glass then bgn = "T" end
				
				-- Horizontal Slab at Top
				if node_a.param2 >= 20 and node_a.param2 <= 23 then ap2 = "T" end
				
				-- Horizontal Slab at Bottom
				if node_b.param2 >= 0 and node_b.param2 <= 3  then  bp2 = "T" end
						
				local comboblock_truthtable_slab_horizontal = {
				-- User clicked top/bottom surface slab and slab is Horizontal
				-- Place Glass, Click Glass
				-- [    T     ,       T   ] - top record table key spaced out
				["TT"] = {{itemstack:get_name(),"p"}, {node_c.name,"c"}},   -- New: Outcome Two
				["TF"] = {err = err_mix},                                 	-- New: Error Two
				["FT"] = {err = err_mix},                               	-- New: Error One
				["FF"] = {{itemstack:get_name(),"p"}, {node_c.name,"c"}}}   -- New: Outcome One

				local comboblock_truthtable_slab_other_orient = {
				-- User clicked top/bottom surface slab and slab in any other Orientation
				-- Place Glass, Above/Below Node Glass, Above/Below P2 eg
				-- [    T     ,       T               ,    T          ] - top record table key spaced out
				["TTT"] = {{node_a.name,"a"}, {itemstack:get_name(),"p"}},   -- New: Outcome Six
				["TTF"] = {{itemstack:get_name(),"p"}, {node_a.name,"a"}},   -- New: Outcome Seven
				["TFT"] = {err = err_mix},                                	 -- New: Error Four
				["TFF"] = {err = err_mix},                                	 -- New: Error Four
				["FTT"] = {err = err_mix},                                	 -- New: Error Three
				["FTF"] = {err = err_mix},                                	 -- New: Error Three
				["FFT"] = {{node_a.name,"a"}, {itemstack:get_name(),"p"}},   -- New: Outcome Four
				["FFF"] = {{itemstack:get_name(),"p"}, {node_a.name,"a"}}}   -- New: Outcome Five		

				local comboblock_truthtable_nil_slab = {
				-- User didn't click a slab but top/bottom surface of a node
				-- Place Glass, Above/Below Node Glass, Above/Below P2 eg
				-- [    T     ,       T               ,    T          ] - top record table key spaced out
				["TTT"] = {{node_a.name,"a"}, {itemstack:get_name(),"p"}},   -- "New: Outcome Eleven"
				["TTF"] = {{itemstack:get_name(),"p"}, {node_a.name,"a"}},   -- "New: Outcome Twelve"
				["TFT"] = {err = err_mix},                               	 -- "New: Error Six"
				["TFF"] = {err = err_mix},                                	 -- "New: Error Six"
				["FTT"] = {err = err_mix},                                	 -- "New: Error Five"
				["FTF"] = {err = err_mix},                                	 -- "New: Error Five"
				["FFT"] = {{node_a.name,"a"},{itemstack:get_name(),"p"}},	 -- "New: Outcome Nine"
				["FFF"] = {{itemstack:get_name(),"p"}, {node_a.name,"a"}}}	 -- "New: Outcome Ten"
			
			  -- Top and Bottom Surface clicking could be rationalilised into a single 
			  -- section, however to aid interpretation/understanding left seperate. 
			  
			  --[[Clicked Top Surface]]--					
				if t_b > 0 then												-- Top surface		
					if node_c_isslab then									-- If we are clicking a slab, calculations are more complex.
						if node_c.param2 <= 3 then							-- Slab in bottom half of node - Horizontal = Param2:0-3      									
							local outcome = comboblock_truthtable_slab_horizontal[pgn..cgn]					
							local n_p2 = cb_get_name_p2(t_b,outcome,placer)
							
							minetest.swap_node(pos,{name=n_p2[1], param2=n_p2[2]})
							itemstack:take_item(1)

						
						else												-- False = Slab in top half of node all - Horizontal/Vertical = Param2:4-23 
							if node_a.name == "air" or             			-- remove air and flora case - simple
							node_a_is_flora > 0 then
								minetest.item_place(itemstack, placer, pointed_thing, param2)
								--minetest.debug(outcome)                     -- New:Outcome Three
							
							elseif node_a_isslab then						-- Theres a slab in the above node 
								local outcome = comboblock_truthtable_slab_other_orient[pgn..agn..ap2]
								local n_p2 = cb_get_name_p2(t_b,outcome,placer)
								
								minetest.swap_node(pos,{name=n_p2[1], param2=n_p2[2]})
								itemstack:take_item(1)
								
							else
								local name = placer:get_player_name()
								minetest.chat_send_player(name ,err_un)     -- New:Unknown Case
							end				
						end			
					else													-- We are not clicking a slab
						if node_a.name == "air" or							-- remove air and flora case - simple
						node_a_is_flora > 0 then
							minetest.item_place(itemstack, placer, pointed_thing, param2)					
							--minetest.debug(outcome)                   		-- New:Outcome Eight
						
						elseif node_a_isslab then							-- Theres a slab in the above node 
							local outcome = comboblock_truthtable_nil_slab[pgn..agn..ap2]
							local n_p2 = cb_get_name_p2(t_b,outcome,placer)
							
							minetest.swap_node(pos,{name=n_p2[1], param2=n_p2[2]})
							itemstack:take_item(1)
							
						else
							local name = placer:get_player_name()
							minetest.chat_send_player(name ,err_un)     	-- New:Unknown Case
						end						
					end
					
			  --[[Clicked Bottom Surface]]--	  										
				elseif t_b < 0 then											-- Bottom surface
					if node_c_isslab then                                   -- If we are clicking a slab, calculations are more complex.
						if node_c.param2 >= 20 and node_c.param2 <= 23 then -- Slab in top half of node - Horizontal = Param2:20-23
							local outcome = comboblock_truthtable_slab_horizontal[pgn..cgn]
							local n_p2 = cb_get_name_p2(t_b,outcome,placer)
							
							minetest.swap_node(pos,{name=n_p2[1], param2=n_p2[2]})
							itemstack:take_item(1)
							
						else												-- False = Slab in bottom half of node all - Horizontal/Vertical = Param2:0-19
							if node_b.name == "air" or                      -- remove air and flora case - simple
							node_b_is_flora > 0 then
								local outcome = itemstack:get_name()
								local param2 = pparam2+20   
								
								minetest.item_place(itemstack, placer, pointed_thing, param2)												
							  --minetest.debug(outcome)                     -- New:Outcome Three
							
							elseif node_b_isslab then                       -- Theres a slab in the below node 
								local outcome = comboblock_truthtable_slab_other_orient[pgn..bgn..bp2]
								local n_p2 = cb_get_name_p2(t_b,outcome,placer)
								
								minetest.swap_node(pos,{name=n_p2[1], param2=n_p2[2]})
								itemstack:take_item(1)
								
							else
								local name = placer:get_player_name()
								minetest.chat_send_player(name ,err_un)     -- New:Unknown Case
							end									
						end
					else                                                    -- We are not clicking a slab
						if node_b.name == "air" or							-- remove air and flora case - simple
						node_b_is_flora > 0 then
							local outcome = itemstack:get_name()
							local param2 = pparam2+20   
							
							minetest.item_place(itemstack, placer, pointed_thing, param2)						
						  --minetest.debug(outcome)                   		-- New:Outcome Eight

						elseif node_b_isslab then							-- Theres a slab in the above node 
							local outcome = comboblock_truthtable_nil_slab[pgn..bgn..bp2]
							local n_p2 = cb_get_name_p2(t_b,outcome,placer)
							
							minetest.swap_node(pos,{name=n_p2[1], param2=n_p2[2]})
							itemstack:take_item(1)
							
						else
							local name = placer:get_player_name()
							minetest.chat_send_player(name ,err_un)     	-- New:Unknown Case
						end	
					end
				else
					local name = placer:get_player_name()
					minetest.chat_send_player(name ,err_un)     			-- New:Unknown Case
				end
				
		  --[[Clicked Node Side]]--
			else															
				-- Used to set Param offset
				local comboblock_param_side_offset = {
				[0] = {x=0 ,z=-1},
				[1] = {x=-1,z=0 },
				[2] = {x=0 ,z=1 },
				[3] = {x=1 ,z=0 }}
			
				if node_c_isslab and									-- If we are clicking a slab standing upright
				   node_c.param2 >= 4 and node_c.param2 <= 19 then
					local node = minetest.get_node(pos)
					side_place(itemstack,placer,pointed_thing,node,pos,err_mix,err_un)
					--minetest.debug("New: Side Slab on slab")
				
				elseif pparam2 <= 3	then									-- If we are clicking a node
					local offset = comboblock_param_side_offset[pparam2] 
					local new_pos = {x=pos.x+offset.x, y=pos.y, z=pos.z+offset.z}
					local node = minetest.get_node(new_pos)
					
						  side_place(itemstack,placer,pointed_thing,node,new_pos,err_mix,err_un)
						--minetest.debug("New: Side Slab on node ".. minetest.pos_to_string(new_pos))
				
				else													-- Last error catch										
					local name = placer:get_player_name()
					minetest.chat_send_player(name ,err_un)     		-- New:Unknown Case
				end	


			end
			
			if not creative.is_enabled_for(placer:get_player_name()) then					   
				return itemstack
			end		
		end })
	end
end
