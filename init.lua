-------------------------------------------------------------------------------------
--    _________               ___.         __________.__                 __        --
--    \_   ___ \  ____   _____\_ |__   ____\______   \  |   ____   ____ |  | __    --
--    /    \  \/ /  _ \ /     \| __ \ /  _ \|    |  _/  |  /  _ \_/ ___\|  |/ /    --
--    \     \___(  <_> )  Y Y  \ \_\ (  <_> )    |   \  |_(  <_> )  \___|    <     --
--     \______  /\____/|__|_|  /___  /\____/|______  /____/\____/ \___  >__|_ \    --
--            \/             \/    \/              \/                 \/     \/    --
--                                                                                 --
--                  Orginally written/created by Pithydon/Pithy                    --
--					           Version 5.2.0.3                                     --
--     first 3 numbers version of minetest created for, last digit mod version     -- 
-------------------------------------------------------------------------------------

----------------------------
--        Settings        --
----------------------------
local S = minetest.get_translator(minetest.get_current_modname())
local cs = tonumber(minetest.settings:get("comboblock_scale")) or 16
local node_count = 0

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


-- group retrieval function by blert2112 minetest forum
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

-- Add "^[lowpart:50:" and resize to all image names against source node for V2 (bottoms)
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


-- place slab against side of node
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
	
----------------------------
--       Main Code        --
---------------------------- 

-- moreblocks code part borrowed from Linuxdirk MT forums
-- Im directly updating these on the fly not using override_item
-- Not the best practice and maybe slower - review later

local mblocks = minetest.get_modpath("moreblocks")              -- used to establish if moreblocks is loaded
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
			--[[for k,v in pairs (def.tiles)do                 -- debug loop
				minetest.debug("name"..tostring(def.tiles[k].name).." align:"..def.tiles[tonumber(k)].align_style)				
			end]]--				
		end
	end
end


-- creates an index of any node name in the group "slab"
local slab_index = registered_nodes_by_group("slab")


