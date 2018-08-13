aliveai_threats_eyes={active={}}


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
aliveai_threats_eyes.checkspace=function(pos)
	for i=1,4,1 do
		local p1=minetest.get_node({x=pos.x+i,y=pos.y,z=pos.z}).name=="air"
		local p2=minetest.get_node({x=pos.x-i,y=pos.y,z=pos.z}).name=="air"
		local p3=minetest.get_node({x=pos.x,y=pos.y,z=pos.z+i}).name=="air"
		local p4=minetest.get_node({x=pos.x,y=pos.y,z=pos.z-i}).name=="air"
		if not (p1 and p2 and p3 and p4) then
			return false
		end
	end
	return true
end

aliveai_threats_eyes.spawn=function(pos)
	for i,v in pairs(aliveai_threats_eyes.active) do
		if not v:get_luaentity() or v:get_hp()<1 then
			table.remove(aliveai_threats_eyes.active,i)
		elseif pos.x==v:get_luaentity().stat.x and pos.z==v:get_luaentity().stat.z then
			return false
		end
	end
	local pos1={x=pos.x,y=pos.y-1,z=pos.z}
	local pos2={x=pos.x,y=pos.y+1,z=pos.z}
	if minetest.get_item_group(minetest.get_node(pos).name,"tree")~=0 and
	aliveai_threats_eyes.checkspace(pos) then
		local p={
			{x=pos.x+1,y=pos.y,z=pos.z},
			{x=pos.x-1,y=pos.y,z=pos.z},
			{x=pos.x,y=pos.y,z=pos.z+1},
			{x=pos.x,y=pos.y,z=pos.z-1}
		}
		local side=math.random(1,4)
		local ob=minetest.add_entity(p[side], "aliveai_threats:eyes")
		ob:get_luaentity().side=side
		ob:get_luaentity().stat=pos
		return true
	end
	return false

end

aliveai_threats_eyes.sweating=function(self,pos)
	local p1={x=pos.x,y=pos.y+0.3,z=pos.z}
	local p2={x=pos.x,y=pos.y-0.3,z=pos.z}
	if self.side==1 or self.side==2 then
		p1.z=p1.z+0.3
		p2.z=p2.z-0.3
	else
		p1.x=p1.x+0.3
		p2.x=p2.x-0.3
	end
	minetest.add_particlespawner({
		amount = 1,
		time =0.1,
		maxpos = p1,
		minpos = p2,
		minvel = {x=0, y=-8, z=0},
		maxvel = {x=0, y=-8, z=0},
		minacc = {x=0, y=-8, z=0},
		maxacc = {x=0, y=-10, z=0},
		minexptime = 0.3,
		maxexptime = 0.3,
		minsize = 0.5,
		maxsize = 0.1,
		texture = "default_water.png",
	})
end

aliveai_threats_eyes.shoot=function(self)
	if not (self.fight and math.random(1,20)==1) then return end
	local e=minetest.add_item(aliveai.pointat(self,1),"default:stick")
	local dir=aliveai.get_dir(self,self.fight)
	local vc = {x = aliveai.nan(dir.x*30), y = aliveai.nan(dir.y*30), z = aliveai.nan(dir.z*30)}
	if not (vc and vc.x and vc.y and vc.z) or vc.x==math.huge or vc.x~=vc.x then return end
	e:set_velocity(vc)
	e:get_luaentity().age=(tonumber(minetest.setting_get("item_entity_ttl")) or 900)-2
	table.insert(aliveai_threats.debris,{ob=e,n=self.botname})
end

minetest.register_craftitem("aliveai_threats:tree_eyes", {
	description = "Tree eyes spawner",
	inventory_image = "aliveai_threats_eyes.png",
	on_place = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" and aliveai_threats_eyes.spawn(pointed_thing.under) then
			itemstack:take_item()
		end
		return itemstack
	end
})

