aliveai_pyramid={
	max_size=10,
	treasures={
		"default:diamond",
		"default:gold_ingot",
		"default:steel_ingot",
		"default:mese_crystal",
		"default:coalblock",
		"default:obsidian",
		"",
		"",
		"",
		"",
		"",
	}
}

aliveai.create_bot({
		description="Old immortal mummy",
		attack_players=1,
		name="mummy",
		team="pyramid",
		texture="aliveai_pyramid_mummy.png",
		attacking=1,
		talking=0,
		light=-1,
		building=0,
		escape=0,
		type="monster",
		dmg=2,
		hp=100,
		name_color="",
		arm=2,
		smartfight=0,
		damage_by_blocks=0,
		mindamage=100,
		spawn_on={"aliveai_pyramid:stone2"},
		spawn_chance=100,
	on_load=function(self)
		self.move.speed=0.2
	end,
	spawn=function(self)
		self.move.speed=0.2
	end,
})

aliveai.register_buildings_spawner("Pyramid",{
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" then
			aliveai_pyramid.gen(pointed_thing.above)
		end
	end,
})

aliveai.register_rndcheck_on_generated({
	node="default:desert_sand",
	chance=20,
	run=function(pos)
		aliveai_pyramid.gen(pos)
	end
})

aliveai_pyramid.settreasure=function(pos)
	minetest.place_node(pos, {name="default:chest"})
	local inv=minetest.get_meta(pos):get_inventory()
	local l=#aliveai_pyramid.treasures
	for i=1,32 do
		inv:set_stack("main",i, ItemStack(aliveai_pyramid.treasures[math.random(1,l)]  .." " .. math.random(1,3)))
	end
end


