minetest.register_node("aliveai_threats:steelnet", {
	description = "Steel net",
	tiles = {"aliveai_threats_steelnet.png"},
	paramtype = "light",
	drawtype = "firelike",
	sunlight_propagates=true,
	walkable = false,
	is_ground_content = false,
	liquidtype = "source",
	liquid_range = 0,
	liquid_alternative_flowing = "aliveai_threats:steelnet",
	liquid_alternative_source = "aliveai_threats:steelnet",
	liquid_viscosity = 15,
	groups = {cracky=1,level=1},
	sounds=default.node_sound_metal_defaults(),
	on_timer = function (pos, elapsed)
		local t
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 15)) do
			if aliveai.is_bot(ob) and ob:get_luaentity().name=="aliveai_threats:spider_terminator" then
				return true	
			elseif aliveai.team(ob)~="nuke" then
				t=ob
			end
		end
		if t then
			local e=minetest.add_entity(pos, "aliveai_threats:spider_terminator")
			e:get_luaentity().fight=t
			e:get_luaentity().temper=3
			aliveai.lookat(e:get_luaentity(),t:get_pos())
		end
		return true
	end,
})


minetest.register_node("aliveai_threats:trapstone", {
	description = "Trapstone",
	tiles={"default_stone.png"},
	groups={cracky=2},
	sounds=default.node_sound_stone_defaults(),
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_timer = function (pos, elapsed)
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
			if aliveai.team(ob)~="nuke" then
				minetest.add_entity(pos, "aliveai_threats:fallingtrap")
				minetest.remove_node(pos)
				return
			end
		end
		return true
	end,
})
minetest.register_node("aliveai_threats:trapdirt", {
	description = "Trapdirt",
	tiles={"default_dirt.png"},
	groups={crumbly=2},
	sounds=default.node_sound_dirt_defaults(),
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_timer = function (pos, elapsed)
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
			if aliveai.team(ob)~="nuke" then
				minetest.add_entity(pos, "aliveai_threats:fallingtrap")
				minetest.remove_node(pos)
				return
			end
		end
		return true
	end,
})

minetest.register_entity("aliveai_threats:fallingtrap",{
	visual = "wielditem",
	physical =true,
	visual_size = {x=0.667,y=0.667},
	textures ={"default:dirt"},
	makes_footstep_sound = true,
	on_activate=function(self, staticdata)
		if staticdata and staticdata~="" then
			local a=minetest.deserialize(staticdata)
			minetest.set_node(a.re,{name=a.tex})
			self.object:remove()
			return self
		end
		self.re=self.object:get_pos()
		self.tex=minetest.get_node(self.re).name
		self.object:set_properties({textures=self.tex})
		self.object:setacceleration({x=0,y=-20,z=0})
		self.object:setvelocity({x=0, y=-1, z=0})
		return self
	end,
	get_staticdata = function(self)
		return minetest.serialize({re=self.re,tex=self.tex})
	end,
	on_step=function(self, dtime)
		self.time=self.time+dtime
		if self.time<1 then return self end
		self.time=0
		if aliveai.def(aliveai.newpos(self,{y=-1}),"walkable") then
			self.timer=self.timer-1
			if self.timer<1 then
				minetest.set_node(self.re,{name=self.tex})
				self.object:remove()
			end
		end
		return self
	end,
	time=0,
	timer=30,
	team="nuke",
})


aliveai.create_bot({
		attack_players=1,
		name="spider_terminator",
		team="nuke",
		texture="aliveai_threats_c4_controller.png",
		drawtype="mesh",
		mesh="aliveai_threats_spider_terminator.b3d",
		visual_size={x=3,y=3},
		collisionbox={-0.5,-0.35,-0.5,0.5,0.5,0.5},
		basey=0.30,
		animation={
			stand={x=20,y=25,speed=0},
			walk={x=0,y=20,speed=60},
			mine={x=0,y=20,speed=120},
		},
		drop_dead_body=0,
		attacking=1,
		talking=0,
		building=0,
		escape=0,
		start_with_items={["default:steelblock"]=1},
		type="monster",
		dmg=10,
		hp=200,
		arm=3,
		name_color="",
		spawn_on={"group:spreading_dirt_type","default:gravel","group:stone"},
		spawn_chance=1000,
		attack_chance=1,
		mindamage=5,
		drowning=0,
		floating=0,
		smartfight=0,
	on_step=function(self,dtime)
		local n=minetest.get_node(self.object:get_pos()).name=="aliveai_threats:steelnet"
		if n and self.floating==0 then
			aliveai.floating(self,1)
		elseif not n and self.floating==1 then
			aliveai.floating(self)
		end
	end,
	spawn=function(self)
		local y=self.object:get_pos()
		if minetest.get_node(y).name=="aliveai_threats:steelnet" then
			return
		end
		y.y=y.y-7
		for _, ob in ipairs(minetest.get_objects_inside_radius(y, 100)) do
			local self2=ob:get_luaentity()
			if aliveai.is_bot(ob) and self2.botname~=self.botname and self2.name=="aliveai_threats:spider_terminator" then
				return
			end
		end
		local p=aliveai.get_nodes(y,4,1,{})
		if not p then return end
		local m={"aliveai_threats:trapstone","aliveai_threats:trapdirt"}
		local mm={"default:stone","default:dirt"}
		for _, pos in ipairs(p) do
			if not minetest.is_protected(pos,"") then
				if pos.y>=y.y and minetest.find_node_near(pos, 1,{"air","group:snappy"}) then
					if pos.y>=y.y+4 then
						minetest.set_node(pos,{name=m[math.random(1,2)]})
					else
						minetest.set_node(pos,{name=mm[math.random(1,2)]})
					end
				else
					minetest.set_node(pos,{name="aliveai_threats:steelnet"})
				end
			end
		end
		minetest.get_node_timer(y):start(5)
		self.object:set_pos(y)
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
	end,
	on_blow=function(self)
		aliveai.kill(self)
		self.death(self,self.object,self.object:getpos())
	end,
	death=function(self,puncher,pos)
			if aliveai_nitroglycerine and not self.ex then
				self.ex=true
				aliveai_nitroglycerine.explode(pos,{
				radius=2,
				set="air",
				})
			end
			return self
	end,
})