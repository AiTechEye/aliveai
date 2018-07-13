aliveai.create_bot({
		attack_players=1,
		name="candycane",
		team="candy",
		texture="aliveai_threats_candycane.png",
		talking=0,
		light=0,
		building=0,
		type="monster",
		hp=40,
		dmg=4,
		arm=2,
		name_color="",
		escape=0,
		spawn_on={"group:sand","group:soil","default:snow","default:snowblock","default:ice","group:leaves","group:spreading_dirt_type","group:stone"},
		attack_chance=2,
		smartfight=0,
		mesh="aliveai_threats_candycane.b3d",
		animation={
			stand={x=1,y=150,speed=30,loop=0},
			walk={x=155,y=170,speed=30,loop=0},
			mine={x=180,y=195,speed=30,loop=0},
			lay={x=201,y=211,speed=0,loop=0}
		},

	spawn=function(self)
		local n=0
		local t="0123456789ABCDEF"
		self.storge1=""
  		for i=1,6,1 do
        			n=math.random(1,16)
       			self.storge1=self.storge1 .. string.sub(t,n,n)
		end
		self.object:set_properties({textures={"aliveai_grey.png^[colorize:#" .. self.storge1 .."ff^aliveai_threats_candycane.png"}})
		print("aliveai_air.png^[colorize:#" .. self.storge1 .."ff^aliveai_threats_candycane.png")
	end,	
	on_load=function(self)
		if not self.storge1 then
			self.spawn(self)
			return self
		end
		self.object:set_properties({textures={"aliveai_grey.png^[colorize:#" .. self.storge1 .."ff^aliveai_threats_candycane.png"}})
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		aliveai.lookat(self,pos)
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-2, y=-2, z=-2},
			maxvel = {x=1, y=0.5, z=1},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 2,
			texture = "aliveai_grey.png^[colorize:#" .. self.storge1 .."ff^aliveai_threats_candycane.png",
			collisiondetection = true,
		})
	end
})
