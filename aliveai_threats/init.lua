aliveai_threats={c4={},debris={},n=0,tox_obs={},stopacidplayer={}}

dofile(minetest.get_modpath("aliveai_threats") .. "/eyes.lua")
dofile(minetest.get_modpath("aliveai_threats") .. "/sec.lua")
dofile(minetest.get_modpath("aliveai_threats") .. "/lab.lua")
dofile(minetest.get_modpath("aliveai_threats") .. "/flowerattack.lua")
dofile(minetest.get_modpath("aliveai_threats") .. "/crystal.lua")
dofile(minetest.get_modpath("aliveai_threats") .. "/tree.lua")
dofile(minetest.get_modpath("aliveai_threats") .. "/fort.lua")
dofile(minetest.get_modpath("aliveai_threats") .. "/spider.lua")

aliveai_threats.tox=function(ob)

	if not ob or not ob:get_pos() or aliveai.gethp(ob,1)<1 or aliveai.team(ob)=="nuke" then
		if ob and ob:is_player() then
			if aliveai_threats.tox_obs[ob:get_player_name()]==2 then return end
			aliveai_threats.tox_obs[ob:get_player_name()]=nil
		end
		return
	end
	if ob:is_player() then
		if aliveai_threats.tox_obs[ob:get_player_name()]==2 then return end
		aliveai_threats.tox_obs[ob:get_player_name()]=1
	elseif ob:get_luaentity() then
		ob:get_luaentity().aliveai_threats_tox=1
	end
	
	local pos=ob:get_pos()
	for _, obs in ipairs(minetest.get_objects_inside_radius(pos, 4)) do
		if aliveai.visiable(pos,obs:get_pos()) and not ((ob:get_luaentity() and ob:get_luaentity().aliveai_threats_tox) or (ob:is_player() and aliveai_threats.tox_obs[ob:get_player_name()])) then aliveai_threats.tox(obs) end
	end
	aliveai.punchdmg(ob)
	if aliveai.gethp(ob,1)<1 or math.random(1,40)==1 then
		if ob and ob:is_player() then
			local name=ob:get_player_name()
			aliveai_threats.tox_obs[name]=2
			minetest.after(5, function(name)
				aliveai_threats.tox_obs[name]=nil
			end,name)
		elseif ob:get_luaentity() then
			ob:get_luaentity().aliveai_threats_tox=nil
		end
		return
	end

	minetest.after(math.random(1,2), function(ob)
		aliveai_threats.tox(ob)
	end,ob)
end
aliveai.create_bot({
		attack_players=1,
		name="toxic_gassman",
		team="nuke",
		texture="aliveai_threats_gassman.png^[colorize:#00ff0055",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=0,
		hp=100,
		name_color="",
		arm=2,
		coming=0,
		smartfight=0,
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","default:stone"},
		attack_chance=5,
	on_punching=function(self,target)
		aliveai_threats.tox(target)
	end,
	on_blow=function(self)
		aliveai.kill(self)
		self.death(self,self.object,self.object:get_pos())
	end,
	death=function(self,puncher,pos)
			if not self.ex then
				self.ex=true
				aliveai_nitroglycerine.explode(pos,{
				radius=1,
				set="air",
				blow_nodes=0,
				hurt=0
				})
				for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 4)) do
					if aliveai.visiable(pos,ob:get_pos()) then aliveai_threats.tox(ob,1) end
				end
			end
			return self
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		aliveai_threats.tox(puncher)
		minetest.add_particlespawner({
			amount = 5,
			time=0.2,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-0.1, y=-0.1, z=-0.1},
			maxvel = {x=0.1, y=0.1, z=0.1},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 0.5,
			maxsize = 2,
			texture = "default_grass.png^[colorize:#00ff0055",
		})
	end
})



if minetest.get_modpath("aliveai_nitroglycerine")~=nil then

minetest.register_craft({
	output = "aliveai_threats:c4 2",
	recipe = {
		{"default:steel_ingot","default:coal_lump","default:steel_ingot"},
		{"default:steel_ingot","default:mese_crystal_fragment","default:steel_ingot"},
		{"default:steel_ingot","default:copper_ingot","default:steel_ingot"},
	}
})


minetest.register_craftitem("aliveai_threats:c4", {
	description = "C4 bomb",
	inventory_image = "aliveai_threats_c4.png",
		on_use = function(itemstack, user, pointed_thing)
			local name=user:get_player_name()
			local c=aliveai_threats.c4[name]
			if not c and pointed_thing.type=="object" then
				local ob=pointed_thing.ref
				aliveai_threats.c4[user:get_player_name()]=ob
				user:get_inventory():add_item("main","aliveai_threats:c4_controler")
				itemstack:take_item()
			elseif not c then
				aliveai_threats.c4[name]=nil
			end
			return itemstack
		end
})

minetest.register_craftitem("aliveai_threats:c4_controler", {
	description = "C4 controller",
	inventory_image = "aliveai_threats_c4_controller.png",
	groups = {not_in_creative_inventory=1},
		on_use = function(itemstack, user, pointed_thing)
			local name=user:get_player_name()
			local ob=aliveai_threats.c4[name]
			if ob and ob:get_pos() and ob:get_pos().x then
				local pos=ob:get_pos()
				for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 3)) do
					local en=ob:get_luaentity()
					if en and en.aliveai then en.drop_dead_body=0 end
					ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=200}})
				end
				aliveai_nitroglycerine.explode(pos,{
					radius=3,
					set="air",
				})
			else
				user:get_inventory():add_item("main","aliveai_threats:c4")
			end
			aliveai_threats.c4[name]=nil
			itemstack:take_item()
			return itemstack
		end
})


aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="nitrogen",
		team="ice",
		texture="aliveai_threats_nitrogen.png",
		stealing=1,
		steal_chanse=2,
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		start_with_items={["default:snowblock"]=1,["default:ice"]=4},
		type="monster",
		dmg=1,
		hp=40,
		name_color="",
		arm=2,
		spawn_on={"default:silver_sand","default:dirt_with_snow","default:snow","default:snowblock","default:ice"},
	on_step=function(self,dtime)
		local pos=self.object:get_pos()
		pos.y=pos.y-1.5
		local node=minetest.get_node(pos)
		if node and node.name and minetest.is_protected(pos,"")==false then
			if minetest.get_item_group(node.name, "soil")>0 then
				minetest.set_node(pos,{name="default:dirt_with_snow"})
			elseif minetest.get_item_group(node.name, "sand")>0  and minetest.registered_nodes["default:silver_sand"] then
				minetest.set_node(pos,{name="default:silver_sand"})
			elseif minetest.get_item_group(node.name, "water")>0 then
				minetest.set_node(pos,{name="default:ice"})
				pos.y=pos.y+1
				if minetest.get_item_group(minetest.get_node(pos).name, "water")>1 then
					minetest.set_node(pos,{name="default:ice"})
				end
			elseif minetest.get_item_group(node.name, "lava")>0 then
				minetest.set_node(pos,{name="default:ice"})
				pos.y=pos.y+1
				if minetest.get_item_group(minetest.get_node(pos).name, "lava")>1 then
					minetest.set_node(pos,{name="default:ice"})
				end
			end
		end
	end,
	on_punching=function(self,target)
		if aliveai.gethp(target)<=self.dmg+5 then
			aliveai_nitroglycerine.freeze(target)
		else
			target:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=self.dmg}},nil)
		end
	end,
	death=function(self,puncher,pos)
		minetest.sound_play("default_break_glass", {pos=pos, gain = 1.0, max_hear_distance = 5,})
		aliveai_nitroglycerine.crush(pos)
	end,
})

aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="gassman",
		team="nuke",
		texture="aliveai_threats_gassman.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=0,
		hp=100,
		name_color="",
		arm=2,
		coming=0,
		smartfight=0,
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","group:stone"},
		attack_chance=5,
	on_fighting=function(self,target)
		if not self.ti then self.ti={t=1,s=0} end
		self.temper=10
		self.ti.s=self.ti.s-1
		if self.ti.s<=0 then
			self.ti.t=self.ti.t-1
			if self.ti.t>=0 then
				self.ti.s=99
			end
		end
		if self.ti.t<0 then
			local pos=self.object:get_pos()
			self.ex=true
			aliveai.kill(self)
			aliveai_nitroglycerine.explode(pos,{
				radius=10,
				set="air",
				drops=0,
			})
			return self
		end

		local tag=self.ti.t ..":" .. self.ti.s
		self.object:set_properties({nametag=tag,nametag_color="#ff0000aa"})
	end,
	on_blow=function(self)
		aliveai.kill(self)
		self.death(self,self.object,self.object:get_pos())
	end,
	death=function(self,puncher,pos)
			if not self.ex then
				self.hp=0
				self.ex=true
				aliveai_nitroglycerine.explode(pos,{
				radius=2,
				set="air",
				})
			end
			return self
	end,
})



aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="nitrogenblow",
		team="ice",
		texture="aliveai_threats_nitrogenblow.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		start_with_items={["default:snowblock"]=10,["default:ice"]=2},
		spawn_on={"default:silver_sand","default:dirt_with_snow","default:snow","default:snowblock","default:ice"},
		type="monster",
		dmg=1,
		hp=30,
		name_color="",
		arm=2,
		coming=0,
		smartfight=0,
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","group:stone"},
		attack_chance=5,
	on_fighting=function(self,target)
		if aliveai.gethp(target)<=self.dmg+5 then
			aliveai_nitroglycerine.freeze(target)
		elseif math.random(1,10)==1 then
			target:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=self.dmg}},nil)
		end
		if not self.ti then self.ti={t=5,s=9} end
		self.temper=10
		self.ti.s=self.ti.s-1
		if self.ti.s<=0 then
			self.ti.t=self.ti.t-1
			if self.ti.t>=0 then
				self.ti.s=9
			end
		end
		if self.ti.t<0 then
			self.ex=true
			if aliveai.gethp(target)<=11 then
				aliveai_nitroglycerine.freeze(target)
			else
				target:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=10}},nil)
			end
			aliveai_nitroglycerine.crush(self.object:get_pos())
			aliveai.kill(self)
			return self
		end
		local tag=self.ti.t ..":" .. self.ti.s
		self.object:set_properties({nametag=tag,nametag_color="#ff0000aa"})
	end,
	death=function(self,puncher,pos)
			minetest.sound_play("default_break_glass", {pos=pos, gain = 1.0, max_hear_distance = 5,})
			if not self.ex then
				self.ex=true
				self.aliveai_ice=1
				local radius=10
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
							ob:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=dmg}})
						end
					end
				end
			end
			return self
	end,
})

aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="heavygassman",
		team="nuke",
		texture="aliveai_threats_gassman2.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		start_with_items={["default:coal_lump"]=4},
		type="monster",
		dmg=0,
		hp=20,
		name_color="",
		arm=2,
		coming=1,
		smartfight=0,
		attack_chance=1,
	on_fighting=function(self,target)
		if not self.t then self.t=20 end
		self.temper=10
		self.t=self.t-1
		if self.t<0 then
			aliveai.kill(self)
			return self
		end
		self.object:set_properties({nametag=self.t,nametag_color="#ff0000aa"})
	end,
	on_blow=function(self)
		aliveai.kill(self)
		self.death(self,self.object,self.object:get_pos())
	end,
	death=function(self,puncher,pos)
		if not self.ex then
			self.ex=true
			local radius=10
			aliveai_nitroglycerine.explode(pos,{
				radius=radius,
				place={"aliveai_threats:gass","aliveai_threats:gass"},
				set="aliveai_threats:gass",
				place_chance=1,
			})
		end
		return self
	end,
})

minetest.register_node("aliveai_threats:gass", {
	description = "Gass",
	inventory_image = "bubble.png",
	tiles = {"aliveai_air.png"},
	walkable = false,
	pointable = false,
	drowning = 1,
	buildable_to = true,
	drawtype = "glasslike",
	post_effect_color = {a = 248, r =0, g = 0, b = 0},
	damage_per_second = 1,
	paramtype = "light",
	liquid_viscosity = 15,
	liquidtype = "source",
	liquid_range = 0,
	liquid_alternative_flowing = "aliveai_threats:gass",
	liquid_alternative_source = "aliveai_threats:gass",
	groups = {liquid = 4,crumbly = 1,not_in_creative_inventory=1},
	on_blast=function(pos)
		minetest.after(0, function(pos)
			local np=minetest.find_node_near(pos, 3,"aliveai_threats:gass")
			if np then
				aliveai_nitroglycerine.cons({pos=pos,max=5000,replace={["aliveai_threats:gass"]="air"}})
			end
		end,pos)
	end,
})

if minetest.get_modpath("fire")~=nil then

aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="lava",
		team="lava",
		texture="default_lava.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		start_with_items={["default:obsidian"]=1,["default:obsidian_shard"]=3},
		type="monster",
		hp=50,
		dmg=8,
		escape=0,
		name_color="",
		attack_chance=2,
		damage_by_blocks=0,
		spawn_on={"default:lava_source","default:lava_flowing"},
		spawn_in="default:lava_source",
		mindamage=5,
	on_step=function(self,dtime)
		if (self.fight and math.random(1,3)==1) or math.random(1,10)==1 then
			local pos=self.object:get_pos()
			for y=-2,4,1 do
			for x=-2,4,1 do
			for z=-2,4,1 do
				local p1={x=pos.x+x,y=pos.y+y,z=pos.z+z}
				local p2={x=pos.x+x,y=pos.y+y-1,z=pos.z+z}
				local no1=minetest.get_node(p1).name
				local no2=minetest.get_node(p2).name
				if not (minetest.registered_nodes[no1] and minetest.registered_nodes[no2]) then return end
				if minetest.get_item_group(no1, "igniter")==0 and minetest.registered_nodes[no1].buildable_to and minetest.registered_nodes[no2].walkable and aliveai.visiable(pos,p1) then
					minetest.set_node(p1, {name = "fire:basic_flame"})
				end
			end
			end
			end
		end
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
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
			minsize = 0.1,
			maxsize = 2,
			texture = "default_lava.png",
			collisiondetection = true,
		})
	end,
	death=function(self,puncher,pos)
		if not self.ex then
			self.ex=true
			aliveai_nitroglycerine.explode(pos,{
				radius=7,
				place={"fire:basic_flame","fire:basic_flame"},
			})
		end
		return self
	end,
})


aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="fire",
		team="lava",
		texture="fire_basic_flame.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		start_with_items={["default:obsidian"]=1,["default:obsidian_shard"]=3},
		type="monster",
		hp=30,
		name_color="",
		attack_chance=2,
		damage_by_blocks=0,
		spawn_on={"fire:basic_flame"},
		dmg=5,
		escape=0,
		mindamage=5,
	on_step=function(self,dtime)
		if (self.fight and math.random(1,3)==1) or math.random(1,10)==1 then
			local pos=self.object:get_pos()
			for y=-1,1,1 do
			for x=-1,1,1 do
			for z=-1,1,1 do
				local p1={x=pos.x+x,y=pos.y+y,z=pos.z+z}
				local p2={x=pos.x+x,y=pos.y+y-1,z=pos.z+z}
				local no1=minetest.get_node(p1).name
				local no2=minetest.get_node(p2).name
				if not (minetest.registered_nodes[no1] and minetest.registered_nodes[no2]) then return end
				if minetest.get_item_group(no1, "igniter")==0 and minetest.registered_nodes[no1].buildable_to and minetest.registered_nodes[no2].walkable and aliveai.visiable(pos,p1) then
					minetest.set_node(p1, {name = "fire:basic_flame"})
				end
			end
			end
			end
		end
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
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
			minsize = 0.1,
			maxsize = 2,
			texture = "fire_basic_flame.png",
			collisiondetection = true,
		})
	end,
	death=function(self,puncher,pos)
		if not self.ex then
			self.ex=true
			aliveai_nitroglycerine.explode(pos,{
				radius=5,
				place={"fire:basic_flame","fire:basic_flame"},
			})
		end
		return self
	end,
})
end


end

aliveai.create_bot({
		attack_players=1,
		name="terminator",
		team="nuke",
		texture="aliveai_threats_terminator.png",
		attacking=1,
		talking=0,
		building=0,
		escape=0,
		start_with_items={["default:steel_ingot"]=4,["default:steelblock"]=1},
		type="monster",
		dmg=0,
		hp=200,
		arm=3,
		name_color="",
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","group:stone"},
		attack_chance=5,
		mindamage=5,
	on_punching=function(self,target)
		local pos=self.object:get_pos()
		pos.y=pos.y-0.5
		local radius=self.arm
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
			local pos2=ob:get_pos()
			local d=math.max(1,vector.distance(pos,pos2))
			local dmg=(8/d)*radius
			local en=ob:get_luaentity()
			if ob:is_player() or not (en and en.team==self.team or ob.itemstring) then
				if en and en.object then
					if en.type~="" then ob:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=dmg}},nil) end
					dmg=dmg*2
					ob:set_velocity({x=(pos2.x-pos.x)*dmg, y=((pos2.y-pos.y)*dmg)+2, z=(pos2.z-pos.z)*dmg})
				elseif ob:is_player() then
					ob:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=dmg}},nil)
					local d=dmg/2
					local v=0
					local dd=0
					local p2={x=pos.x-pos2.x, y=pos.y-pos2.y, z=pos.z-pos2.z}
					local tmp
					for i=0,10,1 do
						dd=d*v
						tmp={x=pos.x+(p2.x*dd), y=pos.y+(p2.y*dd)+2, z=pos.z+(p2.z*dd)}
						local n=minetest.get_node(tmp)
						if n and n.name and minetest.registered_nodes[n.name].walkable then
							if minetest.is_protected(tmp,"")==false and minetest.dig_node(tmp) then
								for _, item in pairs(minetest.get_node_drops(n.name, "")) do
									if item then
										local it=minetest.add_item(tmp, item)
										it:get_luaentity().age=890
										it:set_velocity({x = math.random(-1, 1),y=math.random(-1, 1),z = math.random(-1, 1)})
									end
								end
							else
								break
							end
						end
						v=v-0.1
					end
					d=d*v
					ob:set_pos({x=pos.x+(p2.x*d), y=pos.y+(p2.y*d)+2, z=pos.z+(p2.z*d)})
				end
			end
		end
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
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
			minsize = 0.1,
			maxsize = 2,
			texture = "default_steel_block.png",
			collisiondetection = true,
			spawn_chance=100,
		})
	end
})



