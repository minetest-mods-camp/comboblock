-------------------------------------------------------------------------------------
--    _________               ___.         __________.__                 __        --
--    \_   ___ \  ____   _____\_ |__   ____\______   \  |   ____   ____ |  | __    --
--    /    \  \/ /  _ \ /     \| __ \ /  _ \|    |  _/  |  /  _ \_/ ___\|  |/ /    --
--    \     \___(  <_> )  Y Y  \ \_\ (  <_> )    |   \  |_(  <_> )  \___|    <     --
--     \______  /\____/|__|_|  /___  /\____/|______  /____/\____/ \___  >__|_ \    --
--            \/             \/    \/              \/                 \/     \/    --
--                                                                                 --
--                  Orginally written/created by Pithydon/Pithy                    --
--					           Version 5.2.0.1                                     --
--     first 3 numbers version of minetest created for, last digit mod version     -- 
-------------------------------------------------------------------------------------


----------------------------
--       Functions        --
----------------------------

-- group retrieval function by blert2112 minetest forum
local function registered_nodes_by_group(groupname)
	local result = {}
		for name, def in pairs(minetest.registered_nodes) do
			if def.groups[groupname] then
				result[#result+1] = name
			end
		end
	return result
end

-- standard rotate and place function from stairs mod to maintain standard stairs behaviour for slab placement (LGPLv2.1+)
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


-- place slab against side of node
function side_place(itemstack,placer,pointed_thing,node,nepos)
		local tar_node_name = node.name                                                  -- node clicked by player
		local pla_node_name = itemstack:get_name()                                       -- node the player wants to place
		local pla_is_glass = string.find(string.lower(tostring(itemstack:get_name())), "glass")
		local node_is_slab = minetest.registered_nodes[node.name].groups.slab            -- is node (relative)infront clicked slab
	    local node_is_glass = string.find(string.lower(tostring(node.name)), "glass")    -- is node (relative)infront clicked glass
	    local node_is_flora = minetest.get_item_group(node.name, "flora")                -- is node (relative)infront clicked flora
		local err_mix = "Hmmmm... that wont work I can't mix glass slabs and none glass slabs"   -- error txt for mixing glass/not glass
		local err_un = "Hmmmm... The slab wont fit there, somethings in the way"                 -- error txt for unknown/unexpected
		
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
	       node.param2 <= 3 and                                                          -- bottom slab (@ bottom of node space)
		   node_is_glass and                                                             -- node is glass
	       pla_is_glass then                                                             -- placing item is glass		   
				minetest.swap_node(nepos, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})							
				itemstack:take_item(1)                                                   -- Nil callbacks on swap node mnaual remove 1 item 

	elseif node_is_slab == 1 and                                                         -- Clicked a Slab 
	       node.param2 <= 3 and                                                          -- bottom slab (@ bottom of node space)
		   not node_is_glass and                                                         -- node is not glass
	       not pla_is_glass then                                                         -- placing item is not glass		   
				minetest.swap_node(nepos, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})							
				itemstack:take_item(1)                                                   -- Nil callbacks on swap node mnaual remove 1 item 
				
	elseif node_is_slab == nil and                                                       -- Clicked not a slab                                                               
	       tar_node_name == "air" then                                                   -- Node to side is air
				rotate_and_place(itemstack, placer, pointed_thing)                       -- do stairs mod place function                       

	elseif node_is_slab == nil and                                                       -- Clicked not a slab                                                               
	       node_is_flora > 0 then                                                        -- Node to side is air
				rotate_and_place(itemstack, placer, pointed_thing)                       -- do stairs mod place function 

