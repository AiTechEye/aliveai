minetest.register_craft({
	output = "aliveai_threats:secam_off",
	recipe = {
		{"default:steel_ingot", "dye:black", "default:steel_ingot"},
		{"default:glass", "default:steel_ingot", "default:glass"},
		{"default:steel_ingot", "dye:black", "default:steel_ingot"},
	}
})
minetest.register_craft({
	output = "aliveai_threats:landmine 2",
	recipe = {
		{"","default:coal_lump",""},
		{"default:steel_ingot","default:mese_crystal_fragment",""},
		{"","default:steel_ingot",""},
	}
})
minetest.register_craft({
	output = "aliveai_threats:timed_bumb 2",
	recipe = {
		{"default:steel_ingot","default:coal_lump","default:steel_ingot"},
		{"default:steel_ingot","default:mese_crystal_fragment","default:steel_ingot"},
		{"","default:coal_lump",""},
	}
})
minetest.register_craft({
	output = "aliveai_threats:timed_nitrobumb 4",
	recipe = {
		{"default:steel_ingot","default:coal_lump","default:steel_ingot"},
		{"default:steel_ingot","default:mese_crystal_fragment","default:steel_ingot"},
		{"default:ice","default:coal_lump","default:ice"},
	}
})


minetest.register_node("aliveai_threats:secam_off", {
	description = "Security cam",
	tiles = {"aliveai_threats_cam2.png"},
	drawtype = "nodebox",
	walkable=false,
	groups = {dig_immediate = 3},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {type="fixed",
		fixed={	{-0.2, -0.5, -0.2, 0.2, -0.4, 0.2},
			{-0.1, -0.2, -0.1, 0.1, -0.4, 0.1}}

	},
	on_place = minetest.rotate_node,
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext","click to activate and secure")
	end,
on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	minetest.set_node(pos, {name ="aliveai_threats:secam", param1 = node.param1, param2 = node.param2})
	minetest.get_meta(pos):set_string("team",aliveai.team(player))
	minetest.get_node_timer(pos):start(1)
	minetest.sound_play("aliveai_threats_on", {pos=pos, gain = 1, max_hear_distance = 15})
end,
})

minetest.register_node("aliveai_threats:secam", {
	description = "Security cam",
	tiles = {
		{
			name = "aliveai_threats_cam1.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
	},
	drawtype = "nodebox",
	walkable=false,
	groups = {dig_immediate = 3,stone=1,not_in_creative_inventory=1},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	drop="aliveai_threats:secam_off",
	node_box = {type="fixed",
		fixed={	{-0.2, -0.5, -0.2, 0.2, -0.4, 0.2},
			{-0.1, -0.2, -0.1, 0.1, -0.4, 0.1}}
	},
on_timer=function(pos, elapsed)
		local t=minetest.get_meta(pos):get_string("team")
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 15)) do
			local te=aliveai.team(ob)
			if te~="" and te~="animal" and te~=t and aliveai.visiable(pos,ob:get_pos()) then
				local v=ob:get_pos()
				local s={x=(v.x-pos.x)*3,y=(v.y-pos.y)*3,z=(v.z-pos.z)*3}
				local m=minetest.add_entity(pos, "aliveai_threats:bullet1")
				m:setvelocity(s)
				m:setacceleration(s)
				minetest.sound_play("aliveai_threats_bullet1", {pos=pos, gain = 1, max_hear_distance = 15})
				minetest.after((math.random(1,9)*0.1), function(pos,s)
					local m=minetest.add_entity(pos, "aliveai_threats:bullet1")
					m:get_luaentity().team=t
					m:setvelocity(s)
					m:setacceleration(s)
					minetest.sound_play("aliveai_threats_bullet1", {pos=pos, gain = 1, max_hear_distance = 15})
				end, pos,s)
				return true
			end
		end
		return true
	end,
})