minetest.register_entity("aliveai_threats:eyes",{
	hp_max = 10,
	physical =false,
	weight = 0,
	collisionbox = {0,0,0,0,0,0},
	visual = "upright_sprite",
	visual_size = {x=1,y=1},
	textures ={"aliveai_threats_eyes.png"},
	colors = {},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local en=puncher:get_luaentity()
		if not self.exp and tool_capabilities and tool_capabilities.damage_groups and tool_capabilities.damage_groups.fleshy then
			self.hp=self.hp-tool_capabilities.damage_groups.fleshy
			self.object:set_hp(self.hp)
		end
	end,
	get_staticdata = function(self)
		return aliveai.convertdata({side=self.side,opos=self.opos,stat=self.stat})
	end,
	on_activate=function(self, staticdata)
		self.hp=self.object:get_hp()
		local r=aliveai.convertdata(staticdata)
		if r and r~="" then
			self.side=r.side
			self.opos=r.opos
			self.stat=r.stat
		end
		self.botname=aliveai.genname()
		self.opos=aliveai.roundpos(self.object:get_pos())

		minetest.after(0.1, function(self)
			if not self.stat then self.stat=self.object:get_pos() end
			local s=3.14
			if not self.side then self.side=1 end
			if self.side==1 then
				s=4.71
			elseif self.side==2 then
				s=1.57
			elseif self.side==3 then
				s=0
			end
			self.object:setyaw(s)
			table.insert(aliveai_threats_eyes.active,self.object)
			if self.side==1 then
				self.opos.x=self.opos.x-0.49
			elseif self.side==2 then
				self.opos.x=self.opos.x+0.49
			elseif self.side==3 then
				self.opos.z=self.opos.z-0.49
			elseif self.side==4 then
				self.opos.z=self.opos.z+0.49
			end
			self.object:set_pos(self.opos)
		end,self)
		return self
	end,
	on_step=function(self, dtime)
		self.time=self.time+dtime
		self.time2=self.time2+dtime
		if self.time<self.timer then return self end
		self.time=0

		local pos=self.object:get_pos()

		if minetest.get_node(self.stat).name=="air" then aliveai.punch(self,self.object,100) return self end
		if not self.lookat and math.random(1,10)~=1 then return end
		local ob
		
		for _, o in ipairs(minetest.get_objects_inside_radius(pos, 10)) do
			local en=o:get_luaentity()
			local op=o:get_pos()
			if not (en and en.aliveai_eyes) and aliveai.visiable(self,o:get_pos()) and aliveai.viewfield(self,o) then ob=o break end
		end

		if not ob then
			self.timer=2
			self.time2=0
			if self.lookat then
				self.type=""
				self.fight=nil
				self.lookat=nil
				self.object:move_to(self.opos)
				self.object:set_properties({textures = {"aliveai_threats_eyes.png"}})
			end
			return
		end

		local obpos=ob:get_pos()
		if ob:is_player() then obpos.y=obpos.y+2 end
		local x,y,z=0,0,0
		local d=aliveai.distance(pos,obpos)*2
		if self.side==1 or self.side==2 then
			z=(obpos.z-self.opos.z)/d
			if z>0.3 then z=0.3 end
			if z<-0.3 then z=-0.3 end
		else
			x=(obpos.x-self.opos.x)/d
			if x>0.3 then x=0.3 end
			if x<-0.3 then x=-0.3 end
		end
		y=(obpos.y-self.opos.y)/d
		if y>0.3 then y=0.3 end
		if y<-0.3 then y=-0.3 end
		local spos=false
		if self.lookat then spos=aliveai.samepos(self.lookat,obpos) end
		self.object:move_to({x=self.opos.x+x,y=self.opos.y+y,z=self.opos.z+z})
		self.lookat=obpos
		self.timer=0.1

		if self.fight then
			aliveai_threats_eyes.shoot(self)
		end

		if not self.fight and spos and self.time2>10 then
			if d<4 then
				aliveai_threats_eyes.sweating(self,pos)
			else
				self.object:set_properties({textures = {"aliveai_threats_eyes_mad.png"}})
				self.fight=ob
				self.time2=0
				self.type="monster"
			end
		elseif self.fight and self.time2>20 then
			self.object:move_to(self.opos)
			self.timer=2
			self.time2=0
			self.fight=nil
			self.lookat=nil
			self.object:move_to(self.opos)
			self.object:set_properties({textures = {"aliveai_threats_eyes.png"}})
			self.type=""
		elseif not spos then
			self.time2=0
		end
		return self
	end,
	time=0,
	timer=2,
	time2=0,
	type="",
	team="tree",
	aliveai_eyes=1,
})
aliveai.loaded("aliveai_threats:eyes")

