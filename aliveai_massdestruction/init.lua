aliveai_massdestruction={}
minetest.register_craft({
	output = "aliveai_massdestruction:walking_bomb 3",
	recipe = {
		{"default:mese_crystal_fragment","default:coal_lump"},
	}
})

minetest.register_craft({
	output = "aliveai_massdestruction:timed_nuke",
	recipe = {
		{"default:steel_ingot","default:coalblock","default:steel_ingot"},
		{"default:steel_ingot","default:mese_crystal","default:steel_ingot"},
		{"","",""},
	}
})


if aliveai.spawning then
minetest.register_abm({
	nodenames = {"group:sand","default:snow"},
	interval = 30,
	chance = 1000,
	action = function(pos)
		local pos1={x=pos.x,y=pos.y+1,z=pos.z}
		local pos2={x=pos.x,y=pos.y+2,z=pos.z}
		if aliveai.random(1,1000)==1 and minetest.get_node(pos1).name=="air" and minetest.get_node(pos2).name=="air" then
			minetest.add_entity(pos1, "aliveai_massdestruction:bomb2")
		end
	end,
})
end

minetest.register_craftitem("aliveai_massdestruction:walking_bomb", {
	description = "Walking bomb",
	inventory_image = "aliveai_massdestruction_bomb.png",
	on_use=function(itemstack, user, pointed_thing)
		local dir = user:get_look_dir()
		local pos=user:get_pos()
		local pos2={x=pos.x+(dir.x*2),y=pos.y+1.5+(dir.y*2),z=pos.z+dir.z*2}
		minetest.add_entity(pos2, "aliveai_massdestruction:bomb2"):setvelocity({x=dir.x*10,y=dir.y*10,z=dir.z*10})
		itemstack:take_item()
		return itemstack
	end,
})

if aliveai_electric then

minetest.register_tool("aliveai_massdestruction:core", {
	description = "Uranium core",
	inventory_image = "aliveai_massdestruction_core.png",
	range = 15,
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
			if minetest.registered_nodes[minetest.get_node(p1).name] and minetest.registered_nodes[minetest.get_node(p1).name].walkable then
				break
			end
		end

		if p1.x~=p1.x or p1.y~=p1.y or p1.z~=p1.z then
			return itemstack
		end
		itemstack:add_wear(65535/10)
		aliveai_massdestruction.uran_explode(p1,4)
		return itemstack
	end,
})


aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="uranium",
		team="nuke",
		texture="aliveai_massdestruction_uranium.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=19,
		hp=1000,
		name_color="",
		coming=0,
		smartfight=0,
		visual_size={x=2,y=1.5},
		collisionbox={-0.7,-1.5,-0.7,0.7,1.2,0.7},
		start_with_items={["default:mese_crystal"]=4,["aliveai_massdestruction:core"]=1},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","group:stone"},
		attack_chance=5,
		spawn=function(self)
			self.hp2=self.object:get_hp()
		end,
		on_load=function(self)
			self.hp2=self.object:get_hp()
		end,
	on_step=function(self,dtime)
		if math.random(1,20)==1 then
			local np=minetest.find_node_near(self.object:get_pos(), 3,{"group:flammable"})
			if np and not minetest.is_protected(np,"") then
				minetest.set_node(np,{name="aliveai_massdestruction:fire"})
			end
		end


		if self.fight then
			if math.random(1,20)==1 and aliveai.distance(self,self.fight)>self.arm then
				self.blowing=1
				self.notblow=1
				aliveai_nitroglycerine.explode(self.fight:get_pos(),{
					radius=3,
					set="air",
					place={"aliveai_massdestruction:fire","aliveai_massdestruction:fire","air","air","air"}
				})
				self.notblow=nil
			elseif math.random(1,10)==1 then
				for _, ob in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), self.distance)) do
					if not (aliveai.same_bot(self,ob) and aliveai.team(ob)=="nuke") then
						local pos=ob:get_pos()
						aliveai_electric.hit(ob,4)
						local node=minetest.get_node(ob:get_pos()).name
						if minetest.registered_nodes[node] and minetest.registered_nodes[node].walkable==false and not minetest.is_protected(pos,"") then
							minetest.set_node(pos,{name="aliveai_massdestruction:fire"})
						end
					end
				end
			end

		end
	end,
	on_punched=function(self,puncher,h)
		if self.blowing or self.hp2-self.hp<10 then
			self.object:set_hp(self.hp2)
			self.hp=self.hp2
			self.blowing=nil
			if aliveai.team(puncher)~="nuke" then
				local p=puncher:get_pos()
				local node=minetest.get_node(p).name
				if minetest.registered_nodes[node] and minetest.registered_nodes[node].walkable==false and not minetest.is_protected(p,"") then
					minetest.set_node(p,{name="aliveai_massdestruction:fire"})
				end
				aliveai_electric.hit(puncher,4,4)
			end
			return self
		end
		self.hp2=self.hp
	end,

	on_detecting_enemy=function(self)
		self.notblow=1
		minetest.after(1, function(self)
			self.notblow=nil
		end,self)
	end,
	on_blow=function(self)
		if self.notblow then return end
		aliveai.kill(self)
		self.death(self,self.object,self.object:getpos())
	end,
	death=function(self)
		if not self.ex then
			self.ex=1
			local pos=self.object:get_pos()
			if not pos then return end
			aliveai_massdestruction.uran_explode(pos,10,self)
			minetest.set_node(pos,{name="aliveai_massdestruction:source"})
		end
		return self
	end,
})
end

aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="nuker",
		team="nuke",
		texture="aliveai_massdestruction_nuker.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=0,
		hp=20,
		name_color="",
		arm=2,
		coming=0,
		smartfight=0,
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","group:stone"},
		attack_chance=5,
	on_fighting=function(self,target)
		if not self.ti then self.ti=99 end
		self.temper=1
		self.ti=self.ti-1
		if self.ti<0 then
			self.death(self)
		else
			self.object:set_properties({nametag=self.ti,nametag_color="#ff0000aa"})
		end
	end,
	on_blow=function(self)
		aliveai.kill(self)
		self.death(self)
	end,
	death=function(self)
		if not self.aliveaibomb then
			local pos=self.object:get_pos()
			self.aliveaibomb=1
			self.hp=0
			self.object:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=self.object:get_hp()*2}})
			for i=1,50,1 do
				minetest.add_entity({x=pos.x+math.random(-5,5),y=pos.y+math.random(2,5),z=pos.z+math.random(-5,5)}, "aliveai_massdestruction:bomb")
			end
			aliveai_nitroglycerine.explode(pos,{
				radius=2,
				set="air",
				drops=0,
				place={"air","air"}
			})
		end
		return self
	end,
})


minetest.register_entity("aliveai_massdestruction:bomb",{
	hp_max = 9000,
	physical =true,
	weight = 1,
	collisionbox = {-0.15,-0.15,-0.15,0.15,0.15,0.15},
	visual = "sprite",
	visual_size = {x=0.5,y=0.5},
	textures ={"aliveai_massdestruction_bomb.png"},
	colors = {},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
	on_activate=function(self, staticdata)
		self.time2=math.random(1,20)
		self.object:setacceleration({x =0, y =-10, z =0})
		self.object:setvelocity({x=math.random(-15,15),y=math.random(10,15),z=math.random(-15,15)})
		return self
	end,
	on_step=function(self, dtime)
		self.time=self.time+dtime
		self.time2=self.time2-dtime
		local v=self.object:getvelocity()
		if self.time2>1 and v.y==0 and self.last_y<0 then
			self.time2=0
			self.expl=math.random(1,10)
		end
		if self.time<0.1 then return self end
		self.last_y=v.y
		self.time=0
		if not self.expl then
			for _, ob in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 2)) do
				local en=ob:get_luaentity()
				if not (en and en.aliveaibomb) then
					self.time2=-1
					return self
				end
			end
		end
		if self.time2<0 then
			if self.expl and math.random(1,self.expl)==1 then
				aliveai_nitroglycerine.explode(self.object:get_pos(),{radius=3,set="air",drops=0,place={"air","air"}})
				self.object:remove()
			elseif not self.expl then
				self.expl=math.random(1,10)
			else
				self.time2=0.5
			end
		end
		return self
	end,
	time=0,
	time2=10,
	type="",
	last_y=0,
	aliveaibomb=1
})