--Below here feedback to player you cant mix glass slabs and none glass slabs so they know this is feature
	elseif node_is_slab == 1 and                                                         -- Clicked a Slab
	  (node.param2 >= 20 and node.param2 <= 23) and                                      -- top slab (@ top of node space)
	   node_is_glass and                                                                 -- node is glass
	   not pla_is_glass then                                                             -- placing item is not glass
				minetest.chat_send_player(placer:get_player_name(), err_mix)				

	elseif node_is_slab == 1 and                                                         -- Clicked a Slab
	  (node.param2 >= 20 and node.param2 <= 23) and                                      -- top slab (@ top of node space)
	   not node_is_glass and                                                             -- node is not glass
	   pla_is_glass then                                                                 -- placing item is not glass
				minetest.chat_send_player(placer:get_player_name(), err_mix)

	elseif node_is_slab == 1 and                                                         -- Clicked a Slab 
	       node.param2 <= 3 and                                                          -- bottom slab (@ bottom of node space)
		   node_is_glass and                                                             -- node is glass
	       not pla_is_glass then                                                         -- placing item is not glass		   
				minetest.chat_send_player(placer:get_player_name(), err_mix) 

	elseif node_is_slab == 1 and                                                         -- Clicked a Slab 
	       node.param2 <= 3 and                                                          -- bottom slab (@ bottom of node space)
		   not node_is_glass and                                                         -- node is not glass
	       pla_is_glass then                                                             -- placing item is not glass		   
				minetest.chat_send_player(placer:get_player_name(), err_mix) 	
				
-- Last error catch to account for the unknown/unexpected				
	else                                                                                 
		 minetest.chat_send_player(placer:get_player_name(), err_un)
	end
end
	
----------------------------
--       Main Code        --
---------------------------- 

-- creates an index of any node name in the group "slab"
local slab_index = registered_nodes_by_group("slab")


