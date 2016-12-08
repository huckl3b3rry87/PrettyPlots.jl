function latvplot(dfs::Array{DataFrames.DataFrame,1},label_string::Array{String,1},simulate::Bool,pa::VehicleModels.Vpara)
	@unpack_Vpara pa
	# plotting options
	s = 700; w1 = 7; w2 = 4;
	#t_max = max_DF(dfs,k,'t');
	t_vec = linspace(0,10,length(dfs[1][:V]));

  # plot
	latv=plot(0,leg=:false)
	for i in 1:length(label_string)
			plot!(dfs[i][:t],dfs[i][:V],label=label_string[i],line = (w2),size=(s,s),leg=:bottomright)
	end

	adjust_axis(xlims(),ylims())
	yaxis!("Lateral Velocity (m/s)")
	xaxis!("time (s)")
	if !simulate savefig("latv.png") end
	return latv
end
