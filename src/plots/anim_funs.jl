function panim_fun(dfs::Array{DataFrames.DataFrame,1},label_string::Array{String,1}, results_dir::String, obs_data::DataFrames.DataFrame,s_data::DataFrames.DataFrame,pa::VehicleModels.Vpara)

		anim = @animate for cc in 1:20:length(dfs[1][:V]) # adjust depending on size
			# has to be in this form to use pplot in this manner
			dfs1 = Vector{DataFrame}(1); dfs1[1]=dfs[1];
			dfs2 = Vector{DataFrame}(1); dfs2[1]=dfs[2];

			p1 = pplot(dfs1,cc,["optimized"],false,true,obs_data,s_data,pa)
			p2 = pplot(dfs2,cc,["RK4"],false,true,obs_data,s_data,pa)
      plot(p1,p2,size=(1000,1000))

		end
	gif(anim, "position.gif", fps = 12)
end
