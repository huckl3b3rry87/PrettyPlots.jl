function pplot(dfs::Array{DataFrames.DataFrame,1},cc::Int64,label_string::Array{String,1},closed_loop::Bool,simulate::Bool,obs_data::DataFrames.DataFrame,s_data::DataFrames.DataFrame,pa::VehicleModels.Vpara)
	@unpack_Vpara pa  #TODO surrently, we don't need but eventually put vehicle size in here
	# plotting options
	s = 700; w1 = 7; w2 = 4;
	ms = 5; ms2 = 1

	# limits
	xlims = (147.5, 225); # TODO careful with these, ellipse may dissapear
	ylims = (0, s_data[:y_ref][1] + 5);

	# plot the optimal path, at the very begining of the preview horizon, we can compare paths, if the obstacles are moving, simulate on different plots
	pp=plot(0,leg=:false)
	for j in 1:length(label_string)
		plot!(dfs[j][:X][cc:end],dfs[j][:Y][cc:end],label=label_string[j],line = (w2))
	end

	# plot the goal
	scatter!((s_data[:x_ref][1], s_data[:y_ref][1]), markershape = :hexagon, markersize = ms, label="Goal",leg=true)

	# contants
	w=1.9; #width TODO move these to vehicle parameters
	h=3.3; #height
	XQ = [-w/2 w/2 w/2 -w/2 -w/2];
	YQ = [h/2 h/2 -h/2 -h/2 h/2];

	# plot the vehicle
	if closed_loop
		X_v = dfs[2][:X][end]  # using the end of the simulated data from the vehicle model
		Y_v = dfs[2][:Y][end]
		PSI_v = dfs[2][:PSI][end]-pi/2
	else
		X_v = dfs[1][:X][cc]  # vehicles are in the same spot at the begining
		Y_v = dfs[1][:Y][cc]
		PSI_v = dfs[1][:PSI][cc]-pi/2
	end

	P = [XQ;YQ];
	ct = cos(PSI_v);
	st = sin(PSI_v);
	R = [ct -st;st ct];
	P2 = R * P;
	scatter!((P2[1,:]+X_v,P2[2,:]+Y_v), markershape = :square, markercolor = :black, markersize = ms2, fill = (0, 1, :black),leg=true, grid=true,label="Vehicle")

	# plot the obstacles
	if length(obs_data[:X0]) > 0 # there are many feilds that define an obstacle, TODO maybe find a better way to check this
		for j in 1:length(obs_data[:X0]) # number of obstacles
			a = obs_data[:A][j];
			b = obs_data[:B][j];
			if closed_loop
				x_obs = obs_data[:X0][j] + obs_data[:s_x][j]*dfs[2][:t][end] # pulling the actual obstacle position which may be different from the one that the optimization saw
				y_obs = obs_data[:Y0][j] + obs_data[:s_y][j]*dfs[2][:t][end] # also with [end] we are grabbing the position of the obstacle
			else # what if it is not closed loop and we are not animating individually? ---> TODO
				x_obs = obs_data[:X0][j] + obs_data[:s_x][j]*dfs[1][:t][cc] # this is to individually animate the obstacles for each simulation
				y_obs = obs_data[:Y0][j] + obs_data[:s_y][j]*dfs[1][:t][cc]
	   	end
			f(xx,yy) = ((xx-x_obs)^2)/a + ((yy-y_obs)^2)/b;# could make this a function of time as well!
			if j == 1
				plot!(f < 1, fill = (0, 1, :red),xlims,ylims,size=(s,s), N=10, M=10,leg=true,label="Obstacles",leg=:bottomleft)
			else
				plot!(f < 1, fill = (0, 1, :red),xlims,ylims,size=(s,s), N=10, M=10, label= "",leg=true,leg=:bottomleft)
			end
		end
	end

	title!("Global Position")
	yaxis!("Y (m)")
	xaxis!("X (m)")
	if cc == 1 & !simulate  # only save the first frame
		savefig("pp.png")
	end
	return pp
end
