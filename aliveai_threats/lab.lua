aliveai_threats.lab={
		furnishings1={"vessels:shelf","aliveai:chair","aliveai_threats:timed_bumb","aliveai_threats:timed_nitrobumb","aliveai_threat_eletric:timed_ebumb","aliveai_threats:landmine","aliveai_threats:deadlock","aliveai_massdestruction:nuclearbarrel"},
		furnishings2={"vessels:steel_bottle","vessels:glass_bottle","vessels:drinking_glass","aliveai_threats:toxic_tank","aliveai_threats:labbottle_containing","aliveai_threats:labbottle"},
		cam={"aliveai_threats:secam","aliveai_threats:secam2","aliveai_threat_eletric:secam"}
		}

minetest.register_tool("aliveai_threats:labspawner", {
	description = "labspawner",
	range=15,
	groups={not_in_creative_inventory=1},
	inventory_image = "default_stick.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" then
			aliveai_threats.lab.spawning(pointed_thing.under,1)
		end
	end,
	on_place = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" then
			aliveai_threats.lab.gen_stair2(pointed_thing.above)
		end
	end
})

minetest.register_node("aliveai_threats:lab_spawner", {
	description = "Lab spawner",
	drawtype="airlike",
	groups = {not_in_creative_inventory=1},
	is_ground_content = false
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "aliveai_threats:lab_spawner",
	wherein        = "default:stone",
	clust_scarcity = 36 * 36 * 36,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = -100,
	y_max          = 20,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "aliveai_threats:lab_spawner",
	wherein        = "default:desert_stone",
	clust_scarcity = 36 * 36 * 36,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = -100,
	y_max          = 20,
})

aliveai.register_on_generated("aliveai_threats:lab_spawner",function(pos)
	minetest.after(0, function(pos)
		if math.random(1,10)==1 then
			aliveai_threats.lab.spawning(pos)
		end
	end,pos)
	return "default:stone"
end)

aliveai_threats.lab.spawning=function(p,nrnd)
		if not nrnd and math.random(1,100)~=1 then return end
		local pos4
		for i=1,20,1 do
			pos4={x=p.x,y=p.y+i,z=p.z}
			local get_light=minetest.get_node_light(pos4)
			if minetest.get_node(pos4).name=="ignore" or (get_light and get_light>3) or minetest.is_protected(pos4,"") then return end
		end
			p={x=p.x-20,y=p.y-3,z=p.z-20}
			local sta
			local by=math.random(4,6)
			local bx=12
			local bz=12
			local floor=math.random(1,4)
			local cfloor=0
			local croom=0
			aliveai_threats.lab.gen_stairs2=1
			for y=6,floor*6,6 do
			cfloor=cfloor+1
			for x=0,24,12 do
			for z=0,24,12 do
				croom=croom+1
				aliveai_threats.lab.gen_room({x=p.x+x,y=p.y+y,z=p.z+z},bx,by,bz,floor,cfloor,croom)
			end
			end
			end

			if aliveai_threats.lab.gen_stairs2==1 then		--force add stair if none is spawned
				aliveai_threats.lab.gen_stair2({x=p.x+12+1,y=p.y+(floor*6)+1,z=p.z+12+1})
				aliveai_threats.lab.gen_stairs2=nil
			end

end



