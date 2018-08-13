aliveai_threat_eletric={}

minetest.register_craft({
	output = "aliveai_threat_eletric:secam_off",
	recipe = {
		{"default:steel_ingot", "dye:black", "default:steel_ingot"},
		{"default:glass", "aliveai_threat_eletric:core2", "default:glass"},
		{"default:steel_ingot", "dye:black", "default:steel_ingot"},
	}
})


minetest.register_tool("aliveai_threat_eletric:core", {
	description = "High voltage core",
	inventory_image = "aliveai_threat_eletric_core.png",
	on_use=function(itemstack, user, pointed_thing)
		local pos1,pos2=aliveai_electric.dir(user,pointed_thing)
		local obs,pos,hit=aliveai_electric.getobjects(pos1,pos2)
		aliveai_electric.lightning1(obs,pos,hit)
		itemstack:add_wear(65535/20)
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		itemstack:take_item()
		aliveai_threat_eletric.explode(user:get_pos(),20)
		return itemstack
	end
})

minetest.register_tool("aliveai_threat_eletric:core2", {
	description = "Lightning core",
	inventory_image = "aliveai_threat_eletric_core2.png",
	on_use=function(itemstack, user, pointed_thing)
		local pos1,pos2=aliveai_electric.dir(user,pointed_thing)
		local obs,pos,hit=aliveai_electric.getobjects(pos1,pos2)
		aliveai_electric.lightning2(obs,pos,hit)
		itemstack:add_wear(65535/20)
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		itemstack:take_item()
		aliveai_threat_eletric.explode(user:get_pos(),30)
		return itemstack
	end
})

minetest.register_tool("aliveai_threat_eletric:stungun", {
	description = "Stungun",
	inventory_image = "aliveai_threat_eletric_stungun.png",
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.type=="object" then
			aliveai_electric.hit(pointed_thing.ref,15)
			itemstack:add_wear(65535/20)
			return itemstack
		end
	end
})


minetest.register_craft({
	output = "aliveai_threat_eletric:stungun",
	recipe = {
		{"default:steel_ingot","default:mese_crystal_fragment","default:steel_ingot"},
		{"default:steel_ingot","default:mese_crystal","default:steel_ingot"},
		{"default:steel_ingot","dye:black","default:steel_ingot"},
	}
})


aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="eletric_terminator3",
		team="nuke",
		texture="aliveai_threat_eletric_terminator.png^[colorize:#00ff0033",
		attacking=1,
		talking=0,
		light=0,
		arm=4,
		building=0,
		escape=0,
		start_with_items={["default:steel_ingot"]=4,["aliveai_threat_eletric:stungun"]=1},
		type="monster",
		dmg=5,
		hp=200,
		name_color="",
		attack_chance=3,
		damage_by_blocks=0,
	on_step=function(self,dtime)
		if self.fight and aliveai.visiable(self,self.fight) then
			local p=self.object:get_pos()
			self.temper=3
			local a=aliveai.random_pos(self.fight:get_pos(),2,3)
			if a then self.object:set_pos(a) end
			aliveai.lookat(self,self.fight:get_pos())
			if aliveai.def(p,"buildable_to") then
				minetest.set_node(p,{name="aliveai_electric:chock"})
			elseif aliveai.def({x=p.x,y=p.y+1,z=p.z},"buildable_to") then
				minetest.set_node({x=p.x,y=p.y+1,z=p.z},{name="aliveai_electric:chock"})
			end
		end
	end,
	on_load=function(self)
		self.hp2=self.object:get_hp()
		self.move.speed=4
	end,
	spawn=function(self)
		self.hp2=self.object:get_hp()
		self.move.speed=4
	end,
	on_blow=function(self)
		aliveai.kill(self)
		self.death(self,self.object,self.object:get_pos())
	end,
	death=function(self,puncher,pos)
		if not self.exx then
			self.exx=1
			local pos=self.object:get_pos()
			minetest.add_particlespawner({
				amount = 20,
				time =0.1,
				minpos = pos,
				maxpos = pos,
				minvel = {x=-10, y=10, z=-10},
				maxvel = {x=10, y=50, z=10},
				minacc = {x=0, y=-3, z=0},
				maxacc = {x=0, y=-8, z=0},
				minexptime = 3,
				maxexptime = 1,
				minsize = 1,
				maxsize = 8,
				texture = "default_steel_block.png",
				collisiondetection = true,
			})
			aliveai_threat_eletric.explode(pos,2)
			aliveai.die(self)
		end
	end,
	on_punched=function(self,puncher)
		if self.hp2-self.hp<5 then
			self.object:set_hp(self.hp2)
			self.hp=self.hp2
			if aliveai.team(puncher)~="nuke" then aliveai_electric.hit(puncher) end
			return self
		end
		local pos=self.object:get_pos()
		minetest.add_particlespawner({
			amount = 20,
			time=0.2,
			minpos = {x=pos.x+0.5,y=pos.y+0.5,z=pos.z+0.5},
			maxpos = {x=pos.x-0.5,y=pos.y-0.5,z=pos.z-0.5},
			minvel = {x=-0.1, y=-0.1, z=-0.1},
			maxvel = {x=0.1, y=0.1, z=0.1},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 0.5,
			maxsize = 2,
			texture = "aliveai_electric_vol.png",
		})
	end
})

aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="eletric_terminator",
		team="nuke",
		texture="aliveai_threat_eletric_terminator.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		start_with_items={["default:steel_ingot"]=4,["aliveai_threat_eletric:core"]=1},
		type="monster",
		dmg=9,
		hp=200,
		name_color="",
		attack_chance=3,
		damage_by_blocks=0,
	on_step=function(self,dtime)
		if self.fight and math.random(1,3)==1 and aliveai.visiable(self,self.fight) and aliveai.viewfield(self,self.fight) then
			local pos=self.object:get_pos()
			local ta=self.fight:get_pos()
			aliveai.lookat(self,ta)
			aliveai.use(self)
		end
	end,
	on_load=function(self)
		self.hp2=self.object:get_hp()
	end,
	spawn=function(self)
		self.hp2=self.object:get_hp()
	end,
	on_blow=function(self)
		aliveai.kill(self)
		self.death(self,self.object,self.object:get_pos())
	end,
	death=function(self,puncher,pos)
		if not self.exx then
			self.exx=1
			local pos=self.object:get_pos()
			minetest.add_particlespawner({
				amount = 20,
				time =0.1,
				minpos = pos,
				maxpos = pos,
				minvel = {x=-10, y=10, z=-10},
				maxvel = {x=10, y=50, z=10},
				minacc = {x=0, y=-3, z=0},
				maxacc = {x=0, y=-8, z=0},
				minexptime = 3,
				maxexptime = 1,
				minsize = 1,
				maxsize = 8,
				texture = "default_steel_block.png",
				collisiondetection = true,
			})
			aliveai_threat_eletric.explode(pos,10)
			aliveai.die(self)
		end
	end,
	on_punching=function(self,target)
		local pos=target:get_pos()
		if math.random(1,3)==1 and minetest.registered_nodes[minetest.get_node(pos).name] and minetest.registered_nodes[minetest.get_node(pos).name].buildable_to then
			minetest.set_node(pos, {name="aliveai_threat_eletric:lightning"})
		end
	end,
	on_punched=function(self,puncher)
		if self.hp2-self.hp<5 then
			self.object:set_hp(self.hp2)
			self.hp=self.hp2
			if aliveai.team(puncher)~="nuke" then aliveai_electric.hit(puncher) end
			return self
		end
		local pos=self.object:get_pos()
		minetest.add_particlespawner({
			amount = 20,
			time=0.2,
			minpos = {x=pos.x+0.5,y=pos.y+0.5,z=pos.z+0.5},
			maxpos = {x=pos.x-0.5,y=pos.y-0.5,z=pos.z-0.5},
			minvel = {x=-0.1, y=-0.1, z=-0.1},
			maxvel = {x=0.1, y=0.1, z=0.1},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 0.5,
			maxsize = 2,
			texture = "aliveai_electric_vol.png",
		})
	end
})

aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="eletric_terminator2",
		team="nuke",
		texture="aliveai_threat_eletric_terminator.png^[colorize:#fa7fff44",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		start_with_items={["default:steel_ingot"]=4,["aliveai_threat_eletric:core2"]=1},
		type="monster",
		dmg=9,
		hp=200,
		name_color="",
		attack_chance=3,
		floating=1,
		damage_by_blocks=0,
	on_step=function(self,dtime)
		if self.fight and math.random(1,3)==1 and aliveai.visiable(self,self.fight) and aliveai.viewfield(self,self.fight) then
			local pos=self.object:get_pos()
			local ta=self.fight:get_pos()
			aliveai.lookat(self,ta)
			aliveai.use(self)
		end
	end,
	on_load=function(self)
		self.hp2=self.object:get_hp()
	end,
	spawn=function(self)
		self.hp2=self.object:get_hp()
	end,
	on_blow=function(self)
		aliveai.kill(self)
		self.death(self,self.object,self.object:get_pos())
	end,
	death=function(self,puncher,pos)
		if not self.exx then
			self.exx=1
			local pos=self.object:get_pos()
			minetest.add_particlespawner({
				amount = 20,
				time =0.1,
				minpos = pos,
				maxpos = pos,
				minvel = {x=-10, y=10, z=-10},
				maxvel = {x=10, y=50, z=10},
				minacc = {x=0, y=-3, z=0},
				maxacc = {x=0, y=-8, z=0},
				minexptime = 3,
				maxexptime = 1,
				minsize = 1,
				maxsize = 8,
				texture = "default_steel_block.png",
				collisiondetection = true,
			})
			aliveai_threat_eletric.explode(pos,10)
			aliveai.die(self)
		end
	end,
	on_punching=function(self,target)
		aliveai_electric.hit(target,10)
	end,
	on_punched=function(self,puncher)
		if self.hp2-self.hp<5 then
			self.object:set_hp(self.hp2)
			self.hp=self.hp2
			if aliveai.team(puncher)~="nuke" then
				if aliveai.is_bot(puncher) then aliveai.dying(puncher:get_luaentity(),1) end
				aliveai.punchdmg(puncher,15)
				aliveai_electric.hit(puncher)
			end
			return self
		end
		local pos=self.object:get_pos()
		minetest.add_particlespawner({
			amount = 20,
			time=0.2,
			minpos = {x=pos.x+0.5,y=pos.y+0.5,z=pos.z+0.5},
			maxpos = {x=pos.x-0.5,y=pos.y-0.5,z=pos.z-0.5},
			minvel = {x=-0.1, y=-0.1, z=-0.1},
			maxvel = {x=0.1, y=0.1, z=0.1},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 0.5,
			maxsize = 2,
			texture = "aliveai_electric_vol.png",
		})
	end
})


aliveai_threat_eletric.explode=function(pos,r)
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos, r*2)) do
		if not (ob:get_luaentity() and ob:get_luaentity().itemstring) then
			local pos2=ob:get_pos()
			local d=math.max(1,vector.distance(pos,pos2))
			local dmg=(8/d)*r
			ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=dmg}},nil)
		else
			ob:get_luaentity().age=890
		end
		local pos2=ob:get_pos()
		if aliveai.def(pos2,"buildable_to") then
			minetest.set_node(pos2, {name="aliveai_electric:lightning_clump"})
		end
	end

	for _, ob in ipairs(minetest.get_objects_inside_radius(pos, r*2)) do
		local pos2=ob:get_pos()
		local d=math.max(1,vector.distance(pos,pos2))
		local dmg=(8/d)*r
		if ob:get_luaentity() then
			ob:set_velocity({x=(pos2.x-pos.x)*dmg, y=(pos2.y-pos.y)*dmg, z=(pos2.z-pos.z)*dmg})
		elseif ob:is_player() then
			aliveai_nitroglycerine.new_player=ob
			minetest.add_entity(pos2, "aliveai_nitroglycerine:playerp"):set_velocity({x=(pos2.x-pos.x)*dmg, y=(pos2.y-pos.y)*dmg, z=(pos2.z-pos.z)*dmg})
			aliveai_nitroglycerine.new_player=nil
		end
	end
	minetest.sound_play("aliveai_nitroglycerine_nuke", {pos=pos, gain = 0.5, max_hear_distance = r*4})
