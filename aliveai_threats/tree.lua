aliveai_threats.spawn_tree=function(self)
	if not (self and self.object) then return false end
	local pos=aliveai.roundpos(self.object:getpos())
	if minetest.get_node(pos).name=="air" then return false end

	self.tree_by_nodes={}
	local trunk=""
	local leaves=""
	local tree={}
	local hight=1
	local g=0
	local gm=2
	local xx
	local zz

	for x=-5,5,1 do
	for z=-5,5,1 do
	for y=0,15,1 do
		local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		local name=minetest.get_node(p).name
		local det=0
		if minetest.is_protected(p,"") then
			return false
		elseif aliveai.group(p,"leaves")>0 and (leaves=="" or name==leaves) then
			det=1
		elseif (aliveai.group(p,"tree")>0 or name=="default:acacia_bush_stem" or name=="default:bush_stem") and (trunk=="" or name==trunk) then
			det=2
		end
		if det>0 then
			xx=math.abs(x)
			zz=math.abs(z)
			if xx>g and xx<=gm then
				g=xx
				gm=g+1
			end
			if zz>g and zz<=gm then
				g=zz
				gm=g+1
			end
			if xx<gm and zz<gm then
				if det==1 then leaves=name end
				if det==2 then trunk=name end
				table.insert(tree,{x,y,z,name,p})
				if y>hight then hight=y end
			end
		end
	end
	end
	end

	if #tree<2 then return false end
	self.storge2=hight/2
	local c=self.object:get_properties().collisionbox
	c[5]=self.storge2
	self.object:set_properties({collisionbox=c})
	if trunk~="" then
		self.object:set_properties({textures={trunk}})
		self.storge1=trunk
	else
		self.storge1="default:tree"
	end

	for _, d in ipairs(tree) do
		if d[1]+d[2]+d[3]~=0 then
			local e=minetest.add_entity(pos, "aliveai_threats:trees_block")
			e:set_properties({textures={d[4]}})
			e:set_attach(self.object, "", {x=d[1]*30,y=d[2]*30,z=d[3]*30}, {x=0,y=0,z=0})
			e:get_luaentity().contenta=d[4]
			table.insert(self.tree_by_nodes,{ob=e,pos={x=d[1],y=d[2],z=d[3]},it=d[4]})
		end
		minetest.remove_node(d[5])
	end
	return true
end

aliveai_threats.load_tree=function(self)
	if not (self and self.object) then return false end
	local pos=aliveai.roundpos(self.object:getpos())
	self.tree_by_nodes={}
	local c=self.object:get_properties().collisionbox
	c[5]=self.storge2
	self.object:set_properties({textures={self.storge1},collisionbox=c})

	for _, d in ipairs(self.tree_by_nodes_load) do
		local e=minetest.add_entity(pos, "aliveai_threats:trees_block")
		e:set_properties({textures={d[4]}})
		e:set_attach(self.object, "", {x=d[1]*30,y=d[2]*30,z=d[3]*30}, {x=0,y=0,z=0})
		e:get_luaentity().contenta=d[4]
		table.insert(self.tree_by_nodes,{ob=e,pos={x=d[1],y=d[2],z=d[3]},it=d[4]})	
	end
	self.tree_by_nodes_load=nil
	return true
end

aliveai.savedata.trees=function(self)
	if self.tree_by_nodes then
		local dat=""
		for _, d in ipairs(self.tree_by_nodes) do
			if dat~="" then
				dat=dat .. "!"
			end
			dat=dat .. d.pos.x .."#" .. d.pos.y .."#" .. d.pos.z .."#" .. d.it
		end
		return {tree_by_nodes=dat}
	end
end

aliveai.loaddata.trees=function(self,r)
	if r.tree_by_nodes and type(r.tree_by_nodes)=="string" then
		local dat={}
		local a1=r.tree_by_nodes.split(r.tree_by_nodes,"!")
		for _, d in ipairs(a1) do
			local a2=d.split(d,"#")
			local p=aliveai.strpos(a2[1] .."," .. a2[2] .."," .. a2[3],true)
			table.insert(dat,{p.x,p.y,p.z,a2[4]})
		end
		self.tree_by_nodes_load=dat
	end
	return self
end



aliveai.create_bot({
		attack_players=1,
		name="trees",
		team="tree",
		texture="default_tree.png",
		talking=0,
		light=0,
		building=0,
		type="monster",
		hp=30,
		dmg=9,
		arm=2,
		name_color="",
		collisionbox={-0.5,-0.5,-0.5,0.5,3,0.5},
		visual="wielditem",
		basey=-0.5,
		drop_dead_body=0,
		escape=0,
		spawn_on={"group:tree","default:acacia_bush_stem","default:bush_stem"},
		spawn_y=0,
		visual_size={x=0.5,y=0.5},
		smartfight=0,
		check_spawn_space=0,
		spawn_chance=500,
	spawn=function(self)
		if aliveai_threats.spawn_tree(self)==false then
			self.object:remove()
			return self
		end
	end,	
	on_load=function(self)
		if not self.tree_by_nodes_load then
			self.object:remove()
			return self
		end
		aliveai_threats.load_tree(self)
	end,
	death=function(self,puncher,pos)
		if self.tree_by_nodes then
			for _, d in ipairs(self.tree_by_nodes) do
				if d and d.ob then
					d.ob:set_detach()
					d.ob:setacceleration({x=0, y=-10, z=0})
					d.ob:setvelocity({x=math.random(-2,2), y=math.random(0,1), z=math.random(-2,2)})
					d.ob:set_pos({x=pos.x+d.pos.x,y=pos.y+d.pos.y,z=pos.z+d.pos.z})
					d.ob:set_properties({visual_size={x=0.65,y=0.65}})
				end
			end
		end
	end,
	on_punched=function(self,puncher)
	end
})

minetest.register_entity("aliveai_threats:trees_block",{
	hp_max = 10,
	physical =true,
	pointable=true,
	visual = "wielditem",
	textures ={"air"},
	visual_size={x=2,y=2},
	on_activate=function(self, staticdata)
		minetest.after(0.1, function(self)
			if not self.object:get_attach() then
				self.object:remove()
			end
		end,self)
		self.endtime=math.random(1,4)
	end,
	on_step=function(self, dtime)
		self.time=self.time+dtime
		if self.time<2 then return self end
		self.time=0
		if not self.object:get_attach() then
			self.time2=self.time2+1
			if self.time2>self.endtime then
				if math.random(1,2)==1 then
					minetest.add_item(self.object:get_pos(),self.contenta):get_luaentity().age=890
				end
				self.object:remove()
			end
		end
	end,
	endtime=1,
	time=0,
	time2=0,
})