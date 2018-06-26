minetest.register_craftitem("aliveai_aliens:alien_food", {
	description = "Alien food",
	inventory_image = "default_iron_lump.png^[colorize:#00883344",
	groups = {not_in_creative_inventory=1},
	on_use =minetest.item_eat(8)
})


minetest.register_tool("aliveai_aliens:alien_enginelazer", {
	description = "Alien enginelazer",
	range = 1,
	inventory_image = "aliveai_alien_enginelazer.png",
	wield_scale={x=2,y=1,z=2},
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		local name=user:get_player_name()
		if aliveai_aliens.ael[name] then return itemstack end
		aliveai_aliens.ael[name]=1
		for i=0,50,1 do
		minetest.after(i*0.05, function(user,i,name)

			local dir=user:get_look_dir()
			local pos=user:get_pos()
			pos.y=pos.y+1.5

			pos.x=pos.x+(math.random(-2,2)*0.1)
			pos.y=pos.y+(math.random(-2,2)*0.1)
			pos.z=pos.z+(math.random(-2,2)*0.1)

			local d={x=dir.x*math.random(13,17),y=dir.y*math.random(13,17),z=dir.z*math.random(13,17)}
			aliveai_aliens.user=user
			aliveai_aliens.type=1
			minetest.sound_play("aliveai_aliens_lazer", {pos=pos, gain=1.0, max_hear_distance=10})
			minetest.add_entity({x=aliveai.nan(pos.x+(dir.x)*1),y=aliveai.nan(pos.y+(dir.y)*1),z=aliveai.nan(pos.z+(dir.z)*1)}, "aliveai_aliens:bullet"):setvelocity(d)
			aliveai_aliens.user=nil
			aliveai_aliens.type=nil

			if i>=50 then
				aliveai_aliens.ael[name]=nil
			end
		end,user,i,name)
		end
		itemstack:add_wear(65535/10)
		return itemstack
	end,
})



minetest.register_tool("aliveai_aliens:ozer_sword", {
	description = "Ozer Sword",
	range = 2,
	inventory_image = "alieveai_aliens_ozersword.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" then
			local n1=minetest.get_node(pointed_thing.under)
			local n=minetest.registered_nodes[n1.name]
			if n and not (n.drop=="" or n.unbreakable) then
				minetest.node_dig(pointed_thing.under,n1,user)
				minetest.sound_play("alieveai_aliens_ozersword", {pos =pointed_thing.under, gain = 1.0, max_hear_distance = 10})
			end
			
			itemstack:add_wear(65535/500)
			return itemstack
		end
		local pos=user:get_pos()
		local dir=user:get_look_dir()
		local d={x=pos.x+dir.x*2,y=pos.y+dir.y*2,z=pos.z+dir.z*2}
		local name=user:get_player_name()
		local a=false
		for i, ob in pairs(minetest.get_objects_inside_radius(d, 4)) do
			if not (ob:get_luaentity() and ob:get_luaentity().type==nil) and aliveai.visiable(pos,ob:get_pos()) and not (ob:is_player() and ob:get_player_name()==name) then
				if type(user)=="table" then user=ob end
				ob:punch(user,1,{full_punch_interval=1,damage_groups={fleshy=9}})
				a=true
				itemstack:add_wear(65535/500)
			end
		end
		if a then
			minetest.sound_play("alieveai_aliens_ozersword", {pos=d, gain = 1.0, max_hear_distance = 10})
		end
		return itemstack
	end,
})

minetest.register_tool("aliveai_aliens:alien_nrifle", {
	description = "Alien nitrorifle",
	range = 1,
	inventory_image = "aliveai_alien_nrifle.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		local dir=user:get_look_dir()
		local pos=user:get_pos()
		pos.y=pos.y+1.5
		local d={x=dir.x*15,y=dir.y*15,z=dir.z*15}
		aliveai_aliens.user=user
		aliveai_aliens.type=2
		minetest.sound_play("aliveai_aliens_lazer", {pos=pos, gain=1.0, max_hear_distance=10})
		minetest.add_entity({x=aliveai.nan(pos.x+(dir.x)*1),y=aliveai.nan(pos.y+(dir.y)*1),z=aliveai.nan(pos.z+(dir.z)*1)}, "aliveai_aliens:bullet"):setvelocity(d)
		aliveai_aliens.user=nil
		aliveai_aliens.type=nil
		itemstack:add_wear(65535/50)
		return itemstack
	end,
})

