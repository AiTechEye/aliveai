aliveai_minecontroller.force={}
aliveai_minecontroller.timerf=0

minetest.register_craft({
	output = "aliveai_minecontroller:pad",
	recipe = {
		{"default:steel_ingot","default:tin_ingot","default:steel_ingot"},
		{"default:steel_ingot","default:mese_crystal_fragment","default:steel_ingot"},
		{"default:steel_ingot","default:iron_lump","default:steel_ingot"},
	}
})


minetest.register_node("aliveai_minecontroller:pad", {
	description = "Force pad",
	groups = {cracky=3},
	tiles={"aliveai_minecontroller_pad.png"},
	paramtype = "light",
	walkable=false,
	paramtype2="facedir",
	is_ground_content = false,
	drawtype = "nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	mesecons = {
		receptor = {state = "off"},
		effector = {
		action_on = function (pos, node)
			minetest.get_meta(pos):set_int("state",1)
		end,
		action_off = function (pos, node)
			minetest.get_meta(pos):set_int("state",0)
		end,
	}},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(1)
		local m=minetest.get_meta(pos)
		m:set_int("time",1)
		m:set_int("mode",1)
		m:set_string("infotext","Walk")
	end,
	on_timer = function (pos, elapsed)
		if minetest.get_meta(pos):get_int("state")==1 then return true end
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			local en=ob:get_luaentity()
			if aliveai.is_bot(ob) and not (en.controlled or en.dead or en.dying) then
				aliveai.stand(ob:get_luaentity())
				en.controlled=1
				en.force_controlled=1
				table.insert(aliveai_minecontroller.force,{ob=ob,time=0,speed=1})
				return true
			end
		end
		return true
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos,player:get_player_name()) then return end
		local m=minetest.get_meta(pos)
		local t=m:get_int("time")+1
		local d=m:get_int("mode")
		if t>20 then t=1 end
		m:set_int("time",t)
		if d==6 then
			m:set_string("infotext","Stay (" .. t ..")")
		end
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		local m=minetest.get_meta(pos)
		local d=m:get_int("mode")
		local mode={
			"Walk",
			"Run",
			"Jump",
			"JumpX2",
			"stand",
			"Stay (" .. m:get_int("time") ..")",
			"Relese"
		}
		d=d+1
		if d>#mode then d=1 end
		m:set_int("mode",d)
		m:set_string("infotext",mode[d])
		if d==7 then
			minetest.get_node_timer(pos):stop()
		else
			minetest.get_node_timer(pos):start(1)
		end
	end,
})

aliveai_minecontroller.lookat=function(n,self)
	if n.param2==2 then
		self.object:set_yaw(3.14)
	elseif n.param2==1 then
		self.object:set_yaw(4.71)
	elseif n.param2==0 then
		self.object:set_yaw(0)
	else
		self.object:set_yaw(1.57)
	end
end

minetest.register_globalstep(function(dtime)
	aliveai_minecontroller.timerf=aliveai_minecontroller.timerf+dtime
	if aliveai_minecontroller.timerf<0.2 then return end
	aliveai_minecontroller.timerf=0
	for i, e in pairs(aliveai_minecontroller.force) do

		local self=e.ob:get_luaentity()
		local pos=e.ob:get_pos()

		if not (self and pos) then
			table.remove(aliveai_minecontroller.force,i)
			return
		elseif e.time>2 or self.dead or self.dying then
			self.controlled=nil
			self.force_controlled=nil
			self.force_controlled_walk=nil
			aliveai.stand(self)
			table.remove(aliveai_minecontroller.force,i)
			return
		end
		e.time=e.time+dtime
		local n=minetest.get_node(pos)

		if n.name=="aliveai_minecontroller:pad" then
			local m=minetest.get_meta(pos)

			if m:get_int("state")==1 then return end


			local d=m:get_int("mode")

			e.time=0
			aliveai_minecontroller.lookat(n,self)

			if d==1 or d==2 then
				aliveai.walk(self,d)
				self.force_controlled=d
				e.speed=d
				if self.force_controlled_walk then
					if not aliveai.samepos(aliveai.roundpos(pos),self.force_controlled_walk) then
						self.force_controlled_walk=nil
					end
				end
			elseif d==3 then
				aliveai.jump(self)
				aliveai.walk(self,e.speed)
			elseif d==4 then
				aliveai.jump(self,{y=7})
				aliveai.walk(self,e.speed)
			elseif d==5 then
				aliveai.stand(self)
				self.force_controlled=3
			elseif d==6 and not self.force_controlled_walk then
				aliveai.stand(self)
				self.force_controlled=3
				if not e.stay then e.stay=0 end
				e.stay=e.stay+0.2
				if e.stay>=m:get_int("time") then
					e.stay=nil
					self.force_controlled=1
					self.force_controlled_walk=aliveai.roundpos(pos)
					aliveai.walk(self,e.speed)
				end
			elseif d==7 then
				aliveai.stand(self)
				e.time=3
			end
		elseif self.force_controlled<3 then
			aliveai.jumping(self)
			aliveai.walk(self,e.speed)
		end
	end
end)
