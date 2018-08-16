aliveai.create_bot({
		attack_players=1,
		name="flower",
		team="flowers",
		texture="flowers_rose.png",
		talking=0,
		light=0,
		building=0,
		type="monster",
		hp=1,
		dmg=1,
		arm=1,
		name_color="",
		collisionbox={-0.1,-0.5,-0.1,0.1,0.2,0.1},
		visual="cube",
		drop_dead_body=0,
		escape=0,
		spawn_on={"group:flora"},
		attack_chance=1,
		spawn_chance=50,
		--spawn_interval=5,
		spawn_y=-1,
		smartfight=0,
		basey=-1,
	spawn=function(self,t,t2)
		if not self.storge2 then
			local pos=self.object:get_pos()
			if aliveai.group(pos,"flora")==0 or minetest.is_protected(pos,"") then
				aliveai.kill(self)
				return self
			end
			self.storge1=minetest.get_node(pos).name
			self.inv[self.storge1]=1
			minetest.remove_node(pos)
			pos={x=pos.x,y=pos.y+1,z=pos.z}
			self.object:set_pos(pos)
		end
		self.object:set_properties({visual="wielditem",visual_size={x=0.5,y=0.5},textures={self.storge1}})
	end,	
	on_load=function(self)
		self.spawn(self)
	end,
	on_step=function(self,dtime)
		if self.fight and not self.storge2 then
			local nodes=aliveai.get_nodes(self,self.distance,1)
			for _, nodepos in ipairs(nodes) do
				if aliveai.group(nodepos,"flora")>0 then
					local f=minetest.add_entity(nodepos, "aliveai_threats:flower")
					f:set_yaw(math.random(0,6.28))
					local en=f:get_luaentity()
					aliveai.known(en,self.fight,"fight")
					en.folow=self.fight
					en.fight=self.fight
					en.temper=10
					en.storge2=1
					aliveai.folowing(en)
					return
				end
			end
		elseif not self.fight and self.storge2 and aliveai.def(self.object:get_pos(),"buildable_to") then
			if minetest.get_node(self.object:get_pos()).name~="air" then return end
			local pos=self.object:get_pos()
			if minetest.is_protected(pos,"") then
				aliveai.kill(self)
			else
				minetest.set_node(pos,{name=self.storge1})
				self.object:remove()
			end
		end
	end,
	death=function(self,puncher,pos)
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		aliveai.lookat(self,pos)
	end
})