minetest.register_tool("aliveai_aliens:alien_rifle", {
	description = "Alien rifle",
	range = 1,
	inventory_image = "aliveai_alien_rifle1.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		local dir=user:get_look_dir()
		local pos=user:get_pos()
		pos.y=pos.y+1.5
		local d={x=dir.x*15,y=dir.y*15,z=dir.z*15}
		aliveai_aliens.user=user
		aliveai_aliens.type=1
		minetest.sound_play("aliveai_aliens_lazer", {pos=pos, gain=1.0, max_hear_distance=10})
		minetest.add_entity({x=aliveai.nan(pos.x+(dir.x)*3),y=aliveai.nan(pos.y+(dir.y)*3),z=aliveai.nan(pos.z+(dir.z)*3)}, "aliveai_aliens:bullet"):setvelocity(d)
		minetest.add_entity({x=aliveai.nan(pos.x+(dir.x)*2),y=aliveai.nan(pos.y+(dir.y)*2),z=aliveai.nan(pos.z+(dir.z)*2)}, "aliveai_aliens:bullet"):setvelocity(d)
		minetest.add_entity({x=aliveai.nan(pos.x+(dir.x)*1),y=aliveai.nan(pos.y+(dir.y)*1),z=aliveai.nan(pos.z+(dir.z)*1)}, "aliveai_aliens:bullet"):setvelocity(d)
		aliveai_aliens.user=nil
		aliveai_aliens.type=nil
		itemstack:add_wear(65535/100)
		return itemstack
	end,
})

minetest.register_tool("aliveai_aliens:alien_homing_rifle", {
	description = "Alien homing rifle",
	range = 1,
	inventory_image = "aliveai_alien_rifle2.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		local dir=user:get_look_dir()
		local pos=user:get_pos()
		pos.y=pos.y+1.5
		local name=user:get_player_name()
		local v={x=dir.x*15,y=dir.y*15,z=dir.z*15}
		for i=2,31,1 do
			local pos1={x=aliveai.nan(pos.x+(dir.x)*i),y=aliveai.nan(pos.y+(dir.y)*i),z=aliveai.nan(pos.z+(dir.z)*i)}
			local n = minetest.registered_nodes[minetest.get_node(pos1).name]
			if n and n.walkable then
				return itemstack
			end
			if pos1~=pos1 then return end
			for ii, ob in pairs(minetest.get_objects_inside_radius(pos1, 1.5)) do
				if not (ob:get_luaentity() and ob:get_luaentity().type==nil) and aliveai.visiable(pos,ob:get_pos()) and not (ob:is_player() and ob:get_player_name()==name) then
					aliveai_aliens.target=ob
					aliveai_aliens.user=user
					minetest.add_entity({x=aliveai.nan(pos.x+(dir.x)*3),y=aliveai.nan(pos.y+(dir.y)*3),z=aliveai.nan(pos.z+(dir.z)*3)}, "aliveai_aliens:bullet2")
					itemstack:add_wear(65535/50)
				end
			end
		end
		return itemstack
	end,
})

minetest.register_tool("aliveai_aliens:vexcazer", {
	description = "Vexcazer",
	range = 1,
	inventory_image = "aliveai_alien_vexcazer.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		local dir=user:get_look_dir()
		local pos=user:get_pos()
		pos={x=aliveai.nan(pos.x+(dir.x)*2),y=aliveai.nan(pos.y+(dir.y)*2),z=aliveai.nan(pos.z+(dir.z)*2)}
		local plus=1
		local minus=-1
		local param=0
		dir = minetest.dir_to_facedir(dir)
		if dir==1 then param=minetest.get_node({x=pos.x-1,y=pos.y,z=pos.z}).param2 end
		if dir==3 then param=minetest.get_node({x=pos.x+1,y=pos.y,z=pos.z}).param2 end
		if dir==0 then param=minetest.get_node({x=pos.x,y=pos.y,z=pos.z-1}).param2 end
		if dir==2 then param=minetest.get_node({x=pos.x,y=pos.y,z=pos.z+1}).param2 end
		local p=pos
		p.y=p.y+2
		minetest.sound_play("aliveai_aliens_vexcazer_lazer", {pos=p, gain=1.0, max_hear_distance=10})
		for i=2,11,1 do
			local fn = minetest.registered_nodes[minetest.get_node(p).name]
			if not (fn and fn.buildable_to) or minetest.is_protected(p, user:get_player_name()) then
				return itemstack
			end
			minetest.set_node(p,{name="aliveai_aliens:lazer_node",param2=param})
			if dir==1 then p.x=p.x+plus end
			if dir==3 then p.x=p.x+minus end
			if dir==0 then p.z=p.z+plus end
			if dir==2 then p.z=p.z+minus end
			for i, ob in pairs(minetest.get_objects_inside_radius(p, 2)) do
				if type(user)=="table" then user=ob end
				ob:punch(user,1,{full_punch_interval=1,damage_groups={fleshy=5}})
			end
		end
		itemstack:add_wear(65535/50)
		return itemstack
	end,
})

