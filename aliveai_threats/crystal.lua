minetest.register_craft( {
	output = "aliveai_threats:crystal_small 3",
	recipe = {
		{"aliveai_threats:crystal_big"},
	}
})

minetest.register_craft( {
	output = "aliveai_threats:crystal_small 2",
	recipe = {
		{"aliveai_threats:crystal_medium"},
	}
})

minetest.register_craft( {
	output = "aliveai_threats:chainfence 3",
	recipe = {
		{"default:steel_ingot","","default:steel_ingot"},
		{"default:steel_ingot","aliveai_threats:crystal_small","default:steel_ingot"},
		{"default:steel_ingot","","default:steel_ingot"},
	}
})

if not aliveai_electric then
	aliveai_electric={}
	aliveai_electric.hit=function(ob,h)
	aliveai.punchdmg(ob,h)
	end
end

aliveai.create_bot({
		description="Growing electric crystals on everyone or everything in its way",
		attack_players=1,
		name="crystal",
		team="crystal",
		texture="aliveai_threats_crystals.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		start_with_items={["aliveai_threats:crystalrod"]=1},
		type="monster",
		dmg=5,
		hp=40,
		name_color="",
		coming=0,
		smartfight=0,
		attack_chance=2,
	death=function(self,puncher,pos)
			minetest.sound_play("default_break_glass", {pos=pos, gain = 1.0, max_hear_distance = 5,})
			if not self.ex then
				self.ex=true
				aliveai_threats.crystalblow(pos)
				aliveai_threats.crystalblow(pos)
				minetest.add_particlespawner({
				amount = 5,
				time =0.05,
				minpos = pos,
				maxpos = pos,
				minvel = {x=-2, y=-2, z=-2},
				maxvel = {x=1, y=0.5, z=1},
				minacc = {x=0, y=-8, z=0},
				maxacc = {x=0, y=-10, z=0},
				minexptime = 2,
				maxexptime = 1,
				minsize = 1,
				maxsize = 4,
				texture = "aliveai_threats_crystals",
				collisiondetection = true,
				})
			end
			return self
	end
})


aliveai_threats.crystalblow=function(pos)
	local nodes=aliveai.get_nodes(pos,5,2,{"default:stone"})
	for _, nodepos in pairs(nodes) do
		if not minetest.is_protected(nodepos,"") and aliveai.distance(nodepos,pos)<5 then
			local n=minetest.get_node(nodepos).name
			if minetest.get_item_group(n,"snappy")>0 then
				local na={"aliveai_threats:crystal_medium","aliveai_threats:crystal_big","aliveai_threats:crystal_small","aliveai_threats:crystal_grass"}
				minetest.set_node(nodepos,{name=na[math.random(1,4)]})
			elseif minetest.get_item_group(n,"choppy")>0 then
				minetest.set_node(nodepos,{name="aliveai_threats:crystal_block"})
			elseif minetest.get_item_group(n,"soil")>0 then
				minetest.set_node(nodepos,{name="aliveai_threats:crystal_soil"})
			end 
		end
	end
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 5)) do
		aliveai_electric.hit(ob,10)
	end
end

minetest.register_tool("aliveai_threats:crystalrod", {
	description = "Crystal rod",
	inventory_image = "aliveai_threats_crystals.png",
	range = 15,
	groups = {not_in_creative_inventory=1},
	on_use=function(itemstack, user, pointed_thing)
		if user:get_luaentity() then user=user:get_luaentity() end
		local typ=pointed_thing.type
		local pos1=user:get_pos()
		pos1.y=pos1.y+1.5
		local pos2
		if typ=="object" then
			pos2=pointed_thing.ref:get_pos()
		elseif typ=="node" then
			pos2=pointed_thing.under
		elseif typ=="nothing" then
			local dir
			if user:get_luaentity() then
				if user:get_luaentity().aliveai and user:get_luaentity().fight then
					local dir=aliveai.get_dir(user:get_luaentity(),user:get_luaentity().fight)
					pos2={x=pos1.x+(dir.x*30),y=pos1.y+(dir.y*30),z=pos1.z+(dir.z*30)}
				else
					pos2=aliveai.pointat(user:get_luaentity(),30)
				end
			else
				local dir=user:get_look_dir()
				pos2={x=pos1.x+(dir.x*30),y=pos1.y+(dir.y*30),z=pos1.z+(dir.z*30)}
			end
		else
			return itemstack
		end
		local d=math.floor(aliveai.distance(pos1,pos2)+0.5)
		local dir={x=(pos1.x-pos2.x)/-d,y=(pos1.y-pos2.y)/-d,z=(pos1.z-pos2.z)/-d}
		local p1=pos1
		for i=0,d,1 do
			p1={x=pos1.x+(dir.x*i),y=pos1.y+(dir.y*i),z=pos1.z+(dir.z*i)}
			if aliveai.def(p1,"walkable") then
				break
			end
		end

		if p1.x~=p1.x or p1.y~=p1.y or p1.z~=p1.z then
			return itemstack
		end
		itemstack:add_wear(65535/20)
		aliveai_threats.crystalblow(p1)
		minetest.sound_play("aliveai_electric_lightning", {pos = p1,max_hear_distance = 5,gain = 0.1,})
		minetest.sound_play("aliveai_electric_lightning", {pos = pos1,max_hear_distance = 5,gain = 0.1,})
		return itemstack
	end,
})


