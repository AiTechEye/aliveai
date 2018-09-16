aliveai_weather={mintimeout=200,maxtimeout=1000,players={},timecheck=0,time2=0,time=0,chance=100,size=500,strength=800,currweather={}}


minetest.register_chatcommand("weather", {
	params = "",
	description = "weather settings: <set 20-800> or <stop>",
	privs = {settime=true},
	func = function(name, param)
		local a
		if string.find(param,"set ")~=nil then
			local s=param.split(param," ")
			if not s then return end
			for _,n in pairs(s) do
				local num=tonumber(n)
				if num then
					a=num
					break
				end
			end
			if not a then
				minetest.chat_send_player(name, "<aliveai weather> /weather set <20-" .. aliveai_weather.strength ..">")
				return
			end
		elseif string.find(param,"stop")~=nil then
			a=0
		else
			minetest.chat_send_player(name, "<aliveai weather> /weather set <20-" .. aliveai_weather.strength ..">")
			minetest.chat_send_player(name, "<aliveai weather> /weather stop")
			return
		end

		local user=minetest.get_player_by_name(name)
		if not user then return end
		local pos=user:get_pos()
		for i, w in pairs(aliveai_weather.currweather) do
			if aliveai.distance(w.pos,pos)<w.size and pos.y>-20 and pos.y<120 then
				if a==0 then
					aliveai_weather.currweather[i]=nil
					return
				else
					aliveai_weather.currweather[i].strength=a
					aliveai_weather.currweather[i].change_strength=1
					return
				end
			end
		end
		if a~=0 then
			aliveai_weather.add({pos=pos,strength=a})
		end	
		return
	end
})




minetest.register_globalstep(function(dtime)
	aliveai_weather.time=aliveai_weather.time+dtime
	if aliveai_weather.time<0.5 then return end
	aliveai_weather.time=0
	aliveai_weather.ac()
	aliveai_weather.add()

	aliveai_weather.time2=aliveai_weather.time2+1
	if aliveai_weather.time2<10 then return end
	aliveai_weather.time2=0

	for _,w in pairs(aliveai_weather.players) do
		local ins
		local s
		local pos=w.player:get_pos()
		for i, w in pairs(aliveai_weather.currweather) do
			if aliveai.distance(w.pos,pos)<w.size and pos.y>-20 and pos.y<120 then
				ins=1
				if w.sound then
					s=1
				end
			end
		end
		if not s and aliveai_weather.players[w.player:get_player_name()].sound then
			minetest.sound_stop(aliveai_weather.players[w.player:get_player_name()].sound)
		end
		if not ins then
			w.player:set_clouds({density=0.4,speed={y=-2,x=0},color={r=240,g=240,b=255,a=229}})
			w.player:set_sky({},"regular",{})
			
			aliveai_weather.players[w.player:get_player_name()]=nil
		end
	end
end)


minetest.register_on_leaveplayer(function(player)
	local name=player:get_player_name()
	if aliveai_weather.players[name] and aliveai_weather.players[name].sound then
		minetest.sound_stop(aliveai_weather.players[name].sound)
		aliveai_weather.players[name]=nil
	end
end)


aliveai_weather.get_bio=function(pos)
	local green,dry,cold=0,0,0
	for i, n in pairs(aliveai.get_nodes(pos,3,2)) do
		local w=minetest.get_node(n).name
		if w=="default:dirt_with_dry_grass" or w=="default:desert_sand" or w=="default:silver_sand" then
			dry=dry+1
		elseif w=="default:dirt_with_snow" or w=="default:snowblock" or w=="default:snow" or w=="default:ice" then
			cold=cold+1
		elseif minetest.get_item_group(w,"leaves")==0 then
			green=green+1
		end
	end

	local m=math.max(unpack({green,dry,cold}))
	if green+dry+cold==0 then
		return 0
	elseif m==green then
		return 1
	elseif m==dry then
		return 2
	else -- cold
		return 3
	end
end

aliveai_weather.ac=function()
	local t=minetest.get_timeofday()*24
	for i, w in pairs(aliveai_weather.currweather) do
		for _,player in ipairs(minetest.get_connected_players()) do
			local p=player:get_pos()
			if p.y>-20 and p.y<120 and aliveai.distance(w.pos,p)<=w.size then
				local name=player:get_player_name()
--if the player is in another bio, then limit the area to that bio
				aliveai_weather.timecheck=aliveai_weather.timecheck+1
				if aliveai_weather.timecheck>10 then
					aliveai_weather.timecheck=0
					local bio=aliveai_weather.get_bio(p)
					if bio~=w.bio then
						aliveai_weather.currweather[i].size=aliveai.distance(w.pos,p)
						w.bio=bio
					end
				end
--rnd change strength
				if math.random(1,100)==1 then
					aliveai_weather.currweather[i].strength=math.random(1,aliveai_weather.strength)
				end