minetest.register_entity("aliveai_massdestruction:bomb2",{
	hp_max = 10,
	physical =true,
	weight = 1,
	collisionbox = {-0.2,-0.2,-0.2,0.2,0.2,0.2},
	visual = "sprite",
	visual_size = {x=0.5,y=0.5},
	textures ={"aliveai_massdestruction_bomb.png"},
	colors = {},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = true,
	automatic_rotate = false,
	namecolor="",
	expl=function(self,pos)
		minetest.add_particlespawner({
			amount = 20,
			time =0.2,
			minpos = {x=pos.x-1, y=pos.y, z=pos.z-1},
			maxpos = {x=pos.x+1, y=pos.y, z=pos.z+1},
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=2, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 1,
			maxexptime = 2,
			minsize = 5,
			maxsize = 10,
			texture = "default_item_smoke.png",
			collisiondetection = true,
		})
		self.exp=1
		aliveai_nitroglycerine.explode(pos,{radius=2,set="air",place={"air","air"}})
		self.object:setvelocity({x=math.random(-5,5),y=math.random(5,10),z=math.random(-5,5)})
		self.object:remove()
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local en=puncher:get_luaentity()
		if not self.exp and tool_capabilities and tool_capabilities.damage_groups and tool_capabilities.damage_groups.fleshy then
			self.hp=self.hp-tool_capabilities.damage_groups.fleshy
			self.object:set_hp(self.hp)
			if dir~=nil then
				local v={x = dir.x*5,y = self.object:getvelocity().y,z = dir.z*5}
				self.object:setvelocity(v)
			end
		end
		if self.hp<1 and not self.exp then
			self.expl(self,self.object:get_pos())
		end

	end,
	on_activate=function(self, staticdata)
		self.object:setacceleration({x =0, y =-10, z =0})
		self.hp=self.object:get_hp()
		return self
	end,
	on_step=function(self, dtime)
		self.time=self.time+dtime
		if self.object:getvelocity().y==0 then
			if self.fight then
				local pos=self.object:get_pos()
				local pos2=self.fight:get_pos()
				if aliveai.visiable(pos,pos2) then
					self.object:setvelocity({x=(pos.x-pos2.x)*-1,y=math.random(5,10),z=(pos.z-pos2.z)*-1})
				end
			else
				self.object:setvelocity({x=math.random(-5,5),y=math.random(5,10),z=math.random(-5,5)})
			end
			local y=self.object:getvelocity().y
			if y==0 or y==-0 then self.object:setvelocity({x=0,y=math.random(5,10),z=0}) end
		end
		if self.time<1 then return self end
		self.time=0
		local pos=self.object:get_pos()
		local ob1
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 15)) do
			local en=ob:get_luaentity()
			if not (en and en.aliveaibomb) and aliveai.visiable(pos,ob:get_pos()) then ob1=ob end
			if ob1 and math.random(1,3)==1 then break end
		end
		if not ob1 then self.fight=nil return end
		local pos2=ob1:get_pos()
		local vis=aliveai.visiable(pos,pos2)
		if self.fight and aliveai.visiable(pos,self.fight:get_pos()) then
			ob1=self.fight
			pos2=self.fight:get_pos()
			vis=aliveai.visiable(pos,pos2)
		end
		if aliveai.distance(pos,pos2)<3 and vis then
			self.expl(self,pos)
		else
			self.fight=ob1
		end
		return self
	end,
	time=0,
	type="monster",
	aliveaibomb=1,
	team="bomb"
})



minetest.register_node("aliveai_massdestruction:source", {
	description = "Uranium source",
	drawtype = "liquid",
	tiles = {
		{name = "aliveai_massdestruction_uran.png",
			animation = {type = "vertical_frames",aspect_w = 16,aspect_h = 16,length = 2.0,},
		},
	},
	special_tiles = {
		{
			name = "aliveai_massdestruction_uran.png",
			animation = {type = "vertical_frames",aspect_w = 16,aspect_h = 16,length = 2.0,},
			backface_culling = false,
		},},
	alpha = 220,
	paramtype = "light",
	light_source = 13,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "aliveai_massdestruction:flowing",
	liquid_alternative_source = "aliveai_massdestruction:source",
	liquid_viscosity = 0,
	damage_per_second = 19,
	post_effect_color = {a = 150, r = 150, g = 50, b = 190},
	groups = {aileuran=1,igniter=1, liquid = 3, puts_out_fire = 1,not_in_creative_inventory=1},
})

