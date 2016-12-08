function vtplot(dfs::Array{DataFrames.DataFrame,1},label_string::Array{String,1},simulate::Bool,pa::VehicleModels.Vpara)
	@unpack_Vpara pa
	# plotting options
	s = 700; w1 = 7; w2 = 4;
	#t_max = max_DF(dfs,k,'t');
	t_vec = linspace(0,10,length(dfs[1][:V]));

	# plot the minimum allowable vertical tire force
	vt=plot(t_vec,Fz_min*ones(Float64,(length(dfs[1][:V]),1)),line = (w2),size=(s,s),label="min",leg=:true)

  # calculate and plot the vertical tire forces
  for j in 1:length(label_string)
		 V=dfs[j][:V];U=dfs[j][:U];Ax=dfs[j][:Ax];R=dfs[j][:r];SA=dfs[j][:SA];
	   plot!(dfs[j][:t],@FZ_RL(),line = (w2),label=string(label_string[j]," RL"))
     plot!(dfs[j][:t],@FZ_RR(),line = (w2),label=string(label_string[j]," RR"),size=(s,s),leg=:bottomright)
  end

	adjust_axis(xlims(),ylims())
	title!("Vertical Tire Forces")
	yaxis!("Force (N)")
	xaxis!("time (s)")
	if !simulate savefig("vt.png") end
  return vt
end
