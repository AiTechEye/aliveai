aliveai_ants={max=20}

aliveai_ants.set_color=function(self)
	local c=minetest.get_meta(self.home):get_string("color")
	if c=="" then
		aliveai_ants.gen_color(self)
		c=minetest.get_meta(self.home):get_string("color")
	end
	local t="aliveai_ant.png^[colorize:#" ..  c
	self.object:set_properties({
		textures = {t,t,t,t,t,t},
	})	
end

aliveai_ants.gen_color=function(self)
	local pos=self.home
	local c=""
	local n=0
	local t="0123456789ABCDEF"
  	for i=1,6,1 do
        		n=math.random(1,16)
       		c=c .. string.sub(t,n,n)
	end
	minetest.get_meta(pos):set_string("color",c .. "55")
end

aliveai_ants.gen_hill=function(self)
	local count=0
	local pos=self.home
	local m=minetest.get_meta(pos)
	local size=m:get_int("size")
	local op={x=pos.x,y=pos.y,z=pos.z}
	local s=1
	local level=pos.y
	local wall
	local t=0
	local path={}

	for y=-size,size,1 do
	for x=-size,size,1 do
	for z=-size,size,1 do
		local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		local node=minetest.registered_nodes[minetest.get_node(p).name]
		if node and node.buildable_to and vector.length(vector.new(x,y,z))/size<=1 then
			wall=true
			if p.y==level and (
				(y==0 and (x==0 or z==0)) or
				(z==0 and (p.x==op.x+s or p.x==op.x+s+1)) or
				(z==0 and (p.x==op.x-s or p.x==op.x-s-1)) or
				(x==0 and (p.z==op.z+s or p.z==op.z+s+1)) or
				(x==0 and (p.z==op.z-s or p.z==op.z-s-1))) then
				wall=false
			elseif p.y>level then
				level=p.y
				s=s+1
			end
			if wall then
				t=t+0.01
				minetest.after(t, function(p)
					minetest.add_node(p,{name="aliveai_ants:anthill"})
				end,p)
			end
		end
	end
	end
	end
end