aliveai_pyramid.paths=function(pos,cur,count,size)
	local d={1,-1}
	local a={x=0,y=0,z=0}
	if math.random(1,2)==1 then
		a.x=d[math.random(1,2)]
	else
		a.z=d[math.random(1,2)]
	end


	local len=math.random(1,size)
	local i=0
	local last=cur
	local w=math.random(1,2)
	local aa={}
	local awall=0
	local n
	while(count>1) do
		count=count-1
		i=i+1
		local t1={x=cur.x+(a.x*i),y=0,z=cur.z+(a.z*i)}
		if i>=len
		or (a.x~=0 and (
			(t1.x>size or t1.x<0)
		))
		or (a.z~=0 and (
			(t1.z>size or t1.z<0)
		))
		then
			i=0
			cur=last
			w=math.random(1,10)
			if a.x~=0 then
				a.x=0
				a.z=d[math.random(1,2)]
			else
				a.z=0
				a.x=d[math.random(1,2)]
			end
			len=math.random(1,size/2)
		else
			if awall>0 then
				awall=awall-1
				if awall<1 then n=nil end
			elseif math.random(1,20)==1 then
				n=math.random(1,3)
				awall=math.random(1,20)
			end

			if not n then
				aa[t1.x .. " ".. t1.y .. " " ..t1.z]=0
			elseif n==1 then
				aa[t1.x .. " ".. t1.y .. " " ..t1.z]=1
				aa[t1.x .. " " .. (t1.y+5) .. " " .. t1.z]=1
				aa[t1.x .. " " .. (t1.y+6) .. " " .. t1.z]=1
				aa[t1.x .. " " .. (t1.y+7) .. " " .. t1.z]=1
				aa[t1.x .. " " .. (t1.y+8) .. " " .. t1.z]=1
			elseif n>1 then
				aa[t1.x .. " ".. t1.y .. " " ..t1.z]=0
				aa[t1.x .. " ".. (t1.y-1) .. " " ..t1.z]=n
			end

			last=t1
			if a.x~=0 then
				if w==1 or w==2 then
					aa[t1.x .. " " .. t1.y .. " " .. (t1.z+1)]=0
					if n==1 then
						aa[t1.x .. " " .. t1.y .. " " .. (t1.z+2)]=1
						aa[t1.x .. " " .. (t1.y+5) .. " " .. (t1.z+1)]=1
						aa[t1.x .. " " .. (t1.y+6) .. " " .. (t1.z+1)]=1
						aa[t1.x .. " " .. (t1.y+7) .. " " .. (t1.z+1)]=1
						aa[t1.x .. " " .. (t1.y+8) .. " " .. (t1.z+1)]=1
					elseif n and n>1 then
						aa[t1.x .. " " .. (t1.y-1) .. " " .. (t1.z+1)]=n
					end
				end
				if w==1 or w==3 then
					aa[t1.x .. " " .. t1.y .. " " .. (t1.z-1)]=0
					if n==1 then
						aa[t1.x .. " " .. t1.y .. " " .. (t1.z-2)]=1
						aa[t1.x .. " " .. (t1.y+5) .. " " .. (t1.z-1)]=1
						aa[t1.x .. " " .. (t1.y+6) .. " " .. (t1.z-1)]=1
						aa[t1.x .. " " .. (t1.y+7) .. " " .. (t1.z-1)]=1
						aa[t1.x .. " " .. (t1.y+8) .. " " .. (t1.z-1)]=1
					elseif n and n>1 then
						aa[t1.x .. " " .. (t1.y-1) .. " " .. (t1.z-1)]=n
					end
				end
			else
				if w==1 or w==2 then
					aa[(t1.x+1) .. " " .. t1.y .. " " .. t1.z]=0
					if n==1 then
						aa[(t1.x+2) .. " " .. t1.y .. " " .. t1.z]=1
						aa[(t1.x+1) .. " " .. (t1.y+5) .. " " .. t1.z]=1
						aa[(t1.x+1) .. " " .. (t1.y+6) .. " " .. t1.z]=1
						aa[(t1.x+1) .. " " .. (t1.y+7) .. " " .. t1.z]=1
						aa[(t1.x+1) .. " " .. (t1.y+8) .. " " .. t1.z]=1
					elseif n and n>1 then
						aa[(t1.x+1) .. " " .. (t1.y-1) .. " " .. t1.z]=n
					end
				end
				if w==1 or w==2 then
					aa[(t1.x-1) .. " " .. t1.y .. " " .. t1.z]=0
					if n==1 then
						aa[(t1.x-2) .. " " .. t1.y .. " " .. t1.z]=1
						aa[(t1.x-1) .. " " .. (t1.y+5) .. " " .. t1.z]=1
						aa[(t1.x-1) .. " " .. (t1.y+6) .. " " .. t1.z]=1
						aa[(t1.x-1) .. " " .. (t1.y+7) .. " " .. t1.z]=1
						aa[(t1.x-1) .. " " .. (t1.y+8) .. " " .. t1.z]=1
					elseif n and n>1 then
						aa[(t1.x-1) .. " " .. (t1.y-1) .. " " .. t1.z]=n
					end
				end
			end
		end
	end
	return aa
end


aliveai_pyramid.rooms=function(a,size)
	local m=3000
	for i=0,size/2,1 do
		local x1=math.random(1,size)
		local z1=math.random(1,size)
		local x2=0
		local z2=0
		if a[(x1+1) .. " " .. 0 .. " "  .. z1] or a[(x1-1) .. " " .. 0 .. " "  .. z1] or a[x1 .. " " .. 0 .. " "  .. (z1+1)] or a[x1 .. " " .. 0 .. " "  .. (z1-1)]
		or a[(x1+2) .. " " .. 0 .. " "  .. z1] or a[(x1-2) .. " " .. 0 .. " "  .. z1] or a[x1 .. " " .. 0 .. " "  .. (z1+2)] or a[x1 .. " " .. 0 .. " "  .. (z1-2)]
		then
			z2=size
		end
		while(z2<size and m>1) do
			m=m-1
			local x=x1+x2
			local z=z1+z2
			local t=x .. " " .. 0 .. " "  .. z
			if not a[t] and not a[(x+3) .. " " .. 0 .. " "  .. z] then
				if math.random(1,size)==1 then
					a[z .. " " .. 1 .. " "  .. z]=4
				end
				a[t]=0
				x2=x2+1
			else
				x2=0
				z2=z2+1
				if a[x .. " " .. 0 .. " "  .. z] or a[x .. " " .. 0 .. " "  .. (z+3)] then
					z2=size
				end
			end
		end
	end
	return a