minetest.register_node("aliveai_massdestruction:flowing", {
	description = "Uranium flowing",
	drawtype = "flowingliquid",
	tiles = {"aliveai_massdestruction_uran.png"},
	special_tiles = {
		{
			name = "aliveai_massdestruction_uran.png",
			backface_culling = false,
			animation = {type = "vertical_frames",aspect_w = 16,aspect_h = 16,length = 2.0}
		},
		{
			name = "aliveai_massdestruction_uran.png",
			backface_culling = true,
			animation = {type = "vertical_frames",aspect_w = 16,aspect_h = 16,length = 2.0}
		}
	},
	alpha = 190,
	paramtype = "light",
	light_source = 13,
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "aliveai_massdestruction:flowing",
	liquid_alternative_source = "aliveai_massdestruction:source",
	liquid_viscosity = 2,
	damage_per_second = 19,
	post_effect_color = {a = 150, r = 150, g = 50, b = 190},
	groups = {aileuran=1,igniter=1, liquid = 3, puts_out_fire = 1,not_in_creative_inventory = 1},
})




if aliveai_electric then

minetest.register_abm({
	nodenames = {"group:soil","group:sand","group:flammable","group:dig_immediate","group:water","group:flowers","group:oddly_breakable_by_hand"},
	neighbors = {"group:aileuran"},
	interval = 10,
	chance = 4,
	action = function(pos)
		if minetest.is_protected(pos,"")==false then
			minetest.set_node(pos, {name ="aliveai_massdestruction:fire"})
		end
	end,
})

minetest.register_abm({
	nodenames = {"aliveai_massdestruction:fire","aliveai_massdestruction:source"},
	interval = 10,
	chance = 4,
	action = function(pos)
		if minetest.is_protected(pos,"")==false then
			minetest.set_node(pos, {name ="air"})
		end
	end,
})

minetest.register_abm({
	nodenames = {"group:aileuran"},
	interval = 10,
	chance = 10,
	action = function(pos)
		if math.random(1,10)~=1 then return end
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 15)) do
			local node=minetest.get_node(ob:get_pos()).name
			if aliveai.team(ob)~="nuke" and node~="aliveai_massdestruction:fire" and minetest.registered_nodes[node] and minetest.registered_nodes[node].walkable==false then
				aliveai_electric.hit(ob,4)
				minetest.set_node(ob:get_pos(), {name ="aliveai_massdestruction:fire"})
			end
		end
		local np=minetest.find_node_near(pos,15,{"group:soil","group:sand","group:flammable","group:dig_immediate","group:flowers","group:oddly_breakable_by_hand"})
		if np~=nil then
			minetest.set_node(np, {name ="aliveai_massdestruction:fire"})
		end
	end,
})

minetest.register_node("aliveai_massdestruction:fire", {
	description = "Uranium fire",
	inventory_image = "fire_basic_flame.png^[colorize:#aaff00aa",
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png^[colorize:#aaff00aa",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	paramtype = "light",
	light_source = 13,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 7,
	groups = {dig_immediate = 2,igniter=1,puts_out_fire = 1},
	drop="",
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_punch=function(pos, node, puncher, pointed_thing)
		local p=puncher:get_pos()
		p={x=p.x,y=p.y+1,z=p.z}
		local node=minetest.get_node(p).name
		if minetest.registered_nodes[node] and minetest.registered_nodes[node].walkable==false then minetest.set_node(p, {name ="aliveai_massdestruction:fire"}) end
	end,

	on_timer=function (pos, elapsed)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 4)) do
			local p=ob:get_pos()
			local node=minetest.get_node(p).name
			if aliveai.team(ob)~="nuke" then 
				if minetest.is_protected(p,"")==false and node~="aliveai_massdestruction:fire"
				and minetest.registered_nodes[node] and minetest.registered_nodes[node].walkable==false then
					minetest.set_node(p, {name ="aliveai_massdestruction:fire"})
				end
				aliveai_electric.hit(ob,4)
			end
		end

		if math.random(3)==1 then
			minetest.set_node(pos, {name ="air"})
		else
			minetest.sound_play("fire_small", {pos=pos, gain = 1.0, max_hear_distance = 5,})
		end
		return true
	end
})
end


