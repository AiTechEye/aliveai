aliveai.registered_ores={}

aliveai.register_on_generated=function(name,on_generate)
	if type(name)~="string" or not minetest.registered_nodes[name] or type(on_generate)~="function" then
		if not name or type(name)=="string" then
			name=name or "?"
		else
			name="?"
		end
		print("failed to add " .. name .." to generated ores")
		return
	end
	aliveai.registered_ores[name]=on_generate
end

minetest.register_on_generated(function(minp, maxp, seed)
	local nodes={}
	for i, v in pairs(aliveai.registered_ores) do
		nodes[minetest.get_content_id(i)]=v
	end

	local vox,min,max = minetest.get_mapgen_object("voxelmanip")
	local modify
	local data = vox:get_data()
	local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
	for z = min.z, max.z do
	for y = min.y, max.y do
	for x = min.x, max.x do
		local i = area:index(x,y,z)
		if nodes[data[i]] then
			local re=nodes[data[i]](area:position(i))
			if re and type(re)=="string" and minetest.registered_nodes[re] then
				data[i]=minetest.get_content_id(re)
				modify=true
			end
		end
	end
	end
	end
	if modify then
		vox:set_data(data)
		vox:write_to_map()
		vox:update_map()
		vox:update_liquids()
	end
end)