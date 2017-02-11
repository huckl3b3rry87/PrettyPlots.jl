function all_plots(dfs::Array{DataFrames.DataFrame,1},label_string::Array{String,1},results_dir::String,obs_data::DataFrames.DataFrame,s_data::DataFrames.DataFrame,pa::VehicleModels.Vpara)

	resultsDir(results_dir)
	sa=saplot(dfs,label_string,false,pa)
	sr=srplot(dfs,label_string,false,pa)
	yaw=yawplot(dfs,label_string,false,pa)
	yawr=yawrplot(dfs,label_string,false,pa)

	longv=longvplot(dfs,label_string,false,pa)
	ax=axplot(dfs,label_string,false,pa)
	jx=jxplot(dfs,label_string,false,pa)

	latv=latvplot(dfs,label_string,false,pa)

	if length(dfs)==1
		pp=pplot(dfs,1,label_string,false,false,obs_data,s_data,pa) # no closed loop! --> optimization failed on first run
	else
		pp=pplot(dfs,1,label_string,true,false,obs_data,s_data,pa)
	end

	lt=ltplot(dfs,label_string,false,pa)
	vt=vtplot(dfs,label_string,false,pa)

	# make a figure with all states and controls
	plot(longv, ax, jx, sa, sr, yaw, yawr, latv, pp, size=(1800,1200))
	savefig("main.png")

	export_data(dfs,"DVs.csv") 	# also save the data?

end

function resultsDir(results_dir::String)
	if isdir(results_dir)
		rm(results_dir; recursive=true)
		print("\n The old results have all been deleted! \n \n")
	end
	mkdir(results_dir)
	cd(results_dir)
end