minetest.register_entity("aliveai_aliens:bullet",{
	hp_max = 1,
	physical = false,
	visual = "sprite",
	visual_size = {x=0.1, y=0.1},
	textures = {"bubble.png^[colorize:#ff0000aa"},
	is_visible =true,
	timer = 0,
	dmg=2,
	pointable=false,
	on_activate=function(self, staticdata)
		if not aliveai_aliens.user then
			aliveai.kill(self)
			return
		end
		self.typ=aliveai_aliens.type
		self.user=aliveai_aliens.user
		if self.user:get_luaentity() then
			self.user=self.user:get_luaentity()
		end
		if self.typ==2 then
			self.dmg=5
			self.object:set_properties({nametag="",textures={"bubble.png^[colorize:#51ffe2ff"}})
		end
	end,
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<0.15 then return self end
		local p=self.object:get_pos()
		for i, ob in pairs(minetest.get_objects_inside_radius(p, 1.5)) do
			if not (ob:get_luaentity() and ob:get_luaentity().type==nil) then
				if not self.user then self.user=self.object end
				if self.typ==2 and aliveai_nitroglycerine and aliveai.gethp(ob)<=5 then
					if ob:get_luaentity() then ob:get_luaentity().destroy=1 end
					aliveai_nitroglycerine.freeze(ob)
				else
					ob:punch(self.user,1,{full_punch_interval=1,damage_groups={fleshy=self.dmg}})
				end
				aliveai.kill(self)
				return self
			end
		end
		local n = minetest.registered_nodes[minetest.get_node(p).name]
		if self.timer>2 or (n and n.walkable) then
			aliveai.kill(self)
		end
		return self
	end,
})

minetest.register_entity("aliveai_aliens:bullet2",{
	hp_max = 1,
	physical = false,
	visual = "sprite",
	visual_size = {x=0.3, y=0.3},
	textures = {"bubble.png^[colorize:#ff0000"},
	is_visible =true,
	timer = 0,
	timer2 = 0,
	pointable=false,
	get_staticdata = function(self)
		if self.sound~=nil and self.timer2>0.01 then
			minetest.sound_stop(self.sound)
		end
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if self.sound~=nil then minetest.sound_stop(self.sound) end
	end,
	on_activate=function(self, staticdata)
		if not aliveai_aliens.target then
			aliveai.kill(self)
			return self
		end
		self.target=aliveai_aliens.target
		aliveai_aliens.target=nil
		self.sound=minetest.sound_play("aliveai_aliens_homing", {object=self.object,loop=true,gain=3.0, max_hear_distance=10})
		self.user=aliveai_aliens.user
		aliveai_aliens.user=nil
		if self.user:get_luaentity() then
			self.user=self.user:get_luaentity()
		end
	end,
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<0.01 then return self end
		self.timer2=self.timer2+self.timer
		self.timer=0
		local pos=self.object:get_pos()
		local pos1=self.target:get_pos()
		local n=minetest.registered_nodes[minetest.get_node(pos).name]
		if self.timer2>8 or (n and n.walkable) then
			aliveai.kill(self)
		end
		if not ((pos and pos.x) or (self.target:get_luaentity() or self.target:is_player())) then
			aliveai.kill(self)
			return self
		elseif not aliveai.visiable(pos,pos1) then
			return self
		end
		local v={x=(pos.x-pos1.x)*-2,y=(pos.y-pos1.y)*-2,z=(pos.z-pos1.z)*-2}
		self.object:setvelocity(v)
		if aliveai.distance(self,pos1)<1.5 then
			if not self.user then self.user=self.object end
			self.target:punch(self.user,1,{full_punch_interval=1,damage_groups={fleshy=4}})
			aliveai.kill(self)
			minetest.sound_play("aliveai_aliens_lazer", {pos=pos, gain=1.0, max_hear_distance=10})
		end
		return self
	end,
})


minetest.register_node("aliveai_aliens:lazer_node", {
	description = "Lazer",
	drawtype="glasslike",
	alpha=50,
	tiles = {"gui_hb_bg.png^[colorize:#ffffff"},
	drop="",
	light_source = default.LIGHT_MAX - 1,
	paramtype = "light",
	walkable=false,
	sunlight_propagates = true,
	liquid_viscosity = 1,
	pointable=false,
	buildable_to = true,
	groups = {not_in_creative_inventory=1},
	post_effect_color = {a = 255, r=255, g=255, b=255},
	damage_per_second=2,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function (pos, elapsed)
		minetest.set_node(pos,{name="air"})
	end,
})