minetest.register_node("aliveai_massdestruction:nuclearbarrel", {
	description = "Uranium barrel",
	drawtype = "mesh",
	mesh = "aliveai_massdestruction_barrel.obj",
	paramtype2 = "facedir",
	wield_scale = {x=1, y=1, z=1},
selection_box = {
		type = "fixed",
		fixed = {-0.4, -0.5, -0.4, 0.4,  0.9, 0.4}
	},
collision_box = {
		type = "fixed",
		fixed = {{-0.4, -0.5, -0.4, 0.4,  0.9, 0.4},}},
	tiles = {"default_cloud.png^[colorize:#ffee00ff^aliveai_massdestruction_log.png"},
	groups = {barrel=1,cracky = 1, level = 2, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	liquids_pointable = true,
on_use = function(itemstack, user, pointed_thing)
	if pointed_thing.type=="node" and minetest.is_protected(pointed_thing.under,user:get_player_name())==false then
		if aliveai.def(pointed_thing.above,"buildable_to") then
			local inv = user:get_inventory()
			if inv:room_for_item("main", {name="aliveai_massdestruction:nuclearbarrel_empty"}) then
				inv:add_item("main","aliveai_massdestruction:nuclearbarrel_empty")
				minetest.set_node(pointed_thing.above,{name="aliveai_massdestruction:source"})
				itemstack:take_item()
				return itemstack
			end
		end
	end
	return itemstack
end,
on_blast=function(pos)
	minetest.set_node(pos,{name="air"})
	minetest.after(0.1, function(pos)
		aliveai_massdestruction.uran_explode(pos,10)
		minetest.set_node(pos,{name="aliveai_massdestruction:source"})
	end,pos)
end,
mesecons = {effector =
	{action_on=function(pos)
		minetest.registered_nodes["aliveai_massdestruction:timed_nuke"].on_blast(pos)
	end
	}
},
on_burn = function(pos)
	minetest.registered_nodes["aliveai_massdestruction:timed_nuke"].on_blast(pos)
end,
on_ignite = function(pos, igniter)
	minetest.registered_nodes["aliveai_massdestruction:timed_nuke"].on_blast(pos)
end,
})

minetest.register_node("aliveai_massdestruction:nuclearbarrel_empty", {
	description = "Uranium barrel (empty)",
	drawtype = "mesh",
	mesh = "aliveai_massdestruction_barrel.obj",
	paramtype2 = "facedir",
	wield_scale = {x=1, y=1, z=1},
selection_box = {
		type = "fixed",
		fixed = {-0.4, -0.5, -0.4, 0.4,  0.8, 0.4}
	},
collision_box = {
		type = "fixed",
		fixed = {{-0.4, -0.5, -0.4, 0.4,  0.8, 0.4},}},
	tiles = {"default_cloud.png^[colorize:#ffee00ff^aliveai_massdestruction_log.png"},
	groups = {barrel=1,cracky = 1, level = 2, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	liquids_pointable = true,
on_use = function(itemstack, user, pointed_thing)
	if pointed_thing.type=="node" and minetest.is_protected(pointed_thing.under,user:get_player_name())==false then
		if minetest.get_node(pointed_thing.under).name=="aliveai_massdestruction:source" then
			local inv = user:get_inventory()
			if inv:room_for_item("main", {name="aliveai_massdestruction:nuclearbarrel"}) then
				minetest.set_node(pointed_thing.under,{name="air"})
				inv:add_item("main","aliveai_massdestruction:nuclearbarrel")
				itemstack:take_item()
				return itemstack
			end
		end
	end
	return itemstack
end,
})



aliveai_massdestruction.uran_explode=function(pos,d,self)
	aliveai_nitroglycerine.explode(pos,{
		radius=d,
		set="air",
		drops=0,
		place={"aliveai_massdestruction:fire","aliveai_massdestruction:fire","air","air","air"}
	})
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos, d*2)) do
		if not ((self and aliveai.same_bot(self,ob)) and aliveai.team(ob)=="nuke") then
			aliveai_electric.hit(ob,4)
			local node=minetest.get_node(ob:get_pos()).name
			if minetest.registered_nodes[node] and minetest.registered_nodes[node].walkable==false then
				minetest.set_node(pos,{name="aliveai_massdestruction:fire"})
			end
		end
	end
end