for k,v1 in pairs(slab_index) do

	if node_count > 32768 then
		minetest.debug("WARNING:Comboblock - Max nodes registered: '"..v1.."' slab combos not registered")
	else
		local v1_def = minetest.registered_nodes[v1]                 -- Makes a copy of the relevant node settings	
		local v1_groups = table.copy(v1_def.groups)                  -- Takes the above and places the groups into its own seperate copy
		v1_groups.not_in_creative_inventory = 1
		v1_groups.slab = nil
		local v1_tiles = table.copy(v1_def.tiles)                    -- The first group of tiles ie v1
				--[[for k,v in pairs(v1_tiles) do                    -- Bunch of debug I(S01) added to get my head around data structure.
					minetest.debug("k",tostring(k)," v", tostring(v))
					minetest.debug ("direct:",v1_tiles[k].name)					
					for k2, v2 in pairs(v) do
						minetest.debug("k2",tostring(k2),"v2",tostring(v2))
					end	
				end	]]--
		if not v1_tiles[2] then                                     -- This bit checks if we have an image name 
			v1_tiles[2] = v1_tiles[1]                               -- for each side of the node, if it dosen't it 
		end                                                         -- copies the previous one in
		if not v1_tiles[3] then                                     -- 1 = Top, 2 = Bottom, 3-6 = Sides
			v1_tiles[3] = v1_tiles[2]	
		end
		
		if not v1_tiles[4] then
			v1_tiles[4] = v1_tiles[3]
		end
		
		if not v1_tiles[5] then
			v1_tiles[5] = v1_tiles[4]
		elseif mblocks ~= nil then
			v1_tiles[5].name = v1_tiles[5].name:gsub("%^%[transformR90", "")  -- v1 R90 not needed as applied at V2 stage needed for moreblocks 

		end
		if not v1_tiles[6] then
			v1_tiles[6] = v1_tiles[5]
		elseif mblocks ~= nil then
			v1_tiles[6].name = v1_tiles[6].name:gsub("%^%[transformR90", "")  -- v1 R90 not needed as applied at V2 stage needed for moreblocks 

		end
		for _,v2 in pairs(slab_index) do		                                               
				local v2_def = minetest.registered_nodes[v2]       -- this creates a second copy of all slabs and is identical to v1
				local v2_tiles = table.copy(v2_def.tiles)

				if not v2_tiles[2] then
					v2_tiles[2] = v2_tiles[1]
				end
							
				if not v2_tiles[3] then
					v2_tiles[3] = table.copy(v2_tiles[2])          -- must be table copy do not use "=" 
					v2_tiles[3].name = add_lowpart(v2_tiles[3])    -- only need to do this once as 4,5,6 are basically copy of 3
				else
					v2_tiles[3].name= add_lowpart(v2_tiles[3])	   -- If node has images specified for each slot have to add  string to the front of those    			
				end

				
				if not v2_tiles[4] then
					v2_tiles[4] = v2_tiles[3]			
				else
					v2_tiles[4].name= add_lowpart(v2_tiles[4])				
				end
				
				if not v2_tiles[5] then
					v2_tiles[5] = v2_tiles[4]
				else
					v2_tiles[5].name= add_lowpart(v2_tiles[5])			
				end
				
				if not v2_tiles[6] then
					v2_tiles[6] = v2_tiles[5]
				else
					v2_tiles[6].name= add_lowpart(v2_tiles[6])					
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
					minetest.register_node("comboblock:"..v1:split(":")[2].."_onc_"..v2:split(":")[2], {  -- registering the new combo nodes
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
						end
					})
				
			elseif v1_is_glass or v2_is_glass then
				-- minetest.debug("nothing")
				-- Can't have a nodetype as half "glasslike" and half "normal" :(
				
			else  
																							-- normal nodes	
	--minetest.debug (v1_tiles[1].name.." "..v2_tiles[1].name)																		
					minetest.register_node("comboblock:"..v1:split(":")[2].."_onc_"..v2:split(":")[2], {  -- registering the new combo nodes
						description = v1_def.description.." on "..v2_def.description,					
						tiles = {v1_tiles[1].name.."^[resize:"..cs.."x"..cs, 
								 v2_tiles[2].name.."^[resize:"..cs.."x"..cs,
								 v1_tiles[3].name.."^[resize:"..cs.."x"..cs..v2_tiles[3].name,                                       -- Stairs registers it's tiles slightly differently now
								 v1_tiles[4].name.."^[resize:"..cs.."x"..cs..v2_tiles[4].name,                                       -- in a nested table structure and now makes use of 
								 v1_tiles[5].name.."^[resize:"..cs.."x"..cs..v2_tiles[5].name,                                       -- align_style = "world" for most slabs....I think
								 v1_tiles[6].name.."^[resize:"..cs.."x"..cs..v2_tiles[6].name
								},
						paramtype = "light",
						paramtype2 = "facedir",
						drawtype = "normal",                                                              
						sounds = v1_def.sounds,
						groups = v1_groups,
						drop = v1,
						after_destruct = function(pos, oldnode)
							minetest.set_node(pos, {name = v2, param2 = oldnode.param2})
						end,
						
						--[[on_rightclick = function(pos, node, player, itemstack, pointed_thing)
							local exact_pos = minetest.pointed_thing_to_face_pos(placer,pointed_thing)
							local fpos = exact_pos.y % 1
							minetest.chat_send_all(node.param2.."   "..fpos)
						end]]--

					})
			end				
		end


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
					local err_mix = "Hmmmm... that wont work I can't mix glass slabs and none glass slabs"   -- error txt for mixing glass/not glass
					local err_un = "Hmmmm... The slab wont fit there, somethings in the way"                 -- error txt for unknown/unexpected
					local pla_is_glass = string.find(string.lower(tostring(itemstack:get_name())), "glass")  -- itemstack item glass slab (trying to place item)
					local node_c = minetest.get_node({x=pos.x, y=pos.y, z=pos.z})                            -- node clicked
					local node_c_isslab = minetest.registered_nodes[node_c.name].groups.slab                 -- is node clicked in slab group	

				if fpos == 0.5 then                                                                          -- clicked a flat top or bottom surface

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

		--[[Clicked Top Surface]]--					
						if t_b > 0 then                                                                      -- Top Surface
							 if node_c_isslab == 1  and                                                      -- Clicked a Slab
								not node_c_is_glass and                                                      -- Clicked not glass slab
								not pla_is_glass    and                                                      -- Placing Slab not Glass
								node_c.param2 <= 3 then                                                      -- Clicked bottom slab (slab in bottom of node)
										local tar_node_name = node_c.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item

							elseif node_c_isslab == 1  and                                                      -- Clicked a Slab
								   node_c_is_glass     and                                                      -- Clicked glass slab
								   pla_is_glass        and                                                      -- Placing slab glass   
								   node_c.param2 <= 3 then                                                      -- Clicked bottom slab
										local tar_node_name = node_c.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node manual remove 1 item
										
							elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
								  (node_c.param2 >= 4 and node_c.param2 <= 23) and                           -- top slab + all orientations vertically                                                                  
								   node_a.name == "air" then                                                  -- Node above is air                       									
										local param2 = pparam2                                  
										minetest.item_place(itemstack, placer, pointed_thing, param2)

							elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
								  (node_c.param2 >= 4 and node_c.param2 <= 23) and                            -- top slab + all orientations vertically                                                                 
								   node_a_is_flora > 0 then                                                   -- Node above is flora                       									
										local param2 = pparam2                                  
										minetest.item_place(itemstack, placer, pointed_thing, param2)
										
							elseif node_c_isslab == 1  and                                                    -- Clicked a Slab						
								  (node_c.param2 >= 4 and node_c.param2 <= 23) and                            -- top slab + all orientations vertically                                                                   
								   node_a_isslab == 1  and                                                    -- Node above is another slab assumed 
								  (node_a.param2 >= 20 and node_a.param2 <= 23)  and                          -- Node above is placed Horizontal @ top
								   not node_a_is_glass and                                                    -- Node above not glass slab
								   not pla_is_glass    then                                                   -- Placing Slab not glass 							   
										local tar_node_name = node_a.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})							   
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
										
							elseif node_c_isslab == 1  and                                                    -- Clicked a Slab						
								  (node_c.param2 >= 4 and node_c.param2 <= 23) and                            -- top slab + all orientations vertically                                                                  
								   node_a_isslab == 1  and                                                    -- Node above is another slab assumed
								  (node_a.param2 >= 4 and node_a.param2 <= 19)  and                           -- Node above is not placed Horizontal
								   not node_a_is_glass and                                                    -- Node above not glass slab
								   not pla_is_glass    then                                                   -- Placing Slab not glass 							   
										local tar_node_name = node_a.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = node_a.param2})							   
										itemstack:take_item(1) 
																			
							elseif node_c_isslab == 1  and                                                    -- Clicked a Slab						
								  (node_c.param2 >= 4 and node_c.param2 <= 23) and                            -- top slab + all orientations vertically                                                                   
								   node_a_isslab == 1  and                                                    -- Node above is another slab assumed 
								  (node_a.param2 >= 20 and node_a.param2 <= 23)  and                          -- Node above is placed Horizontal @ top
								   node_a_is_glass and                                                        -- Node above glass slab
								   pla_is_glass    then                                                       -- Placing Slab glass 							   
										local tar_node_name = node_a.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})							   
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
										
							elseif node_c_isslab == 1  and                                                    -- Clicked a Slab						
								  (node_c.param2 >= 4 and node_c.param2 <= 23) and                            -- top slab + all orientations vertically                                                                   
								   node_a_isslab == 1  and                                                    -- Node above is another slab assumed
								  (node_a.param2 >= 4 and node_a.param2 <= 19)  and                           -- Node above is not placed Horizontal
								   node_a_is_glass and                                                        -- Node above glass slab
								   pla_is_glass    then                                                       -- Placing Slab glass 							   
										local tar_node_name = node_a.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = node_a.param2})							   
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
										
							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
								   node_a_isslab == 1   and                                                   -- Node above is a slab assumed 
								  (node_a.param2 >= 20 and node_a.param2 <= 23)  and                          -- Node above is placed Horizontal @ top								   
								   not node_a_is_glass  and                                                   -- Node above not glass slab
								   not pla_is_glass     then                                                  -- Placing Slab not glass 							   
										local tar_node_name = node_a.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item

							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
								   node_a_isslab == 1   and                                                   -- Node above is a slab assumed @ top
								  (node_a.param2 >= 4 and node_a.param2 <= 19)  and                           -- Node above is not placed Horizontal							   
								   not node_a_is_glass  and                                                   -- Node above not glass slab
								   not pla_is_glass     then                                                  -- Placing Slab not glass 							   
										local tar_node_name = node_a.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = node_a.param2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item									
										
							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
								   node_a_isslab == 1   and                                                   -- Node above is a slab assumed @ top
								  (node_a.param2 >= 20 and node_a.param2 <= 23)  and                          -- Node above is placed Horizontal
								   node_a_is_glass      and                                                   -- Node above glass slab
								   pla_is_glass         then                                                  -- Placing Slab glass 							   
										local tar_node_name = node_a.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
							
							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
								   node_a_isslab == 1   and                                                   -- Node above is a slab assumed @ top
								  (node_a.param2 >= 4 and node_a.param2 <= 19)  and                           -- Node above is not placed Horizontal
								   node_a_is_glass      and                                                   -- Node above glass slab
								   pla_is_glass         then                                                  -- Placing Slab glass 							   
										local tar_node_name = node_a.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = node_a.param2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
							
							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                               
								   node_a.name == "air" then                                                  -- Node above is air                                                     							   
										local param2 = pparam2                                  
										minetest.item_place(itemstack, placer, pointed_thing, param2)

							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                               
								   node_a_is_flora > 0  then                                                  -- Node above is flora - allows build on grass/flowers etc                                                      							   
										local param2 = pparam2                                  
										minetest.item_place(itemstack, placer, pointed_thing, param2)
							
							--Below here Feedback to player you cant mix glass slabs and none glass slabs so they know this is feature
							--Seperated for easy reading (turn to function later above/below almost identical)
							
							elseif node_c_isslab == 1  and                                                      -- Clicked a Slab
								   node_c_is_glass     and                                                      -- Clicked glass slab
								   not pla_is_glass    and                                                      -- Placing not slab glass   
								   node_c.param2 <= 3 then                                                      -- Clicked bottom slab
										minetest.chat_send_player(player_n, err_mix)                       

							elseif node_c_isslab == 1  and                                                      -- Clicked a Slab (reverse of above)
								   not node_c_is_glass and                                                      -- Clicked not glass slab
								   pla_is_glass        and                                                      -- Placing slab glass   
								   node_c.param2 <= 3 then                                                      -- Clicked bottom slab
										minetest.chat_send_player(player_n, err_mix)
										
							elseif node_c_isslab == 1  and                                                    -- Clicked a Slab 					
								  (node_c.param2 >= 4 and node_c.param2 <= 23) and                            -- top slab + all orientations vertically                                                                   
								   node_a_isslab == 1  and                                                    -- Node above is another slab assumed @ top
								   node_a_is_glass     and                                                    -- Node above glass slab
								   not pla_is_glass    then                                                   -- Placing not glass							   
										minetest.chat_send_player(player_n, err_mix)

							elseif node_c_isslab == 1  and                                                    -- Clicked a Slab (reverse of the above)						
								  (node_c.param2 >= 4 and node_c.param2 <= 23) and                            -- top slab + all orientations vertically                                                                   
								   node_a_isslab == 1  and                                                    -- Node above is another slab assumed @ top
								   not node_a_is_glass and                                                    -- Node above not glass slab
								   pla_is_glass    then                                                       -- Placing glass							   
										minetest.chat_send_player(player_n, err_mix)	

							elseif node_c_isslab == nil and                                                   -- clicked not slab 					                                                                
								   node_a_isslab == 1   and                                                   -- Node above is another slab assumed @ top
								   node_a_is_glass      and                                                   -- Node above glass slab
								   not pla_is_glass    then                                                   -- Placing not glass							   
										minetest.chat_send_player(player_n, err_mix)

							elseif node_c_isslab == nil and                                                   -- Clicked not Slab (reverse of the above)						                                                                
								   node_a_isslab == 1   and                                                   -- Node above is another slab assumed @ top
								   not node_a_is_glass  and                                                   -- Node above glass slab
								   pla_is_glass         then                                                  -- Placing not glass							   
										minetest.chat_send_player(player_n, err_mix)										
							
							-- Last error catch to account for the unknown/unexpected
							else                                                                              
								 minetest.chat_send_player(player_n, err_un)

							end	
							
		--[[Clicked Bottom Surface]]--	  										
						elseif t_b < 0 then                                                                   -- Bottom Surface	
						
							if  node_c_isslab == 1 and                                                        -- Clicked a Slab
								not node_c_is_glass and                                                       -- Clicked not glass slab
								not pla_is_glass    and                                                       -- Placing Slab not glass 						
								(node_c.param2 >= 20 and node_c.param2 <= 23) then                            -- top slab (slab in top of node)  								
									local tar_node_name = node_c.name
									local pla_node_name = itemstack:get_name()
									minetest.swap_node(pos, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})
									itemstack:take_item(1)                                                    -- Nil callbacks on swap node manual remove 1 item
	 
							elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
								   not node_c_is_glass and                                                    -- Clicked glass slab
								   not pla_is_glass    and                                                    -- Placing Slab glass 						
								  (node_c.param2 >= 20 and node_c.param2 <= 23) then                          -- top slab (slab in top of node)  								
									   local tar_node_name = node_c.name
									   local pla_node_name = itemstack:get_name()
									   minetest.swap_node(pos, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})
									   itemstack:take_item(1)                                                 -- Nil callbacks on swap node manual remove 1 item
	 
							elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
								  (node_c.param2 >= 0 and node_c.param2 <= 19) and                            -- bottom slab + all orientations vertically                                                                 
								   node_b.name == "air" then                                                  -- Node below is air                       
										local param2 = pparam2+20                                  
										minetest.item_place(itemstack, placer, pointed_thing, param2)								

							elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
								  (node_c.param2 >= 0 and node_c.param2 <= 19) and                            -- bottom slab + all orientations vertically                                                                  
								   node_b_is_flora > 0 then                                                   -- Node below is flora                       
										local param2 = pparam2+20                                  
										minetest.item_place(itemstack, placer, pointed_thing, param2)	
										
							elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
								  (node_c.param2 >= 0 and node_c.param2 <= 19) and                            -- bottom slab + all orientations vertically                                                                   
								   node_b_isslab == 1 and                                                     -- Node below is another slab assumed @ bottom
								  (node_b.param2 >= 0 and node_b.param2 <= 3)  and                            -- Node below is placed Horizontal							   
								   not node_b_is_glass and                                                    -- Node below not glass slab
								   not pla_is_glass   then                                                    -- Placing Slab not glass 							   
										local tar_node_name = node_b.name
										local pla_node_name = itemstack:get_name()
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node manual remove 1 item									

							elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
								  (node_c.param2 >= 0 and node_c.param2 <= 19) and                            -- bottom slab + all orientations vertically                                                                   
								   node_b_isslab == 1 and                                                     -- Node below is another slab assumed @ bottom
								  (node_b.param2 >= 4 and node_b.param2 <= 19)  and                           -- Node below is not placed Horizontal							   
								   not node_b_is_glass and                                                    -- Node below not glass slab
								   not pla_is_glass   then                                                    -- Placing Slab not glass 							   
										local tar_node_name = node_b.name
										local pla_node_name = itemstack:get_name()
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = node_b.param2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node manual remove 1 item									

							elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
								  (node_c.param2 >= 0 and node_c.param2 <= 19) and                            -- bottom slab + all orientations vertically                                                                   
								   node_b_isslab == 1 and                                                     -- Node below is another slab assumed @ bottom
								  (node_b.param2 >= 0 and node_b.param2 <= 3)  and                            -- Node below is placed Horizontal							   
								   node_b_is_glass and                                                        -- Node below glass slab
								   pla_is_glass   then                                                        -- Placing Slab glass 							   
										local tar_node_name = node_b.name
										local pla_node_name = itemstack:get_name()
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item

							elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
								  (node_c.param2 >= 0 and node_c.param2 <= 19) and                            -- bottom slab + all orientations vertically                                                                 
								   node_b_isslab == 1 and                                                     -- Node below is another slab assumed @ bottom
								  (node_b.param2 >= 4 and node_b.param2 <= 19)  and                           -- Node below is placed not Horizontal							   
								   node_b_is_glass and                                                        -- Node below glass slab
								   pla_is_glass   then                                                        -- Placing Slab glass 							   
										local tar_node_name = node_b.name
										local pla_node_name = itemstack:get_name()
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = node_b.param2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
										
							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
								   node_b_isslab == 1 and                                                     -- Node below is a slab assumed @ bottom
								  (node_b.param2 >= 0 and node_b.param2 <= 3)  and                            -- Node below is placed Horizontal							   
								   not node_b_is_glass and                                                    -- Node below not glass slab
								   not pla_is_glass   then                                                    -- Placing Slab not glass
										local tar_node_name = node_b.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
										
							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
								   node_b_isslab == 1 and                                                     -- Node below is a slab assumed @ bottom
								  (node_b.param2 >= 4 and node_b.param2 <= 19)  and                           -- Node below is placed not Horizontal							   
								   not node_b_is_glass and                                                    -- Node below not glass slab
								   not pla_is_glass   then                                                    -- Placing Slab not glass
										local tar_node_name = node_b.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = node_b.param2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item

							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
								   node_b_isslab == 1 and                                                     -- Node below is a slab assumed @ bottom
								  (node_b.param2 >= 0 and node_b.param2 <= 3)  and                            -- Node below is placed Horizontal								   
								   node_b_is_glass and                                                        -- Node below glass slab
								   pla_is_glass   then                                                        -- Placing Slab glass
										local tar_node_name = node_b.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
										
							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
								   node_b_isslab == 1 and                                                     -- Node below is a slab assumed @ bottom
								  (node_b.param2 >= 4 and node_b.param2 <= 19)  and                           -- Node below is not placed Horizontal								   
								   node_b_is_glass and                                                        -- Node below glass slab
								   pla_is_glass   then                                                        -- Placing Slab glass
										local tar_node_name = node_b.name
										local pla_node_name = itemstack:get_name()								
										minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = node_b.param2})
										itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
										
							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                               
								   node_b.name == "air" then                                                  -- Node below is air                                                                                                                        
										local param2 = pparam2+20
										minetest.item_place(itemstack, placer, pointed_thing, param2)

							elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                               
								   node_b_is_flora > 0 then                                                   -- Node below is flora                                                                                                                        
										local param2 = pparam2+20
										minetest.item_place(itemstack, placer, pointed_thing, param2)	

							--Below here Feedback to player you cant mix glass slabs and none glass slabs so they know this is feature
							--Seperated for easy reading (turn to function later above/below almost identical)
							
							elseif node_c_isslab == 1  and                                                      -- Clicked a Slab
								   node_c_is_glass     and                                                      -- Clicked glass slab
								   not pla_is_glass    and                                                      -- Placing not slab glass   
								  (node_c.param2 >= 20 and node_c.param2 <= 23) then                            -- Clicked top slab in node
										minetest.chat_send_player(player_n, err_mix)                       

							elseif node_c_isslab == 1  and                                                      -- Clicked a Slab (reverse of above)
								   not node_c_is_glass and                                                      -- Clicked not glass slab
								   pla_is_glass        and                                                      -- Placing slab glass   
								  (node_c.param2 >= 20 and node_c.param2 <= 23) then                            -- Clicked top slab
										minetest.chat_send_player(player_n, err_mix)
										
							elseif node_c_isslab == 1  and                                                    -- Clicked a Slab 					
								  (node_c.param2 >= 0 and node_c.param2 <= 19) and                            -- bottom slab + all orientations vertically                                                                   
								   node_b_isslab == 1  and                                                    -- Node below is another slab assumed @ bottom
								   node_b_is_glass     and                                                    -- Node below glass slab
								   not pla_is_glass    then                                                   -- Placing not glass							   
										minetest.chat_send_player(player_n, err_mix)

							elseif node_c_isslab == 1  and                                                    -- Clicked a Slab (reverse of the above)						
								  (node_c.param2 >= 0 and node_c.param2 <= 19) and                            -- bottom slab + all orientations vertically                                                                  
								   node_b_isslab == 1  and                                                    -- Node below is another slab assumed @ bottom
								   not node_a_is_glass and                                                    -- Node below not glass slab
								   pla_is_glass    then                                                       -- Placing glass							   
										minetest.chat_send_player(player_n, err_mix)	

							elseif node_c_isslab == nil and                                                   -- clicked not slab 					                                                                
								   node_b_isslab == 1   and                                                   -- Node below is another slab assumed @ bottom
								   node_b_is_glass      and                                                   -- Node below glass slab
								   not pla_is_glass    then                                                   -- Placing not glass							   
										minetest.chat_send_player(player_n, err_mix)

							elseif node_c_isslab == nil and                                                   -- Clicked not Slab (reverse of the above)						                                                                
								   node_b_isslab == 1   and                                                   -- Node below is another slab assumed @ bottom
								   not node_a_is_glass  and                                                   -- Node below not glass slab
								   pla_is_glass         then                                                  -- Placing glass			
										minetest.chat_send_player(player_n, err_mix)
										
							 -- Last error catch to account for the unknown/unexpected		
							else                                                                             
								 minetest.chat_send_player(player_n, err_un)								
									
							end		
						end
						
				else                                                                                             -- clicked a node side somewhere

						if pparam2 == 0 and                                                                     -- -z side
						(node_c.param2 >= 8 and node_c.param2 <= 11) and                                        -- from this direction must be standing vertical at back of node
						node_c_isslab == 1 then                                                                 -- Node clicked is slab (removes conflict with full node)                                                                            
							local node = minetest.get_node({x=pos.x, y=pos.y, z=pos.z})					
							local nepos = {x=pos.x, y=pos.y, z=pos.z}
							
								side_place(itemstack,placer,pointed_thing,node,nepos,err_mix,err_un)	
				
						elseif pparam2 == 0 then                                                                 -- -z side
							local node = minetest.get_node({x=pos.x, y=pos.y, z=pos.z-1})					
							local nepos = {x=pos.x, y=pos.y, z=pos.z-1}
							
								side_place(itemstack,placer,pointed_thing,node,nepos,err_mix,err_un)	

						elseif pparam2 == 1 and                                                                 -- -x side
						(node_c.param2 >= 16 and node_c.param2 <= 19) and                                       -- from this direction must be standing vertical at back of node
						node_c_isslab == 1 then                                                                 -- Node clicked is slab (removes conflict with full node)                                                                            
							local node = minetest.get_node({x=pos.x, y=pos.y, z=pos.z})					
							local nepos = {x=pos.x, y=pos.y, z=pos.z}
							
								side_place(itemstack,placer,pointed_thing,node,nepos,err_mix,err_un)	
						
						elseif pparam2 == 1 then                                                                -- -x side
							local node = minetest.get_node({x=pos.x-1, y=pos.y, z=pos.z})
							local nepos = {x=pos.x-1, y=pos.y, z=pos.z}
						
							side_place(itemstack,placer,pointed_thing,node,nepos,err_mix,err_un)

						elseif pparam2 == 2 and                                                                 -- +z side
						(node_c.param2 >= 4 and node_c.param2 <= 7) and                                         -- from this direction must be standing vertical at back of node
						node_c_isslab == 1 then                                                                 -- Node clicked is slab (removes conflict with full node)                                                                            
							local node = minetest.get_node({x=pos.x, y=pos.y, z=pos.z})					
							local nepos = {x=pos.x, y=pos.y, z=pos.z}
							
								side_place(itemstack,placer,pointed_thing,node,nepos,err_mix,err_un)	
							
						elseif pparam2 == 2 then                                                                -- +z side
							local node = minetest.get_node({x=pos.x, y=pos.y, z=pos.z+1})
							local nepos = {x=pos.x, y=pos.y, z=pos.z+1}
						
							side_place(itemstack,placer,pointed_thing,node,nepos,err_mix,err_un)

						elseif pparam2 == 3 and                                                                 -- +x side
						(node_c.param2 >= 12 and node_c.param2 <= 15) and                                       -- from this direction must be standing vertical at back of node
						node_c_isslab == 1 then                                                                 -- Node clicked is slab (removes conflict with full node)                                                                            
							local node = minetest.get_node({x=pos.x, y=pos.y, z=pos.z})					
							local nepos = {x=pos.x, y=pos.y, z=pos.z}
							
								side_place(itemstack,placer,pointed_thing,node,nepos,err_mix,err_un)	
							
						elseif pparam2 == 3 then                                                                -- +x side
							local node = minetest.get_node({x=pos.x+1, y=pos.y, z=pos.z})
							local nepos = {x=pos.x+1, y=pos.y, z=pos.z}
						
							side_place(itemstack,placer,pointed_thing,node,nepos,err_mix,err_un)
							
						else                                                                                    -- Last error catch to account for the unknown/unexpected
							minetest.chat_send_player(player_n, err_un)   

						end					
				end	
					if not creative.is_enabled_for(placer:get_player_name()) then					   
						return itemstack
					end
					
				
			end
		})	
		node_count = node_count+1
	end	
end