
"""
# plotting functionality for NLOptControl.jl
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 2/10/2017, Last Modified: 2/14/2017 \n
--------------------------------------------------------------------------------------\n
"""
function allPlots(n::NLOpt,r::Result,s::Settings,idx::Int64)
  stp = [statePlot(n,r,s,idx,st) for st in 1:n.numStates];
  ctp = [controlPlot(n,r,s,idx,ctr) for ctr in 1:n.numControls];
  all = [stp;ctp];
  h = plot(all...,size=(s.s1,s.s1));
  if !s.simulate; savefig(string("main.",s.format)) end
  return h
end

function statePlot(n::NLOpt,r::Result,s::Settings,idx::Int64,st::Int64)
  # plot the limits
  stp=plot(0,leg=:false)
  t_vec = linspace(r.dfs[idx][:t][1],r.dfs[idx][:t][end],s.L);
  if !isinf(n.XL[st]);plot!(t_vec,n.XL[st]*ones(s.L,1),w=s.lw1,label="min");end
  if !isinf(n.XU[st]);plot!(t_vec,n.XU[st]*ones(s.L,1),w=s.lw1,label="max");end

  # plot the values
  if s.MPC
    plot!(r.dfs[idx][:t],r.dfs[idx][n.state.name[st]],w=s.lw1,label="mpc");
    plot!(r.dfs_plant[idx][:t],r.dfs_plant[idx][n.state.name[st]],w=s.lw2,label="plant");
  else
    plot!(r.dfs[idx][:t],r.dfs[idx][n.state.name[st]],w=s.lw2,label="mpc");
  end
  adjust_axis(xlims(),ylims());
  yaxis!(n.state.description[st]); xaxis!("time (s)");
  if !s.simulate; savefig(string(n.state.name[st],".",s.format)); end
  return stp
end

# to compare two different states
function statePlot(n::NLOpt,r::Result,s::Settings,idx::Int64,st1::Int64,st2::Int64)
  # plot the limits
  stp=plot(0,leg=:false)
  # TODO check if all constraints are given
  if !isinf(n.XL[st1]);plot!([n.XL[st1],n.XL[st1]],[n.XL[st2],n.XU[st2]],w=s.lw1,label=string(n.state.name[st1],"_min"));end
  if !isinf(n.XU[st1]);plot!([n.XU[st1],n.XU[st1]],[n.XL[st2],n.XU[st2]],w=s.lw1,label=string(n.state.name[st1],"_max"));end

  if !isinf(n.XL[st1]);plot!([n.XL[st1],n.XU[st1]],[n.XL[st2],n.XL[st2]],w=s.lw1,label=string(n.state.name[st2],"_min"));end
  if !isinf(n.XU[st1]);plot!([n.XL[st1],n.XU[st1]],[n.XU[st2],n.XU[st2]],w=s.lw1,label=string(n.state.name[st2],"_max"));end

  # plot the values
  if s.MPC
    plot!(r.dfs[idx][n.state.name[st1]],r.dfs[idx][n.state.name[st2]],w=s.lw1,label="mpc");
    plot!(r.dfs_plant[idx][n.state.name[st1]],r.dfs_plant[idx][n.state.name[st2]],w=s.lw2,label="plant");
  else
    plot!(r.dfs[idx][n.state.name[st1]],r.dfs[idx][n.state.name[st2]],w=s.lw1,label="mpc");
  end
  adjust_axis(xlims(),ylims());
  xaxis!(n.state.description[st1]);
  yaxis!(n.state.description[st2]);
  if !s.simulate savefig(string(n.state.name[st1],"_vs_",n.state.name[st2],".",s.format)); end
  return stp
end

function controlPlot(n::NLOpt,r::Result,s::Settings,idx::Int64,ctr::Int64)
  # plot the limits
  ctrp=plot(0,leg=:false)
  t_vec = linspace(r.dfs[idx][:t][1],r.dfs[idx][:t][end],s.L);
  if !isinf(n.CL[ctr]); plot!(t_vec,n.CL[ctr]*ones(s.L,1),w=s.lw1,label="min"); end
  if !isinf(n.CU[ctr]);plot!(t_vec,n.CU[ctr]*ones(s.L,1),w=s.lw1,label="max");end

  # plot the values
  if s.MPC
    plot!(r.dfs[idx][:t],r.dfs[idx][n.control.name[ctr]],w=s.lw1,label="mpc");
    plot!(r.dfs_plant[idx][:t],r.dfs_plant[idx][n.control.name[ctr]],w=s.lw2,label="plant");
  else
    plot!(r.dfs[idx][:t],r.dfs[idx][n.control.name[ctr]],w=s.lw2,label="mpc")
  end
  adjust_axis(xlims(),ylims());
  yaxis!(n.control.description[ctr]);	xaxis!("time (s)");
	if !s.simulate savefig(string(n.control.name[ctr],".",s.format)) end
  return ctrp
end