end

if aliveai_nitroglycerine then
minetest.register_craft({
	output = "aliveai_threat_eletric:timed_ebumb 2",
	recipe = {
		{"default:steel_ingot","default:coal_lump","default:steel_ingot"},
		{"default:steel_ingot","default:mese_crystal","default:steel_ingot"},
		{"","",""},
	}
})
minetest.register_node("aliveai_threat_eletric:timed_ebumb", {
	description = "Timed bomb",
	tiles = {"aliveai_threats_c4_controller.png^[colorize:#fa7fff55"},
	groups = {dig_immediate = 2,mesecon = 2,flammable = 5},
	sounds = default.node_sound_wood_defaults(),
	on_blast=function(pos)
		minetest.set_node(pos,{name="air"})
		minetest.after(0.1, function(pos)
			aliveai_threat_eletric.explode(pos,7)
			aliveai_nitroglycerine.explode(pos,{radius=3,set="air"})
		end,pos)
	end,
	on_timer=function(pos, elapsed)
		minetest.registered_nodes["aliveai_threat_eletric:timed_ebumb"].on_blast(pos)
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
			minetest.registered_nodes["aliveai_threat_eletric:timed_ebumb"].on_rightclick(pos)
		end
		}
	},
	on_burn = function(pos)
		minetest.registered_nodes["aliveai_threat_eletric:timed_ebumb"].on_rightclick(pos)
	end,
	on_ignite = function(pos, igniter)
		minetest.registered_nodes["aliveai_threat_eletric:timed_ebumb"].on_rightclick(pos)
	end,
})
end



minetest.register_node("aliveai_threat_eletric:secam_off", {
	description = "Lightning security cam",
	tiles = {"aliveai_threats_cam2.png^[colorize:#fa7fff44"},
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
	minetest.set_node(pos, {name ="aliveai_threat_eletric:secam", param1 = node.param1, param2 = node.param2})
	minetest.get_meta(pos):set_string("team",aliveai.team(player))
	if minetest.get_node(pos).param2==21 then
		minetest.get_meta(pos):set_int("y",-1)
	else
		minetest.get_meta(pos):set_int("y",1)
	end
	minetest.get_node_timer(pos):start(1)
	minetest.sound_play("aliveai_threats_on", {pos=pos, gain = 1, max_hear_distance = 15})
end,
})

minetest.register_node("aliveai_threat_eletric:secam", {
	description = "Lightning security cam",
	tiles = {
		{
			name = "aliveai_threats_cam1.png^[colorize:#fa7fff44",
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
	drop="aliveai_threat_eletric:secam_off",
	node_box = {type="fixed",
		fixed={	{-0.2, -0.5, -0.2, 0.2, -0.4, 0.2},
			{-0.1, -0.2, -0.1, 0.1, -0.4, 0.1}}
	},
on_timer=function(pos, elapsed)
		local t=minetest.get_meta(pos):get_string("team")
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 15)) do
			local te=aliveai.team(ob)
			local obpos=ob:get_pos()
			obpos={x=obpos.x,y=obpos.y-1,z=obpos.z}
			if te~="" and te~="animal" and te~=t and aliveai.gethp(ob)>0 and not (aliveai.is_bot(ob) and ob:get_luaentity().dying) and aliveai.visiable(pos,obpos) then
				local obs,pos2=aliveai_electric.getobjects({x=pos.x,y=pos.y+minetest.get_meta(pos):get_int("y"),z=pos.z},obpos)
				aliveai_electric.lightning2(obs,pos2)
				return true
			end
		end
		return true
	end,
})

