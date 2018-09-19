aliveai_storm={time=tonumber(minetest.settings:get("item_entity_ttl")),hails=0,max_hails=20}

aliveai.create_bot({
		description="Using its whirlwind based power to throw everything up in the sky",
		drop_dead_body=0,
		attack_players=1,
		name="storm",
		team="storm",
		texture="aliveai_storm.png",
		stealing=1,
		steal_chanse=2,
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=1,
		hp=40,
		name_color="",
		spawn_on={"group:sand","group:spreading_dirt_type","default:stone"},
	on_step=function(self,dtime)
		if self.fight then
			if not self.power then
				self.timer3 = 0
				self.power=5
			end
			local pos=self.object:get_pos()
			for i, ob in pairs(minetest.get_objects_inside_radius(pos, self.power)) do
				if not ob:get_attach() and aliveai.team(ob)~="storm" and aliveai.visiable(self,ob) and minetest.is_protected(pos,"")==false then
				local v=ob:get_pos()
				aliveai_storm.tmp={ob1=self.object,ob2=ob}
				local m=minetest.add_entity(ob:get_pos(), "aliveai_storm:power")
				if ob:get_luaentity() and ob:get_luaentity().age then ob:get_luaentity().age=0 end
				ob:set_attach(m, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
				end
			end
			self.arm=self.arm+self.power
			self.object:set_properties({
				visual_size={x=self.power/5,y=self.power/5},
				automatic_rotate=self.power*4
			})
			self.power=self.power+0.1
			if self.power>16 then self.fight=nil end
		elseif self.power then
			self.power=nil
			self.arm=2
			self.object:set_properties({
				visual_size={x=1,y=1},
				automatic_rotate=false
			})
		end
	end,
	on_punching=function(self,target)
		self.punc=1
		minetest.after(0.5, function(self)
			self.punc=nil
		end,self)
	end,
})


aliveai.create_bot({
		description="Creates hails",
		drop_dead_body=0,
		attack_players=1,
		name="hail1",
		team="storm",
		texture="default_cloud.png",
		stealing=1,
		steal_chanse=2,
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=1,
		hp=40,
		name_color="",
		start_with_items={["aliveai_storm:hailcore"]=1},
})

aliveai.create_bot({
		description="Creates destroying hails",
		drop_dead_body=0,
		attack_players=1,
		name="hail2",
		team="storm",
		texture="default_ice.png",
		stealing=1,
		steal_chanse=2,
		attacking=1,
		talking=0,
		light=0,
		building=0,
		escape=0,
		type="monster",
		dmg=1,
		hp=40,
		name_color="",
		start_with_items={["aliveai_storm:hailcore2"]=1},
})

minetest.register_entity("aliveai_storm:power",{
	hp_max = 100,
	physical = false,
	visual = "sprite",
	visual_size = {x=1, y=1},
	textures = {"aliveai_air.png"},
	is_visible =true,
	timer = 0,
	timer2=0,
	team="storm",
	on_activate=function(self, staticdata)
		if not aliveai_storm.tmp then
			aliveai.punch(self,self.object,1000)
			return self
		end
		self.ob=aliveai_storm.tmp.ob1
		self.target=aliveai_storm.tmp.ob2

		aliveai_storm.tmp=nil

		self.d=aliveai.distance(self,self.ob:get_pos())
		self.s=0.1
		self.a=0

		local pos=self.ob:get_pos()
		local spos=self.object:get_pos()
		local a=self.a * math.pi * self.s
  		local x, z =  pos.x+self.d*math.cos(a), pos.z+self.d*math.sin(a)
		local y=(pos.y - self.object:get_pos().y)*(self.s*0.5)
		self.a=aliveai.distance(self,{x=x,y=spos.y+y,z=z})*(math.pi*1)
	end,
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<0.15 then return true end
		self.timer=0
		if not self.ob:get_luaentity() or self.kill then
			self.target:set_detach()
			self.target:set_acceleration({x=0,y=-10,z=0})
			if self.target:get_luaentity() and
			self.target:get_luaentity().age then
				self.target:get_luaentity().age=aliveai_storm.time
			end
			aliveai.punch(self,self.object,1000)
			return self
		end
		if self.ob:get_luaentity().punc then
			self.d=1
		end
		if not self.pus and self.d<2 then
			local v=self.object:get_velocity()
			self.object:set_velocity({x=v.x,y=100,z=v.z})
			self.object:set_acceleration({x=0,y=-10,z=0})
			self.pus=1
			self.object:set_properties({physical = true})
			return self
		elseif self.pus then
			if aliveai.distance(self,self.ob)>100 or self.object:get_velocity().y==0 then
				self.kill=1
				aliveai.punch(self,self.target,10)
				return self
			end
		end
		local pos=self.ob:get_pos()
		local spos=self.object:get_pos()
		local s=0
		local a=self.a * math.pi * self.s
  		local x, z =  pos.x+self.d*math.cos(a), pos.z+self.d*math.sin(a)
  		self.a=self.a+1
		self.d=self.d-0.1

		local y=(pos.y - self.object:get_pos().y)*self.s
		if minetest.registered_nodes[minetest.get_node({x=x,y=spos.y+y,z=z}).name].walkable then
			if minetest.registered_nodes[minetest.get_node({x=x,y=spos.y+y+1,z=z}).name].walkable==false then
				y=y+1
			else
				self.d=self.d-0.5
				a=self.a * self.s
  				x=pos.x+self.d*math.cos(a)
				z =pos.z+self.d*math.sin(a)
				self.object:move_to({x=x,y=spos.y+y,z=z})
				return self
			end
		end
		self.object:move_to({x=x,y=spos.y+y,z=z})
		return self
	end,
})


minetest.register_tool("aliveai_storm:hailcore", {
	description = "Hail core",
	inventory_image = "default_cloud.png",
	on_use = function(itemstack, user, pointed_thing)
		local pos=user:get_pos()
		pos.y=pos.y+15
		local r
		local e=0
		if aliveai_storm.hails>aliveai_storm.max_hails then return end
		aliveai_storm.hails=aliveai_storm.hails+1
		for i=0,500,1 do
			e=i*0.1
			r={x=pos.x+math.random(-10,10),y=pos.y+math.random(-5,5),z=pos.z+math.random(-10,10)}
			minetest.after(e, function(r)
				aliveai_storm.new=1
				minetest.add_entity(r, "aliveai_storm:hail")
				aliveai_storm.new=nil
			end,r)
		end
		minetest.after(e, function()
			aliveai_storm.hails=aliveai_storm.hails-1
		end)
		itemstack:add_wear(65535/15)
		return itemstack
	end
})
	
minetest.register_tool("aliveai_storm:hailcore2", {
	description = "Hail core 2",
	inventory_image = "default_ice.png",
	on_use = function(itemstack, user, pointed_thing)
		local pos=user:get_pos()
		pos.y=pos.y+15
		local r
		local e=0
		if aliveai_storm.hails>aliveai_storm.max_hails then return end
		aliveai_storm.hails=aliveai_storm.hails+1
		for i=0,500,1 do
			e=i*0.1
			r={x=pos.x+math.random(-10,10),y=pos.y+math.random(-5,5),z=pos.z+math.random(-10,10)}
			minetest.after(e, function(r)
				aliveai_storm.new=2
				minetest.add_entity(r, "aliveai_storm:hail")
				aliveai_storm.new=nil
			end,r)
		end
		minetest.after(e, function()
			aliveai_storm.hails=aliveai_storm.hails-1
		end)
		itemstack:add_wear(65535/10)
		return itemstack
	end
})

minetest.register_entity("aliveai_storm:hail",{
	hp_max = 1,
	physical = true,
	visual = "sprite",
	visual_size = {x=0.1, y=0.1},
	collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
	textures = {"default_cloud.png"},
	is_visible =true,
	timer = 0,
	timer2 = 3,
	team="storm",
	type="monster",
	on_activate=function(self, staticdata)
		if not aliveai_storm.new then
			self.object:remove()
			return self
		end
		self.hail=aliveai_storm.new
		if self.hail==2 then
			self.object:set_properties({
				textures={"default_ice.png"},
				visual_size = {x=0.5, y=0.5},
				collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
				makes_footstep_sound = true,
			})
			self.object:set_velocity({x=math.random(-1,1),y=-3,z=math.random(-1,1)})
		else
			self.object:set_velocity({x=math.random(-5,5),y=-30,z=math.random(-5,5)})
		end
		self.object:set_acceleration({x=0,y=-10,z=0})
	end,
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<0.15 then return true end
		self.timer2=self.timer2-self.timer
		self.timer=0
		if self.object:get_velocity().y>=-0.9 or self.timer2<0 then
			local pos=self.object:get_pos()
			pos.y=pos.y-1.5
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
				if aliveai.team(ob)~="storm" then aliveai.punch(self,ob,2*self.hail) end
			end
			pos.y=pos.y+0.5
			if self.hail==2 and minetest.is_protected(pos,"")==false then
				local n=minetest.get_node(pos).name
				if minetest.get_item_group(n,"flammable")>0
				or minetest.get_item_group(n,"oddly_breakable_by_hand")>0
				or minetest.get_item_group(n,"crumbly")>0
				or minetest.get_item_group(n,"choppy")>0
				or minetest.get_item_group(n,"flammable")>0
				or minetest.get_item_group(n,"dig_immediate")>0 then
					minetest.set_node(pos,{name="air"})
				end
			end
			self.object:remove()
			return self
		end
	end,
})