aliveai.create_bot({
		attack_players=1,
		name="pull_monster",
		team="pull",
		texture="aliveai_threats_pull.png",
		visual_size={x=0.8,y=1.4},
		collisionbox={-0.33,-1.3,-0.33,0.33,1.5,0.33},
		attacking=1,
		talking=0,
		light=-1,
		lowest_light=9,
		building=0,
		smartfight=0,
		escape=0,
		type="monster",
		dmg=0,
		hp=80,
		arm=2,
		name_color="",
		spawn_on={"group:sand","group:spreading_dirt_type","group:stone","default:snow"},
		attack_chance=3,
		spawn_chance=200,
		spawn_y=1,
	on_punching=function(self,target)
		if not self.pull_down then
			local pos=aliveai.roundpos(target:get_pos())
			local n=minetest.get_node(pos)
			if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].walkable then return end
			pos.y=pos.y-1
			self.pull_down={pos={pos0=pos}}
			local p
			for i=1,3,1 do
				p={x=pos.x,y=pos.y-i,z=pos.z}
				n=minetest.get_node(p)
				self.pull_down.pos["pos" .. i]=p
				if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].walkable==false then
					self.pull_down=nil
					return
				end
			end
			self.pull_down.target=target
		end
	end,
	on_detect_enemy=function(self,target)
		self.object:set_properties({
			mesh = aliveai.character_model,
			textures = {"aliveai_threats_pull.png"},
		})
	end,
	on_load=function(self)
		self.move.speed=0.5
		local pos=aliveai.roundpos(self.object:get_pos())
		local n=minetest.get_node(pos)
		if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].walkable then
			pos.y=pos.y+3
			local l=minetest.get_node_light(pos)
			if not l then return end
			local n=minetest.get_node(pos)
			if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].walkable then
				self.domovefromslp=true
				return self
			elseif l>9 then
				self.sleep={ground=pos}
				return self
			else
				self.domovefromslp=true
				return self
			end
		end
	end,
	on_step=function(self,dtime)
		if self.movefromslp then
			aliveai.rndwalk(self,false)
			aliveai.stand(self)
			for i, v in pairs(self.movefromslp) do
				self.object:move_to(v)
				table.remove(self.movefromslp,i)
				return self
			end
			self.movefromslp=nil
			return self
		end
		if self.domovefromslp then
			self.domovefromslp=nil
			local pos=self.object:get_pos()
			local gpos={x=pos.x,y=pos.y+3,z=pos.z}
			local n=minetest.get_node(gpos)
			if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].walkable then
				self.movefromslp={} -- move up from stuck sleep pos
				local p3=0
				for i=1,103,1 do
					local p={x=gpos.x,y=gpos.y+i,z=gpos.z}
					local n=minetest.get_node(p)
					self.movefromslp[i]=p
					if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].walkable==false then
						p3=p3+1
						if p3>2 then
							self.sleep=nil
							return self
						end
					else
						p3=0
					end
				end
				aliveai.kill(self)
				return self
			end
		end
		if self.sleep then
			local pos=aliveai.roundpos(self.object:get_pos())
			if self.sleep.pos then
				if self.sleep.pos.pos0 then
					self.object:move_to(self.sleep.pos.pos0)
					self.sleep.pos.pos0=nil
				elseif self.sleep.pos.pos1 then
					self.object:move_to(self.sleep.pos.pos1)
					self.sleep.pos.pos1=nil
				elseif self.sleep.pos.pos2 then
					self.object:move_to(self.sleep.pos.pos2)
					self.sleep.pos=nil
				end
				if not self.pull_down then return self end
			end
			if self.pull_down then
				if self.pull_down.target and self.pull_down.pos then
					if self.pull_down.pos.pos0 and not (self.sleep.pos and self.sleep.pos.pos2) then 
						self.pull_down=nil
						self.sleep=nil
						return
					end
					if self.pull_down.pos.pos0 then
						self.pull_down.target:move_to(self.pull_down.pos.pos0)
						self.pull_down.pos.pos0=nil
					elseif self.pull_down.pos.pos1 then
						self.pull_down.target:move_to(self.pull_down.pos.pos1)
						self.pull_down.pos.pos1=nil
					elseif self.pull_down.pos.pos2 then
						self.pull_down.target:move_to(self.pull_down.pos.pos2)
						self.pull_down.pos=nil
					end
					return self
				end
				if self.pull_down.target and aliveai.gethp(self.pull_down.target)>0 and aliveai.distance(self,self.pull_down.target:get_pos())<=self.arm+1 then
					aliveai.punch(self,self.pull_down.target,1)
					if aliveai.gethp(self.pull_down.target)<=0 then
						self.object:set_hp(self.hp_max)
						aliveai.showhp(self,true)
						self.domovefromslp=true
					end
					return self
				else
					self.sleep=nil
					self.pull_down=nil
					return
				end
			end
			if self.hide then
				self.time=self.otime
				if math.random(1,2)==1 then
					if not self.abortsleep then
						for _, ob in ipairs(minetest.get_objects_inside_radius(self.sleep.ground, 10)) do
							local en=ob:get_luaentity()
							if not (en and en.aliveai and en.team==self.team) then
								return self
							end
						end
					end
					self.hide=nil
					self.pull_down=nil
					self.domovefromslp=true
				end
				if self.hide then return self end
			end
			local l=minetest.get_node_light(self.sleep.ground)
			if not l then
				aliveai.kill(self)
				self.sleep=nil
				self.domovefromslp=true
				return self
			elseif l<=9 or self.abortsleep then
				self.domovefromslp=true
			else
				if math.random(1,10)==1 then
					for _, ob in ipairs(minetest.get_objects_inside_radius(self.sleep.ground, self.distance)) do
						local en=ob:get_luaentity()
						if not (en and en.aliveai and en.team==self.team) then
							return self
						end
					end
					aliveai.kill(self)
				end
				return self
			end
		elseif math.random(1,10)==1 or self.pull_down or self.hide then
			local pos=aliveai.roundpos(self.object:get_pos())
			pos.y=pos.y-1
			local l=minetest.get_node_light(pos)
			if not l then return end
			if l>9 or self.pull_down or self.hide then
				local p
				self.sleep={ground=pos,pos={pos0=pos}}
				for i=1,3,1 do
					p={x=pos.x,y=pos.y-i,z=pos.z}
					local n=minetest.get_node(p)
					self.sleep.pos["pos" .. i]=p
					if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].walkable==false then
						self.sleep=nil
						self.pull_down=nil
						return
					end
				end
				aliveai.rndwalk(self,false)
				aliveai.stand(self)
				return self
			end
		elseif math.random(1,10)==1 then
			local pos=self.object:get_pos()
			pos.y=pos.y-1.5
			local n=minetest.get_node(pos)
			if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].tiles then
				local tiles=minetest.registered_nodes[n.name].tiles
				if type(tiles)=="table" and type(tiles[1])=="string" then
				self.tex=tiles[1]
				self.object:set_properties({
					mesh = aliveai.character_model,
					textures = {tiles[1]},
				})
				end
			end 
		end
	end,
	on_punched=function(self,puncher)
		self.object:set_properties({
			mesh = aliveai.character_model,
			textures = {"aliveai_threats_pull.png"},
		})
		local pos=self.object:get_pos()
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
			minsize = 0.1,
			maxsize = 2,
			texture = self.tex or "default_dirt.png",
			collisiondetection = true,
		})
		self.tex=nil
		if self.sleep or self.hide then self.abortsleep=true end
		if self.hide or not self.fight then return end
		if not self.ohp then self.ohp=self.object:get_hp()*0.8 return end
		if self.ohp>self.object:get_hp() then
			local pos=self.object:get_pos()
			local n=minetest.get_node(pos)
			if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].walkable then return end
			self.hide=true
			self.ohp=nil
			self.time=0.2
			self.pull_down=nil
			return self
		end
	end
})

minetest.register_craft({
	output = "aliveai_threats:mind_manipulator",
	recipe = {
		{"default:steel_ingot", "default:papyrus"},
		{"default:steel_ingot", "default:mese_crystal"},
		{"default:steel_ingot", "default:obsidian_glass"},
	}
})

minetest.register_tool("aliveai_threats:mind_manipulator", {
	description = "Mind manipulator",
	inventory_image = "aliveai_threats_mind_manipulator.png",
		on_use = function(itemstack, user, pointed_thing)
			if pointed_thing.type=="object" then
				local ob=pointed_thing.ref
				if ob:get_luaentity() and ob:get_luaentity().type and ob:get_luaentity().type=="monster" then
					ob:get_luaentity().team="mind_manipulator" .. math.random(1,100)
				elseif ob:get_luaentity() then
					ob:get_luaentity().type="monster"
					ob:get_luaentity().team="mind_manipulator" .. math.random(1,100)
					ob:get_luaentity().attack_players=1
					ob:get_luaentity().attacking=1
					ob:get_luaentity().talking=0
					ob:get_luaentity().light=0
					ob:get_luaentity().building=0
					ob:get_luaentity().fighting=1
					ob:get_luaentity().attack_chance=2
					ob:get_luaentity().temper=3
--support for other mobs
					ob:get_luaentity().attack_type="dogfight"
					ob:get_luaentity().reach=2
					ob:get_luaentity().damage=3
					ob:get_luaentity().view_range=10
					ob:get_luaentity().walk_velocity= ob:get_luaentity().walk_velocity or 2
					ob:get_luaentity().run_velocity= ob:get_luaentity().run_velocity or 2
				elseif ob:is_player() then
					ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=5}},nil)
						ob:set_properties({
							mesh = aliveai.character_model,
							textures = {"aliveai_threats_mind_manipulator.png"}
						})
					if ob:get_hp()<=0 and aliveai.registered_bots["bot"] and aliveai.registered_bots["bot"].bot=="aliveai:bot" then
						local tex=ob:get_properties().textures
						local pos=ob:get_pos()
						local m=minetest.add_entity(pos, "aliveai:bot")
						m:get_luaentity().attack_chance=2
						m:get_luaentity().type="monster"
						m:get_luaentity().team="mind_manipulator" .. math.random(1,100)
						m:get_luaentity().attack_players=1
						m:get_luaentity().attacking=1
						m:get_luaentity().talking=0
						m:get_luaentity().light=0
						m:get_luaentity().building=0
						m:get_luaentity().fighting=1
						m:set_yaw(math.random(0,6.28))
						m:set_properties({
							mesh = aliveai.character_model,
							textures = tex
						})
					end
				end
			itemstack:add_wear(65536/10)
			return itemstack
			end
		end
})



aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="cockroach",
		team="bug",
		texture={"aliveai_threats_cockroach.png","aliveai_threats_cockroach.png","aliveai_threats_cockroach.png","aliveai_threats_cockroach.png","aliveai_threats_cockroach.png","aliveai_threats_cockroach.png"},
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=1,
		hp=4,
		name_color="",
		arm=2,
		coming=0,
		smartfight=0,
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","group:stone"},
		attack_chance=2,
		visual="cube",
		visual_size={x=0.4,y=0.001},
		collisionbox={-0.1,0,-0.1,0.2,0.1,0.2},
		basey=0,
		distance=10,
		spawn_y=2,
	on_load=function(self)
		if self.save__clone then
			self.object:remove()
		end
	end,
	on_step=function(self,dtime)
		if self.fight then
			local pos=aliveai.roundpos(self.object:get_pos())
			local n=0
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 20)) do
				local en=ob:get_luaentity()
				if en and en.name=="aliveai_threats:cockroach" then
					n=n+1
				end
			end
			if n<10 then
				for y=-2,5,1 do
				for x=-2,2,1 do
				for z=-2,2,1 do
					local p1={x=pos.x+x,y=pos.y+y,z=pos.z+z}
					local p2={x=pos.x+x,y=pos.y+y-1,z=pos.z+z}
					local no1=minetest.get_node(p1).name
					local no2=minetest.get_node(p2).name
					if not (minetest.registered_nodes[no1] and minetest.registered_nodes[no2]) then return end
					if minetest.registered_nodes[no1].walkable==false and minetest.registered_nodes[no2].walkable
					and aliveai.visiable(pos,p1) then
						local e=minetest.add_entity(p1,"aliveai_threats:cockroach")
						e:get_luaentity().save__clone=1
						e:get_luaentity().fight=self.fight
						e:get_luaentity().temper=3
						e:set_yaw(math.random(0,6.28))
						n=n+1
						if n>=10 then
							return
						end
					end
					end
					end
				end
			end
		elseif self.save__clone and not self.fight then
			aliveai.kill(self)
		end
	end,
	click=function(self,clicker)
		clicker:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=self.object:get_hp()*2}},nil)
	end,
	death=function(self,puncher,pos)
		local pos=self.object:get_pos()
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
			minsize = 0.1,
			maxsize = 1,
			texture = "default_dirt.png^[colorize:#000000cc",
			collisiondetection = true,
		})
		return self
	end,
})


aliveai.create_bot({
		attack_players=1,
		name="ninja",
		team="bug",
		texture="aliveai_threats_ninja.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		start_with_items={["default:sword_steel"]=1},
		type="",
		hp=30,
		name_color="",
		attack_chance=2,
	on_step=function(self,dtime)
		if not self.finvist and (self.fight or self.fly) then
			self.finvist=true
				self.object:set_properties({
					is_visible=false,
					makes_footstep_sound=false,
					textures={"aliveai_threats_i.png","aliveai_threats_i.png","aliveai_threats_i.png"}
				})
		elseif self.finvist and not (self.fight or self.fight) then
			self.finvist=nil
			self.object:set_properties({
				is_visible=true,
				makes_footstep_sound=true,
				textures={"aliveai_threats_ninja.png","aliveai_threats_i.png","aliveai_threats_i.png"}
			})
		elseif self.finvist and self.fight then
			if math.random(1,10)<3 then
				self.object:set_properties({is_visible=true})
			else
				self.object:set_properties({is_visible=false})

				if math.random(1,5)==1 then
					local pos=self.object:get_pos()
					for _, ob in ipairs(minetest.get_objects_inside_radius(pos, self.distance/2)) do
						local en=ob:get_luaentity()
						if en and en.aliveai and en.fight and en.fight:get_luaentity() and en.fight:get_luaentity().aliveai and en.fight:get_luaentity().botname==self.botname then
							ob:get_luaentity().fight=nil
						end
					end
				end

			end
		end
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		if self.finvist then
			self.finvist=nil
			self.object:set_properties({
				is_visible=true,
				makes_footstep_sound=true,
				textures={"aliveai_threats_ninja.png","aliveai_threats_i.png","aliveai_threats_i.png"},
			})
		end
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
			minsize = 0.1,
			maxsize = 2,
			texture = "default_dirt.png^[colorize:#000000cc",
			collisiondetection = true,
		})
	end
})

