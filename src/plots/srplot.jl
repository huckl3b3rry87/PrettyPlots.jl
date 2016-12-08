function srplot(dfs::Array{DataFrames.DataFrame,1},label_string::Array{String,1},simulate::Bool,pa::VehicleModels.Vpara)
	@unpack_Vpara pa
	# plotting options
	s = 700; w1 = 7; w2 = 4;
	#t_max = max_DF(dfs,k,'t');
	t_vec = linspace(0,10,length(dfs[1][:V]));

  # plot the limits
	sr=plot(t_vec,sr_min*180/pi*ones(Float64,(length(dfs[1][:V]),1)),size=(s,s),line = (w2),label="min")
  plot!(t_vec,sr_max*180/pi*ones(Float64,(length(dfs[1][:V]),1)),size=(s,s),line = (w2),label="max")

  # plot
	for j in 1:length(label_string)
		plot!(dfs[j][:t],dfs[j][:SR]*180/pi,label=label_string[j],line = (w2),leg=:bottomright)
	end

	adjust_axis(xlims(),ylims())
	yaxis!("Steering Rate (deg/s)")
	xaxis!("time (s)")
	if !simulate savefig("sr.png") end
	return sr
end
