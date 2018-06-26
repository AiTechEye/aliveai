aliveai_chemistry={
	compounds={ex=15,dmg=9000,radio=20,tox=1,tel=100,acid=1,down=500,slime=1,eletric=100,mindman=1,nitro=1,hypo=1,relive=1},
	chemicals={
		["default:coal_lump"]={ex=1},
		["default:iron_lump"]={dmg=2},
		["default:copper_lump"]={radio=3},
		["default:papyrus"]={tox=1},
		["aliveai_threats:killerplant"]={down=2},
		["aliveai_threats:quantumcore"]={tel=5},
		["aliveai_threats:slime"]={slime=1},
		["default:mese_crystal"]={eletric=9},
		["default:mese_crystal_fragment"]={eletric=1},
		["aliveai_threats:mind_manipulator"]={mindman=1},
		["default:ice"]={nitro=1},
		["aliveai:hypnotics"]={hypo=1},
		["aliveai:relive"]={relive=1},
		["dye:green"]={acid=1},
	}
}


aliveai_chemistry.effect=function(pos,chemistry,o)

	local obs={o}

	if chemistry.radio then
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, tonumber(chemistry.radio))) do
			local en=ob:get_luaentity()
			if ((en and en.type) or ob:is_player()) and aliveai.visiable(pos,ob:get_pos()) then
				table.insert(obs,ob)
			end
		end
	end
	if chemistry.dmg then
		local d=tonumber(chemistry.dmg)
		for _, ob in ipairs(obs) do
			aliveai.punchdmg(ob,d)
		end
	end
	if chemistry.tox and aliveai_threats then
		for _, ob in ipairs(obs) do
			aliveai_threats.tox(ob)
		end
	end
	if chemistry.acid and aliveai_threats then
		for _, ob in ipairs(obs) do
			aliveai_threats.acid(ob)
		end
	end
	if chemistry.eletric and aliveai_electric then
		local dmg=chemistry.dmg or 1
		dmg=tonumber(dmg)
		local el=tonumber(chemistry.eletric)
		for _, ob in ipairs(obs) do
			aliveai_electric.hit(ob,el,dmg)
		end
	end
	if chemistry.slime and aliveai_threats then
		for _, ob in ipairs(obs) do
			local p=ob:get_pos()
			if p and not minetest.is_protected(p,"") then
				minetest.add_node(p,{name="aliveai_threats:slime"})
			end
		end
	end
	if  chemistry.nitro and aliveai_nitroglycerine then
		for _, ob in ipairs(obs) do
			if aliveai.gethp(ob)<1 then
				aliveai_nitroglycerine.freeze(ob)
			end
		end
	end
	if  chemistry.mindman and aliveai_threats then
		local tool=minetest.registered_tools["aliveai_threats:mind_manipulator"]
		for _, ob in ipairs(obs) do
			tool.on_use(nil, nil, {type="object",ref=ob})
		end
	end
	if chemistry.ex and aliveai_nitroglycerine then
		local r=tonumber(chemistry.ex)
		local d=1
		if r>6 then
			d=0
		end

		if  chemistry.radio then
			for _, ob in ipairs(obs) do
				aliveai_nitroglycerine.explode(ob:get_pos(),{
					radius=r,
					set="air",
					drops=d
				})
			end
		else
			aliveai_nitroglycerine.explode(pos,{
				radius=r,
				set="air",
				drops=d
			})
		end
	end
	if chemistry.down then
		local y=tonumber(chemistry.down)
		for _, ob in ipairs(obs) do
			local p=ob:get_pos()
			if p then ob:set_pos({x=p.x,y=p.y-y,z=p.z}) end
		end
	end
	if chemistry.hypo then
		for _, ob in ipairs(obs) do
			local en=ob:get_luaentity()
			if en and aliveai.is_bot(ob) and en.hp_max<101 and en.type=="npc" then
				aliveai.sleep(en,2)
			else
				aliveai.punchdmg(ob,10)
			end
		end
	end
	if chemistry.relive then
		for _, ob in ipairs(obs) do
			local en=ob:get_luaentity()
			if en and aliveai.is_bot(ob) then
				if en.dying or en.dead then
					en.dying={step=0,try=en.hp_max*2}
					en.dead=nil
				elseif en.hp_max<101 and en.drop_dead_body==1 then
					en.hp=-10
					aliveai.dying(en,1)
				else
					aliveai.punchdmg(ob,20)
				end
			end
		end
	end
	if chemistry.tel then
		local n=chemistry.radio or 0
		local r=tonumber(n)
		for _, ob in ipairs(obs) do
			local p=aliveai.random_pos(ob:get_pos(),15+r)
			if p then ob:set_pos(p) end
		end
	end
