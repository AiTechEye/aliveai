aliveai_electric={player={}}

aliveai_electric.pos_between=function(pos1,pos2,density)
	if not ((pos1 and pos1.x and pos1.y and pos1.z) or (pos2 and pos2.x and pos2.y and pos2.z)) then return end
	local d=aliveai.distance(pos1,pos2)
	density=density or 1
	local allpos={}
	local v = {x = pos1.x - pos2.x, y = pos1.y - pos2.y-1, z = pos1.z - pos2.z}
	local amount = (v.x ^ 2 + v.y ^ 2 + v.z ^ 2) ^ 0.5
	local d=math.sqrt((pos1.x-pos2.x)*(pos1.x-pos2.x) + (pos1.y-pos2.y)*(pos1.y-pos2.y)+(pos1.z-pos2.z)*(pos1.z-pos2.z))
	v.x = (v.x  / amount)*-1
	v.y = (v.y  / amount)*-1
	v.z = (v.z  / amount)*-1
	for i=1,d,density do
		local posn={x=pos1.x+(v.x*i),y=pos1.y+(v.y*i),z=pos1.z+(v.z*i)}
		if not aliveai.def(posn,"buildable_to") then
			return allpos
		end
		table.insert(allpos,posn)
	end
	return allpos
end

aliveai_electric.getobjects=function(pos1,pos2)
	if not ((pos1 and pos1.x and pos1.y and pos1.z) or (pos2 and pos2.x and pos2.y and pos2.z)) then return end
	local d=aliveai.distance(pos1,pos2)
	local p={}
	local obs2={}
	local obs1=minetest.get_objects_inside_radius(pos1, d)
	local allpos={}
	local v = {x = pos1.x - pos2.x, y = pos1.y - pos2.y-1, z = pos1.z - pos2.z}
	local amount = (v.x ^ 2 + v.y ^ 2 + v.z ^ 2) ^ 0.5
	local d=math.sqrt((pos1.x-pos2.x)*(pos1.x-pos2.x) + (pos1.y-pos2.y)*(pos1.y-pos2.y)+(pos1.z-pos2.z)*(pos1.z-pos2.z))
	v.x = (v.x  / amount)*-1
	v.y = (v.y  / amount)*-1
	v.z = (v.z  / amount)*-1
	for i=1,d,1 do
		local posn={x=pos1.x+(v.x*i),y=pos1.y+(v.y*i),z=pos1.z+(v.z*i)}
		if not aliveai.def(posn,"buildable_to") then
			return obs2,allpos,posn
		else
			for _, ob in ipairs(obs1) do
				if aliveai.samepos(aliveai.roundpos(posn),aliveai.roundpos(ob:get_pos())) then
					table.insert(obs2,ob)
				end
			end
		end
		table.insert(allpos,posn)
	end
	return obs2,allpos
end


minetest.register_on_dieplayer(function(player)
	aliveai_electric.player[player:get_player_name()]=nil
end)


aliveai_electric.hit=function(ob,level,dmg1)
	if not ob or aliveai.team(ob)=="nuke" then return end
	level=level or 2
	dmg1=dmg1 or 2
	local hp=aliveai.gethp(ob)
	if aliveai.is_bot(ob) then
		hp=hp+(ob:get_luaentity().hp_max*2)
	end
	local en=0
	if ob:get_luaentity() then en=1 end

	local playername
	if ob:is_player() then
		playername=ob:get_player_name()
		aliveai_electric.player[playername]=1
	end

	minetest.sound_play("aliveai_electric", {pos=ob:get_pos(), gain = 0.1, max_hear_distance = 10})
	local time=0
	for i=0,level,1 do
		local dmg=math.random(1,dmg1)
		hp=hp-dmg
		minetest.after((i*0.3)+time, function(ob,playername)
			if playername and not aliveai_electric.player[playername] then return end
			if aliveai.gethp(ob,1)>0 then
				local p=ob:get_pos()
				minetest.add_particlespawner({
					amount = 8,
					time =0.2,
					maxpos = {x=p.x+0.5,y=p.y+1.5,z=p.z+0.5},
					minpos = {x=p.x-0.5,y=p.y+0.5,z=p.z-0.5},
					minvel = {x=-0.01, y=-0.01, z=-0.01},
					maxvel = {x=0.01, y=0.01, z=0.01},
					minacc = {x=0, y=0, z=0},
					maxacc = {x=0, y=0, z=0},
					minexptime = 0.5,
					maxexptime = 1,
					minsize = 1,
					maxsize = 4,
					texture = "aliveai_electric_vol.png^[colorize:#ffffffff",
					glow=13,
				})
				if aliveai.def(p,"buildable_to") then
					minetest.set_node(p,{name="aliveai_electric:chock"})
				elseif aliveai.def({x=p.x,y=p.y+1,z=p.z},"buildable_to") then
					minetest.set_node({x=p.x,y=p.y+1,z=p.z},{name="aliveai_electric:chock"})
				end
				aliveai.punchdmg(ob,dmg)
				if en==1 and ob then
					ob:set_velocity({x=math.random(-1,1)*0.1, y=ob:get_velocity().y, z=math.random(-1,1)*0.1})
				end
			elseif aliveai_nitroglycerine and dmg>4 and math.random(1,5)==1 then
				aliveai_nitroglycerine.explode(ob:get_pos(),{radius=2,blow_nodes=0})
			end


		if playername and i>=level then
			aliveai_electric.player[playername]=nil
		end
			
		end, ob,playername)
		time=math.random(1,5)*0.1
		if hp<=0 then return false end
	end