minetest.register_node("aliveai_massdestruction:timed_nuke", {
	description = "Timed nuke",
	tiles = {"aliveai_massdestruction_nuke.png"},
	groups = {dig_immediate = 2,mesecon = 2,flammable = 5},
	sounds = default.node_sound_wood_defaults(),
	on_blast=function(pos)
		minetest.set_node(pos,{name="air"})
		minetest.after(0.1, function(pos)
			aliveai_massdestruction.uran_explode(pos,10)
			minetest.set_node(pos,{name="aliveai_massdestruction:source"})
		end,pos)
	end,
	on_timer=function(pos, elapsed)
		minetest.registered_nodes["aliveai_massdestruction:timed_nuke"].on_blast(pos)
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
			minetest.registered_nodes["aliveai_massdestruction:timed_nuke"].on_rightclick(pos)
		end
		}
	},
	on_burn = function(pos)
		minetest.registered_nodes["aliveai_massdestruction:timed_nuke"].on_rightclick(pos)
	end,
	on_ignite = function(pos, igniter)
		minetest.registered_nodes["aliveai_massdestruction:timed_nuke"].on_rightclick(pos)
	end,
})

aliveai.loaded("aliveai_massdestruction:walking_bomb")

aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="blackholebot",
		team="nuke",
		texture="aliveai_massdestruction_blackholebot.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=19,
		hp=1000,
		name_color="",
		coming=0,
		smartfight=0,
		visual_size={x=2,y=1.5},
		collisionbox={-0.7,-1.5,-0.7,0.7,1.2,0.7},
		start_with_items={["aliveai_massdestruction:blackholecore"]=2},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","default:stone"},
		attack_chance=5,
		spawn=function(self)
			self.hp2=self.object:get_hp()
		end,
		on_load=function(self)
			self.hp2=self.object:get_hp()
		end,
	on_step=function(self,dtime)
		if self.fight then
			self.blowing=1
			aliveai_nitroglycerine.explode(self.object:get_pos(),{
				radius=2,
				set="air",
				place={"air"}
			})
			minetest.add_entity(self.object:getpos(), "aliveai_massdestruction:blackhole")
			aliveai.kill(self)
		end
	end,
})



minetest.register_node("aliveai_massdestruction:blackholecore", {
	description = "Blackhole core",
	groups = {vessel = 1, not_in_creative_inventory=0,dig_immediate = 3, attached_node = 1},
	tiles={"aliveai_massdestruction_blackhole.png"},
	inventory_image = "aliveai_massdestruction_blackhole.png",
	paramtype = "light",
	is_ground_content = false,
	drawtype = "plantlike",
	walkable = false,
	sounds = default.node_sound_glass_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.27, -0.5, -0.27, 0.27, 0.2, 0.27}
	},
	on_use = function(itemstack, user, pointed_thing)
		local pos=user:get_pos()
		local dir=user:get_look_dir()
		local e=minetest.add_item({x=pos.x+(dir.x*2),y=pos.y+2+(dir.y*2),z=pos.z+(dir.z*2)},"aliveai_massdestruction:blackholecore")
		local vc = {x = dir.x*15, y = dir.y*15, z = dir.z*15}
		e:setvelocity(vc)
		e:get_luaentity().age=(tonumber(minetest.setting_get("item_entity_ttl")) or 900)-10
		e:get_luaentity().on_punch=nil 
		e:get_luaentity().hp_max=10
		table.insert(aliveai_threats.debris,{ob=e,n=user:get_player_name(),
			on_hit_object=function(self,pos,ob)
				self.object:remove()
				pos.y=pos.y+2
				minetest.add_entity(pos, "aliveai_massdestruction:blackhole")
			end,
			on_hit_ground=function(self,pos)
				self.object:remove()
				pos.y=pos.y+2
				minetest.add_entity(pos, "aliveai_massdestruction:blackhole")
			end
		})
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_entity("aliveai_massdestruction:blackhole",{
	hp_max = 1000,
	physical =false,
	pointable=false,
	visual = "sprite",
	textures ={"aliveai_massdestruction_blackhole.png"},
	visual_size={x=2,y=2},
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if #self.inv==0 then
			self.kill=1
			self.nodrop=1
		end
	end,
	on_step=function(self, dtime)
		self.timer1=os.clock()
		if self.timer2>0.5 then
			self.timer2=os.clock()-self.timer1
			return
		end
		if self.kill then
			self.power=self.power-(self.power/10)
			self.object:set_properties({visual_size = {x=0.2+(self.power*0.02), y=0.2+(self.power*0.02)}})
		else
			self.power=self.power-(self.power*0.005)
		end
		local pos=self.object:get_pos()

		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, self.power/10)) do
			local en=ob:get_luaentity()
			local opos=ob:get_pos()
			if aliveai.visiable(pos,opos) and not (en and en.blackhole and en.power>=self.power) then
				if aliveai.distance(pos,opos)<1+(self.power*0.01) then
					if ob:is_player() then
						aliveai.respawn_player(ob)

					else
						if en and en.name=="__builtin:item" and en.itemstring=="aliveai_massdestruction:blackholecore" then
							self.kill=1
						end
						ob:remove()
					end
					self.power=self.power+5
				else
					if ob:is_player() and not ob:get_attach() then
						aliveai_nitroglycerine.new_player=ob
						minetest.add_entity({x=opos.x,y=opos.y+1,z=opos.z}, "aliveai_nitroglycerine:playerp"):setvelocity({x=(pos.x-opos.x)/0.1, y=((pos.y-opos.y)*1)/0.1, z=(pos.z-opos.z)/0.1})
						aliveai_nitroglycerine.new_player=nil
					else
						ob:setvelocity({x=(pos.x-opos.x)/0.9, y=(pos.y-opos.y)/0.9, z=(pos.z-opos.z)/0.9})
					end
					
				end
			end

			if self.power<5 then
				if self.kill and not self.nodrop then
					minetest.add_item(pos,"aliveai_massdestruction:blackholecore 2")
				end
				self.object:remove()
			end

			if self.power>1000 then self.power=1000 end
			self.time=self.time+dtime
			if self.time>1 and self.timer2<0.01 then
				self.time=0
				self.object:set_properties({visual_size = {x=0.2+(self.power*0.02), y=0.2+(self.power*0.02)}})
				local pick=math.floor(self.power/30)
				if pick>0 then
					local nodes={
						"group:flora",
						"group:dig_immediate",
						"group:snappy",
						"group:leaves",
						"group:wood",
						"group:oddly_breakable_by_hand",
						"group:choppy",
						"group:tree",
						"group:sand",
						"group:crumbly",
						"group:soil",
						"group:level",
					}

					local topick={}
					if pick>13 then pick=13 end
					for i=1,pick,1 do
						table.insert(topick,nodes[i])
					end
					local np=minetest.find_node_near(pos, math.floor(self.power/10),topick)
					if np and (minetest.is_protected(np,"") or aliveai.protected(np)) then
						self.power=0
					elseif np then
						if not aliveai_nitroglycerine.spawn_dust(np) then
							local nn=minetest.get_node(np).name
							if nn then
								minetest.add_item(np, nn):get_luaentity().age=890
							end
						end
						minetest.remove_node(np)
					end
				end
			end

		end
		self.timer2=os.clock()-self.timer1
	end,
	inv={["aliveai_massdestruction:blackholecore"]=1},
	aliveai=1,
	blackhole=1,
	power=100,
	time=0,
	timer1=0,
	timer2=0,
})