minetest.register_tool("aliveai_threats:quantumcore", {
	description = "Quantum core",
	inventory_image = "aliveai_threats_quantumcore.png",
	range = 15,
	on_use=function(itemstack, user, pointed_thing)
		if user:get_luaentity() then user=user:get_luaentity() end
		local type=pointed_thing.type
		if type=="node" or type=="object" then
			local pos=pointed_thing.above
			if type=="object" then
				pos=pointed_thing.ref:get_pos()
			end
			local n1=minetest.registered_nodes[minetest.get_node(pos).name]
			pos.y=pos.y+1
			local n2=minetest.registered_nodes[minetest.get_node(pos).name]
			if n1 and n2 and not (n1.walkable and n2.walkable) then
				user:set_pos(pos)
			end
		else
			local p=aliveai.random_pos(user:get_pos(),15)
			if p then user:set_pos(p) end
		end

	end,
	on_place=function(itemstack, user, pointed_thing)
		local p=aliveai.random_pos(user:get_pos(),15)
		if p then user:set_pos(p) end	
	end
})

aliveai.create_bot({
		attack_players=1,
		name="quantum_monster",
		team="bug",
		texture="aliveai_threats_quantum_monster.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		start_with_items={["aliveai_threats:quantumcore"]=1},
		type="",
		hp=40,
		name_color="",
		visual_size={x=1,y=1.4},
		collisionbox={-0.33,-1.3,-0.33,0.33,1.2,0.33},
		spawn_y=1,
	on_step=function(self,dtime)
		if self.fight and not self.fly and (math.random(1,5)==1 or self.epunched) then
			self.epunched=nil
			local p=aliveai.roundpos(self.fight:get_pos())
			if not p then self.fight=nil return end
			local pos={x=p.x+math.random(-1,4),y=p.y,z=p.z+math.random(-1,4)}
			for i=-2,2,1 do
				local pos1={x=pos.x,y=pos.y+i,z=pos.z}
				local pos2={x=pos.x,y=pos.y+i+1,z=pos.z}
				local pos3={x=pos.x,y=pos.y+i+2,z=pos.z}
				local pos4={x=pos.x,y=pos.y+i+3,z=pos.z}

				local n1=minetest.registered_nodes[minetest.get_node(pos1).name]
				local n2=minetest.registered_nodes[minetest.get_node(pos2).name]
				local n3=minetest.registered_nodes[minetest.get_node(pos3).name]
				local n4=minetest.registered_nodes[minetest.get_node(pos4).name]

				if n2 and n2.walkable==false and n1 and n3 and n4 and n1.walkable and not (n3.walkable and n4.walkable) then
					pos2.y=pos2.y+1
					self.object:set_pos(pos2)
				end
			end
		elseif self.fly and (self.epunched or aliveai.distance(self,self.fly:get_pos())<self.distance) then
			self.epunched=nil
			local p=aliveai.random_pos(self.fly:get_pos(),15)
			if p then self.object:set_pos(p) end
		end

		local p=self.object:get_pos()
		minetest.add_particlespawner({
			amount = 20,
			time =1,
			minpos = {x=p.x+1,y=p.y+1,z=p.z+1},
			maxpos = {x=p.x-1,y=p.y-1,z=p.z-1},
			minvel = {x=0, y=0, z=0},
			maxvel = {x=0, y=0, z=0},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 0.4,
			maxsize = 0.8,
			glow=13,
			texture = "aliveai_threats_quantum_monster_lights.png",
		})

	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		self.epunched=true
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
			minsize = 0.1,
			maxsize = 2,
			texture = "default_dirt.png^[colorize:#000000cc",
			collisiondetection = true,
		})
	end
})

minetest.register_globalstep(function(dtime)
	for i, o in pairs(aliveai_threats.debris) do
		if o.ob and o.ob:get_luaentity() and o.ob:get_hp()>0 and o.ob:get_velocity().y~=0 then
			for ii, ob in pairs(minetest.get_objects_inside_radius(o.ob:get_pos(), 1.5)) do
				local en=ob:get_luaentity()
				if not en or (en.name~="__builtin:item" and not (en.aliveai and en.botname==o.n) ) then
					ob:punch(o.ob,1,{full_punch_interval=1,damage_groups={fleshy=1}})
					o.ob:set_velocity({x=0, y=0, z=0})
					if o.on_hit_object then
						o.on_hit_object(o.ob:get_luaentity(),o.ob:get_pos(),ob)
					end
					table.remove(aliveai_threats.debris,i)
					break
				end
			end
		else

			if o and o.on_hit_ground and o.ob:get_velocity() and o.ob:get_velocity().y==0 then
				o.on_hit_ground(o.ob:get_luaentity(),o.ob:get_pos())
			end
			table.remove(aliveai_threats.debris,i)
		end
	end
end)


aliveai.create_bot({
		attack_players=1,
		name="natural_monster",
		team="natural",
		texture="aliveai_threats_natural_monster.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		type="monster",
		hp=10,
		name_color="",
		collisionbox={-0.5,-0.5,-0.5,0.5,0.5,0.5},
		visual="cube",
		basey=-0.5,
		drop_dead_body=0,
		escape=0,
		spawn_on={"group:sand","group:soil","default:snow","default:snowblock","default:ice","group:leaves","group:tree","group:stone","group:cracky","group:level","group:crumbly","group:choppy"},
		attack_chance=2,
		spawn_y=0,
	spawn=function(self)
		local pos=self.object:get_pos()
		pos.y=pos.y-1.5
		if minetest.get_node(pos).name=="aliveai:spawner" then pos.y=pos.y-1 end
		local drop=minetest.get_node_drops(minetest.get_node(pos).name)[1]
		local n=minetest.registered_nodes[minetest.get_node(pos).name]
		if not (n and n.walkable) or drop=="" or type(drop)~="string" then self.object:remove() return self end
		local t=n.tiles
		if not t[1] then self.object:remove() return self end
		local tx={}
		self.save__t1=t[1]
		self.save__t2=t[1]
		self.save__t3=t[1]
		self.save__natural_monster=1
		self.save__consists=drop
		self.team=self.save__consists
		if t[2] then self.save__t2=t[2] self.save__t3=t[2] end
		if t[3] and t[3].name then self.save__t3=t[3].name
		elseif t[3] then self.save__t3=t[3]
		end
		if type(self.save__t3)=="table" then return end
		tx[1]=self.save__t1
		tx[2]=self.save__t2
		tx[3]=self.save__t3
		tx[4]=self.save__t3
		tx[5]=self.save__t3 .."^aliveai_threats_natural_monster.png"
		tx[6]=self.save__t3
		self.object:set_properties({textures=tx})
		self.cctime=0
	end,	
	on_load=function(self)
		if self.save__natural_monster then
			local tx={}
			tx[1]=self.save__t1
			tx[2]=self.save__t2
			tx[3]=self.save__t3
			tx[4]=self.save__t3
			tx[5]=self.save__t3 .."^aliveai_threats_natural_monster.png"
			tx[6]=self.save__t3
			self.object:set_properties({textures=tx})
			self.team=self.save__consists
			self.cctime=0
		else
			self.object:remove()
		end
	end,
	on_step=function(self,dtime)
		if self.fight and (self.cctime<1 or self.time==self.otime) then
			self.cctime=5
			local d=aliveai.distance(self,self.fight:get_pos())
			if not (d>4 and d<self.distance and aliveai.viewfield(self,self.fight) and aliveai.visiable(self,self.fight:get_pos())) then return end
			local pos=self.object:get_pos()
			local ta=self.fight:get_pos()
			if not (ta and pos) then return end
			aliveai.stand(self)
			aliveai.lookat(self,ta)

			local e=minetest.add_item({x=pos.x,y=pos.y,z=pos.z},self.save__consists)
			local dir=aliveai.get_dir(self,ta)
			local vc = {x = dir.x*30, y = dir.y*30, z = dir.z*30}
			e:set_velocity(vc)

			e:get_luaentity().age=(tonumber(minetest.settings:get("item_entity_ttl")) or 900)-2
			table.insert(aliveai_threats.debris,{ob=e,n=self.botname})
			return self
		elseif self.fight and self.cctime>1 then
			self.cctime=self.cctime-1
		end
	end,
	death=function(self,puncher,pos)
		aliveai.invadd(self,self.save__consists,math.random(1, 4),false)
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		aliveai.lookat(self,pos)
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
			minsize = 0.2,
			maxsize = 4,
			texture = self.save__t1,
			collisiondetection = true,
		})
	end
})

aliveai.create_bot({
		type="monster",
		name="stubborn_monster",
		texture="aliveai_threats_stubborn_monster.png",
		hp=20,
		drop_dead_body=0,
		usearmor=0,
	on_load=function(self)
		self.save__hp_max=self.save__hp_max or 20
		if not self.save__body or self.save__killed then self.spawn(self) return self end
		local s={}
		local c=""
		local t=""
		for i,v in ipairs(self.save__body) do
			s["s"..v]=v
			if i>1 then c="^" end
			t=t .. c.. "aliveai_threats_stubborn_monster" .. v ..".png"
		end
		self.object:set_properties({
				mesh = aliveai.character_model,
				textures = {t,"aliveai_threats_i.png","aliveai_threats_i.png"},
		})
		if not s["s3"] then self.nhead=true end
		self.spawn(self)
	end,
	spawn=function(self)
		if not self.save__body then
			self.save__body={1,2,3}
		end
		self.save__hp_max=self.save__hp_max or 20
		self.hp2=self.object:get_hp()
		self.deadtimer=10
		self.hurted=0
		if self.save__killed then
			self.attack_players=1
			self.attacking=1
			self.team="stubborn"
			self.talking=0
			self.light=0
			self.building=0
			self.type="monster"
			self.escape=0
			self.attack_chance=1
			self.smartfight=0
		end

	end,
	on_step=function(self,dtime)
		if self.dead1 then
			self.time=self.otime
			self.deadtimer=self.deadtimer-1
			if self.deadtimer<0 then 
				self.object:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=self.hp*2}},nil)
			end
			return self
		end
		if self.lay then
			self.time=self.otime
			if math.random(0,5)==1 then
				aliveai.anim(self,"stand")
				self.lay=nil
			end
			return self
		end
		if self.nhead then
			self.fight=nil
			self.fly=nil
			self.temper=0
			self.come=nil
		end
	end,
	on_punched=function(self,puncher,h) 
		self.hurted=h
	end,
	death=function(self,puncher,pos)
		local r=math.random(1,5)
		if r>3 then
			if self.basey==-0.5 then local pos=self.object:get_pos() self.object:set_pos({x=pos.x,y=pos.y+1,z=pos.z}) end
			aliveai.anim(self,"lay")
			self.lay=true
		end
		if r<3 or not self.save__killed then
			r=math.random(1,3)
			table.remove(self.save__body,r)
			local t=""
			local c=""
			local c2=0
			for i,v in ipairs(self.save__body) do
				if i>1 then c="^" end
				t=t .. c.. "aliveai_threats_stubborn_monster" .. v ..".png"
				c2=i
			end
			self.object:set_properties({
				mesh = aliveai.character_model,
				textures = {t,"aliveai_threats_i.png","aliveai_threats_i.png"},
			})
			if r==1 or c2==1 or self.hurted>self.save__hp_max then
				if self.basey==-0.5 then self.object:set_properties({mesh = aliveai.character_model}) local pos=self.object:get_pos() self.object:set_pos({x=pos.x,y=pos.y+1,z=pos.z}) end
				aliveai.anim(self,"lay")
				self.object:set_hp(self.save__hp_max)
				self.hp=self.save__hp_max
				self.dead1=true
				return self
			end
			if r==3 then self.nhead=true end
			if not self.save__killed then
				self.save__killed=1
				self.spawn(self)
			end
		end
		if not self.dead1 then
			self.save__hp_max=self.save__hp_max-2
			self.object:set_hp(self.save__hp_max)
			self.hp=self.save__hp_max
		end
	end
})


aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="slime",
		team="slime",
		texture="aliveai_threats_slime.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		start_with_items={["aliveai_threats:slime"]=2},
		type="monster",
		dmg=2,
		hp=10,
		name_color="",
	on_punch_hit=function(self,target)
		if self.setslime and aliveai.gethp(target)<1 then
			local e=minetest.add_entity(self.setslime, "aliveai_threats:slime")
			if self.fight and self.fight:get_luaentity() then
				e:set_properties({
					visual_size=target:get_properties().visual_size,
					collisionbox=target:get_properties().collisionbox
				})
				if aliveai.is_bot(self.fight) then
					aliveai.anim(self.fight:get_luaentity(),"lay")
				end
				self.setslime=nil
				self.fight:remove()
				self.fight=nil
			end
		end
	end,
	on_punching=function(self,target)
		self.setslime=target:get_pos()
	end,
	death=function(self,puncher,pos)
		minetest.add_particlespawner({
		amount = 15,
		time =0.1,
		minpos = pos,
		maxpos = pos,
		minvel = {x=-2, y=-2, z=-2},
		maxvel = {x=2, y=2, z=2},
		minacc = {x=0, y=-8, z=0},
		maxacc = {x=0, y=-10, z=0},
		minexptime = 2,
		maxexptime = 1,
		minsize = 0.1,
		maxsize = 3,
		texture =  "default_dirt.png^[colorize:#00aa00aa",
		collisiondetection = true,
		})
	end,
})

minetest.register_node("aliveai_threats:slime", {
	description = "Slime",
	tiles = {"default_river_water.png^[colorize:#00aa00aa"},
	alpha = 200,
	walkable = false,
	pointable = true,
	drowning = 1,
	buildable_to = true,
	drawtype = "glasslike",
	post_effect_color = {a = 248, r =0, g = 255, b = 0},
	damage_per_second = 1,
	paramtype = "light",
	liquid_viscosity = 15,
	liquidtype = "source",
	liquid_range = 0,
	liquid_alternative_flowing = "aliveai_threats:slime",
	liquid_alternative_source = "aliveai_threats:slime",
	groups = {liquid = 4,crumbly = 1,not_in_creative_inventory=1}
})

aliveai.create_bot({
		name="killerplant",
		type="",
		texture="default_grass_5.png^[colorize:#00ff0022",
		talking=0,
		light=0,
		building=0,
		type="monster",
		name_color="",
		collisionbox={-0.5,-0.5,-0.5,0.5,0.5,0.5},
		visual="cube",
		basey=-0.5,
		drop_dead_body=0,
		spawn_on={"group:sand","group:soil","group:stone","group:cracky","group:level","group:crumbly","group:choppy"},
		spawn_y=0,
	spawn=function(self)
		local pos=self.object:get_pos()
		local opos=pos
		local npos
		local n
		for i=0,10,1 do
			npos={x=pos.x,y=pos.y-i,z=pos.z,}
			n=minetest.registered_nodes[minetest.get_node(npos).name]
			if n and n.walkable then
				minetest.set_node(opos,{name="aliveai_threats:killerplant"})
				aliveai.kill(self)
				return
			end
			opos=npos
		end
		aliveai.kill(self)
	end,	
})


minetest.register_node("aliveai_threats:killerplant", {
	description = "Killerplant",
	groups = {attached_node=1,choppy = 1,not_in_creative_inventory=1},
	tiles = {"default_grass_5.png^[colorize:#00ff0022"},
	paramtype="light",
	walkable=false,
	sounds = default.node_sound_leaves_defaults(),
	drawtype = "plantlike",
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
	},
	on_construct = function(pos)
		local meta=minetest.get_meta(pos)
		meta:set_string("owner","plant")
		minetest.get_node_timer(pos):start(3)
	end,
	on_timer = function (pos, elapsed)
		for i, ob in pairs(minetest.get_objects_inside_radius({x=pos.x,y=pos.y-2.5,z=pos.z}, 2)) do
			ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=1}})
		end
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do
			minetest.sound_play("default_grass_footstep", {pos=pos,max_hear_distance = 10, gain = 0.5})
			ob:move_to({x=pos.x,y=pos.y-3,z=pos.z})
		end
		return true
	end,
})


aliveai.create_bot({
		attack_players=1,
		name="bee",
		team="bug",
		floating=1,
		texture={"aliveai_threats_bee.png","aliveai_threats_bee.png","aliveai_threats_bee.png","aliveai_threats_bee.png","aliveai_threats_bee.png","aliveai_threats_bee.png"},
		attacking=1,
		talking=0,
		light=0,
		building=0,
		type="monster",
		hp=2,
		name_color="",
		collisionbox={-0.2,-0.2,-0.2,0.2,0.2,0.2},
		visual_size={x=0.1,y=0.1},
		visual="cube",
		basey=-0.5,
		drop_dead_body=0,
		escape=0,
		spawn_on={"group:sand","group:soil","default:snow","default:snowblock","default:ice","group:leaves","group:tree","group:stone","group:cracky","group:level","group:crumbly","group:choppy"},
		attack_chance=2,
		spawn_y=0,
	death=function(self,puncher,pos)
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
			minsize = 0.2,
			maxsize = 1,
			texture ="aliveai_threats_bee.png",
			collisiondetection = true,
		})
	end
})




minetest.register_tool("aliveai_threats:quake_core", {
	description = "Quake core",
	inventory_image = "default_dirt.png",
	on_use=function(itemstack, user, pointed_thing)
		if user:get_luaentity() then user=user:get_luaentity() end
		local type=pointed_thing.type
		local pos1=user:get_pos()
		pos1.y=pos1.y+1.5
		local pos2
		if type=="object" then
			pos2=pointed_thing.ref:get_pos()
		elseif type=="node" then
			pos2=pointed_thing.under
		elseif type=="nothing" then
			local dir
			if user:get_luaentity() then
				if user:get_luaentity().aliveai and user:get_luaentity().fight then
					local dir=aliveai.get_dir(user:get_luaentity(),user:get_luaentity().fight)
					pos2={x=pos1.x+(dir.x*15),y=pos1.y+(dir.y*15),z=pos1.z+(dir.z*15)}
				else
					pos2=aliveai.pointat(user:get_luaentity(),15)
				end
			else
				local dir=user:get_look_dir()
				pos2={x=pos1.x+(dir.x*15),y=pos1.y+(dir.y*15),z=pos1.z+(dir.z*15)}
			end
		else
			return itemstack
		end

		local n=minetest.get_node(pos1).name
		if minetest.registered_nodes[n] and minetest.registered_nodes[n].walkable then return end
		aliveai_threats.quake(pos1,pos2)
		itemstack:add_wear(65535/50)
		return itemstack
	end,
})


aliveai_threats.quake=function(pos1,pos2)
	if aliveai_threats.n>20 then return end
	aliveai_threats.n=aliveai_threats.n+1
	local d=math.floor(aliveai.distance(pos1,pos2)+0.5)
	local dir={x=(pos1.x-pos2.x)/-d,y=(pos1.y-pos2.y)/-d,z=(pos1.z-pos2.z)/-d}
	local p1
	local p2
	local i1=1
	local ii=15
	for i=1,d,1 do
		ii=i
		p1={x=pos1.x+(dir.x*i),y=pos1.y,z=pos1.z+(dir.z*i)}
			p2={x=p1.x+math.random(-1,1),y=pos1.y,z=p1.z+math.random(-1,1)}
		if not p1.x or p1.x~=p1.x or not p2.x or p2.x~=p2.x then
			return
		end
		aliveai_threats.quaking(p2,i,i1)
		aliveai_threats.quaking(p1,i,i1)
		i1=i1+1
		if i1>3 then i1=1 end
	end
	minetest.after((ii*0.1)+10, function()
		aliveai_threats.n=aliveai_threats.n-1
	end)

end