minetest.register_entity("aliveai_threats:bullet1",{
	hp_max = 1,
	physical = false,
	weight = 5,
	visual = "sprite",
	visual_size = {x=0.1, y=0.1},
	textures = {"default_mese_block.png"},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
on_step=function(self, dtime)
		local pos=self.object:get_pos()
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			local t=aliveai.team(ob)
			if t~="" and t~="animal" and t~=self.team then
				aliveai.punchdmg(ob,3)
				self.timer=2
				break
			end
		end
		self.timer=self.timer+dtime
		local n=minetest.get_node(self.object:get_pos()).name
		if self.timer>1 or (n and minetest.registered_nodes[n].walkable) then aliveai.kill(self) end
	end,
	timer=0,
	team="",
})
if aliveai_nitroglycerine then
minetest.register_node("aliveai_threats:landmine_on", {
	description = "Landmine",
	tiles = {"aliveai_threats_c4_controller.png"},
	drawtype = "nodebox",
	groups = {attached_node = 1,dig_immediate = 3,stone=1,not_in_creative_inventory=1},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype = "light",
	drop="aliveai_threats:landmine",
	node_box = {type="fixed",
		fixed={{-0.3, -0.7, -0.3, 0.3, -0.6, 0.3}}
	},
	on_blast=function(pos)
		minetest.set_node(pos,{name="air"})
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			local en=ob:get_luaentity()
			if en and en.aliveai then en.drop_dead_body=0 end
			ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=250}})
		end
		if aliveai_nitroglycerine then
		aliveai_nitroglycerine.explode(pos,{
			radius=2,
			set="air",
		})
		end
	end,
	on_timer=function(pos, elapsed)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			local en=ob:get_luaentity()
			if en and en.aliveai then en.drop_dead_body=0 end
			ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=250}})
			aliveai_nitroglycerine.explode(pos,{
				radius=2,
				set="air",
			})
		end
		return true
	end,
})

minetest.register_node("aliveai_threats:landmine", {
	description = "Landmine",
	tiles = {"aliveai_threats_c4_controller.png"},
	drawtype = "nodebox",
	groups = {attached_node = 1,dig_immediate = 3,stone=1,not_in_creative_inventory=0},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype = "light",
	node_box = {type="fixed",
		fixed={{-0.3, -0.5, -0.3, 0.3, -0.4, 0.3}}
	},
	on_blast=function(pos)
		minetest.set_node(pos,{name="air"})
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			local en=ob:get_luaentity()
			if en and en.aliveai then en.drop_dead_body=0 end
			ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=250}})
		end
		aliveai_nitroglycerine.explode(pos,{
			radius=2,
			set="air",
		})
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos,{name="aliveai_threats:landmine_on"})
		minetest.after(3, function(pos)
			minetest.get_node_timer(pos):start(1)
			minetest.sound_play("aliveai_threats_on", {pos=pos, gain = 1, max_hear_distance = 7})
		end, pos)
	end,
})


minetest.register_node("aliveai_threats:timed_bumb", {
	description = "Timed bomb",
	tiles = {"aliveai_threats_c4_controller.png"},
	groups = {dig_immediate = 2,mesecon = 2,flammable = 5},
	sounds = default.node_sound_wood_defaults(),
	on_blast=function(pos)
		minetest.set_node(pos,{name="air"})
		minetest.after(0.1, function(pos)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 5)) do
			local en=ob:get_luaentity()
			if en and en.aliveai then en.drop_dead_body=0 end
			ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=250}})
		end
		aliveai_nitroglycerine.explode(pos,{radius=5,set="air"})
		end,pos)
	end,
	on_timer=function(pos, elapsed)
		minetest.registered_nodes["aliveai_threats:timed_bumb"].on_blast(pos)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		if meta:get_int("b")==1 then return end
		meta:set_int("b",1)
		minetest.get_node_timer(pos):start(5)
		minetest.sound_play("aliveai_threats_on", {pos=pos, gain = 1, max_hear_distance = 7})
	end,
	mesecons = {effector =
		{action_on=function(pos)
			minetest.registered_nodes["aliveai_threats:timed_bumb"].on_rightclick(pos)
		end
		}
	},
	on_burn = function(pos)
		minetest.registered_nodes["aliveai_threats:timed_bumb"].on_rightclick(pos)
	end,
	on_ignite = function(pos, igniter)
		minetest.registered_nodes["aliveai_threats:timed_bumb"].on_rightclick(pos)
	end,
})