end

aliveai_chemistry.setinfo=function(pos,en)
	local meta=minetest.get_meta(pos)
	local cms=""
	if en==1 then
		for cm, p in pairs(aliveai_chemistry.compounds) do
			local c=meta:get_int(cm)
			if c>0 then 
				cms=cms .. cm ..":" .. c .." "
			end
		end
		meta:set_string("infotext",cms)
	end
	if en==0 then
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			local en=ob:get_luaentity()
			if  en and en.name=="aliveai_chemistry:item2" then
				ob:remove()
			end
		end
		meta:set_int("entity",0)
	elseif en==1 then
		if meta:get_int("entity")==0 then
			minetest.add_entity(pos, "aliveai_chemistry:item2")
			meta:set_int("entity",1)
		end
	end
end

minetest.register_node("aliveai_chemistry:mixer", {
	description = "Chemistry mixer",
	tiles = {"default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png","default_glass.png","default_glass.png"},
	groups = {cracky = 3},
	drawtype="nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = default.node_sound_glass_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{0.43, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.43, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.43, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, -0.43, 0.5, 0.5},
			{-0.5, -0.5, -0.5, 0.5, -0.43, 0.5},
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.43},
		}
	},
	on_blast=function(pos)
		local meta=minetest.get_meta(pos)
		local chemistry={}
		for cm, p in pairs(aliveai_chemistry.compounds) do
			local c=meta:get_int(cm)
			if c>0 then
				if c>aliveai_chemistry.compounds[cm] then
					c=aliveai_chemistry.compounds[cm]
				end
				chemistry[cm]=c
			end
		end
		aliveai_chemistry.setinfo(pos,0)
		minetest.set_node(pos,{name="air"})
		minetest.after(0.01, function(pos,chemistry)
			aliveai_chemistry.effect(pos,chemistry)
		end,pos,chemistry)
	end,
	on_timer = function (pos, elapsed)
		local p={x=pos.x,y=pos.y+1,z=pos.z}
		local update
		local meta=minetest.get_meta(pos)
		for _, ob in ipairs(minetest.get_objects_inside_radius(p,1)) do
			local en=ob:get_luaentity()
			if en and en.name=="__builtin:item" then
				local item=ItemStack(en.itemstring)
				local name=en.dropped_by
				if not minetest.is_protected(pos,name) and aliveai_chemistry.chemicals[item:get_name()] then
					for c, p in pairs(aliveai_chemistry.chemicals[item:get_name()]) do
						meta:set_int(c,meta:get_int(c)+(p*item:get_count()))
					end
					en.object:remove()
					update=true
				end
			end
		end
		if update then
			aliveai_chemistry.setinfo(pos,1)
		end
		return true
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		if minetest.is_protected(pos,player:get_player_name()) then return end
		local bottle=meta:get_string("bottle")
		if itemstack:get_name()=="aliveai_chemistry:tube" then
			meta:set_string("bottle",itemstack:get_name())
			local item=itemstack:to_table()
			if item.meta then
				for cm, p in pairs(aliveai_chemistry.compounds) do
					if item.meta[cm] then
						meta:set_int(cm,meta:get_int(cm)+item.meta[cm])
					end
				end
			end
			if bottle=="" then
				minetest.get_node_timer(pos):start(3)
				itemstack:take_item()
			else
				itemstack:replace(ItemStack(itemstack:get_name()))
			end
			aliveai_chemistry.setinfo(pos,1)
			return itemstack
		elseif bottle=="" then
			return
		end

		if aliveai_chemistry.chemicals[itemstack:get_name()] then
			for c, p in pairs(aliveai_chemistry.chemicals[itemstack:get_name()]) do
				meta:set_int(c,meta:get_int(c)+p)
			end
			itemstack:take_item()
			aliveai_chemistry.setinfo(pos,1)
			return itemstack
		end
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		if minetest.is_protected(pos,puncher:get_player_name())==false then
			local meta=minetest.get_meta(pos)
			local bottle=meta:get_string("bottle")
			if bottle~="" then
				local item=ItemStack(bottle):to_table()
				local cms=""
				for cm, p in pairs(aliveai_chemistry.compounds) do
					local c=meta:get_int(cm)
					local oc=c
					local sc=0
					if c>0 then
						if c>aliveai_chemistry.compounds[cm] then
							c=aliveai_chemistry.compounds[cm]
						end
						item.meta[cm]=c
						cms=cms .. cm ..":" .. c .." "
						sc=oc-c
						if sc<0 then
							sc=0
						end
						meta:set_int(cm,sc)
					end
				end
				item.meta.description=cms
				puncher:get_inventory():add_item("main", item)
				meta:set_string("bottle","")
				minetest.get_node_timer(pos):stop()
				aliveai_chemistry.setinfo(pos,1)
				aliveai_chemistry.setinfo(pos,0)
			end
		end
	end,
	on_destruct = function(pos)
		aliveai_chemistry.setinfo(pos,0)
	end
})