aliveai_threats.close=function(re,i1,lo)
	for i, p in pairs(re) do
		if aliveai.def(p.p,"buildable_to") then
			minetest.set_node(p.p,{name=p.n})
		end
	end

	if lo>7 and re[#re] and (i1==1 or lo<25) then
		for _, ob in ipairs(minetest.get_objects_inside_radius(re[#re].p, 3)) do
			ob:punch(ob,20,{full_punch_interval=1,damage_groups={fleshy=9000}})
		end
	end
end

aliveai_threats.quaking=function(pos,i2,i1)
	local pos2
	local s
	local re={}
	for i=0,-30,-1 do
		pos2={x=pos.x,y=pos.y+i,z=pos.z}
		if aliveai.def(pos2,"is_ground_content") and
		minetest.get_item_group(minetest.get_node(pos2).name, "cracky")~=0 or 
		minetest.get_item_group(minetest.get_node(pos2).name, "soil")~=0 and
		minetest.is_protected(pos2,"")==false then

			table.insert(re,{n=minetest.get_node(pos2).name,p=pos2})

			if s then
				s=s+1
				minetest.set_node(pos2,{name="air"})
			else
				s=0
				minetest.after(i2*0.1, function(pos2)
					minetest.set_node(pos2,{name="air"})
				end, pos2)
			end
		elseif s then
			minetest.after((i2*0.1)+10, function(re)
				aliveai_threats.close(re,i1,s)
			end, re)
			return
		end
	end
	if s then
		minetest.after((i2*0.1)+10, function(re)
			aliveai_threats.close(re,i1,s)
		end, re)
	end
end

aliveai.create_bot({
		attack_players=1,
		name="quake",
		team="quak",
		texture="default_dirt.png",
		stealing=1,
		steal_chanse=2,
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		start_with_items={["default:dirt"]=5,["default:stone"]=5,["aliveai_threats:quake_core"]=1},
		type="monster",
		dmg=1,
		hp=40,
		name_color="",
		spawn_on={"group:sand","group:soail","default:stone"},
		tool_near=1,
		tool_chance=2
})



aliveai.create_bot({
		attack_players=1,
		name="pull_master_monster",
		team="pull",
		texture="aliveai_threats_pull.png^[colorize:#00000044",
		attacking=1,
		talking=0,
		light=-1,
		lowest_light=9,
		building=0,
		smartfight=0,
		escape=0,
		type="monster",
		dmg=5,
		hp=200,
		arm=5,
		name_color="",
		spawn_on={"group:sand","group:spreading_dirt_type","group:stone","default:snow"},
		attack_chance=3,
		spawn_y=1,
		visual_size={x=2,y=1.5},
		collisionbox={-0.7,-1.5,-0.7,0.7,1.2,0.7},
		start_with_items={["default:mese_crystal"]=1,["aliveai:relive"]=2},
	on_punching=function(self,target)
		local pos=aliveai.roundpos(target:get_pos())
		local n
		for i=-2,-6,-1 do
			n=minetest.registered_nodes[minetest.get_node({x=pos.x,y=pos.y+i,z=pos.z}).name]
			if n and n.walkable==false then
				return
			end
		end
		pos.y=pos.y-4
		target:set_pos(pos)
		if minetest.is_protected(pos,"")==false then
			minetest.set_node(pos,{name="aliveai_threats:slime"})
		end
	end,
	on_step=function(self,dtime)
	if self.fight and math.random(1,20)==1 then
		local c=0
		for _, ob in ipairs(aliveai.active) do
			local en=ob:get_luaentity()
			if en and en.name=="aliveai_threats:pull_monster" then
				if en.lifetimer and en.lifetimer<aliveai.lifetimer/2 then
					aliveai.kill(en)
				else
					c=c+1
					if c>20 then return end
				end
			end
		end

		for i=0,math.random(2,10),1 do
			local p=aliveai.random_pos(self,5,10)
			if p then
				local n
				local p1=1
				for i=-2,-5,-1 do
					n=minetest.registered_nodes[minetest.get_node({x=p.x,y=p.y+i,z=p.z}).name]
					if n and n.walkable==false then
						p1=nil
					end
				end
				if p1 then
					p.y=p.y-3
					local en=minetest.add_entity(p, "aliveai_threats:pull_monster"):get_luaentity()
					en.temper=2
					en.fight=self.fight
				end
			end
		end
	end
	end,
	on_punched=function(self,puncher)
		self.object:set_properties({
			mesh = aliveai.character_model,
			textures = {"aliveai_threats_pull.png"},
		})
		local pos=self.object:get_pos()
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
			minsize = 0.1,
			maxsize = 2,
			texture = self.tex or "default_dirt.png",
			collisiondetection = true,
		})
		self.tex=nil
		if self.sleep or self.hide then self.abortsleep=true end
		if self.hide or not self.fight then return end
		if not self.ohp then self.ohp=self.object:get_hp()*0.8 return end
		if self.ohp>self.object:get_hp() then
			local pos=self.object:get_pos()
			local n=minetest.get_node(pos)
			if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].walkable then return end
			self.hide=true
			self.ohp=nil
			self.time=0.2
			self.pull_down=nil
			return self
		end
	end,
	death=function(self,puncher,pos)
		if not self.ex then
			self.ex=1
			aliveai_nitroglycerine.explode(pos)
			minetest.after(1, function(self)
				if self and self.ex then self.ex=nil end
			end,self)
		end
		return self
	end,
})


aliveai.create_bot({
		attack_players=1,
		name="stick_man",
		team="bug",
		texture="aliveai_threats_ninja.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		hp=15,
		name_color="",
		visual_size={x=0.2,y=1},
		type="monster",
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		if self.finvist then
			self.finvist=nil
			self.object:set_properties({
				is_visible=true,
				makes_footstep_sound=true,
				textures={"aliveai_threats_ninja.png","aliveai_threats_i.png","aliveai_threats_i.png"},
			})
		end
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
			minsize = 0.1,
			maxsize = 2,
			texture = "default_dirt.png^[colorize:#000000cc",
			collisiondetection = true,
		})
	end
})

aliveai.create_bot({
		attack_players=1,
		name="bronze_terminator",
		team="nuke",
		texture="aliveai_threats_terminator_bronze.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		start_with_items={["default:bronze_ingot"]=4,["default:bronzeblock"]=1},
		type="monster",
		dmg=5,
		hp=200,
		arm=2,
		name_color="",
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","group:stone"},
		attack_chance=5,
		floating=1,
		mindamage=5,
	on_punching=function(self,target)
		if not self.att and self.object:get_velocity().y==0 then
			self.att=target
			self.att:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=2,z=0})
			self.att_pos=self.object:get_pos()
			self.controlled=1
			self.att_a=self.att:get_acceleration()
		end
	end,
	on_step=function(self,dtime)
		if self.att then
			self.object:set_velocity({x=math.random(-3,3), y=10, z=math.random(-3,3)})
			aliveai.punch(self,self.att)
			if self.object:get_pos().y-self.att_pos.y>40 then
				self.att:set_detach()
				minetest.after(0.5, function(self)
					if self.att then
						self.att:set_acceleration(self.att_a)
						self.att=nil
					end
					self.object:set_pos(self.att_pos)
					self.controlled=nil
				end,self)
			end

		end
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
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
			minsize = 0.1,
			maxsize = 2,
			texture = "default_bronze_block.png",
			collisiondetection = true,
			spawn_chance=100,
		})
	end,
	death=function(self,puncher,pos)
		aliveai.floating(self)
		if self.att then
			self.att:set_detach()
		end
	end


})

if aliveai.spawning then
minetest.register_abm({
	nodenames = {"group:tree"},
	interval = 30,
	chance = 300,
	action = function(pos)
		aliveai_threats_eyes.spawn(pos)
	end,
})
end


aliveai.create_bot({
		attack_players=1,
		name="jumper",
		team="natural",
		texture="default_dirt.png^aliveai_threats_eyes.png",
		talking=0,
		light=0,
		building=0,
		type="monster",
		hp=10,
		dmg=2,
		name_color="",
		collisionbox={-0.5,-0.5,-0.5,0.5,0.5,0.5},
		visual="cube",
		basey=-0.5,
		drop_dead_body=0,
		escape=0,
		spawn_on={"group:sand","group:soil","default:snow","default:snowblock","default:ice","group:leaves","group:tree","group:stone","group:cracky","group:level","group:crumbly","group:choppy"},
		attack_chance=2,
		spawn_y=0,
		smartfight=0,
	spawn=function(self)
		local pos=self.object:get_pos()
		pos.y=pos.y-1.5
		if minetest.get_node(pos).name=="aliveai:spawner" then pos.y=pos.y-1 end
		local drop=minetest.get_node_drops(minetest.get_node(pos).name)[1]
		local n=minetest.registered_nodes[minetest.get_node(pos).name]
		if not (n and n.walkable) or drop=="" or type(drop)~="string" then self.object:remove() return self end
		local t=n.tiles
		if not t[1] then self.object:remove() return self end
		local tx={}
		self.t1=t[1]
		self.t2=t[1]
		self.t3=t[1]
		self.natural_monster=1
		self.consists=drop
		self.team=self.consists
		if t[2] then self.t2=t[2] self.t3=t[2] end
		if t[3] and t[3].name then self.t3=t[3].name
		elseif t[3] then self.t3=t[3]
		end
		if type(self.t3)=="table" then return end

		tx[1]=self.t1
		tx[2]=self.t2
		tx[3]=self.t3
		tx[4]=self.t3
		tx[5]=self.t3 .."^aliveai_threats_eyes.png"
		tx[6]=self.t3

		self.object:set_properties({textures=tx})
		self.textxs=tx
		self.jtimer=0
	end,	
	on_load=function(self)
		if self.natural_monster then
			local tx={}
			tx[1]=self.t1
			tx[2]=self.t2
			tx[3]=self.t3
			tx[4]=self.t3
			tx[5]=self.t3 .."^aliveai_threats_eyes.png"
			tx[6]=self.t3
			self.object:set_properties({textures=tx})
			self.team=self.consists
			self.textxs=tx
		else
			self.object:remove()
		end
		self.jtimer=0
	end,
	on_step=function(self,dtime)
		local v=self.object:get_velocity()
		if self.jtimer>1 and v.y==0 then
			aliveai.jump(self)
			self.jtimer=0
		else
			self.jtimer=self.jtimer+1
		end
		if self.fight and not self.fight_before then
			local t=self.textxs
			t[5]=self.t3 .."^aliveai_threats_eyes_mad.png"
			self.object:set_properties({textures=t})
			self.fight_before=1
		elseif not self.fight and self.fight_before then
			local t=self.textxs
			t[5]=self.t3 .."^aliveai_threats_eyes.png"
			self.object:set_properties({textures=t})
			self.fight_before=nil
		end
	end,
	death=function(self,puncher,pos)
		aliveai.invadd(self,self.consists,math.random(1, 4),false)
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		aliveai.lookat(self,pos)
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
			minsize = 0.2,
			maxsize = 4,
			texture = self.t1,
			collisiondetection = true,
		})
	end
})

aliveai_threats.acid=function(ob)
	if aliveai.gethp(ob,1)<1 then return end

	if ob:is_player() and aliveai_threats.stopacidplayer[ob:get_player_name()] then
		return
	end

	local pos=ob:get_pos()
	minetest.add_particlespawner({
		amount = 3,
		time =0.1,
		minpos = pos,
		maxpos = pos,
		minvel = {x=-1, y=-1, z=-1},
		maxvel = {x=1, y=-1, z=1},
		minacc = {x=0, y=-9, z=0},
		maxacc = {x=0, y=-10, z=0},
		minexptime = 2,
		maxexptime = 1,
		minsize = 0.1,
		maxsize = 2,
		texture =  "default_dirt.png^[colorize:#00aa00ff",
		collisiondetection = true,
		})
	aliveai.punchdmg(ob)
	if aliveai.gethp(ob,1)<1 then
		if ob:is_player() then
			aliveai_threats.stopacidplayer[ob:get_player_name()]=1
			minetest.after(10, function(ob)
				aliveai_threats.stopacidplayer[ob:get_player_name()]=nil
			end,ob)
		end
		return
	end

	minetest.after(math.random(1,4), function()
		aliveai_threats.acid(ob)
	end)
end


minetest.register_tool("aliveai_threats:acid", {
	description = "Acid",
	inventory_image = "aliveai_relive.png^[colorize:#00aa00aa",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type~="object" or aliveai.team(pointed_thing.ref)=="nuke" then return end
		aliveai_threats.acid(pointed_thing.ref)
		itemstack:add_wear(6000)
		return itemstack
	end
})


