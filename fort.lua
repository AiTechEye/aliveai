aliveai_threats.fort={furnishings={"aliveai_threats:toxic_tank","aliveai_threats:labbottle_containing","aliveai_threats:timed_bumb","aliveai_threats:timed_nitrobumb","aliveai_threat_eletric:timed_ebumb","aliveai_threats:landmine","aliveai_threats:deadlock","aliveai_massdestruction:nuclearbarrel"},}

minetest.register_tool("aliveai_threats:fortspawner", {
	description = "fort spawner",
	range=15,
	groups={not_in_creative_inventory=1},
	inventory_image = "default_stick.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" then
			aliveai_threats.fort.spawning(pointed_thing.under,1)
		end
	end,
})

aliveai.register_rndcheck_on_generated({	
	group="spreading_dirt_type",
	node="default:snowblock",
	chance=30,
	mindistance=1000,
	run=function(pos)
		aliveai_threats.fort.spawning(pos)
	end
})

aliveai_threats.fort.spawning=function(pos,nrnd)
		if not nrnd then return end
		local test1=0
		local test2=0

		for y=-5,6,1 do
		for x=-5,31,1 do
		for z=-5,31,1 do
			local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			if nrnd and minetest.is_protected(p,"") then return end
			if y<1 and aliveai.def(p,"walkable") then
				test1=test1+1
			elseif y>0 and aliveai.def(p,"walkable") then
				test2=test2+1

				if test2>3000 then return end
			end
		end
		end
		end

		if test1<6000 then return end

		local door=math.random(11,17)
		local n
		local cam
		local start
		for y=0,6,1 do
		for x=-5,31,1 do
		for z=-5,31,1 do
			local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local n="air"
			local param=0
			if y==0 then
				n="default:silver_sandstone_brick"
			elseif y==6 and ((x==9 and z==9) or (x==18 and z==18) or (x==18 and z==9) or (x==9 and z==18)) then
				n="aliveai_threats:secam2"
				cam=1
			elseif y<5 and (x==1 or x==26 or z==1 or z==26) and (x>0 and z>0 and x<27 and z<27) then
				n="aliveai_threats:chainfence"
				if aliveai_electric then start=1 end
				param=1
				if x==1 then
					param=1
				elseif x==26 then
					param=3
				elseif z==1 then
					param=2
				else
					param=0
				end
			elseif (y==1 or y==2) and (((x==door and (z==9 or z==18)) or (z==door and (x==9 or x==18))))then
				if y==1 then n="aliveai:door_steel" end
			elseif (y==1 or y==2) and (x==door or z==door) then
			elseif (y==1 or y==2) and (((x==10 or x==17) and (z>9 and z<18)) or ((z==10 or z==17) and (x>9 and x<18))) then
				if y==1 then
					n="aliveai_threats:labtable"
				elseif math.random(1,3)==1 then
					n=aliveai_threats.fort.furnishings[math.random(1,#aliveai_threats.fort.furnishings)]
				end
			elseif y<5 and (((x==9 or x==18) and (z>8 and z<19)) or ((z==9 or z==18) and (x>8 and x<19))) then
				n="default:silver_sandstone_brick"
			elseif y==5 and (x>8 and x<19 and z>8 and z<19) then
				n="default:silver_sandstone_brick"
			end

			if n then
				minetest.set_node(p,{name=n,param2=param})
				if cam then
					minetest.get_meta(p):set_string("team","nuke")
					minetest.get_node_timer(p):start(1)
					cam=nil
				elseif start then
					minetest.get_node_timer(p):start(1)
					start=nil
				end
			end
		end
		end
		end

		if math.random(1,3)==1 then return end

		for y=-5,0,1 do
		for x=-4,30,1 do
		for z=-4,30,1 do
			local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local n=nil
			if y==-5 and ((x<0 or x>26) or (z<0 or z>26)) then
				n="default:silver_sandstone_brick"
			elseif x==-4 or x==30 or z==-4 or z==30 then
				n="default:silver_sandstone_brick"
			elseif (x>-4 and x<0) or (x>26 and x<30) or (z>-5 and z<0) or (z>26 and z<30) then
				n="aliveai_threats:slime"
			elseif x==0 or x==26 or z==0 or z==26 then
				n="default:silver_sandstone_brick"
			end

			if n then
				minetest.set_node(p,{name=n})
			end
		end
		end
		end
end

minetest.register_node("aliveai_threats:chainfence", {
	description = "Chain fence",
	tiles = {"aliveai_threats_chainfence.png"},
	drawtype = "nodebox",
	groups = {cracky=1, not_in_creative_inventory=0,level=3},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	paramtype2 = "facedir",
	paramtype = "light",
	node_box = {type="fixed",fixed={-0.5,-0.5,0.45,0.5,0.5,0.5}},
	on_punch = function(pos, node, puncher, pointed_thing)
		if not (puncher:is_player() and minetest.get_meta(pos):get_string("owner")==puncher:get_player_name()) then
			if aliveai_electric and aliveai.team(puncher)~="nuke" then
				aliveai_electric.hit(puncher,20,5)
			end
		end
	end,
	after_place_node = function(pos, placer)
		if placer:is_player() then
			minetest.get_meta(pos):set_string("owner",placer:get_player_name())
		end
	end,
	on_construct = function(pos)
		if aliveai_electric then
			minetest.get_node_timer(pos):start(5)
		end
	end,
	on_timer = function (pos, elapsed)
		if math.random(1,4)~=1 then return true end
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			if aliveai.team(ob)~="nuke" then
				aliveai_electric.hit(ob,20,5)
			end
		end
		return true
	end
})