minetest.register_craft({
	output = "aliveai_chemistry:mixer",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"default:steel_ingot","default:glass","default:steel_ingot"},
		{"default:steel_ingot","dye:white","default:steel_ingot"},
	}
})


minetest.register_tool("aliveai_chemistry:tube", {
	description = "Tube",
	inventory_image = "chemistry_tube.png",
		on_use=function(itemstack, user, pointed_thing)
			local item=itemstack:to_table()
			if not item.meta then
				item.meta={dmg=1}
			end
			local chemistry={}
			for cm, p in pairs(aliveai_chemistry.compounds) do
				if item.meta[cm] then
					chemistry[cm]=item.meta[cm]
				end
			end
			if pointed_thing.type=="node" then
				aliveai_chemistry.effect(pointed_thing.above,chemistry)
				itemstack:take_item()
			elseif pointed_thing.type=="object" then
				aliveai_chemistry.effect(pointed_thing.ref:get_pos(),chemistry,pointed_thing.ref)
				itemstack:take_item()
			else
				local dir=user:get_look_dir()
				local pos=user:get_pos()
				pos.y=pos.y+1.5
				local d={x=dir.x*30,y=dir.y*30,z=dir.z*30}
				local e=minetest.add_entity({x=aliveai.nan(pos.x+(dir.x)*1),y=aliveai.nan(pos.y+(dir.y)*1),z=aliveai.nan(pos.z+(dir.z)*1)}, "aliveai_chemistry:item1")
				e:get_luaentity().chemistry=chemistry
				e:setvelocity(d)
				itemstack:take_item()
			end
			return itemstack
		end,
})

minetest.register_craft({
	output = "aliveai_chemistry:tube 9",
	recipe = {
		{"","default:glass",""},
		{"","default:glass",""},
		{"","default:glass",""},
	}
})

minetest.register_entity("aliveai_chemistry:item2",{
	hp_max = 1,
	physical =false,
	pointable=false,
	visual = "wielditem",
	visual_size = {x=0.5,y=0.5},
	textures ={"aliveai_chemistry:tube"},
	is_visible = true,
	automatic_rotate=1,
	on_activate=function(self, staticdata)
		if minetest.get_node(self.object:get_pos()).name~="aliveai_chemistry:mixer" then
			self.object:remove()
		end
	end,
})

minetest.register_entity("aliveai_chemistry:item1",{
	hp_max = 10,
	physical =false,
	visual = "wielditem",
	visual_size = {x=0.5,y=0.5},
	textures ={"aliveai_chemistry:tube"},
	is_visible = true,
	on_activate=function(self, staticdata)
		local r=aliveai.convertdata(staticdata)
		if r and r~="" then
			self.chemistry={}
			for c, p in pairs(r) do
				self.chemistry[c]=p
			end
			self.object:setvelocity({x=0, y=-5, z=0})
		else
			minetest.after(0.01, function(self)
				if not self.chemistry then
					self.object:remove()
				end
			end,self)
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.chemistry_id=math.random(1,99)
		return self
	end,
	get_staticdata = function(self)
		return aliveai.convertdata(self.chemistry)
	end,
	on_step=function(self, dtime)
		self.time=self.time+dtime
		if self.time<self.timer then return self end
		self.time2=self.time2+self.time
		self.time=0
		local pos=self.object:get_pos()
		if not self.oldpos then
			self.oldpos=pos
		end
		if aliveai.def(pos,"walkable") then
			minetest.add_item(self.oldpos,"aliveai_chemistry:tube"):get_luaentity().age=880
			aliveai_chemistry.effect(self.oldpos,self.chemistry)
			self.object:remove()
			return
		end
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 1.5)) do
			local en=ob:get_luaentity()
			if not (en and en.chemistry_id==self.chemistry_id) then
				minetest.add_item(self.oldpos,"aliveai_chemistry:tube"):get_luaentity().age=880
				aliveai_chemistry.effect(pos,self.chemistry,ob)
				self.object:remove()
				return
			end
		end

		if self.time2>5 then
			minetest.add_item(self.oldpos,"aliveai_chemistry:tube"):get_luaentity().age=880
			aliveai_chemistry.effect(self.oldpos,self.chemistry)
			self.object:remove()
		end
		self.oldpos=pos
		return self
	end,
	time=0,
	timer=0.03,
	time2=0,
})