aliveai.create_bot({
		attack_players=1,
		name="acidman",
		team="nuke",
		texture="aliveai_threats_acidman.png",
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		hp=50,
		name_color="",
		arm=2,
		coming=0,
		smartfight=0,
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","group:stone"},
		attack_chance=5,
		start_with_items={["aliveai_threats:acid"]=1},
		tool_near=1,
		tool_chance=1,
	on_blow=function(self)
		aliveai.kill(self)
		self.death(self,self.object,self.object:get_pos())
	end,
	death=function(self,puncher,pos)
			if not self.ex then
				self.ex=true
				aliveai_nitroglycerine.explode(pos,{
				radius=1,
				set="air",
				blow_nodes=0,
				hurt=0
				})
				for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 4)) do
					if aliveai.visiable(pos,ob:get_pos()) then aliveai_threats.tox(ob) end
				end
			end
			return self
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		aliveai_threats.acid(puncher)
		minetest.add_particlespawner({
			amount = 5,
			time=0.2,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-0.1, y=-0.1, z=-0.1},
			maxvel = {x=0.1, y=0.1, z=0.1},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 0.5,
			maxsize = 2,
			texture = "default_grass.png^[colorize:#00ff00aa",
		})
	end
})


aliveai.create_bot({
		attack_players=1,
		name="fangs",
		team="fangs",
		texture="default_dirt.png^aliveai_threats_fangs.png",
		talking=0,
		light=0,
		building=0,
		type="monster",
		hp=100,
		arm=2,
		name_color="",
		collisionbox={-1,-1,-1,1,1,1},
		visual="cube",
		drop_dead_body=0,
		escape=0,
		spawn_on={"group:sand","group:soil","default:snow"},
		attack_chance=1,
		spawn_y=2,
		smartfight=0,
	spawn=function(self,t,t2)
		local tx=""
		if not t then
			tx="aliveai_threats:fangs"
		elseif t==1 then
			tx="aliveai_threats:fangs_fight"
		elseif t2 and t2:is_player() then
			t2:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
		else
			tx="aliveai_threats:fangs_attack"
		end
		self.fangs=t
		self.object:set_properties({visual="wielditem",visual_size={x=1.2,y=1.2},textures={tx}})
	end,	
	on_load=function(self)
		self.spawn(self)
	end,
	on_step=function(self,dtime)
		if self.eating then
			if not self.eating:get_attach() then
				self.spawn(self,3,self.eating)
				self.eating=nil
				return
			end
			local hp=aliveai.gethp(self.eating)
			if self.eating:get_luaentity() then
				if self.eating:get_luaentity().health then
					self.eating:get_luaentity().health=hp-2
				elseif self.eating:get_luaentity().hp then
					self.eating:get_luaentity().hp=hp-2
				end
			elseif self.eating:is_player() then
				self.eating:set_hp(hp-2)
			end
			if self.fangs then
				self.spawn(self)
			end
			aliveai.punchdmg(self.eating,2)
			if hp<=0 then
				self.eating:set_detach()
				if self.eating:get_luaentity() then
					self.eating:remove()
				else
					local pos=aliveai.roundpos(self.eating:get_pos())
					local n
					for i=-2,-6,-1 do
						if not aliveai.def({x=pos.x,y=pos.y+i,z=pos.z},"walkable") then
							return
						end
					end
					pos.y=pos.y-4
					self.eating:set_pos(pos)
				end
				self.spawn(self,3,self.eating)
				self.eating=nil
				self.object:set_hp(100)
				aliveai.showhp(self,true)
				return
			end
		end
		if not self.eating and self.fight then
			if self.fight:get_attach() then
				self.fight=nil
				return
			end
			if aliveai.distance(self,self.fight:get_pos())<2.5 then
				self.eating=self.fight
				self.eating:set_attach(self.object, "",{x=0, y=-3 , z=0}, {x=0, y=0, z=0})
				if self.eating:is_player() then
					self.eating:set_eye_offset({x=0, y=-15, z=0}, {x=0, y=0, z=0})
				end
				self.spawn(self,2)
				return self
			else
				self.spawn(self,1)
			end
		elseif self.fangs and not self.fight then
			self.spawn(self)
		elseif not self.fight and math.random(1,3)==1 then
			for _, ob in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), self.distance)) do
				local pos=ob:get_pos()
				if aliveai.is_bot(ob) and aliveai.team(ob)~=self.team and aliveai.viewfield(self,pos) then
					local en=ob:get_luaentity()
					if en.dying or en.dead then
						self.fight=ob
						self.temper=self.temper+1
						return self
					end
				end
			end
		end
	end,
	death=function(self,puncher,pos)
		if self.eating and self.eating:get_attach() then
			self.eating:set_detach()
			self.spawn(self,3,self.eating)
		end
		aliveai.invadd(self,"default:dirt",math.random(1, 4),false)
		minetest.add_particlespawner({
			amount = 30,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 2,
			maxsize = 8,
			texture = "default_dirt.png",
			collisiondetection = true,
		})

	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		aliveai.lookat(self,pos)
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 8,
			texture = "default_dirt.png",
			collisiondetection = true,
		})
	end
})
local fangsbox = {
	type = "fixed",
	fixed = {
		{0.2, -0.5, -0.5, 0.5, 0.5, 0.5},
		{-0.5, 0.2, -0.5, 0.5, 0.5, 0.5},
		{-0.5, -0.5, 0.2, 0.5, 0.5, 0.5},
		{-0.5, -0.5, -0.5, -0.2, 0.5, 0.5},
		{-0.5, -0.5, -0.5, 0.5, -0.2, 0.5},
		{-0.5, -0.5, -0.5, 0.5, 0.5, -0.2},
	}
}
minetest.register_node("aliveai_threats:fangs", {
	tiles = {"default_dirt.png","default_dirt.png","default_dirt.png","default_dirt.png","default_dirt.png","default_dirt.png"},
	groups = {cracky = 2,not_in_creative_inventory=1},
	drawtype="nodebox",
	node_box = fangsbox
})
minetest.register_node("aliveai_threats:fangs_fight", {
	tiles = {"default_dirt.png","default_dirt.png","default_dirt.png","default_dirt.png","default_dirt.png^aliveai_threats_fangs.png","default_dirt.png"},
	groups = {cracky = 2,not_in_creative_inventory=1},
	drawtype="nodebox",
	node_box = fangsbox
})
minetest.register_node("aliveai_threats:fangs_attack", {
	tiles = {"default_dirt.png","default_dirt.png","default_dirt.png","default_dirt.png","default_dirt.png^aliveai_threats_fangs2.png","default_dirt.png"},
	groups = {cracky = 2,not_in_creative_inventory=1},
	drawtype="nodebox",
	node_box = fangsbox
})


minetest.register_abm{
	nodenames = {"air"},
	neighbors = {"group:soil","group:stone"},
	interval = 300,
	chance = 10000,
	action = function(pos)
		if not minetest.is_protected(pos,"") and minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name=="air" then
			minetest.set_node(pos, {name = "aliveai_threats:statue"})
		end
	end,
}

minetest.register_node("aliveai_threats:statue", {
	description = "Statue",
	tiles = {"aliveai_air.png"},
	inventory_image = "default_stone.png",
	wield_image = "default_stone.png",
	groups = {cracky = 1,level=3,stone=1},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype="glasslike",
	visual_scale = 0.12,
	post_effect_color = {a=255, r=0, g=0, b=0},
	selection_box ={
		type = "fixed",
		fixed = {
			{-0.4, -0.5, -0.4, 0.4, 1.2, 0.4},
		}
	},
	on_construct = function(pos)
		minetest.add_entity({x=pos.x,y=pos.y+0.5,z=pos.z}, "aliveai_threats:statue")
		minetest.get_node_timer(pos):start(5)
	end,
	on_destruct = function(pos)
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			local en=ob:get_luaentity()
			if en and en.name=="aliveai_threats:statue" then
				ob:remove()
			end
		end
	end,
	on_timer = function (pos, elapsed)
		if math.random(1,100)==1 and not minetest.is_protected(pos,"") then
			minetest.remove_node(pos)
			return
		end

		local l=minetest.get_node_light(pos)
		if l and l>5 then return true end
		local o
		local cfo
		local c=0
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			local en=ob:get_luaentity()
			if en and en.name=="aliveai_threats:statue" then
				cfo=ob
				break
			end

		end
		if not cfo then
			minetest.add_entity({x=pos.x,y=pos.y+0.5,z=pos.z}, "aliveai_threats:statue")
			return true
		end
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 15)) do
			local en=ob:get_luaentity()
			if not (en and (en.type==nil or en.name=="aliveai_threats:statue")) and aliveai.visiable(pos,ob:get_pos()) then
				c=c+1
				if c>1 then return true end
				o=ob
				
			end
		end
		if not o then
			return true
		end
		local d
		local opos=o:get_pos()
		if o:get_luaentity() then
			d=aliveai.pointat(o:get_luaentity(),1)
		elseif o:is_player(o) then
			d=o:get_look_dir()
			d={x=d.x*1.1,y=d.y*1.1,z=d.z*1.1}
			d={x=opos.x+d.x,y=opos.y+d.y,z=opos.z+d.z}
		else
			return true
		end
		local self=cfo:get_luaentity()
		local p=aliveai.pointat(self,1)
		if aliveai.distance(pos,d)>aliveai.distance(pos,opos) then
			if minetest.get_node(p).name=="aliveai_threats:statue" then
				return true
			end
			if not aliveai.def(p,"buildable_to")
			and aliveai.def({x=p.x,y=p.y+1,z=p.z},"buildable_to") then
				if not aliveai.def({x=p.x,y=p.y+2,z=p.z},"buildable_to") then
					return true
				end
				p={x=p.x,y=p.y+1,z=p.z}
			elseif aliveai.def(p,"buildable_to")
			and aliveai.def({x=p.x,y=p.y-1,z=p.z},"buildable_to") then
				if aliveai.def({x=p.x,y=p.y-2,z=p.z},"buildable_to") then
					return true
				end
				p={x=p.x,y=p.y-1,z=p.z}
			end
			if not aliveai.def(p,"buildable_to") or minetest.is_protected(p,"") then
				return true
			end
			minetest.set_node(p,{name="aliveai_threats:statue"})
			minetest.remove_node(pos)
			if aliveai.distance(p,opos)<1 then
				aliveai.punchdmg(o,50)
			end
			for _, ob in ipairs(minetest.get_objects_inside_radius(p, 1)) do
				local en=ob:get_luaentity()
				if en and en.name=="aliveai_threats:statue" then
					aliveai.lookat(en,opos)
					return true
				end
			end
		end
		return true
	end,
})
minetest.register_entity("aliveai_threats:statue",{
	hp_max = 10,
	physical =false,
	pointable=false,
	visual = "mesh",
	mesh=aliveai.character_model,
	collisionbox={0,0,0,0,0,0},
	textures ={"default_stone.png"},
	on_activate=function(self, staticdata)
		if minetest.get_node(aliveai.newpos(self):yy(-0.5)).name~="aliveai_threats:statue" then
			self.object:remove()
		end
	end,
})
aliveai.loaded("aliveai_threats:statue")