aliveai_threats.lab.spawn=function(pos)
	local bots={}
	local c=0
	for i, v in pairs(aliveai.registered_bots) do
		if (v.team=="nuke" or v.team=="alien") and v.mod_name~="aliveai_massdestruction" then
			table.insert(bots,v.bot)
		end
	end
	local addbot=bots[aliveai.random(1,#bots)]
	if addbot then minetest.add_entity(pos, addbot) end
end

aliveai_threats.lab.gen_stair2=function(pos)

	local ys=0
	local base="default:silver_sandstone_brick"
	local stair="stairs:stair_steelblock"

	local pos3
	local get_light
	local light="aliveai_threats:lablight"
	local light2="aliveai_threats:lablight2"
	local set_timer=false
	for i=1,1000,1 do
		pos3={x=pos.x,y=pos.y+i,z=pos.z}
		get_light=minetest.get_node_light(pos3)
		if minetest.get_node(pos3).name=="ignore" then return end
		if i>6 and get_light and get_light>3 and pos3.y>7 and aliveai.def(pos3,"buildable_to") then
			ys=i-1
			break
		end	
	end
	if ys==0 then return end
	pos3={x=pos.x+2,y=pos3.y-1,z=pos.z+2}
	local pos4
	for y=0,6,1 do
	for x=-6,6,1 do
	for z=-6,6,1 do
		pos4={x=pos3.x+x,y=pos3.y+y,z=pos3.z+z}
		if not minetest.is_protected(pos4,"") then
			if (y==0 or y==6 or x==-6 or x==6 or z==-6 or z==6) and not ((y==1 or y==2) and (x==0 or z==0)) then
				minetest.set_node(pos4,{name=base})
			elseif y==5 and ((x==-4 and z==-4) or (x==4 and z==4) or (x==-4 and z==4) or (x==4 and z==-4)) then
				local r=math.random(1,4)
				if r==3 then
					local r2=math.random(1,#aliveai_threats.lab.cam)
					if aliveai_threats.lab.cam[r2] then
						minetest.set_node(pos4,{name=aliveai_threats.lab.cam[r2],param2=21})
						minetest.get_meta(pos4):set_string("team","nuke")
						minetest.get_node_timer(pos4):start(1)
					end
					elseif r==1 then
					minetest.set_node(pos4,{name=light})
				elseif r==2 then
					minetest.set_node(pos4,{name=light2})
					minetest.get_node_timer(pos4):start(1)
				else
					minetest.set_node(pos4,{name=light2})
				end
			else
				minetest.set_node(pos4,{name="air"})
			end
		end
	end
	end
	end

	local a={x=0,y=0,z=0}

	local pos2
	local n
	local k=true
	local m
	local p=0

	local st=(ys+1)*5*5
	local s=0
	local ss=0
	local set_timer=false
	for y=0,ys,1 do
	for x=-1,5,1 do
	for z=-1,5,1 do
		ss=ss+1
		pos2={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		if y==a.y and x==a.x and z==a.z then			--stair
			n=stair
			a.y=a.y+1
			s=s+1
			if s<=4 then
				p=1
				if s==1 then p=2 end
				a.x=a.x+1
			elseif s<=8 then
				if s==5 then p=1 end
				a.z=a.z+1
			elseif s<=12 then
				p=3
				if s==9 then p=0 end
				a.x=a.x-1
			elseif s<=16 then
				p=2
				if s==13 then p=3 end
				a.z=a.z-1
				if s==16 then s=0 end
			end
		elseif y==ys and not (x==-1 or x==5 or z==-1 or z==5) then				--floor table
			n="aliveai_threats:labtable2"
			set_timer=true
		elseif s==5 and x==4 and z==4 then
			local r=math.random(1,4)
			if r==1 then
				n=light
			elseif r==2 then
				n=light2
				set_timer=true
			else
				n=light2
			end
			p=12
		elseif y>=4 and (x==-1 or x==5 or z==-1 or z==5) then			--walls
			n=base
		elseif y<4 and (x==-1 or x==5 or z==-1 or z==5) then
			n=""
		elseif y<ys then						--clean
			n="air"
		end
									--set
		if n~="" then minetest.set_node(pos2,{name=n,param2=p}) end
		if set_timer then
			minetest.get_node_timer(pos2):start(1)
			set_timer=false
		end
		p=0
	end
	end
	end
end

aliveai_threats.lab.gen_stair=function(pos)
	local base="default:silver_sandstone_brick"
	local stair="stairs:stair_steelblock"
	local a={x=0,y=0,z=0}
	local pos2
	local n
	local k=true
	local m
	local p=0
	for y=0,6,1 do
	for x=0,4,1 do
	for z=0,4,1 do
		if y==a.y and y<6 and x==a.x and z==a.z then			--stair
			n=stair
			a.y=a.y+1
			if y==0 then
				a.x=a.x+1
				p=2
			elseif y<4 then
				a.x=a.x+1
				p=1
			else
				if y==4 then p=1 end
				a.z=a.z+1
			end
		elseif y>2 and ((z==0 and x>0) or (z==1 and x==4)) then		--hole
			n="air"
			if y==5 and (x==1 or x==2) then
				n="aliveai_threats:labtable2"
			end
		else							--clean
			n="air"
			if y>2 then n="" end
		end

		if n~="" then						--set
			pos2={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			minetest.set_node(pos2,{name=n,param2=p})
		end
		p=0

	end
	end
	end
end

aliveai_threats.lab.gen_room=function(pos,bx,by,bz,floor,cfloor,croom)
	if not pos then return end
	pos=aliveai.roundpos(pos)

	local base="default:silver_sandstone_brick"
	local n="air"
	local door="aliveai:door_steel"
	local light="aliveai_threats:lablight"
	local light2="aliveai_threats:lablight2"
	local furn="aliveai_threats:labtable"
	local pos2
	local set_timer=false
	local get_light=0
	local m=nil
	local d={}
	local a={x=bx,y=by,z=bz}

	local doors={
		x1=math.random(1,5)>1,
		x2=math.random(1,5)>1,
		z1=math.random(1,5)>1,
		z2=math.random(1,5)>1,
		xb1=math.random(1,5)>1,
		xb2=math.random(1,5)>1,
		zb1=math.random(1,5)>1,
		zb2=math.random(1,5)>1
		}


	local wall={n=0,
		x1=math.random(0,20)>5,
		x2=math.random(0,20)>5,
		z1=math.random(0,20)>5,
		z2=math.random(0,20)>5
		}
--door inside ... pos of 1/2 box
	local x1=a.x/2
	local z1=a.z/2
--door boxes sides
	local x2a=a.x/4
	local x2b=a.x-x2a
	local z2a=a.z/4
	local z2b=a.z-z2a
--walls count

	if wall.x1 then wall.n=wall.n+1 end
	if wall.x2 then wall.n=wall.n+1 end
	if wall.z1 then wall.n=wall.n+1 end
	if wall.z2 then wall.n=wall.n+1 end


	local all_nodes={}

	for y=0,a.y,1 do
	for x=0,a.x,1 do
	for z=0,a.z,1 do
		pos2={x=pos.x+x,y=pos.y+y,z=pos.z+z}

		get_light=minetest.get_node_light(pos2)

		if (get_light and get_light>7) or minetest.is_protected(pos2,"") then return end

		if x==0 or x==a.x				--wall box
		or y==0
		or y==a.y
		or z==0 or z==a.z then
			if (y==1 or y==2) and ((x==x2a and doors.xb1) or (x==x2b and doors.xb2) or (z==z2a and doors.zb1) or (z==z2b and doors.zb2)) and minetest.get_node(pos2).name==base then
				if y==1 then 
					n=door
				else
					n="air"
				end
			else
				n=base
			end
		elseif y==1 and ((x==1 and z==1) or (x==x1+1 and z==z1+1)) then	--set stair
			if aliveai_threats.lab.gen_stairs2 and cfloor==floor and (math.random(1,20)==1 or croom==9) then
				aliveai_threats.lab.gen_stairs2=nil
				n="stair2"
			elseif cfloor<floor and math.random(1,8)==1 then
				n="stair"
			end
		elseif wall.n>1 and (			--middle walls
		(wall.x1 and x<x1 and z==z1) or
		(wall.x2 and x>x1 and z==z1) or
		(wall.z1 and z<z1 and x==x1) or
		(wall.z2 and z>x1 and x==x1)) then
			if (y==1 or y==2) and (		--door
			(doors.x1 and wall.x1 and x==x1/2) or
			(doors.x2 and wall.x2 and x==x1*1.5) or
			(doors.z1 and wall.z1 and z==z1/2) or
			(doors.z2 and wall.z2 and z==z1*1.5)) then
				if y==1 then
					n=door
				else
					n="air"
				end
			else
				n=base	
			end
		elseif wall.n>1 and x==x1 and z==z1 then			--center
			n=base
		elseif y==a.y-1 and ((x==x2a and z==z2a) or (x==x2b and z==z2b) or (x==x2a and z==z2b) or (x==x2b and z==z2a)) then
			local r=math.random(1,10)
			if r==5 and math.random(1,2)==1 then
				local r2=math.random(1,#aliveai_threats.lab.cam)
				if aliveai_threats.lab.cam[r2] then
					n=aliveai_threats.lab.cam[r2]
					m=1
					set_timer=true
				end
			elseif r>4 then
				n=light
			elseif r<4 then
				n=light2
			else
				n=light
				set_timer=true
			end
		elseif y==1 and (x==1 or z==1 or x==a.x-1 or z==a.z-1) then	--set furns
			n=furn
			set_timer=true
		else					--else
			n="air"
		end

		table.insert(all_nodes,{n=n,pos=pos2,m=m})
		m=nil
		if set_timer then
			set_timer=false
			minetest.get_node_timer(pos2):start(1)
		end
	end
	end
	end
	for i, v in pairs(all_nodes) do
		if v.m then
			minetest.set_node(v.pos,{name=v.n,param2=21})
			minetest.get_meta(pos):set_string("team","nuke")
		elseif v.n=="stair" then
			minetest.after(math.random(1), function(v)
				aliveai_threats.lab.gen_stair(v.pos)
			end,v)
		elseif v.n=="stair2" then
			minetest.after(math.random(1), function(v)
				aliveai_threats.lab.gen_stair2(v.pos)
			end,v)
		else
			minetest.set_node(v.pos,{name=v.n})
		end
	end

end


minetest.register_node("aliveai_threats:lablight", {
	description = "Lab light",
	tiles = {"default_cloud.png"},
	drawtype = "nodebox",
	groups = {snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {type="fixed",fixed={-0.2,0.3,-0.4,0.2,0.5,0.4}},
	light_source=14,
	on_punch = function(pos, node, puncher, pointed_thing)
		if minetest.is_protected(pos,puncher:get_player_name())==false then
			minetest.sound_play("default_break_glass", {pos=pos, gain = 1.0, max_hear_distance = 5})
			minetest.get_node_timer(pos):start(1)
			minetest.swap_node(pos, {name = "aliveai_threats:lablight2",param2=minetest.get_node(pos).param2})
		end
	end,
	on_timer = function (pos, elapsed)
		if math.random(3)==1 then
			minetest.swap_node(pos, {name = "aliveai_threats:lablight2",param2=minetest.get_node(pos).param2})
		end
		return true
	end,
	on_blast=function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
})

minetest.register_node("aliveai_threats:lablight2", {
	description = "Lab light damaged (off)",
	tiles = {"default_cloud.png"},
	drawtype = "nodebox",
	groups = {snappy = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	node_box = {type="fixed",fixed={-0.2,0.3,-0.4,0.2,0.5,0.4}},
	drop="aliveai_threats:lablight",
	paramtype2 = "facedir",
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function (pos, elapsed)
		if math.random(3)==1 then
			minetest.swap_node(pos, {name = "aliveai_threats:lablight",param2=minetest.get_node(pos).param2})
		end
		return true
	end,
	on_blast=function(pos)
		minetest.get_node_timer(pos):stop()
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		if minetest.is_protected(pos,puncher:get_player_name())==false then
			minetest.sound_play("default_break_glass", {pos=pos, gain = 1.0, max_hear_distance = 5})
			minetest.get_node_timer(pos):stop()
		end
	end,
})

minetest.register_node("aliveai_threats:labtable2", {
	description = "Lab table2",
	tiles = {"default_silver_sandstone_brick.png"},
	drawtype = "nodebox",
	node_box = {type="fixed",fixed={-0.5,0.4,-0.5,0.5,0.5,0.5}},
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	on_timer = function (pos, elapsed)
		for i=1,3,1 do
			if aliveai.def({x=pos.x,y=pos.y-i,z=pos.z},"walkable") then
				minetest.set_node(pos,{name="air"})
				return false
			end	
		end
		return false
	end,
})

minetest.register_node("aliveai_threats:deadlock", {
	description = "Deadlock",
	groups = {cracky=3,not_in_creative_inventory=1},
	tiles={"default_steel_block.png^aliveai_threats_quantum_monster_lights.png"},
	paramtype = "light",
	is_ground_content = false,
	drawtype = "nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function (pos, elapsed)
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			if aliveai.is_bot(ob) then
				ob:get_luaentity().timer=-1
				return true
			end
		end
		return true
	end,
})

minetest.register_node("aliveai_threats:toxic_tank", {
	description = "Toxic tank",
	groups = {cracky=3,snappy = 3,not_in_creative_inventory=1},
	tiles={"default_glass.png"},
	special_tiles = {
		{
			name = "default_lava_source_animated.png^[colorize:#d8ff2d77",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1,
			},
		},
	},
	paramtype = "light",
	is_ground_content = false,
	drawtype = "glasslike_framed",
	paramtype2 = "glasslikeliquidlevel",
	sounds = default.node_sound_glass_defaults(),
	on_punch = function(pos, node, puncher, pointed_thing)
		minetest.get_node_timer(pos):start(1)
	end,

	on_construct = function(pos)
		local a=math.random(32,64)
		minetest.get_meta(pos):set_int("v",a)
		minetest.swap_node(pos, {name = "aliveai_threats:toxic_tank",param2=a})
	end,
	on_timer = function (pos, elapsed)
		local v=minetest.get_meta(pos):get_int("v")
		minetest.get_meta(pos):set_int("v",v-1)
		
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 3)) do
			if  aliveai.visiable(pos,ob:get_pos()) then aliveai_threats.tox(ob) end
		end
		if v>0 then
			minetest.swap_node(pos, {name = "aliveai_threats:toxic_tank",param2=v})
			return true
		else
			minetest.set_node(pos,{name="default:glass"})
			return false
		end
	end,
})

minetest.register_node("aliveai_threats:labbottle_containing", {
	description = "Lab bottle",
	groups = {not_in_creative_inventory=1,dig_immediate = 3, attached_node = 1},
	inventory_image = "aliveai_threats_testbottle_containin.png",
	tiles={"aliveai_threats_testbottle_containin.png"},
	paramtype = "light",
	is_ground_content = false,
	drawtype = "plantlike",
	walkable = false,
	sounds = default.node_sound_glass_defaults(),			
	selection_box = {
		type = "fixed",
		fixed = {-0.27, -0.5, -0.27, 0.27, 0.2, 0.27}
	},
	drop = {
		max_items=2,
		items = {
			{items = {"aliveai_threats:labbottle"}},
			{items = {"aliveai:hypnotics"}, rarity = 2},
			{items = {"aliveai_threats:mind_manipulator"}, rarity = 3},
			{items = {"aliveai_threats:acid"}, 2},
			{items = {"aliveai_massdestruction:blackholecore"}, rarity = 2},
			{items = {"aliveai:relive"}, rarity = 2},
			{items = {"aliveai:team_gift"}, rarity = 3},
		}}
})
minetest.register_node("aliveai_threats:labbottle", {
	description = "Lab bottle",
	groups = {vessel = 1, not_in_creative_inventory=1,dig_immediate = 3, attached_node = 1},
	tiles={"aliveai_threats_testbottle.png"},
	inventory_image = "aliveai_threats_testbottle.png",
	paramtype = "light",
	is_ground_content = false,
	drawtype = "plantlike",
	walkable = false,
	sounds = default.node_sound_glass_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.27, -0.5, -0.27, 0.27, 0.2, 0.27}
	},
	on_use = function(itemstack, user, pointed_thing)
		local pos=user:get_pos()
		local dir=user:get_look_dir()
		local e=minetest.add_item({x=pos.x+(dir.x*2),y=pos.y+2+(dir.y*2),z=pos.z+(dir.z*2)},"aliveai_threats:labbottle")
		local vc = {x = dir.x*15, y = dir.y*15, z = dir.z*15}
		e:set_velocity(vc)
		e:get_luaentity().age=(tonumber(minetest.setting_get("item_entity_ttl")) or 900)-10
		e:get_luaentity().on_punch=nil 
		e:get_luaentity().hp_max=10
		table.insert(aliveai_threats.debris,{ob=e,n=user:get_player_name()})
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft( {
	output = "vessels:glass_fragments",
	recipe = {
		{"aliveai_threats:labbottle"},
		{"aliveai_threats:labbottle"},
	}
})

minetest.override_item("vessels:drinking_glass", {
	on_use = function(itemstack, user, pointed_thing)
		local pos=user:get_pos()
		local dir=user:get_look_dir()
		local e=minetest.add_item({x=pos.x+(dir.x*2),y=pos.y+2+(dir.y*2),z=pos.z+(dir.z*2)},"vessels:drinking_glass")
		local vc = {x = dir.x*15, y = dir.y*15, z = dir.z*15}
		e:set_velocity(vc)
		e:get_luaentity().age=(tonumber(minetest.setting_get("item_entity_ttl")) or 900)-10
		table.insert(aliveai_threats.debris,{ob=e,n=user:get_player_name()})
		itemstack:take_item()
		return itemstack
	end,
})
minetest.override_item("vessels:glass_bottle", {
	on_use = function(itemstack, user, pointed_thing)
		local pos=user:get_pos()
		local dir=user:get_look_dir()
		local e=minetest.add_item({x=pos.x+(dir.x*2),y=pos.y+2+(dir.y*2),z=pos.z+(dir.z*2)},"vessels:glass_bottle")
		local vc = {x = dir.x*15, y = dir.y*15, z = dir.z*15}
		e:set_velocity(vc)
		e:get_luaentity().age=(tonumber(minetest.setting_get("item_entity_ttl")) or 900)-10
		table.insert(aliveai_threats.debris,{ob=e,n=user:get_player_name()})
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_node("aliveai_threats:labtable", {
	description = "Lab table",
	tiles = {"default_silver_sandstone_block.png^[colorize:#ffffff77"},
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	on_timer = function (pos, elapsed)
		local d="aliveai:door_steel"
		if minetest.get_node({x=pos.x+1,y=pos.y,z=pos.z}).name==d
		or minetest.get_node({x=pos.x-1,y=pos.y,z=pos.z}).name==d
		or minetest.get_node({x=pos.x,y=pos.y,z=pos.z+1}).name==d
		or minetest.get_node({x=pos.x,y=pos.y,z=pos.z-1}).name==d then
			minetest.set_node(pos,{name="air"})
			return false
		end
		local r1=math.random(1,5)
		if r1>3 then 
			local n=math.random(1,#aliveai_threats.lab.furnishings2+5)
			if aliveai_threats.lab.furnishings2[n] then
				pos.y=pos.y+1
				minetest.set_node(pos,{name=aliveai_threats.lab.furnishings2[n]})
			end
		elseif r1==3 and math.random(1,10)==1 then
			local n=math.random(1,#aliveai_threats.lab.furnishings1)
			if aliveai_threats.lab.furnishings1[n] then
				minetest.set_node(pos,{name=aliveai_threats.lab.furnishings1[n]})
				if aliveai_threats.lab.furnishings1[n]=="aliveai_threats:deadlock" then
					aliveai_threats.lab.spawn(pos)
				end
			end
		elseif r1<3 then
			minetest.set_node(pos,{name="air"})
			if math.random(1,30)==1 then
				aliveai_threats.lab.spawn(pos)
			end
		end
		return false
	end,
})

