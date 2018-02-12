function adjust_axis(x_lim,y_lim)

	# scaling factors
	al_x = [0.05, 0.05];  # x axis (low, high)
	al_y = [0.05, 0.05];  # y axis (low, high)

	# additional axis movement
	if x_lim[1]==0.0; a=-1; else a=0; end
	if x_lim[2]==0.0; b=1; else b=0; end
	if y_lim[1]==0.0; c=-1; else c=0; end
	if y_lim[2]==0.0; d=1; else d=0; end

	xlim = Float64[0,0]; ylim = Float64[0,0];
	xlim[1] = x_lim[1]-abs(x_lim[1]*al_x[1])+a;
	xlim[2] = x_lim[2]+abs(x_lim[2]*al_x[2])+b;
	ylim[1] = y_lim[1]-abs(y_lim[1]*al_y[1])+c;
	ylim[2] = y_lim[2]+abs(y_lim[2]*al_y[2])+d;

	xlims!((xlim[1],xlim[2]))
	ylims!((ylim[1],ylim[2]))
end


"""
allPlots(n;idx)
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 2/10/2017, Last Modified: 11/10/2017 \n
--------------------------------------------------------------------------------------\n
"""
function allPlots(n;idx::Int64=1,kwargs...)
  if !isdir(n.r.results_dir); resultsDir!(n); end
  stp = [statePlot(n,idx,st;kwargs...) for st in 1:n.numStates];
  ctp = [controlPlot(n,idx,ctr;kwargs...) for ctr in 1:n.numControls];

  if n.s.evalCostates && n.s.integrationMethod == :ps && n.s.evalConstraints
    csp = [costatePlot(n,idx,st;kwargs...) for st in 1:n.numStates];
    all = [stp;ctp;csp];
  else
    all = [stp;ctp];
  end

  h = plot(all...,size=_pretty_defaults[:size]);
  if !_pretty_defaults[:simulate]; savefig(string(n.r.results_dir,"main.",_pretty_defaults[:format])) end
  return h
end