minetest.register_node("aliveai_threats:hat", {
	tiles = {"default_coal_block.png^[colorize:#000000aa"},
	groups = {dig_immediate = 3,not_in_creative_inventory=1},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(1,10))
	end,
	on_timer = function (pos, elapsed)
		if minetest.get_node({x=pos.x, y=pos.y-1 , z=pos.z}).name=="default:snowblock" then
			minetest.add_entity({x=pos.x, y=pos.y-1 , z=pos.z}, "aliveai_threats:snowman")
			minetest.remove_node({x=pos.x, y=pos.y-1 , z=pos.z})
			minetest.remove_node(pos)
		end
		return false
	end,
	drawtype="nodebox",
	node_box ={
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.375, 0.375, -0.4375, 0.375},
			{-0.22, -0.4375, -0.22, 0.22, 0.0625, 0.22}
		}
	}
})

minetest.register_entity("aliveai_threats:hat",{
	hp_max = 20,
	physical =true,
	pointable=false,
	visual = "wielditem",
	textures ={"aliveai_threats:hat"},
	visual_size={x=2,y=2},
	on_step=function(self, dtime)
		self.t=self.t+dtime
		if self.t<1 then return end
		self.t=0
		if not self.object:get_attach() then
			self.object:remove()
		end
	end,
	t=0,
})



minetest.register_node("aliveai_threats:snowman", {
	tiles = {"default_snow.png"},
	groups = {cracky = 2,not_in_creative_inventory=1},
	drawtype="nodebox",
	node_box ={
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.375, 0.5, -0.375, 0.375, 1.2, 0.375},
			{-0.25, 1.2, -0.25, 0.25, 1.6, 0.25}
		}
	}
})


aliveai.create_bot({
		attack_players=1,
		name="snowman",
		team="snow",
		texture="default_snow.png",
		talking=0,
		light=0,
		building=0,
		type="monster",
		hp=10,
		arm=2,
		name_color="",
		collisionbox={-0.5,-0.45,-0.5,0.5,2.0,0.5},
		visual="cube",
		drop_dead_body=0,
		escape=0,
		start_with_items={["default:snow"]=1,["default:snowblock"]=3,["aliveai_threats:hat"]=1},
		spawn_on={"default:snow","default:snowblock"},
		attack_chance=1,
		basey=-1,
		smartfight=0,
		spawn_chance=100,
	spawn=function(self,t,t2)
		self.object:set_properties({visual="wielditem",visual_size={x=0.6,y=0.6},textures={"aliveai_threats:snowman"}})
		local e=minetest.add_entity(self.object:get_pos(), "aliveai_threats:hat")
		e:set_attach(self.object, "",{x=0, y=62 , z=0}, {x=0, y=0, z=0})
		self.hat=e
		self.cctime=0
	end,	
	on_load=function(self)
		self.spawn(self)
	end,
	on_step=function(self,dtime)
		if self.fight and (self.cctime<1 or self.time==self.otime) then
			self.cctime=5
			local d=aliveai.distance(self,self.fight:get_pos())
			if not (aliveai.viewfield(self,self.fight) and aliveai.visiable(self,self.fight:get_pos())) then return end
			local pos=self.object:get_pos()
			local ta=self.fight:get_pos()
			if not (ta and pos) then return end
			ta.y=ta.y+1.5
			aliveai.stand(self)
			aliveai.lookat(self,ta)
			local e=minetest.add_item(aliveai.pointat(self,2),"default:snow")
			local dir=aliveai.get_dir(self,ta)
			e:set_velocity({x =aliveai.nan(dir.x*30), y = aliveai.nan(dir.y*30), z = aliveai.nan(dir.z*30)})
			e:get_luaentity().age=(tonumber(minetest.settings:get("item_entity_ttl")) or 900)-2
			table.insert(aliveai_threats.debris,{ob=e,n=self.botname})
			return self
		elseif self.fight and self.cctime>1 then
			self.cctime=self.cctime-1
		end

	end,
	death=function(self,puncher,pos)
		if self.hat and self.hat:get_attach() then
			self.hat:set_detach()
			self.hat:remove()
		end
		minetest.add_particlespawner({
			amount = 30,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 2,
			maxsize = 4,
			texture = "default_snow.png",
			collisiondetection = true,
		})
		minetest.sound_play("default_snow_footstep", {pos=pos, gain = 1.0, max_hear_distance = 5,})
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		if self.hp<6 and self.hp>0 and not minetest.is_protected(pos,"") and aliveai.def(pos,"buildable_to") and math.random(1,5)==1 then
			minetest.set_node(pos,{name="default:snowblock"})
			local psa={x=pos.x,y=pos.y+1,z=pos.z}
			if not minetest.is_protected(psa,"") and aliveai.def(psa,"buildable_to") then
				self.inv["aliveai_threats:hat"]=nil
				minetest.set_node(psa,{name="aliveai_threats:hat"})
			end
			aliveai.punchdmg(self.object,100)
		end
		aliveai.lookat(self,pos)
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 2,
			texture = "default_snow.png",
			collisiondetection = true,
		})
	end
})

minetest.register_tool("aliveai_threats:stoneman_spawn", {
	description = "Stoneman",
	inventory_image = "aliveai_threats_stoneman.png",
	on_use=function(itemstack, user, pointed_thing)
		if user:get_luaentity() then user=user:get_luaentity() end
		local type=pointed_thing.type
		local pos
		if type=="node" then
			pos=pointed_thing.above
			pos.y=pos.y+1
		elseif type=="object" then
			pos=pointed_thing.ref:get_pos()
		else
			pos=user:get_pos()
			pos.y=pos.y+1
		end
		local e=minetest.add_entity(pos, "aliveai_threats:stoneman")
		e:get_luaentity().team=aliveai.team(user)
		local self=user:get_luaentity()
		if self then
			minetest.after(0.1, function(self)
				if self and self.object then
					aliveai.invadd(self,"aliveai_threats:stoneman_spawn",-1)
					self.tools=""
					self.savetool=1
					self.tool_near=0
				end
			end,self)
		end
		itemstack:add_wear(65536)
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		if user:get_luaentity() then user=user:get_luaentity() end
		local type=pointed_thing.type
		local pos
		if type=="node" then
			pos=pointed_thing.above
			pos.y=pos.y+1
		elseif type=="object" then
			pos=pointed_thing.ref:get_pos()
		else
			pos=user:get_pos()
			pos.y=pos.y+1
		end
		local e=minetest.add_entity(pos, "aliveai_threats:stoneman")
		e:get_luaentity().team=aliveai.team(user)
		itemstack:add_wear(65536)
		return itemstack
	end
})

minetest.register_craft({
	output = "aliveai_threats:stoneman_spawn",
	recipe = {
		{"default:stone","default:stone","default:stone"},
		{"","default:cobble",""},
		{"default:stone","","default:stone"},
	}
})

aliveai.create_bot({
		attack_players=1,
		name="stoneman",
		team="stone",
		texture="default_stone.png",
		talking=0,
		light=0,
		building=0,
		type="monster",
		hp=30,
		arm=2,
		dmg=3,
		hugwalk=1,
		name_color="",
		escape=0,
		start_with_items={["default:stone"]=1},
		spawn_on={"default:stone"},
		annoyed_by_staring=0,
		attack_chance=1,
		smartfight=0,
		spawn_chance=100,
		mindamage=2,
	spawn=function(self)
		self.animation.stand.speed=0
		aliveai.stand(self)
		minetest.after(0, function(self)
			if self.team~="stone" then
				self.name_color="aaaaaa"
				self.object:set_properties({nametag=self.botname,nametag_color="#" .. self.name_color})
			end
		end,self)
	end,	
	on_load=function(self)
		self.animation.stand.speed=0
		aliveai.stand(self)
		if self.team~="stone" then
			self.name_color="aaaaaa"
			self.object:set_properties({nametag=self.botname,nametag_color="#" .. self.name_color})

		end
	end,
	death=function(self,puncher,pos)
		minetest.add_particlespawner({
			amount = 30,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 2,
			texture = "default_stone.png",
			collisiondetection = true,
		})
	end,
})

if minetest.get_modpath("aliveai_folk") then
aliveai.create_bot({
		attack_players=1,
		name="toxic_npc",
		team="toxic_npc",
		texture="aliveai_folk23a.png",
		talking=0,
		light=0,
		building=0,
		type="monster",
		hp=40,
		arm=2,
		dmg=3,
		hugwalk=1,
		name_color="",
		escape=0,
		--start_with_items={["default:stone"]=1},
		spawn_on={"default:stone","bones:bones","default:silver_sandstone_brick","default:sandstone_brick"},
		annoyed_by_staring=0,
		attack_chance=1,
		smartfight=0,
		spawn_chance=100,
		mindamage=2,
	spawn=function(self)
		local t={}
		for _, v in pairs(aliveai.registered_bots) do
			if v.mod_name=="aliveai_folk" and string.find(v.name,"folk") then
				table.insert(t,v.textures[1])
			end
		end
		self.save__1=t[math.random(1,#t)] or "aliveai_threats_stubborn_monster.png"
		self.object:set_properties({textures={self.save__1}})
	end,	
	on_load=function(self)
		self.object:set_properties({textures={self.save__1 or "aliveai_threats_stubborn_monster.png"}})
		if self.save__3 and self.save__4 then
			self.object:set_properties({visual_size=self.save__3,collisionbox=self.save__4})
		end
	end,
	on_detect_enemy=function(self,target)
		if self.save__2~="by_another" then
			for i=1,math.random(1,5),1 do
				local pos=aliveai.random_pos(self,10,20)
				if not pos then
					pos=aliveai.random_pos(self,10,20)
					if not pos then return self end
				end
				local en=minetest.add_entity(pos, "aliveai_threats:toxic_npc"):get_luaentity()
				en.temper=3
				en.fight=target
				en.save__2="by_another"
			end
			self.save__2="by_another"
		end
	end,
	on_punch_hit=function(self,fight)
		if aliveai.is_bot(fight) and fight:get_properties().visual=="mesh" and fight:get_properties().mesh==aliveai.character_model then
			local pos=fight:get_pos()
			local t=fight:get_properties().textures[1]
			local e=minetest.add_entity(pos, "aliveai_threats:toxic_npc")
			local en=e:get_luaentity()
			e:set_yaw(self.object:get_yaw())
			en.inv=fight:get_luaentity().inv
			en.namecolor="ff0000"
			en.save__1=t
			en.save__2="by_another"
			en.dmg=fight:get_luaentity().dmg
			en.floating=fight:get_luaentity().floating
			en.save__3=fight:get_properties().visual_size
			en.save__4=fight:get_properties().collisionbox
			e:set_properties({
				textures={t},
				visual_size=en.save__3,
				collisionbox=en.save__4,
			})
			fight:remove()
			self.fight=nil

		elseif aliveai.is_bot(fight) then
			local en=fight:get_luaentity()
			en.fight=nil
			en.save__2="by_another"
			en.team=self.team
			en.namecolor="ff0000"
			aliveai.showhp(en)
			en.on_punch_hit=self.on_punch_hit
			self.fight=nil
		end
	end,
})
end

