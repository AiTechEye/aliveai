Version: 3
name: nitroglycerine
By: AiTechEye

powerful explosion / nitrogen api

======ice crush======
aliveai_nitroglycerine.crush(pos)

======freese object======
nitroglycerine.freese(object)

======all options is optional, exept position======
nitroglycerine.explotion(pos,{
	radius=5,						--optional, default: 9
	set="node",					--optional, default: ""
	place={nodes},					--optional, default: {"aliveai_nitroglycerine:fire","air","air","air","air"}
	place_chance=5,					--optional, default: 5
	user_name="name",				--optional, default: ""
	drops=1						--optional, default: 1
	velocity=1					--optional, default: 1
	hurt=1						--optional, default: 1
	})

======cons (connected nodes)======

	aliveai_nitroglycerine.cons({
		pos=pos,					--required
		max=500,				--optional (default: 9)
		distance=1,				--optional (default: 1) the higher number the longer between nodes + lag
		name="a replacing",			--optional (default: random number)
		replace={				--required (atleast 1 option) [options] can be node or group [value] node or function
			["flora"]="default:dry_shrub",
			["default:leaves"]="default:stone",
			["spreading_dirt_type"]="dirt",
			["leaves"]=function(pos)
				minetest.remove_node(pos)
			end,
			},
		on_replace=function(pos)
			print(replaced,dump(pos))
		end,
		})
	end