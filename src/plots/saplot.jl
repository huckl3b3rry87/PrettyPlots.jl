function saplot(dfs::Array{DataFrames.DataFrame,1},label_string::Array{String,1},simulate::Bool,pa::VehicleModels.Vpara)
	@unpack_Vpara pa
	# plotting options
	s = 700; w1 = 7; w2 = 4;
	#t_max = max_DF(dfs,k,'t');
	t_vec = linspace(0,10,length(dfs[1][:V]));

	# plot the limits
	sa=plot(t_vec,sa_min*180/pi*ones(Float64,(length(dfs[1][:V]),1)),size=(s,s),w=w1,label="min")
	plot!(t_vec,sa_max*180/pi*ones(Float64,(length(dfs[1][:V]),1)),size=(s,s),w=w1,label="max",leg=:bottomright)

	for i in 1:length(label_string)
		plot!(dfs[i][:t],dfs[i][:SA]*180/pi,label=label_string[i],line = (w2))
	end

	adjust_axis(xlims(),ylims())
	yaxis!("Steering Angle (deg)")
	xaxis!("time (s)")
	if !simulate savefig("sa.png") end
	return sa
end
