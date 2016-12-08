function adjust_axis(x_lim,y_lim, args...)

	if length(args) < 4    # use default scaling factors
	  #  print("Using default scaling factors in adjust_axis.jl \n")
		# scaling factors
		al_x = [0.0, 0.05]; # x axis (low, high)
		al_y = [0.0, 0.0];  # y axis (low, high)
		# additional axis movement - useful for case where data is at zero or user wants a fixed shift
		hl_x = [-0.12, 0.0]; # x axis (low, high)
		hl_y = [-1.0, 1.0];  # y axis (low, high)
	else
	#	print("Not using default scaling factors in adjust_axis.jl \n")
	end

	xlim = Float64[0,0];
  ylim = Float64[0,0];
	xlim[1] = x_lim[1]+abs(x_lim[1])*al_x[1]+hl_x[1];
	xlim[2] = x_lim[2]+abs(x_lim[2])*al_x[2]+hl_x[2];
#	xlim[2] = x_lim[2]+abs(x_lim[2])*al_x[1]+hl_x[1];

	ylim[1] = y_lim[1]+abs(y_lim[1])*al_y[1]+hl_y[1];
	ylim[2] = y_lim[2]+abs(y_lim[2])*al_y[2]+hl_y[2];
	xlims!((xlim[1],xlim[2]))
	ylims!((ylim[1],ylim[2]))
end
