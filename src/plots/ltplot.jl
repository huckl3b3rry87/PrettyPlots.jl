function ltplot(dfs::Array{DataFrames.DataFrame,1},label_string::Array{String,1},simulate::Bool,pa::VehicleModels.Vpara)
	@unpack_Vpara pa 
	# plotting options
	s = 700; w1 = 7; w2 = 4;
	#t_max = max_DF(dfs,k,'t');
	t_vec = linspace(0,10,length(dfs[1][:V]));

	lt=plot(0,leg=:false)
	# plot the lateral tire forces
	for j in 1:length(label_string)
		V=dfs[j][:V];U=dfs[j][:U];Ax=dfs[j][:Ax];R=dfs[j][:r];SA=dfs[j][:SA];
		plot!(dfs[j][:t], @F_YF(),line = (w2),label=string(label_string[j]," Front"))
		plot!(dfs[j][:t], @F_YR(),line = (w2),label=string(label_string[j]," Rear"),size=(s,s),leg=:bottomright)
	end

	adjust_axis(xlims(),ylims())
	title!("Lateral Tire Forces")
	yaxis!("Force (N)")
	xaxis!("time (s)")
	if !simulate savefig("lt.png") end
	return lt
end