aliveai.create_bot({
		drop_dead_body=0,
		attack_players=1,
		name="ant",
		team="bug",
		texture={"aliveai_ant.png","aliveai_ant.png","aliveai_ant.png","aliveai_ant.png","aliveai_ant.png","aliveai_ant.png"},
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=0,
		hp=4,
		name_color="",
		arm=1,
		smartfight=0,
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel"},
		attack_chance=2,
		visual="cube",
		visual_size={x=0.4,y=0.001},
		collisionbox={-0.1,0,-0.1,0.2,0.3,0.2},
		basey=0,
		distance=10,
		pickuping=0,
		annoyed_by_staring=0,
	on_load=function(self)
		self.aliveai_ant=1
		if self.home and minetest.get_node(self.home).name=="aliveai_ants:antbase" then
			local m=minetest.get_meta(self.home)
			self.antcolor=m:get_string("color")
			self.antsize=m:get_int("size")
			self.antcount=m:get_int("count")
			self.team=m:get_string("team")
			aliveai_ants.set_color(self)
		end
	end,
	spawn=function(self)
		self.aliveai_ant=1
		local pos=aliveai.roundpos(self.object:get_pos())
		self.home=pos
		self.team=pos.x .."_" .. pos.y .. "_" .. pos.z
		if minetest.get_node(pos).name=="aliveai_ants:antbase" then
			self.home=pos
			local m=minetest.get_meta(self.home)
			self.antcolor=m:get_string("color")
			self.antsize=m:get_int("size")
			self.antcount=m:get_int("count")
			self.team=m:get_string("team")
			aliveai_ants.set_color(self)
			local ss=m:get_int("size")
			local ssrnd={x=math.random(-1,1)*ss,z=math.random(-1,1)*ss}
			local ssp={x=self.home.x+ssrnd.x,y=self.home.y,z=self.home.z+ssrnd.z}
			local p=aliveai.creatpath(self,self.home,ssp)
			if p then
				self.antdig=""
				self.path=p
			end
			return self
		end
		local opos={x=pos.x,y=pos.y,z=pos.z}
		for i=-1,-9,-1 do
			local tn=minetest.registered_nodes[minetest.get_node({x=pos.x,y=pos.y+i,z=pos.z}).name]
			if tn and tn.walkable and tn.buildable_to==false then
				pos=opos
				self.home=opos
				break
			elseif i==-9 then
				--aliveai.punch(self,self.object,20)
				return self
			end
			opos={x=pos.x,y=pos.y+i,z=pos.z}
		end
		local node=minetest.registered_nodes[minetest.get_node(pos).name]
		if not node or node.buildable_to==false or minetest.is_protected(pos,"") then return self end
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 20)) do
			local en=ob:get_luaentity()
			if en and en.aliveai_ant and aliveai.get_bot_name(ob)~=self.botname then return self end
		end
		minetest.set_node(pos,{name="aliveai_ants:antbase"})
		self.home=pos
		aliveai_ants.gen_color(self)
		aliveai_ants.set_color(self)
		local m=minetest.get_meta(pos)
		m:set_string("team",self.team)
		self.antcolor=m:get_string("color")
		self.antsize=m:get_int("size")
		self.antcount=m:get_int("count")
	end,
	on_step=function(self,dtime)

		if self.path and math.random(1,20)==1 then
			for _, ob in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 1)) do
				local en=ob:get_luaentity()
				if en and en.aliveai_ant and aliveai.get_bot_name(ob)~=self.botname then
					aliveai.jump(self)
					break
				end
			end
		end

		if self.antdig and self.path then
			aliveai.path(self)
			if not self.path or self.done=="path" then
				local n=aliveai.digdrop(self.antdig)
				if n and n~="" then
					self.fight=minetest.add_item(self.antdig, n.name .." ".. n.n)
					minetest.set_node(self.antdig,{name="air"})
					self.antdig=nil
				end
			else
				return self
			end
		end


		if self.carry and self.path then
			aliveai.path(self)
			if not self.path or self.done=="path" then
				if self.done=="path" or aliveai.distance(self,self.home)<4 then
					if minetest.get_node(self.home).name~="aliveai_ants:antbase" then
					local opos={x=self.home.x,y=self.home.y,z=self.home.z}
					for i=-1,-9,-1 do
						local tn=minetest.registered_nodes[minetest.get_node({x=self.home.x,y=self.home.y+i,z=self.home.z}).name]
						if tn and tn.walkable and tn.buildable_to==false then
							self.home=opos
							break
						elseif i==-9 then
							aliveai.punch(self,self.object,20)
							return self
						end
							opos={x=self.home.x,y=self.home.y+i,z=self.home.z}
						end
						minetest.set_node(self.home,{name="aliveai_ants:antbase"})
						local m=minetest.get_meta(self.home)
						m:set_string("color",self.antcolor)
						m:set_string("count",self.antcount)
						m:set_string("size",self.antsize)
					else
						local m=minetest.get_meta(self.home)
						local s=m:get_int("s")
						local count=m:get_int("count")
						for _, ob in ipairs(minetest.get_objects_inside_radius(self.home, 2)) do
							if ob and ob:get_attach() then ob:set_detach() end
							if not (ob:get_luaentity() and ob:get_luaentity().team==self.team) then
								aliveai.punch(self,ob,10)
								count=count+1
								s=s+1
							end
						end
						m:set_int("count",count)
						if s>9 then
							m:set_int("s",0)
							m:set_int("size",m:get_int("size")+1)
							aliveai_ants.gen_hill(self)
						else
							m:set_int("s",s)
						end
						local ss=m:get_int("size")
						local ssrnd={x=math.random(-1,1)*ss,z=math.random(-1,1)*ss}
						local ssp={x=self.home.x+ssrnd.x,y=self.home.y,z=self.home.z+ssrnd.z}
						local p=aliveai.creatpath(self,self.home,ssp)
						if p then
							self.antdig=""
							self.path=p
						end
					end
				end
				self.done=""
				self.carry=nil
				self.fight=nil
			end
			return self
		end


		if self.fight and not self.fight:get_attach() and aliveai.distance(self,self.fight:get_pos())<=self.arm+2 then
			if aliveai.gethp(self.fight)>6 then
				aliveai.punch(self,self.fight,1)
			elseif aliveai.gethp(self.fight)>0 and not self.fight:get_attach() then
				local pos=self.object:get_pos()
				local p=aliveai.creatpath(self,pos,aliveai.roundpos(self.home))
				if p~=nil then
					aliveai_ants.ant=self.object
					aliveai_ants.carry=self.fight
					local e=minetest.add_entity(pos, "aliveai_ants:antcarry")
					self.fight:set_attach(e, "",{x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
					self.carry=e
					self.path=p
					self.done=""
					return self
				end
			end
		else
			if math.random(1,10)==1 then
				local pos=self.object:get_pos()
				for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 5)) do
					if ob and ob:get_luaentity() and not ob:get_attach() and ob:get_luaentity().name=="__builtin:item" then
						self.fight=ob
						self.temper=1
						return self
					end
				end

				local dg=minetest.find_node_near(aliveai.roundpos(pos), self.distance,{"group:choppy","group:snappy","group:flora","group:choppy","group:oddly_breakable_by_hand","group:leaves","aliveai_ants:antbase"})
				if not dg or aliveai.samepos(dg,self.home) or minetest.is_protected(dg,"") or minetest.get_meta(dg):get_string("owner")~="" then return end
				local p=aliveai.neartarget(self,dg,0,1,1)
				if not p then return end
				p=aliveai.creatpath(self,pos,p)
				if not p then return end
				self.path=p
				self.antdig=dg
				self.done=""
				return self
			else
				aliveai.task_stay_at_home(self)
			end
		end
	end,
	click=function(self,clicker)
		clicker:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=2}})
	end,
	death=function(self,puncher,pos)
		if not self.antcolor then self.antcolor="000000" end
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
			maxsize = 0.5,
			texture = "default_dirt.png^[colorize:#" .. self.antcolor,
			collisiondetection = true,
		})
		return self
	end,
})