minetest.register_node("aliveai_massdestruction:gass", {
	description = "Gass",
	inventory_image = "bubble.png",
	tiles = {"aliveai_air.png"},
	walkable = false,
	pointable = false,
	drowning = 1,
	buildable_to = true,
	drawtype = "glasslike",
	damage_per_second = 1,
	paramtype = "light",
	groups = {crumbly = 1,not_in_creative_inventory=1}
})



minetest.register_node("aliveai_massdestruction:toxicdirt", {
	description = "Toxic dirt",
	tiles = {"default_dirt.png^[colorize:#604f20aa"},
	groups = {crumbly = 3,spreading_dirt_type=1},
	sounds = default.node_sound_dirt_defaults(),
	on_construct = function(pos)
		local meta=minetest.get_meta(pos)
		meta:set_string("owner","plant")
		minetest.get_node_timer(pos):start(math.random(1,10))
	end,
	on_timer = function (pos, elapsed)
		local p={x=pos.x,y=pos.y+1,z=pos.z}
		if minetest.get_node(p).name=="air" then
			minetest.set_node(p,{name="aliveai_massdestruction:gass"})
		end
		return false
	end,


})

minetest.register_node("aliveai_massdestruction:toxicwater", {
	description = "Toxic water",
	tiles = {"default_river_water.png^[colorize:#604f20aa"},
	alpha = 200,
	walkable = false,
	pointable = true,
	drowning = 1,
	buildable_to = true,
	drawtype = "glasslike",
	post_effect_color = {a = 68, r =134, g = 244, b = 0},
	damage_per_second = 1,
	paramtype = "light",
	liquid_viscosity = 15,
	liquidtype = "source",
	liquid_range = 0,
	liquid_alternative_flowing = "aliveai_massdestruction:toxicwater",
	liquid_alternative_source = "aliveai_massdestruction:toxicwater",
	groups = {liquid = 4,crumbly = 1,not_in_creative_inventory=1}
})


aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="pollution",
		team="pollution",
		texture="aliveai_massdestruction_uranium.png^[colorize:#604f20aa",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=19,
		hp=100,
		name_color="",
		coming=0,
		smartfight=0,
		visual_size={x=2,y=1.5},
		collisionbox={-0.7,-1.5,-0.7,0.7,1.2,0.7},
		start_with_items={["default:mese_crystal"]=4},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel"},
		attack_chance=5,
	on_detecting_enemy=function(self)
		if self.ex then return end
		self.ex=1
		aliveai_massdestruction.pollutionblow(self.object:get_pos())
		aliveai_nitroglycerine.explode(self.object:get_pos(),{
			radius=1,
			set="air",
			place={"air"}
		})
		aliveai.kill(self)
	end,
	on_blow=function(self)
		if self.ex then return end
		self.ex=1
		aliveai_nitroglycerine.explode(self.object:get_pos(),{
			radius=3,
			set="air",
			place={"air"}
		})
		aliveai.kill(self)
	end,
	death=function(self,puncher,pos)
		self.on_detecting_enemy(self)
	end,
})

aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="icebomb",
		team="ice",
		texture="aliveai_threats_nitrogenblow.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=19,
		hp=100,
		name_color="",
		coming=0,
		smartfight=0,
		visual_size={x=2,y=1.5},
		collisionbox={-0.7,-1.5,-0.7,0.7,1.2,0.7},
		start_with_items={["default:mese"]=1},
		spawn_on={"group:sand","spreading_dirt_type","default:gravel","group:stone"},
		attack_chance=5,
	on_detecting_enemy=function(self)
		if self.ex then return end
		self.ex=1
		aliveai_massdestruction.iceblow(self.object:get_pos())
		aliveai_nitroglycerine.crush(self.object:get_pos())
		aliveai_nitroglycerine.explode(self.object:get_pos(),{
			radius=2,
			set="air",
			place={"air"}
		})
		aliveai.kill(self)
	end,
	on_blow=function(self)
		if self.ex then return end
		self.ex=1
		aliveai_nitroglycerine.crush(self.object:get_pos())
		aliveai_nitroglycerine.explode(self.object:get_pos(),{
			radius=3,
			place={"default:snowblock","default:ice","default:snowblock"},
			place_chance=2,
		})
		aliveai.kill(self)
	end,
	death=function(self,puncher,pos)
		self.on_detecting_enemy(self)
	end,
})

aliveai_massdestruction.pollutionblow=function(pos)
	local np=minetest.find_node_near(pos, 5,{"group:spreading_dirt_type"})
	if np and not minetest.is_protected(np,"") then
		aliveai_nitroglycerine.cons({pos=np,max=3000,
			replace={
				["spreading_dirt_type"]="aliveai_massdestruction:toxicdirt",
				["flora"]="default:dry_shrub",
				["tree"]="default:sand",
				["choppy"]="default:sand",
				["leaves"]=function(pos)
					aliveai_nitroglycerine.cons({pos=pos,max=10,replace={["leaves"]="air"}})
				end,
				["water"]=function(pos)
					aliveai_nitroglycerine.cons({pos=pos,max=10,replace={["water"]="aliveai_massdestruction:toxicwater"}})
				end,
			},
			on_replace=function(pos)
				for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
					aliveai.punchdmg(ob,100)
				end
			end,
		})
	end
end


aliveai_massdestruction.iceblow=function(pos)
	local np=minetest.find_node_near(pos, 5,{"group:spreading_dirt_type"})
	if np and not minetest.is_protected(np,"") then
		aliveai_nitroglycerine.cons({pos=np,max=3000,
			replace={
				["spreading_dirt_type"]="default:dirt_with_snow",
				["flora"]="default:dry_shrub",
				["tree"]="default:snowblock",
				["choppy"]="default:ice",
				["leaves"]=function(pos)
					aliveai_nitroglycerine.cons({pos=pos,max=10,replace={["leaves"]="default:ice"}})
				end,
				["water"]=function(pos)
					aliveai_nitroglycerine.cons({pos=pos,max=10,replace={["water"]="default:ice"}})
				end,
			},
			on_replace=function(pos)
				for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
					aliveai_nitroglycerine.freeze(ob)
				end
			end,
		})
	end
end
