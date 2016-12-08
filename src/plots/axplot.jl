function axplot(dfs::Array{DataFrames.DataFrame,1},label_string::Array{String,1},simulate::Bool,pa::VehicleModels.Vpara)

	@unpack_Vpara pa
	# plotting options
	s = 700; w1 = 7; w2 = 4;

  # plot the limits
	ax=plot(0,leg=:false)
	for j in 1:length(label_string)
		U = dfs[j][:U]
		t_vec = linspace(0,10,length(dfs[j][:V]));
	  plot!(t_vec,@Ax_min(),size=(s,s),w=w1,label=string(label_string[j]," min"))
  	plot!(t_vec,@Ax_max(),size=(s,s),w=w1,label=string(label_string[j]," max"),leg=:bottomright)
	end

  # plot
	for i in 1:length(label_string)
		plot!(dfs[i][:t],dfs[i][:Ax],label=label_string[i],line = (w2))
	end

	adjust_axis(xlims(),ylims())
	yaxis!("Longitudinal Acceleration (m/s^2)")
	xaxis!("time (s)")
	if !simulate savefig("ax.png") end
	return ax
end