--wet/rain
				if w.bio==1 then
					if not aliveai_weather.players[name] or aliveai_weather.players[name].bio~=w.bio or aliveai_weather.currweather[i].change_strength then
						local s=(w.strength*0.01)*1.2
						local sound
						if w.strength>30 then
							sound=minetest.sound_play("aliveai_weather_rain", {to_player = name,gain = 2.0,loop=true})
						end
						if t>6 and t<19 then
							player:set_sky({r=149-(s*2),g=154-(s*3),b=209-(s*9),a=255},"plain",{})
							player:set_clouds({density=0.5+(s*0.05),color={r=240/s,g=240/s,b=255/s,a=229*s}})
						end
						if aliveai_weather.players[name] and aliveai_weather.players[name].sound then
							minetest.sound_stop(aliveai_weather.players[name].sound)
						end
						aliveai_weather.players[name]={player=player,sound=sound,bio=w.bio}
					end
					for s=1,w.strength,1 do
						local p={x=p.x+math.random(-10,10),y=p.y+math.random(10,15),z=p.z+math.random(-10,10)}

						if minetest.get_node_light(p,0.5)==15  then
							minetest.add_particle({
								pos=p,
								velocity={x=math.random(-0.5,0.5),y=-math.random(7,9),z=math.random(-0.5,0.5)},
								acceleration={x=0,y=-2,z=0},
								expirationtime=3,
								size=1,
								collisiondetection=true,
								collision_removal=true,
								vertical=true,
								texture="aliveai_weather_drop.png",
								playername=player:get_player_name(),
							})
						end
					end
--hot/dry
				elseif w.bio==2 then
					if  not aliveai_weather.players[name] or aliveai_weather.players[name].bio~=w.bio then
						if t>6 and t<19 then
							player:set_sky({r=100,g=160,b=209,a=255},"plain",{})
						end
						player:set_clouds({density=0.2,color={r=240,g=240,b=255,a=229}})
						if aliveai_weather.players[name] and aliveai_weather.players[name].sound then
							minetest.sound_stop(aliveai_weather.players[name].sound)
						end
						aliveai_weather.players[name]={player=player,bio=w.bio}
					end
--cold/snowy
				elseif w.bio==3 then
					if  not aliveai_weather.players[name] or aliveai_weather.players[name].bio~=w.bio or aliveai_weather.currweather[i].change_strength then
						local s=(w.strength*0.01)*1.2
						if t>6 and t<19 then
							player:set_sky({r=149-(s*2),g=154-(s*3),b=209-(s*9),a=255},"plain",{})
							player:set_clouds({density=0.5+(s*0.05),color={r=240/s,g=240/s,b=255/s,a=229*s}})
						end
						if aliveai_weather.players[name] and aliveai_weather.players[name].sound then
							minetest.sound_stop(aliveai_weather.players[name].sound)
						end
						aliveai_weather.players[name]={player=player,bio=w.bio}
					end
					for s=1,math.floor(w.strength/4),1 do
						local p={x=p.x+math.random(-10,10),y=p.y+math.random(5,10),z=p.z+math.random(-10,10)}

						if minetest.get_node_light(p,0.5)==15  then
							minetest.add_particle({
								pos=p,
								velocity={x=math.random(-0.5,0.5),y=-math.random(1,2),z=math.random(-0.5,0.5)},
								acceleration={x=0,y=0,z=0},
								expirationtime=6,
								size=1,
								collisiondetection=true,
								collision_removal=true,
								vertical=true,
								texture="aliveai_weather_snow" .. math.random(1,4) .. ".png",
								playername=player:get_player_name(),
							})
						end
					end
				end
--neutral
			end
--weather timeout
		aliveai_weather.currweather[i].timeout=aliveai_weather.currweather[i].timeout-1
		if aliveai_weather.currweather[i].timeout<20 then
			aliveai_weather.currweather[i].timeout=0
			aliveai_weather.currweather[i].strength=aliveai_weather.currweather[i].strength-10
			if aliveai_weather.currweather[i].strength<20 then
				aliveai_weather.currweather[i]=nil
				return
			end
		end

		end

	aliveai_weather.currweather[i].change_strength=nil
	end
end

aliveai_weather.add=function(set)
	if set then
		if set.pos.y>-20 and set.pos.y<120 then
			local b=aliveai_weather.get_bio(set.pos)
			if b==1 or b==2 or b==3 then 
				table.insert(aliveai_weather.currweather,{timeout=math.random(aliveai_weather.mintimeout,aliveai_weather.maxtimeout),pos=set.pos,size=math.random(20,aliveai_weather.size),strength=set.strength,sound=1,bio=b})
			end
		end
		return
	end

	if math.random(1,aliveai_weather.chance)~=1 then return end
	local players={}
	local n=0

	for _,player in ipairs(minetest.get_connected_players()) do
		n=n+1
		players[n]=player
	end
	for o=1,n,1 do
		local p=players[math.random(1,n)]
		if p then
			local pos=aliveai.roundpos(p:get_pos())
			if pos.y>-20 and pos.y<120 then
				local ins
				for i, w in pairs(aliveai_weather.currweather) do
					if aliveai.distance(w.pos,pos)<w.size then
						ins=1
					end
				end
				if not ins then
					local b=aliveai_weather.get_bio(pos)
					if b==1 or b==2 or b==3 then 
						table.insert(aliveai_weather.currweather,{timeout=math.random(aliveai_weather.mintimeout,aliveai_weather.maxtimeout),pos=pos,size=math.random(20,aliveai_weather.size),strength=math.random(2,aliveai_weather.strength),sound=1,bio=b})
						return
					end
				end
			end
		end
	end
end