end

aliveai_pyramid.set=function(pos,a,size,yy)
	local n
	local a2
	for y=yy,8,1 do
	for x=0,size,1 do
	for z=0,size,1 do
		a2=a[x .." " .. y .. " "  .. z]

		if y>0 and not a2 then
			a2=a[x .." " .. 0 .. " "  .. z]
		end

		if (a2==0 or a2==4) and y>-1 and y<5 then
			n="air"
		elseif a2==2 then
			n="aliveai_pyramid:stone1"	--deep hole trap
			for i=-1,-50,-1 do
				minetest.set_node({x=pos.x+x,y=pos.y+y+i,z=pos.z+z},{name="air"})
			end
			if math.random(1,5)==1 then
				n="aliveai_pyramid:stone3"
				minetest.after(1, function(pos,x,y,z)
					minetest.get_node_timer({x=pos.x+x,y=pos.y+y,z=pos.z+z}):start(1)
				end,pos,x,y,z)
			end
		elseif a2==3 then
			n="aliveai_pyramid:stone1"	--quicksand trap
			for i=-1,-10,-1 do
				local d="air"
				if i<-5 then
					d="aliveai_pyramid:quicksand"
				end
				minetest.set_node({x=pos.x+x,y=pos.y+y+i,z=pos.z+z},{name=d})
			end
			if math.random(1,5)==1 then
				n="aliveai_pyramid:stone3"
				minetest.after(1, function(pos,x,y,z)
					minetest.get_node_timer({x=pos.x+x,y=pos.y+y,z=pos.z+z}):start(1)
				end,pos,x,y,z)
			end
		elseif a2==1 then
			n="aliveai_pyramid:stone1"	--falling trap
		else
			n="aliveai_pyramid:stone2"
		end
		minetest.set_node({x=pos.x+x,y=pos.y+y,z=pos.z+z},{name=n})
		if a2==4 then
			aliveai_pyramid.settreasure({x=pos.x+x,y=pos.y+y,z=pos.z+z})
		elseif a2==0 and y==1 and math.random(1,size)==1 then
			minetest.add_entity({x=pos.x+x,y=pos.y+y,z=pos.z+z}, "aliveai_pyramid:mummy")
		end
	end
	end
	end
end

aliveai_pyramid.gen=function(pos)
	local size=math.random(3,aliveai_pyramid.max_size)*10

	local test=0
	for y=-3,0,1 do
	for x=0,size,1 do
	for z=0,size,1 do
		local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		if aliveai.def(p,"walkable") then
			test=test+1
		end
	end
	end
	end
	if test<100*size then return end

	print("aliveai: generating a pyramid [size " .. size .. "] (about" .. (( size*size*size)/2) .." will be affected), you can expect lags")

	local start={
		{x=size/2,z=0},
		{x=size/2,z=size},
		{x=0,z=size/2},
		{x=size,z=size/2}
	}

	local rstart=math.random(1,4)
	start=start[rstart]

	local ostart={x=pos.x+start.x,y=pos.y,z=pos.z+start.z}


	local halfor=math.random(1,2)
	local cur=start
	local count=math.random(size,size*(size/halfor))
	local tsize=size
	local yy=-1

	for i=0,8,1 do
		local a=aliveai_pyramid.paths(pos,cur,count,tsize)
		a=aliveai_pyramid.rooms(a,tsize)
		aliveai_pyramid.set(pos,a,tsize,yy)

		for yo=0,8,1 do
		local m=(yo-9)
		for y=-1,yo,1 do
		for x=-8+y,tsize+(8-y),1 do
		for z=-8+y,tsize+(8-y),1 do
			if (x<=m or x>=tsize-m) or (z<=m or z>=tsize-m) then
				minetest.set_node({x=pos.x+x,y=pos.y+y,z=pos.z+z},{name="aliveai_pyramid:stone2"})
			end
		end
		end
		end
		end

		tsize=tsize-16
		pos={x=pos.x+8,y=pos.y+8,z=pos.z+8}
		yy=1
		local start={
			{x=tsize/2,z=0},
			{x=tsize/2,z=tsize},
			{x=0,z=tsize/2},
			{x=tsize,z=tsize/2}
		}
		start=start[math.random(1,4)]
		local halfor=math.random(1,2)
		local cur=start
		local count=math.random(tsize,tsize*(tsize/halfor))
	end

		local x2=0
		local z2=0

		if rstart==1 then
			z2=-1
		elseif rstart==2 then
			z2=1
		elseif rstart==3 then
			x2=-1
		else
			x2=1
		end

		for y=0,3,1 do
		for i=0,9,1 do
			minetest.set_node({x=ostart.x+(i*x2),y=ostart.y+y,z=ostart.z+(i*z2)},{name="air"})
		end
		end
		print("Pyramid done")
