function optplot(dfs_opt::Array{DataFrames.DataFrame,1},label_string::Array{String,1},simulate::Bool)

	w1 = [7,3,1,0.5];
	opt = plot(0,leg=:false)
	for i in 1:length(label_string)
		 plot!(dfs_opt[i][:obj_val],w=w1[i],label=label_string[i])
	end
	yaxis!("Objective Function Value")
	xaxis!("Evaluation Number")

 if !simulate savefig("optplot.png") end

 return opt
end