for k,v1 in pairs(slab_index) do
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
	end
	if not v1_tiles[6] then
		v1_tiles[6] = v1_tiles[5]
	end
	for _,v2 in pairs(slab_index) do		                                               
			local v2_def = minetest.registered_nodes[v2]       -- this creates a second copy of all slabs and is identical to v1
			local v2_tiles = table.copy(v2_def.tiles)
			if not v2_tiles[2] then
				v2_tiles[2] = v2_tiles[1]
			end
			if not v2_tiles[3] then
				v2_tiles[3] = v2_tiles[2]
			end
			if not v2_tiles[4] then
				v2_tiles[4] = v2_tiles[3]
			end
			if not v2_tiles[5] then
				v2_tiles[5] = v2_tiles[4]
			end
			if not v2_tiles[6] then
				v2_tiles[6] = v2_tiles[5]


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
					tiles = {v1_tiles[1].name, v2_tiles[2].name,
							v1_tiles[3].name.."^[lowpart:50:"..v2_tiles[3].name,                      -- Stairs registers it's tiles slightly differently now
							v1_tiles[4].name.."^[lowpart:50:"..v2_tiles[4].name,                      -- in a nested table structure and now makes use of 
							v1_tiles[5].name.."^[lowpart:50:"..v2_tiles[5].name,                      -- align_style = "world" for most slabs....I think
							v1_tiles[6].name.."^[lowpart:50:"..v2_tiles[6].name
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
			
		else                                                                                          -- normal nodes					
				minetest.register_node("comboblock:"..v1:split(":")[2].."_onc_"..v2:split(":")[2], {  -- registering the new combo nodes
					description = v1_def.description.." on "..v2_def.description,
					tiles = {v1_tiles[1].name, v2_tiles[2].name,
							v1_tiles[3].name.."^[lowpart:50:"..v2_tiles[3].name,                      -- Stairs registers it's tiles slightly differently now
							v1_tiles[4].name.."^[lowpart:50:"..v2_tiles[4].name,                      -- in a nested table structure and now makes use of 
							v1_tiles[5].name.."^[lowpart:50:"..v2_tiles[5].name,                      -- align_style = "world" for most slabs....I think
							v1_tiles[6].name.."^[lowpart:50:"..v2_tiles[6].name
							},
					paramtype = "light",
					paramtype2 = "facedir",
					drawtype = "normal",                                                              
					sounds = v1_def.sounds,
					groups = v1_groups,
					drop = v1,
					after_destruct = function(pos, oldnode)
						minetest.set_node(pos, {name = v2, param2 = oldnode.param2})
					end
				})
		end	
			
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

				
			if fpos == 0.5 then                                                                          -- clicked a flat top or bottom surface
				local node_c = minetest.get_node({x=pos.x, y=pos.y, z=pos.z})                            -- node clicked
				local node_c_isslab = minetest.registered_nodes[node_c.name].groups.slab                 -- is node clicked in slab group
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
									itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
									
						elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
						      (node_c.param2 >= 20 and node_c.param2 <= 23) and                           -- top slab                                                                   
						       node_a.name == "air" then                                                  -- Node above is air                       									
									local param2 = pparam2                                  
									minetest.item_place(itemstack, placer, pointed_thing, param2)

						elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
						      (node_c.param2 >= 20 and node_c.param2 <= 23) and                           -- top slab                                                                   
						       node_a_is_flora > 0 then                                                   -- Node above is flora                       									
									local param2 = pparam2                                  
									minetest.item_place(itemstack, placer, pointed_thing, param2)
									
						elseif node_c_isslab == 1  and                                                    -- Clicked a Slab						
						      (node_c.param2 >= 20 and node_c.param2 <= 23) and                           -- top slab                                                                   
						       node_a_isslab == 1  and                                                    -- Node above is another slab assumed @ top
							   not node_a_is_glass and                                                    -- Node above not glass slab
							   not pla_is_glass    then                                                   -- Placing Slab not glass 							   
									local tar_node_name = node_a.name
									local pla_node_name = itemstack:get_name()								
									minetest.swap_node(pos1, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})							   
									itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item

						elseif node_c_isslab == 1  and                                                    -- Clicked a Slab						
						      (node_c.param2 >= 20 and node_c.param2 <= 23) and                           -- top slab                                                                   
						       node_a_isslab == 1  and                                                    -- Node above is another slab assumed @ top
							   node_a_is_glass and                                                        -- Node above glass slab
							   pla_is_glass    then                                                       -- Placing Slab glass 							   
									local tar_node_name = node_a.name
									local pla_node_name = itemstack:get_name()								
									minetest.swap_node(pos1, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})							   
									itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
									
						elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
						       node_a_isslab == 1   and                                                   -- Node above is a slab assumed @ top
							   not node_a_is_glass  and                                                   -- Node above not glass slab
							   not pla_is_glass     then                                                  -- Placing Slab not glass 							   
									local tar_node_name = node_a.name
									local pla_node_name = itemstack:get_name()								
									minetest.swap_node(pos1, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})
									itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item

						elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
						       node_a_isslab == 1   and                                                   -- Node above is a slab assumed @ top
							   node_a_is_glass      and                                                   -- Node above glass slab
							   pla_is_glass         then                                                  -- Placing Slab glass 							   
									local tar_node_name = node_a.name
									local pla_node_name = itemstack:get_name()								
									minetest.swap_node(pos1, {name = "comboblock:"..tar_node_name:split(":")[2].."_onc_"..pla_node_name:split(":")[2], param2 = pparam2})
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
						      (node_c.param2 >= 20 and node_c.param2 <= 23) and                           -- top slab                                                                   
						       node_a_isslab == 1  and                                                    -- Node above is another slab assumed @ top
							   node_a_is_glass     and                                                    -- Node above glass slab
							   not pla_is_glass    then                                                   -- Placing not glass							   
									minetest.chat_send_player(player_n, err_mix)

						elseif node_c_isslab == 1  and                                                    -- Clicked a Slab (reverse of the above)						
						      (node_c.param2 >= 20 and node_c.param2 <= 23) and                           -- top slab                                                                   
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
						       node_c.param2 <= 3 and                                                     -- bottom slab                                                                   
						       node_b.name == "air" then                                                  -- Node below is air                       
									local param2 = pparam2+20                                  
									minetest.item_place(itemstack, placer, pointed_thing, param2)								

						elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
						       node_c.param2 <= 3 and                                                     -- bottom slab                                                                   
						       node_b_is_flora > 0 then                                                   -- Node below is flora                       
									local param2 = pparam2+20                                  
									minetest.item_place(itemstack, placer, pointed_thing, param2)	
									
						elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
						       node_c.param2 <= 3 and                                                     -- bottom slab                                                                    
						       node_b_isslab == 1 and                                                     -- Node below is another slab assumed @ bottom
							   not node_b_is_glass and                                                    -- Node below not glass slab
							   not pla_is_glass   then                                                    -- Placing Slab not glass 							   
									local tar_node_name = node_b.name
									local pla_node_name = itemstack:get_name()
									minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})
									itemstack:take_item(1)                                                -- Nil callbacks on swap node manual remove 1 item									

						elseif node_c_isslab == 1 and                                                     -- Clicked a Slab
						       node_c.param2 <= 3 and                                                     -- bottom slab                                                                    
						       node_b_isslab == 1 and                                                     -- Node below is another slab assumed @ bottom
							   node_b_is_glass and                                                        -- Node below glass slab
							   pla_is_glass   then                                                        -- Placing Slab glass 							   
									local tar_node_name = node_b.name
									local pla_node_name = itemstack:get_name()
									minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})
									itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item
									
						elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
						       node_b_isslab == 1 and                                                     -- Node below is a slab assumed @ bottom
							   not node_b_is_glass and                                                    -- Node below not glass slab
							   not pla_is_glass   then                                                    -- Placing Slab not glass
									local tar_node_name = node_b.name
									local pla_node_name = itemstack:get_name()								
									minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})
									itemstack:take_item(1)                                                -- Nil callbacks on swap node mnaual remove 1 item

						elseif node_c_isslab == nil and                                                   -- Clicked not a slab                                                                  
						       node_b_isslab == 1 and                                                     -- Node below is a slab assumed @ bottom
							   node_b_is_glass and                                                        -- Node below glass slab
							   pla_is_glass   then                                                        -- Placing Slab glass
									local tar_node_name = node_b.name
									local pla_node_name = itemstack:get_name()								
									minetest.swap_node(pos1, {name = "comboblock:"..pla_node_name:split(":")[2].."_onc_"..tar_node_name:split(":")[2], param2 = pparam2})
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
						       node_c.param2 <= 3 and                                                     -- Bottom slab in node                                                                  
						       node_b_isslab == 1  and                                                    -- Node below is another slab assumed @ bottom
							   node_b_is_glass     and                                                    -- Node below glass slab
							   not pla_is_glass    then                                                   -- Placing not glass							   
									minetest.chat_send_player(player_n, err_mix)

						elseif node_c_isslab == 1  and                                                    -- Clicked a Slab (reverse of the above)						
						       node_c.param2 <= 3 and                                                     -- bottom slab                                                                   
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
							   not node_a_is_glass  and                                                   -- Node below glass slab
							   pla_is_glass         then                                                  -- Placing not glass			
									minetest.chat_send_player(player_n, err_mix)
									
						 -- Last error catch to account for the unknown/unexpected		
						else                                                                             
						     minetest.chat_send_player(player_n, err_un)								
								
						end		
				    end
					
			else                                                                                             -- clicked a node side somewhere				
					if pparam2 == 0 then                                                                     -- -z side
						local node = minetest.get_node({x=pos.x, y=pos.y, z=pos.z-1})					
						local nepos = {x=pos.x, y=pos.y, z=pos.z-1}
					    
							side_place(itemstack,placer,pointed_thing,node,nepos)	

					
					elseif pparam2 == 1 then                                                                -- -x side
						local node = minetest.get_node({x=pos.x-1, y=pos.y, z=pos.z})
						local nepos = {x=pos.x-1, y=pos.y, z=pos.z}
					
						side_place(itemstack,placer,pointed_thing,node,nepos)
						
					elseif pparam2 == 2 then                                                                -- +z side
						local node = minetest.get_node({x=pos.x, y=pos.y, z=pos.z+1})
						local nepos = {x=pos.x, y=pos.y, z=pos.z+1}
					
						side_place(itemstack,placer,pointed_thing,node,nepos)
						
					elseif pparam2 == 3 then                                                                -- +x side
						local node = minetest.get_node({x=pos.x+1, y=pos.y, z=pos.z})
						local nepos = {x=pos.x+1, y=pos.y, z=pos.z}
					
						side_place(itemstack,placer,pointed_thing,node,nepos)
						
					else                                                                                    -- Last error catch to account for the unknown/unexpected
						minetest.chat_send_player(player_n, err_un)   

					end					
		    end	
				if not creative.is_enabled_for(placer:get_player_name()) then					   
					return itemstack
				end
		end,
	})
end