end

aliveai_electric.dir=function(user,pointed)
	if user:get_luaentity() then user=user:get_luaentity() end
	local type=pointed.type
	local pos1=user:get_pos()
	pos1.y=pos1.y+1.5
	local pos2
	if type=="object" then
		pos2=pointed.ref:get_pos()
	elseif type=="node" then
		pos2=pointed.under
	elseif type=="nothing" then
		local dir
		if user:get_luaentity() then
			if user:get_luaentity().aliveai and user:get_luaentity().fight then
				local dir=aliveai.get_dir(user:get_luaentity(),user:get_luaentity().fight)
				pos2={x=pos1.x+(dir.x*30),y=pos1.y+(dir.y*30),z=pos1.z+(dir.z*30)}
			else
				pos2=aliveai.pointat(user:get_luaentity(),30)
			end
		else
			local dir=user:get_look_dir()
			pos2={x=pos1.x+(dir.x*30),y=pos1.y+(dir.y*30),z=pos1.z+(dir.z*30)}
		end
	else
		return
	end
	if aliveai.def(pos1,"walkable") then return end
	return pos1,pos2
end


aliveai_electric.lightning2=function(obs,pos,hit)
	if not (obs and pos) then return end

	if pos[1] then
		minetest.sound_play("aliveai_electric_lightning", {
			pos = pos[1],
			max_hear_distance = 5,
			gain = 0.1,
		})
	end
	if pos[#pos] then
		minetest.sound_play("aliveai_electric_lightning", {
			pos = pos[#pos],
			max_hear_distance = 5,
			gain = 0.1,
		})
	end

	local oo
	for _, ob in ipairs(obs) do
		if aliveai.is_bot(ob) then aliveai.dying(ob:get_luaentity(),1) end
		aliveai.punchdmg(ob,15)
		aliveai_electric.hit(ob)
		minetest.sound_play("aliveai_electric_lightning", {
			pos=ob:get_pos(),
			max_hear_distance = 5,
			gain = 0.1,
		})
	oo=1
	end
	if not oo and pos[#pos] then
		for i, ob2 in pairs(minetest.get_objects_inside_radius(pos[#pos], 2)) do
			if aliveai.is_bot(ob2) then aliveai.dying(ob2:get_luaentity(),1) end
			aliveai.punchdmg(ob2,15)
			aliveai_electric.hit(ob2)
		end
	end

	for _, p in ipairs(pos) do
		minetest.set_node(p,{name="aliveai_electric:lightning"})
	end
	if aliveai_nitroglycerine and hit then
		aliveai_nitroglycerine.explode(hit,{radius=2})
	end
end

aliveai_electric.lightning1=function(obs,pos,hit)
	if not (obs and pos) then return end
	if pos[1] then
		minetest.sound_play("aliveai_electric_lightning", {
			pos = pos[1],
			max_hear_distance = 5,
			gain = 0.1,
		})
	end
	if pos[#pos] then
		minetest.sound_play("aliveai_electric_lightning", {
			pos = pos[#pos],
			max_hear_distance = 5,
			gain = 0.1,
		})
	end
	for _, ob in ipairs(obs) do
		minetest.set_node(ob:get_pos(), {name="aliveai_electric:lightning_clump"})
		aliveai_electric.hit(ob,math.random(2,7))
		minetest.sound_play("aliveai_electric_lightning", {
			pos=ob:get_pos(),
			max_hear_distance = 5,
			gain = 0.1,
		})
	end
	for _, p in ipairs(pos) do
		minetest.add_particlespawner({
			amount = 20,
			time =0.2,
			minpos = {x=p.x-0.3,y=p.y-0.3,z=p.z-0.3},
			maxpos = {x=p.x+0.3,y=p.y+0.3,z=p.z+0.3},
			minvel = {x=-0.1, y=-0.1, z=-0.1},
			maxvel = {x=0.1, y=0.1, z=0.1},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 0.1,
			maxexptime = 0.5,
			minsize = 1,
			maxsize = 3,
			texture = "aliveai_electric_vol.png",
			glow=13,
		})
		minetest.set_node(p,{name="aliveai_electric:chock"})
	end
	if hit and pos[#pos] then minetest.set_node(pos[#pos],{name="aliveai_electric:lightning_clump"}) end
end

minetest.register_node("aliveai_electric:lightning_clump", {
	description = "Lightning clump",
	groups = {not_in_creative_inventory=1},
	drops="",
	tiles = {
		{
			name = "aliveai_electric_clump.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.4,
			},
		},
	},
	pointable=false,
	post_effect_color = {a = 210, r =10, g = 80, b = 230},
	drawtype="plantlike",
	light_source = 8,
	paramtype = "light",
	alpha = 50,
	sunlight_propagates = true,
	liquid_viscosity = 8,
	liquid_renewable = false,
	liquid_range = 0,
	liquid_alternative_flowing="aliveai_electric:lightning_clump",
	liquid_alternative_source="aliveai_electric:lightning_clump",
	liquidtype = "source",
	walkable=false,
	is_ground_content = false,
on_construct=function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
on_timer=function(pos, elapsed)
		local rnd=math.random(1,3)
		local sp=0
	for i, ob in pairs(minetest.get_objects_inside_radius(pos, 3)) do
		local p=ob:get_pos()
		if aliveai.team(ob)~="nuke" and aliveai.def(p,"buildable_to") then
			minetest.set_node(p, {name="aliveai_electric:lightning_clump"})
			aliveai_electric.hit(ob)
			minetest.sound_play("aliveai_electric", {pos=pos, gain = 0.1, max_hear_distance = 10,})
			p.y=p.y+1
			if aliveai.def(p,"buildable_to") then
				minetest.set_node(p, {name="aliveai_electric:lightning_clump"})
			end
		end
		sp=sp+1
		if sp>2 then break end
	end
	if rnd>=2 then
		minetest.set_node(pos, {name = "air"})
		return false
	else
		local np=minetest.find_node_near(pos, 2,{"air"})
		if np~=nil then
			minetest.set_node(np, {name="aliveai_electric:lightning_clump"})
			minetest.sound_play("aliveai_electric", {pos=pos, gain = 0.1, max_hear_distance = 10})
		end
	end
	return true
	end
})




minetest.register_node("aliveai_electric:lightning", {
	description = "lightning",
	drawtype="glasslike",
	tiles = {"default_cloud.png^[colorize:#ff3fd7ff"},
	drop="",
	light_source = default.LIGHT_MAX - 1,
	paramtype = "light",
	walkable=false,
	sunlight_propagates = true,
	pointable=false,
	buildable_to = true,
	groups = {not_in_creative_inventory=1},
	post_effect_color = {a = 255, r=255, g=255, b=255},
	walkable=false,
	damage_per_second = 10,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.3)
	end,
	on_timer = function (pos, elapsed)
		minetest.set_node(pos,{name="air"})
	end,
})

minetest.register_node("aliveai_electric:chock", {
	drawtype="airlike",
	tiles = {"aliveai_air.png"},
	drop="",
	light_source = default.LIGHT_MAX - 1,
	walkable=false,
	sunlight_propagates = true,
	pointable=false,
	buildable_to = true,
	groups = {not_in_creative_inventory=1},
	post_effect_color = {a = 200, r=255, g=255, b=255},
	walkable=false,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.1)
	end,
	on_timer = function (pos, elapsed)
		minetest.set_node(pos,{name="air"})
	end,
})