minetest.register_node("aliveai_threats:crystal_big", {
	description = "Big crystal",
	drawtype = "mesh",
	mesh = "aliveai_threats_crystals.obj",
	visual_scale = 0.3,
	wield_scale = {x=1, y=1, z=1},
	alpha = 20,
	tiles = {
		{
			name = "aliveai_threats_crystals.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	damage_per_second = 10,
	walkable = false,
	is_ground_content = false,
	light_source=3,
	selection_box = {
		type = "fixed",
		fixed = {-1, -1, -1, 1, 1, 1}
	},
	collision_box = {
		type = "fixed",
		fixed = {{-2, -2, -2, 2, 2, 2},}},
	groups = {cracky = 1, level = 3},
	on_punch = function(pos, node, puncher, pointed_thing)
		aliveai_electric.hit(pointed_thing.ref,30)
	end,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" or pointed_thing.type=="nothing" then return itemstack end
		local pvp=minetest.settings:get_bool("enable_pvp")
		local ob=pointed_thing.ref
		if ob:is_player() and pvp==false then return itemstack end
		aliveai_electric.hit(puncher,30)
		itemstack:take_item(1)
		return itemstack
		end,
})

minetest.register_node("aliveai_threats:crystal_medium", {
	description = "Medium crystal",
	drawtype = "mesh",
	mesh = "aliveai_threats_crystals.obj",
	visual_scale = 0.2,
	wield_scale = {x=1, y=1, z=1},
	alpha = 20,
	tiles = {
		{
			name = "aliveai_threats_crystals.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	damage_per_second = 4,
	walkable = false,
	is_ground_content = false,
	light_source=3,
	groups = {cracky = 2, level = 2},
	on_punch = function(pos, node, puncher, pointed_thing)
		aliveai_electric.hit(puncher,15)
	end,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" or pointed_thing.type=="nothing" then return itemstack end
		local pvp=minetest.settings:get_bool("enable_pvp")
		local ob=pointed_thing.ref
		if ob:is_player() and pvp==false then return itemstack end
		aliveai_electric.hit(pointed_thing.ref,15)
		itemstack:take_item(1)
		return itemstack
		end,
})

minetest.register_node("aliveai_threats:crystal_small", {
	description = "Small crystal",
	drawtype = "mesh",
	mesh = "aliveai_threats_crystal.obj",
	visual_scale = 2,
	wield_scale = {x=2, y=2, z=2},
	alpha = 20,
	tiles = {
		{
			name = "aliveai_threats_crystals.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	damage_per_second = 5,
	walkable = false,
	is_ground_content = false,
	light_source=8,
	selection_box = {
		type = "fixed",
		fixed = {-0.1, -0.5, -0.1, 0.1, 0.25, 0.1}
	},
	groups = {cracky = 1, level = 1},
	on_punch = function(pos, node, puncher, pointed_thing)
		aliveai_electric.hit(puncher,5)
	end,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" or pointed_thing.type=="nothing" then return itemstack end
		local pvp=minetest.settings:get_bool("enable_pvp")
		local ob=pointed_thing.ref
		if ob:is_player() and pvp==false then return itemstack end
		aliveai_electric.hit(pointed_thing.ref,5)
		itemstack:take_item(1)
		return itemstack
		end,
})

minetest.register_node("aliveai_threats:crystal_block", {
	description = "Crystal block",
	tiles = {
		{
			name = "aliveai_threats_crystals.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	groups = {cracky = 1, puts_out_fire = 1, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	light_source=8,
	paramtype = "light",
	is_ground_content = false,
	on_punch = function(pos, node, puncher, pointed_thing)
		aliveai_electric.hit(pointed_thing.ref,5)
	end,

})

minetest.register_node("aliveai_threats:crystal_soil", {
	description = "Crystal soil",
	tiles = {"default_obsidian.png^[colorize:#6d1d7caa"},
	groups = { oddly_breakable_by_hand = 1,choppy = 1, not_in_creative_inventory=1},
	sounds = default.node_sound_dirt_defaults(),
	light_source=5,
	paramtype = "light",
	is_ground_content = false,
	on_punch = function(pos, node, puncher, pointed_thing)
		aliveai_electric.hit(pointed_thing.ref,5)
	end,
})

minetest.register_node("aliveai_threats:crystal_grass", {
	description = "Crystal grass",
	tiles = {"aliveai_threats_crystal_grass.png"},
	groups = {cracky = 2, puts_out_fire = 1, not_in_creative_inventory=1},
	sounds = default.node_sound_glass_defaults(),
	paramtype = "light",
	walkable = false,
	sunlight_propagates = true,
	drawtype = "plantlike",
	damage_per_second = 3,
})