minetest.register_node("aliveai_aliens:wsteelblock", {
	description = "Hardened steel block",
	tiles = {"default_steel_block.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 2,not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("aliveai_aliens:ufo_spawner", {
	tiles = {"aliveai_air.png"},
	groups = {not_in_creative_inventory=1},
	sunlight_propagates = true,
	is_ground_content = false,
	drawtype = "glasslike_framed_optional",
	paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
})

minetest.register_node("aliveai_aliens:alien_spawner", {
	description = "Alien group spawner",
	tiles = {"default_diamond_block.png"},
})

minetest.register_node("aliveai_aliens:asteroid", {
	description = "Asteroid",
	tiles = {"aliveai_air.png"},
	groups = {not_in_creative_inventory=1},
	sunlight_propagates = true,
	is_ground_content = false,
	drawtype = "glasslike_framed_optional",
	paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
})


minetest.register_abm({
	nodenames = {"aliveai_aliens:ufo_spawner","aliveai_aliens:alien_spawner","aliveai_aliens:asteroid"},
	interval = 2,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local n=minetest.get_node(pos).name

		minetest.set_node(pos, {name = "air"})

		if n=="aliveai_aliens:alien_spawner" then
			for i=1,7,1 do
				minetest.add_entity(pos, "aliveai_aliens:alien" .. i)
			end
			return
		end

		if n=="aliveai_aliens:asteroid" and minetest.get_modpath("aliveai_nitroglycerine")~=nil then
			if math.random(1,100)~=1 then return end
			local x=math.random(-1,1)
			local z=math.random(-1,1)
			local pos3={}
			local fire={name="aliveai_nitroglycerine:fire2"}
			local id=math.random(1,900)
			aliveai_aliens.atra[id]=0
			for i=1,150,1 do
				pos3={x=pos.x+(x*i),y=pos.y-i,z=pos.z+(z*i)}
				local fn = minetest.registered_nodes[minetest.get_node(pos3).name]
				if minetest.is_protected(pos3,"") then
					aliveai_aliens.atra[id]=nil
					return
				elseif not (fn and fn.buildable_to) or aliveai_aliens.atra[id]==1 or i==150 then
					minetest.after(i*0.05, function(pos3,fire)
						aliveai_aliens.atra[id]=nil
						aliveai_nitroglycerine.explode(pos3,{
							radius=5,
							set="air",
							drops=0,
							place={"aliveai_nitroglycerine:fire","air","air","air","air"}
						})
						minetest.set_node(pos3,{name="aliveai_aliens:alien_spawner"})
						minetest.sound_play("aliveai_nitroglycerine_nuke", {pos=pos3, gain = 0.5, max_hear_distance = 5*30})
					end, pos3,fire)
					return
				end
				minetest.after(i*0.05, function(pos3,fire,id)
					if not aliveai_aliens.atra[id] or aliveai_aliens.atra[id]==1 then return end
					local fn = minetest.registered_nodes[minetest.get_node(pos3).name]
					if not (fn and fn.buildable_to) then aliveai_aliens.atra[id]=1 i=150 print("bug") end
					minetest.set_node(pos3,fire)
					minetest.set_node({x=pos3.x+math.random(-1,1),y=pos3.y,z=pos3.z+math.random(-1,1)},fire)
					minetest.set_node({x=pos3.x+math.random(-1,1),y=pos3.y,z=pos3.z+math.random(-1,1)},fire)
				end, pos3,fire,id)
			end
			return
		end

		if math.random(1,40)~=1 then return end
		for i=1,30,1 do
			if minetest.get_node({x=pos.x,y=pos.y-i,z=pos.z}).name~="air" then return end
		end
		local u=minetest.get_modpath("aliveai_aliens").."/schematics/ufo.mts"
		minetest.place_schematic({x=pos.x-15,y=pos.y,z=pos.z-15}, u, "random", {}, true)
	end,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "aliveai_aliens:ufo_spawner",
	wherein        = "air",
	clust_scarcity = 64 * 64 * 64,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = 30,
	y_max          = 100,
})


minetest.register_ore({
	ore_type       = "scatter",
	ore            = "aliveai_aliens:asteroid",
	wherein        = "air",
	clust_scarcity = 64 * 64 * 64,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = 30,
	y_max          = 100,
})