"""
stp=statePlot(n,r.eval_num,7);
stp=statePlot(n,idx,st);
stp=statePlot(n,idx,st;(:legend=>"test1"));
stp=statePlot(n,idx,st,stp;(:append=>true));
stp=statePlot(n,idx,st,stp;(:lims=>false));
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 2/10/2017, Last Modified: 9/21/2017 \n
--------------------------------------------------------------------------------------\n
"""
function statePlot(n,idx::Int64,st::Int64,args...;kwargs...)
  kw = Dict(kwargs);

  # check to see if user would like to add to an existing plot
  if !haskey(kw,:append); append=false;
  else; append = get(kw,:append,0);
  end
  if !append; stp=plot(0,leg=:false); else stp=args[1]; end

  if idx > length(n.r.dfs)
    warn("Cannot plot idx = ", idx, " because length(n.r.dfs) = ", length(n.r.dfs), ". \n
          Skipping idx in statePlot().")
    return stp
  end

  # check to see if user would like to plot limits
  if !haskey(kw,:lims); lims=true;
  else; lims=get(kw,:lims,0);
  end

  # check to see if user would like to label legend
  if !haskey(kw,:legend); legend_string = "";
  else; legend_string = get(kw,:legend,0);
  end

	if n.r.dfs[idx]!=nothing
  	t_vec=linspace(0.0,n.r.dfs[end][:t][end],_pretty_defaults[:L]);
	else
		t_vec=linspace(0.0,n.r.dfs_plant[end][:t][end],_pretty_defaults[:L]);
	end

  if lims
		# plot the upper limits
		if n.mXU[st]!=false
			if !isnan(n.XU[st]);plot!(n.r.t_st,n.XU_var[st,:],line=_pretty_defaults[:limit_lines][2],label=string(legend_string,"max"));end
		else
			if !isnan(n.XU[st]);plot!(t_vec,n.XU[st]*ones(_pretty_defaults[:L],1),line=_pretty_defaults[:limit_lines][2],label=string(legend_string,"max"));end
		end

    # plot the lower limits
    if n.mXL[st]!=false
      if !isnan(n.XL[st]);plot!(n.r.t_st,n.XL_var[st,:],line=_pretty_defaults[:limit_lines][1],label=string(legend_string,"min"));end
    else
      if !isnan(n.XL[st]);plot!(t_vec,n.XL[st]*ones(_pretty_defaults[:L],1),line=_pretty_defaults[:limit_lines][1],label=string(legend_string,"min"));end
    end
  end

  # plot the values TODO if there are no lims then you cannot really see the signal
	if n.r.dfs[idx]!=nothing && !_pretty_defaults[:plantOnly]
    if n.s.integrationMethod == :ps && _pretty_defaults[:polyPts]
      int_color = 1
      for int in 1:n.Ni
          if int_color > length(_pretty_defaults[:mpc_lines]) # reset colors
            int_color = 1
          end
          plot!(n.r.t_polyPts[int],n.r.X_polyPts[st][int],line=_pretty_defaults[:mpc_lines][int_color], label=string("poly. # ", int))
          int_color = int_color + 1
      end
      scatter!(n.r.dfs[idx][:t],n.r.dfs[idx][n.state.name[st]],marker=_pretty_defaults[:mpc_markers],label=string(legend_string,"colloc. pts."))
    else
      plot!(n.r.dfs[idx][:t],n.r.dfs[idx][n.state.name[st]],marker=_pretty_defaults[:mpc_markers],line=_pretty_defaults[:mpc_lines][1],label=string(legend_string,"mpc"))
    end
	end
  if _pretty_defaults[:plant]
		# values
		temp = [n.r.dfs_plant[jj][n.state.name[st]] for jj in 1:idx];
	  vals=[idx for tempM in temp for idx=tempM];

		# time
		temp = [n.r.dfs_plant[jj][:t] for jj in 1:idx];
		time=[idx for tempM in temp for idx=tempM];

    plot!(time,vals,line=_pretty_defaults[:plant_lines][1],label=string(legend_string,"plant"));
  end
  adjust_axis(xlims(),ylims());
	xlims!(t_vec[1],t_vec[end]);
  plot!(size=_pretty_defaults[:size]);
  yaxis!(n.state.description[st]); xaxis!("time (s)");
  if !_pretty_defaults[:simulate]; savefig(string(n.r.results_dir,n.state.name[st],".",_pretty_defaults[:format])); end
  return stp
end

"""
stp=statePlot(n,idx,st1,st2);
stp=statePlot(n,idx,st1,st2;(:legend=>"test1"));
stp=statePlot(n,idx,st1,st2,stp;(:append=>true),(:lims=>false));
# to compare two different states
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 2/10/2017, Last Modified: 5/28/2017 \n
--------------------------------------------------------------------------------------\n
"""
function statePlot(n,idx::Int64,st1::Int64,st2::Int64,args...;kwargs...)
  kw = Dict(kwargs);

  # check to see if user would like to add to an existing plot
  if !haskey(kw,:append); kw_ = Dict(:append => false); append = get(kw_,:append,0);
  else; append = get(kw,:append,0);
  end
  if !append; stp=plot(0,leg=:false); else stp=args[1]; end

  if idx > length(n.r.dfs)
    warn("Cannot plot idx = ", idx, " because length(n.r.dfs) = ", length(n.r.dfs), ". \n
          Skipping idx in statePlot().")
    return stp
  end

  # check to see if user would like to plot limits
  if !haskey(kw,:lims); kw_ = Dict(:lims => true); lims = get(kw_,:lims,0);
  else; lims = get(kw,:lims,0);
  end

  # check to see if user would like to label legend
  if !haskey(kw,:legend); kw_ = Dict(:legend => ""); legend_string = get(kw_,:legend,0);
  else; legend_string = get(kw,:legend,0);
  end

  # plot the limits
  # TODO check if all constraints are given
	# TODO make it work for linear varying stateTol
  if lims
    if !isnan(n.XU[st1]);plot!([n.XU[st1],n.XU[st1]],[n.XL[st2],n.XU[st2]],line=_pretty_defaults[:limit_lines][2],label=string(n.state.name[st1],"_max"));end
    if !isnan(n.XL[st1]);plot!([n.XL[st1],n.XL[st1]],[n.XL[st2],n.XU[st2]],line=_pretty_defaults[:limit_lines][1],label=string(n.state.name[st1],"_min"));end
    if !isnan(n.XU[st1]);plot!([n.XL[st1],n.XU[st1]],[n.XU[st2],n.XU[st2]],line=_pretty_defaults[:limit_lines][4],label=string(n.state.name[st2],"_max"));end
    if !isnan(n.XL[st1]);plot!([n.XL[st1],n.XU[st1]],[n.XL[st2],n.XL[st2]],line=_pretty_defaults[:limit_lines][3],label=string(n.state.name[st2],"_min"));end
  end

  # plot the values
	if n.r.dfs[idx]!=nothing && !_pretty_defaults[:plantOnly]
		plot!(n.r.dfs[idx][n.state.name[st1]],n.r.dfs[idx][n.state.name[st2]],line=_pretty_defaults[:mpc_lines][1],label=string(legend_string,"mpc"));
	end

  if _pretty_defaults[:plant]
		# values
		temp = [n.r.dfs_plant[jj][n.state.name[st1]] for jj in 1:idx];
		vals1=[idx for tempM in temp for idx=tempM];

		# values
		temp = [n.r.dfs_plant[jj][n.state.name[st2]] for jj in 1:idx];
		vals2=[idx for tempM in temp for idx=tempM];

		plot!(vals1,vals2,line=_pretty_defaults[:plant_lines][1],label=string(legend_string,"plant"));
  end
  adjust_axis(xlims(),ylims());
  plot!(size=_pretty_defaults[:size]);
  xaxis!(n.state.description[st1]);
  yaxis!(n.state.description[st2]);
  if !_pretty_defaults[:simulate] savefig(string(n.r.results_dir,n.state.name[st1],"_vs_",n.state.name[st2],".",_pretty_defaults[:format])); end
  return stp
end

"""
ctrp=controlPlot(n,idx,ctr);
ctrp=controlPlot(n,idx,ctr,ctrp;(:append=>true));
# to plot control signals
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 2/10/2017, Last Modified: 9/19/2017 \n
--------------------------------------------------------------------------------------\n
"""
function controlPlot(n,idx::Int64,ctr::Int64,args...;kwargs...)
  kw = Dict(kwargs);

  # check to see if user would like to add to an existing plot
  if !haskey(kw,:append); kw_ = Dict(:append => false); append = get(kw_,:append,0);
  else; append = get(kw,:append,0);
  end
  if !append; ctrp=plot(0,leg=:false); else ctrp=args[1]; end

  if idx > length(n.r.dfs)
    warn("Cannot plot idx = ", idx, " because length(n.r.dfs) = ", length(n.r.dfs), ". \n
          Skipping idx in controlPlot().")
    return ctrp
  end

  # check to see if user would like to plot limits
  if !haskey(kw,:lims); kw_ = Dict(:lims => true); lims = get(kw_,:lims,0);
  else; lims = get(kw,:lims,0);
  end

  # check to see if user would like to label legend
  if !haskey(kw,:legend); kw_ = Dict(:legend => ""); legend_string = get(kw_,:legend,0);
  else; legend_string = get(kw,:legend,0);
  end

  if n.r.dfs[idx]!=nothing
  	t_vec=linspace(0.0,n.r.dfs[end][:t][end],_pretty_defaults[:L]);
	else
		t_vec=linspace(0.0,n.r.dfs_plant[end][:t][end],_pretty_defaults[:L]);
	end

  # plot the limits
  if lims
    if !isnan(n.CU[ctr]);plot!(t_vec,n.CU[ctr]*ones(_pretty_defaults[:L],1),line=_pretty_defaults[:limit_lines][2],label="max");end
    if !isnan(n.CL[ctr]); plot!(t_vec,n.CL[ctr]*ones(_pretty_defaults[:L],1),line=_pretty_defaults[:limit_lines][1],label="min"); end
  end

  if n.r.dfs[idx]!=nothing  && !_pretty_defaults[:plantOnly]
    if n.s.integrationMethod == :ps && _pretty_defaults[:polyPts]
      int_color = 1
      for int in 1:n.Ni
        if int_color > length(_pretty_defaults[:mpc_lines]) # reset colors
          int_color = 1  # reset colors
        end  # TODO shift t_polyPts to t0, currently starting at 0
        plot!(n.r.t_polyPts[int],n.r.U_polyPts[ctr][int],line=_pretty_defaults[:mpc_lines][int_color], label=string("poly. # ", int))
        int_color = int_color + 1
      end
      scatter!(n.r.dfs[idx][:t],n.r.dfs[idx][n.control.name[ctr]],marker=_pretty_defaults[:mpc_markers],label=string(legend_string,"colloc. pts."))
    else
      plot!(n.r.dfs[idx][:t],n.r.dfs[idx][n.control.name[ctr]],marker=_pretty_defaults[:mpc_markers],line=_pretty_defaults[:mpc_lines][1],label=string(legend_string,"mpc"))
    end
  end

  if _pretty_defaults[:plant]
		# values
		temp = [n.r.dfs_plant[jj][n.control.name[ctr]] for jj in 1:idx];
	  vals=[idx for tempM in temp for idx=tempM];

		# time
		temp = [n.r.dfs_plant[jj][:t] for jj in 1:idx];
		time=[idx for tempM in temp for idx=tempM];

		plot!(time,vals,line=_pretty_defaults[:plant_lines][1],label=string(legend_string,"plant"));
  end
  adjust_axis(xlims(),ylims());
	xlims!(t_vec[1],t_vec[end]);
  plot!(size=_pretty_defaults[:size]);
  yaxis!(n.control.description[ctr]);	xaxis!("time (s)");
	if !_pretty_defaults[:simulate] savefig(string(n.r.results_dir,n.control.name[ctr],".",_pretty_defaults[:format])) end
  return ctrp
end

"""
tp=tPlot(n,r,idx)
tp=tPlot(n,r,idx,tp;(:append=>true))
# plot the optimization times
# this is an MPC plot
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/11/2017, Last Modified: 6/28/2017 \n
--------------------------------------------------------------------------------------\n
"""
function tPlot(n,idx::Int64,args...;kwargs...);
  r=n.r;

  kw = Dict(kwargs);
  # check to see if user would like to add to an existing plot
  if !haskey(kw,:append); append=false;
  else; append = get(kw,:append,0);
  end
  if !append; tp=plot(0,leg=:false); else tp=args[1]; end

  if idx > length(r.dfs_opt[:tSolve])
      warn("Cannot plot idx = ", idx, " because length(r.dfs_opt[:tSolve]) = ", length(r.dfs_opt[:tSolve]), ". \n
            Skipping idx in tPlot!().")
      return tp
  end
  
  # check to see if user would like to label legend
  if !haskey(kw,:legend);legend_string="";
  else; legend_string = get(kw,:legend,0);
  end

  # to avoid a bunch of jumping around in the simulation
	idx_max=length(r.dfs_opt[:tSolve]);
	if (idx_max<10); idx_max=10 end

  scatter!(1:idx,r.dfs_opt[:tSolve][1:idx],marker=_pretty_defaults[:opt_marker],label=string(legend_string,"optimization times"))
	plot!(1:length(r.dfs_opt[:tSolve]),n.mpc.tex*ones(length(r.dfs_opt[:tSolve])),line=_pretty_defaults[:limit_lines][2],leg=:true,label="real-time threshhold",leg=:topright)

	ylims!(0,max(n.mpc.tex*1.2, maximum(r.dfs_opt[:tSolve])))
  xlims!(1,length(r.dfs_opt[:tSolve]))
	yaxis!("Optimization Time (s)")
	xaxis!("Evaluation Number")
  plot!(size=_pretty_defaults[:size]);
	if !_pretty_defaults[:simulate] savefig(string(n.r.results_dir,"tplot.",_pretty_defaults[:format])) end

	return tp
end

"""
--------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 7/04/2017, Last Modified: 7/04/2017 \n
--------------------------------------------------------------------------------------\n
"""
function optPlot(n)
  L=length(n.r.dfs_opt[:tSolve])
  temp = [n.r.dfs_opt[:objVal][jj] for jj in 1:L];
  val=[idx for tempM in temp for idx=tempM];

  opt=plot(1:L,val)

  yaxis!("Objective Function Values")
	xaxis!("Evaluation Number")
  savefig(string(n.r.results_dir,"optPlot.",_pretty_defaults[:format]))
  return opt
end



"""
costatesPlot(n)
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 11/10/2017, Last Modified: 11/10/2017 \n
--------------------------------------------------------------------------------------\n
"""
function costatesPlot(n;idx::Int64=1,kwargs...)
  if !(n.s.evalCostates && n.s.integrationMethod == :ps && n.s.evalConstraints)
    error("   if n.s.evalCostates && n.s.integrationMethod == :ps && n.s.evalConstraints  \n
              must all be true.")
  end

  if !isdir(n.r.results_dir); resultsDir!(n); end

  csp = [costatePlot(n,idx,st;kwargs...) for st in 1:n.numStates];
  h = plot(csp...,size=_pretty_defaults[:size])
  if !_pretty_defaults[:simulate]; savefig(string(n.r.results_dir,"cs_main.",_pretty_defaults[:format])) end
  return h
end

"""
costatePlot(n,idx,st)
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 11/10/2017, Last Modified: 11/10/2017 \n
--------------------------------------------------------------------------------------\n
"""
function costatePlot(n,idx::Int64,st::Int64;kwargs...)
  if !(n.s.evalCostates && n.s.integrationMethod == :ps && n.s.evalConstraints)
    error("   if n.s.evalCostates && n.s.integrationMethod == :ps && n.s.evalConstraints  \n
              must all be true.")
  end
  kw = Dict(kwargs);

  # check to see if user would like to add to an existing plot
  if !haskey(kw,:append); append=false;
  else; append = get(kw,:append,0);
  end
  if !append; csp=plot(0,leg=:false); else csp=args[1]; end


  # check to see if user would like to label legend
  if !haskey(kw,:legend); legend_string = "";
  else; legend_string = get(kw,:legend,0);
  end

	if n.r.dfs[idx]!=nothing
  	t_vec=linspace(0.0,n.r.dfs[end][:t][end],_pretty_defaults[:L]);
	else
		t_vec=linspace(0.0,n.r.dfs_plant[end][:t][end],_pretty_defaults[:L]);
	end

  if n.s.integrationMethod == :ps
    t_st_int = [n.r.t_st[n.Nck_cum[int]+1:n.Nck_cum[int+1]+1] for int in 1:n.Ni] # this is redundant in interpolateLagrange!()

    int_color = 1
    for int in 1:n.Ni
        if int_color > length(_pretty_defaults[:mpc_lines]) # reset colors
          int_color = 1
        end
        plot!(n.r.t_polyPts[int],n.r.CS_polyPts[st][int],line=_pretty_defaults[:mpc_lines][int_color], label=string("poly. # ", int))
        int_color = int_color + 1
        scatter!(t_st_int[int][1:end-1],n.r.CS[st][int],marker=_pretty_defaults[:mpc_markers],label=string(legend_string,"costate pts."))
    end
  #else # NOTE for now :tm methods do not have a costate option
  #  plot!(n.r.dfs[idx][:t],n.r.CS[st],marker=_pretty_defaults[:mpc_markers],line=_pretty_defaults[:mpc_lines][1],label=string(legend_string,"mpc"))
  end

  adjust_axis(xlims(),ylims());
  xlims!(t_vec[1],t_vec[end]);
  plot!(size=_pretty_defaults[:size]);
  yaxis!(string(n.state.description[st]," costate")); xaxis!("time (s)");

  if !_pretty_defaults[:simulate]; savefig(string(n.r.results_dir,n.state.name[st]," costate.",_pretty_defaults[:format])); end
  return csp
end
