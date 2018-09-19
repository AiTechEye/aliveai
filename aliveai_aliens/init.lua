aliveai_aliens={ael={},atra={}}

dofile(minetest.get_modpath("aliveai_aliens") .. "/items.lua")

aliveai_aliens.set_color=function(self)
	if not self.save__acolor then return end
	local tx=self.object:get_properties().textures[1]
	self.object:set_properties({
		textures = {tx .. "^[colorize:#" .. self.save__acolor},
	})
end

aliveai_aliens.gen_color=function(self,retry)
	local c=""
	local n=0
	local t="0123456789ABCDEF"
  	for i=1,6,1 do
        		n=math.random(1,16)
       		c=c .. string.sub(t,n,n)
	end
	if type(c)~="string" then
		if retry then
			self.save__acolor="ffffff55"
			aliveai_aliens.set_color(self)
			return
		end
		aliveai_aliens.gen_color(self,1)
	end
	self.save__acolor=c .. "55"
	aliveai_aliens.set_color(self)
end

aliveai.create_bot({
		description="The big and strong alien",
		dmg=15,
		smartfight=0,
		visual_size={x=2,y=1.5},
		collisionbox={-0.7,-1.5,-0.7,0.7,1.2,0.7},
		name="alien8",
		texture="aliveai_alien1.png",
		hp=500,
		light=0,
		stealing=1,
		talking=0,
		annoyed_by_staring=0,
		type="monster",
		building=0,
		attacking=1,
		name_color="",
		team="alien",
		attack_players=1,
		start_with_items={["aliveai_aliens:alien_enginelazer"]=1,["aliveai_aliens:alien_food"]=20},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","default:stone"},
		mindamage=2,
	spawn=function(self)
		aliveai_aliens.gen_color(self)
	end,
	on_load=function(self)
		aliveai_aliens.set_color(self)
	end,
	death=function(self,puncher,pos)
		minetest.add_particlespawner({
			amount = 30,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 2,
			maxsize = 8,
			texture = "default_cloud.png",
			collisiondetection = true,
		})

	end,

})




aliveai.create_bot({
		description="Alien with powerful short range weapon",
		name="alien1",
		texture="aliveai_alien1.png",
		hp=50,
		light=0,
		stealing=1,
		talking=0,
		annoyed_by_staring=0,
		type="monster",
		dmg=4,
		building=0,
		attacking=1,
		name_color="",
		team="alien",
		attack_players=1,
		start_with_items={["aliveai_aliens:vexcazer"]=1,["aliveai_aliens:alien_food"]=10},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","default:stone"},
	spawn=function(self)
		aliveai_aliens.gen_color(self)
	end,
	on_load=function(self)
		aliveai_aliens.set_color(self)
	end,
})
aliveai.create_bot({
		description="Long range alien",
		name="alien2",
		texture="aliveai_alien2.png",
		hp=50,
		light=0,
		stealing=1,
		talking=0,
		annoyed_by_staring=0,
		type="monster",
		dmg=4,
		building=0,
		attacking=1,
		name_color="",
		team="alien",
		attack_players=1,
		start_with_items={["aliveai_aliens:alien_rifle"]=1,["aliveai_aliens:alien_food"]=10},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","default:stone"},
	spawn=function(self)
		aliveai_aliens.gen_color(self)
	end,
	on_load=function(self)
		aliveai_aliens.set_color(self)
	end,
})
aliveai.create_bot({
		description="Long shooting alien with homing projects",
		name="alien3",
		texture="aliveai_alien3.png",
		hp=50,
		light=0,
		stealing=1,
		talking=0,
		annoyed_by_staring=0,
		type="monster",
		dmg=4,
		building=0,
		attacking=1,
		name_color="",
		team="alien",
		attack_players=1,
		start_with_items={["aliveai_aliens:alien_homing_rifle"]=1,["aliveai_aliens:alien_food"]=10},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","default:stone"},
	spawn=function(self)
		aliveai_aliens.gen_color(self)
	end,
	on_load=function(self)
		aliveai_aliens.set_color(self)
	end,
})
aliveai.create_bot({
		description="Litle alien with sword",
		name="alien4",
		texture="aliveai_alien4.png",
		hp=25,
		work_helper=1,
		light=0,
		stealing=1,
		talking=0,
		smartfight=0,
		annoyed_by_staring=0,
		type="monster",
		dmg=4,
		building=0,
		attacking=1,
		name_color="",
		team="alien",
		attack_players=1,
		visual_size={x=0.8,y=0.8},
		collisionbox={-0.3,-0.8,-0.3,0.3,0.65,0.3},
		start_with_items={["aliveai_aliens:ozer_sword"]=1,["aliveai_aliens:alien_food"]=10},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","default:stone"},
	spawn=function(self)
		aliveai_aliens.gen_color(self)
	end,
	on_load=function(self)
		aliveai_aliens.set_color(self)
	end,
})