minetest.register_node("aliveai_ants:anthill", {
	description = "Ant base",
	tiles = {"aliveai_anthill.png"},
	groups = {crumbly = 1, soil = 1,not_in_creative_inventory=1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("aliveai_ants:antbase", {
	description = "Ant base",
	tiles = {"aliveai_ant_base.png"},
	groups = {crumbly = 1, soil = 1,not_in_creative_inventory=1},
	sounds = default.node_sound_dirt_defaults(),
	paramtype="light",
	drawtype="glasslike",
	walkable=false,
	on_timer = function (pos, elapsed)
		local c=0
		local ants=0
		local meta=minetest.get_meta(pos)
		local team=meta:get_string("team")
		local count=meta:get_int("count")
		for i in pairs(aliveai.active) do
			c=c+1
			if not aliveai.active[i] or not aliveai.active[i]:get_luaentity() or not aliveai.active[i]:get_hp() or aliveai.active[i]:get_hp()<=0 then
				table.remove(aliveai.active,c)
				c=c-1
			elseif aliveai.active[i]:get_luaentity().aliveai_ant and aliveai.active[i]:get_luaentity().team==team then
				ants=ants+1
				if ants>=count or ants>aliveai_ants.max then return true end
			end
		end
	local e=minetest.add_entity(pos,"aliveai_ants:ant")
	return true
	end,
	on_construct = function(pos)
		local m=minetest.get_meta(pos)
		m:set_int("count",1)
		minetest.get_node_timer(pos):start(10)
	end,
})

aliveai.savedata.task_build=function(self)
	if self.aliveai_ant then
		return {aliveai_ant=1,team=self.team,antcolor=self.antcolor,antcount=self.antcount,antsize=self.antsize}
	end
end

aliveai.loaddata.task_build=function(self,r)
	if r.aliveai_ant then
		self.aliveai_ant=1
		self.team=r.team
		self.antcolor=r.antcolor
		self.antsize=r.antsize
		self.antcount=r.antcount
	end
	return self
end


minetest.register_entity("aliveai_ants:antcarry",{
	hp_max = 5,
	physical =false,
	weight = 5,
	collisionbox = {-0.35,-0.35,-0.35,0.35,0.35,0.35},
	visual = "cube",
	visual_size = {x=1,y=1},
	textures ={"aliveai_air.png","aliveai_air.png","aliveai_air.png","aliveai_air.png","aliveai_air.png","aliveai_air.png"},
	colors = {},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
	on_activate=function(self, staticdata)
		if not aliveai_ants.carry then self.object:remove() return end
		self.carry=aliveai_ants.carry
		self.ant=aliveai_ants.ant
		aliveai_ants.carry=nil
		aliveai_ants.ant=nil
		return self
	end,
	on_step=function(self, dtime)
		self.time=self.time+dtime
		if self.time<0.1 then return self end
		self.time=0
		if not (self.ant and self.ant:get_luaentity() and self.ant:get_hp()>0 and self.carry and self.carry:get_attach()) then
			aliveai.punch(self,self.object,20)
			return self
		end
		local c=self.ant:get_pos()
		local pos=self.object:get_pos()
		if not (c and c.x) then aliveai.punch(self,self.object,20) return end
		local v={x=(c.x-pos.x)*4,y=(c.y-pos.y+0.5)*4, z=(c.z-pos.z)*4}
		self.object:set_velocity(v)
		return self
	end,
	time=0,
	type=""
})

