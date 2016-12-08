function jxplot(dfs::Array{DataFrames.DataFrame,1},label_string::Array{String,1},simulate::Bool,pa::VehicleModels.Vpara)
  @unpack_Vpara pa
	# plotting options
	s = 700; w1 = 7; w2 = 4;
	#t_max = max_DF(dfs,k,'t');
	t_vec = linspace(0,10,length(dfs[1][:V]));

	# plot the limits
	jx=plot(t_vec,jx_min*ones(Float64,(length(dfs[1][:V]),1)),size=(s,s),w=w1,label="min")
  plot!(t_vec,jx_max*ones(Float64,(length(dfs[1][:V]),1)),size=(s,s),w=w1,label="max",leg=:true)

  # plot
	for i in 1:length(label_string)
		plot!(dfs[i][:t],dfs[i][:Jx],label=label_string[i],line = (w2),leg=:bottomright)
	end

	adjust_axis(xlims(),ylims())
	yaxis!("Longitudinal Jerk (m/s^3)")
	xaxis!("time (s)")
	if !simulate savefig("jx.png") end
	return jx
end