aliveai.create_bot({
		description="Long range alien",
		name="alien5",
		texture="aliveai_alien5.png",
		hp=50,
		light=0,
		stealing=1,
		talking=0,
		annoyed_by_staring=0,
		type="monster",
		dmg=4,
		building=0,
		attacking=1,
		name_color="",
		team="alien",
		attack_players=1,
		start_with_items={["aliveai_aliens:alien_rifle"]=1,["aliveai_aliens:alien_food"]=10},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","default:stone"},
		annoyed_by_staring=0,
	spawn=function(self)
		aliveai_aliens.gen_color(self)
	end,
	on_load=function(self)
		aliveai_aliens.set_color(self)
	end,
})
aliveai.create_bot({
		description="Long shooting alien with homing projects",
		name="alien6",
		texture="aliveai_alien6.png",
		hp=50,
		light=0,
		stealing=1,
		talking=0,
		annoyed_by_staring=0,
		type="monster",
		dmg=4,
		building=0,
		attacking=1,
		name_color="",
		team="alien",
		attack_players=1,
		start_with_items={["aliveai_aliens:alien_homing_rifle"]=1,["aliveai_aliens:alien_food"]=10},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","default:stone"},
	spawn=function(self)
		aliveai_aliens.gen_color(self)
	end,
	on_load=function(self)
		aliveai_aliens.set_color(self)
	end,
})


aliveai.create_bot({
		description="Shrinker alien, shrinks its enemies until they disappear",
		name="alien9",
		texture="aliveai_alien9.png",
		hp=50,
		light=0,
		stealing=1,
		talking=0,
		annoyed_by_staring=0,
		type="monster",
		dmg=4,
		building=0,
		attacking=1,
		name_color="",
		team="alien",
		attack_players=1,
		start_with_items={["aliveai_aliens:alien_shrinker"]=1,["aliveai_aliens:alien_food"]=25},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","default:stone"},
	spawn=function(self)
		aliveai_aliens.gen_color(self)
	end,
	on_load=function(self)
		aliveai_aliens.set_color(self)
	end,
})




aliveai.create_bot({
		description="A floating and long shooting alien, that freezing its enemies",
		name="alien7",
		texture="aliveai_alien7.png",
		floating=1,
		hp=50,
		light=0,
		stealing=1,
		talking=0,
		annoyed_by_staring=0,
		type="monster",
		dmg=4,
		building=0,
		attacking=1,
		name_color="",
		team="alien",
		attack_players=1,
		start_with_items={["aliveai_aliens:alien_nrifle"]=1,["aliveai_aliens:alien_food"]=10},
		spawn_on={"group:sand","group:spreading_dirt_type","default:gravel","default:stone"},
	spawn=function(self)
		aliveai_aliens.gen_color(self)
	end,
	on_load=function(self)
		aliveai_aliens.set_color(self)
	end,
})