minetest.register_node("aliveai_threats:timed_nitrobumb", {
	description = "Timed nitrobomb",
	tiles = {"aliveai_threats_c4_controller.png^[colorize:#51ffe255"},
	groups = {dig_immediate = 2,mesecon = 2,flammable = 5},
	sounds = default.node_sound_wood_defaults(),
	on_blast=function(pos)
		minetest.set_node(pos,{name="air"})
		minetest.after(0.1, function(pos)
				aliveai_nitroglycerine.crush(pos)
				local radius=5
				aliveai_nitroglycerine.explode(pos,{
					radius=radius,
					hurt=0,
					place={"default:snowblock","default:ice","default:snowblock"},
					place_chance=2,
				})
				for _, ob in ipairs(minetest.get_objects_inside_radius(pos, radius*2)) do
					local pos2=ob:get_pos()
					local d=math.max(1,vector.distance(pos,pos2))
					local dmg=(8/d)*radius
					local en=ob:get_luaentity()
					if ob:is_player() or not (en and en.name=="aliveai_nitroglycerine:ice" or en.aliveai_ice) then
						if ob:get_hp()<=dmg+5 then
							aliveai_nitroglycerine.freeze(ob)
						else
							ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=dmg}})
						end
					end
				end
		end,pos)
	end,
	on_timer=function(pos, elapsed)
		minetest.registered_nodes["aliveai_threats:timed_nitrobumb"].on_blast(pos)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		if meta:get_int("b")==1 then return end
		meta:set_int("b",1)
		minetest.get_node_timer(pos):start(5)
		minetest.sound_play("aliveai_threats_on", {pos=pos, gain = 1, max_hear_distance = 7})
	end,
	mesecons = {effector =
		{action_on=function(pos)
			minetest.registered_nodes["aliveai_threats:timed_nitrobumb"].on_rightclick(pos)
		end
		}
	},
	on_burn = function(pos)
		minetest.registered_nodes["aliveai_threats:timed_nitrobumb"].on_rightclick(pos)
	end,
	on_ignite = function(pos, igniter)
		minetest.registered_nodes["aliveai_threats:timed_nitrobumb"].on_rightclick(pos)
	end,
})

end

if aliveai_nitroglycerine then

minetest.register_craft({
	output = "aliveai_threats:secam2_off 3",
	recipe = {
		{"default:diamond","aliveai_threats:secam_off", "default:ice"},
	}
})

minetest.register_node("aliveai_threats:secam2_off", {
	description = "Nitro security cam",
	tiles = {"aliveai_threats_cam2.png^[colorize:#51ffe255"},
	drawtype = "nodebox",
	walkable=false,
	groups = {dig_immediate = 3},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {type="fixed",
		fixed={	{-0.2, -0.5, -0.2, 0.2, -0.4, 0.2},
			{-0.1, -0.2, -0.1, 0.1, -0.4, 0.1}}

	},
	on_place = minetest.rotate_node,
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext","click to activate and secure")
	end,
on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	minetest.set_node(pos, {name ="aliveai_threats:secam2", param1 = node.param1, param2 = node.param2})
	minetest.get_meta(pos):set_string("team",aliveai.team(player))
	minetest.get_node_timer(pos):start(1)
	minetest.sound_play("aliveai_threats_on", {pos=pos, gain = 1, max_hear_distance = 15})
end,
})

minetest.register_node("aliveai_threats:secam2", {
	description = "Security cam",
	tiles = {
		{
			name = "aliveai_threats_cam1.png^[colorize:#51ffe255",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
	},
	drawtype = "nodebox",
	walkable=false,
	groups = {dig_immediate = 3,stone=1,not_in_creative_inventory=1},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	drop="aliveai_threats:secam2_off",
	node_box = {type="fixed",
		fixed={	{-0.2, -0.5, -0.2, 0.2, -0.4, 0.2},
			{-0.1, -0.2, -0.1, 0.1, -0.4, 0.1}}
	},
on_timer=function(pos, elapsed)
		local t=minetest.get_meta(pos):get_string("team")
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 15)) do
			local te=aliveai.team(ob)
			if te~="" and te~="animal" and te~=t and aliveai.visiable(pos,ob:get_pos()) then
				local v=ob:get_pos()
				local s={x=(v.x-pos.x)*3,y=(v.y-pos.y)*3,z=(v.z-pos.z)*3}
				local m=minetest.add_entity(pos, "aliveai_threats:bullet2")
				m:get_luaentity().team=t
				m:setvelocity(s)
				m:setacceleration(s)
				minetest.sound_play("aliveai_threats_bullet1", {pos=pos, gain = 1, max_hear_distance = 15})
				return true
			end
		end
		return true
	end,
})

minetest.register_entity("aliveai_threats:bullet2",{
	hp_max = 1,
	physical = false,
	weight = 5,
	visual = "sprite",
	visual_size = {x=0.1, y=0.1},
	textures = {"default_mese_block.png^[colorize:#51ffe2ff"},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
on_step=function(self, dtime)
		local pos=self.object:get_pos()
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			local t=aliveai.team(ob)
			if t~="" and t~="animal" and t~=self.team then
				if aliveai.gethp(ob)<=5 then
					if ob:get_luaentity() then ob:get_luaentity().destroy=1 end
					minetest.after(0.1, function(ob)
						aliveai_nitroglycerine.freeze(ob)
					end,ob)
				else
					aliveai.punchdmg(ob,5)
				end
				self.timer=2
				break
			end

		end
		self.timer=self.timer+dtime
		local n=minetest.get_node(self.object:get_pos()).name
		if self.timer>1 or (n and minetest.registered_nodes[n].walkable) then aliveai.kill(self) end
	end,
	timer=0,
	team=""
})
end