end


minetest.register_node("aliveai_pyramid:stone3", {
	description = "Pyramid trigger stone",
	tiles = {"default_desert_sandstone_block.png"},
	groups = {falling_node=1,cracky=1,level=3},
	damage_per_second =1,
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	drop="aliveai_pyramid:stone2",
	on_punch = function(pos, node, puncher, pointed_thing)
		minetest.check_for_falling(pos)
	end,
	on_timer = function (pos, elapsed)
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos,1.5)) do
			if aliveai.team(ob)~="pyramid" then
				minetest.set_node(pos,{name="aliveai_pyramid:stone1"})
				minetest.check_for_falling(pos)
				return false
			end
		end
		return true
	end,
})



minetest.register_node("aliveai_pyramid:stone1", {
	description = "Pyramid falling stone",
	tiles = {"default_desert_sandstone_block.png"},
	groups = {falling_node=1,cracky=1,level=3},
	damage_per_second =1,
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	drop="aliveai_pyramid:stone2",
	on_punch = function(pos, node, puncher, pointed_thing)
		if math.random(1,10)==1 then
			minetest.remove_node(pos)
			minetest.check_for_falling(pos)
		end
	end,
})

minetest.register_node("aliveai_pyramid:stone2", {
	description = "Pyramid stone",
	tiles = {"default_desert_sandstone_block.png"},
	groups = {cracky=1,level=3},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
})

minetest.register_node("aliveai_pyramid:quicksand", {
	description = "Quicksand",
	drawtype = "liquid",
	tiles = {"default_desert_sand.png"},
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	is_ground_content = false,
	drowning = 1,
	liquidtype = "source",
	liquid_range = 0,
	liquid_alternative_flowing = "aliveai_pyramid:quicksand",
	liquid_alternative_source = "aliveai_pyramid:quicksand",
	liquid_viscosity = 15,
	post_effect_color = {a=255,r=0,g=0,b=0},
	groups = {liquid = 4,crumbly = 1, sand = 1},
})

local dis={
	{"Blue pyramid diamond","000088"},
	{"White pyramid diamond","ffffff"},
	{"Yellow pyramid diamond","aaaa00"},
	{"Red pyramid diamond","aa0000"},
	{"Green pyramid diamond","00aa00"},
	{"Orange pyramid diamond","aa5511"},
	{"Purple pyramid diamond","550055"},
	{"Pink pyramid diamond","aa55aa"},
	{"black pyramid diamond","111111"},
}

for i, d in ipairs(dis) do
minetest.register_node("aliveai_pyramid:diamond" .. i, {
	description = d[1],
	tiles = {"default_sand.png^[colorize:#" .. d[2] .. "bb"},
	groups = {dig_immediate=3},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	walkable=false,
	drawtype = "mesh",
	paramtype = "light",
	sunlight_propagates = true,
	visual_scale = 0.2,
	wield_scale = {x=10, y=10, z=10},
	alpha = 20,
	selection_box = {type = "fixed",fixed={-0.2, -0.5, -0.2, 0.2, -0.2, 0.2}},
	mesh="aliveai_pyramid_diamond.obj",
})
table.insert(aliveai_pyramid.treasures,"aliveai_pyramid:diamond" .. i)
end