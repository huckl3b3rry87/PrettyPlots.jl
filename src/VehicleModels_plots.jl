module VehicleModels_plots

using NLOptControl
using VehicleModels
using Plots

include("NLOptControl_plots.jl")
using .NLOptControl_plots

export
      obstaclePlot,
      vehiclePlot,
      vtPlot,
      axLimsPlot,
      mainSim,
      mainSimPath,
      pSimPath

"""
pp=obstaclePlot(n,r,s,c,idx);
pp=obstaclePlot(n,r,s,c,idx,pp;(:append=>true));
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/11/2017, Last Modified: 3/29/2017 \n
--------------------------------------------------------------------------------------\n
"""
function obstaclePlot(n,r,s,c,idx,args...;kwargs...)
  kw = Dict(kwargs);

  # check to see if user would like to add to an existing plot
  if !haskey(kw,:append); kw_ = Dict(:append => false); append = get(kw_,:append,0);
  else; append = get(kw,:append,0);
  end
  if !append; pp=plot(0,leg=:false); else pp=args[1]; end

  # plot the goal; assuming same in x and y
  if !isempty(c.g.name)
    if isnan(n.XF_tol[1]); rg=1; else rg=n.XF_tol[1]; end[]
    pts = Plots.partialcircle(0,2π,100,rg);
    x, y = Plots.unzip(pts);
    x += c.g.x_ref;  y += c.g.y_ref;
    pts = collect(zip(x, y));
    plot!(pts, fill = (0, 0.7, :green),leg=true,label="Goal")
  end

  if !isempty(c.o.A)
    for i in 1:length(c.o.A)
      # create an ellipse
      pts = Plots.partialcircle(0,2π,100,c.o.A[i])
      x, y = Plots.unzip(pts)
      if s.MPC
        x += c.o.X0[i] + c.o.s_x[i]*r.dfs_plant[idx][:t][end];
        y = c.o.B[i]/c.o.A[i]*y + c.o.Y0[i] + c.o.s_y[i]*r.dfs_plant[idx][:t][end];
      else
        x += c.o.X0[i] + c.o.s_x[i]*r.dfs[idx][:t][end];
        y = c.o.B[i]/c.o.A[i]*y + c.o.Y0[i] + c.o.s_y[i]*r.dfs[idx][:t][end];
      end
      pts = collect(zip(x, y))
      if i==1
        plot!(pts, fill = (0, 0.7, :red),leg=true,label="Obstacles",leg=:bottomleft)
      else
        plot!(pts, fill = (0, 0.7, :red),leg=true,label="",leg=:bottomleft)
      end
    end
  end

  xaxis!(n.state.description[1]);
  yaxis!(n.state.description[2]);
  xlims!(-50,50);ylims!(0,100); #TODO pass this based off of obstacle feild
  if !s.simulate savefig(string(r.results_dir,"/",n.state.name[1],"_vs_",n.state.name[2],".",s.format)); end
  return pp
end

"""
pp=vehiclePlot(n,r,s,c,idx);
pp=vehiclePlot(n,r,s,c,idx,pp;(:append=>true));
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/11/2017, Last Modified: 3/11/2017 \n
--------------------------------------------------------------------------------------\n
"""
function vehiclePlot(n,r,s,c,idx,args...;kwargs...)
  kw = Dict(kwargs);

  # check to see if user would like to add to an existing plot
  if !haskey(kw,:append); kw_ = Dict(:append => false); append = get(kw_,:append,0);
  else; append = get(kw,:append,0);
  end
  if !append; pp=plot(0,leg=:false); else pp=args[1]; end

  # contants
  w=1.9; #width TODO move these to vehicle parameters
  h=3.3; #height
  XQ = [-w/2 w/2 w/2 -w/2 -w/2];
  YQ = [h/2 h/2 -h/2 -h/2 h/2];

  # plot the vehicle
  if s.MPC
    X_v = r.dfs_plant[idx][:x][end]  # using the end of the simulated data from the vehicle model
    Y_v = r.dfs_plant[idx][:y][end]
    PSI_v = r.dfs_plant[idx][:psi][end]-pi/2
  else
    X_v = r.dfs[idx][:x][end]  # vehicles are in the same spot at the begining
    Y_v = r.dfs[idx][:y][end]
    PSI_v = r.dfs[idx][:psi][end]-pi/2
  end

  P = [XQ;YQ];
  ct = cos(PSI_v);
  st = sin(PSI_v);
  R = [ct -st;st ct];
  P2 = R * P;
  scatter!((P2[1,:]+X_v,P2[2,:]+Y_v), markershape = :square, markercolor = :black, markersize = s.ms1, fill = (0, 1, :black),leg=true, grid=true,label="Vehicle")
  if !s.simulate; savefig(string(r.results_dir,"x_vs_y",".",s.format)); end

  return pp
end
"""
vt=vtPlot(n,r,s,pa,idx)
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/11/2017, Last Modified: 3/11/2017 \n
--------------------------------------------------------------------------------------\n
"""
function vtPlot(n::NLOpt,r::Result,s::Settings,pa::VehicleModels.Vpara,idx::Int64)
	@unpack_Vpara pa

  if !s.MPC && r.dfs[idx]!=nothing
  	t_vec=linspace(r.dfs[1][:t][1],round(r.dfs[end][:t][end]/10)*10,s.L);
	else
    t_vec=linspace(r.dfs_plant[1][:t][1],max(5,round(r.dfs_plant[end][:t][end]/5)*5),s.L);
	end

	vt=plot(t_vec,Fz_min*ones(s.L,1),line=(s.lw2),label="min")

  if r.dfs[idx]!=nothing
    V=r.dfs[idx][:v];U=r.dfs[idx][:ux];Ax=r.dfs[idx][:ax];R=r.dfs[idx][:r];SA=r.dfs[idx][:sa];
    plot!(r.dfs[idx][:t],@FZ_RL(),w=s.lw1,label="RL-mpc");
    plot!(r.dfs[idx][:t],@FZ_RR(),w=s.lw1,label="RR-mpc");
  end
  if s.MPC
    temp = [r.dfs_plant[jj][:v] for jj in 1:idx]; # V
    V=[idx for tempM in temp for idx=tempM];

    temp = [r.dfs_plant[jj][:ux] for jj in 1:idx]; # ux
    U=[idx for tempM in temp for idx=tempM];

    temp = [r.dfs_plant[jj][:ax] for jj in 1:idx]; # ax
    Ax=[idx for tempM in temp for idx=tempM];

    temp = [r.dfs_plant[jj][:r] for jj in 1:idx]; # r
    R=[idx for tempM in temp for idx=tempM];

    temp = [r.dfs_plant[jj][:sa] for jj in 1:idx]; # sa
    SA=[idx for tempM in temp for idx=tempM];

    # time
    temp = [r.dfs_plant[jj][:t] for jj in 1:idx];
    time=[idx for tempM in temp for idx=tempM];

    plot!(time,@FZ_RL(),w=s.lw2,label="RL-plant");
    plot!(time,@FZ_RR(),w=s.lw2,label="RR-plant");
  end
  plot!(size=(s.s1,s.s1));
	adjust_axis(xlims(),ylims());
  xlims!(t_vec[1],t_vec[end]);
  ylims!(ylims()[1]-500,ylims()[2]+100)
	title!("Vertical Tire Forces"); yaxis!("Force (N)"); xaxis!("time (s)")
	if !s.simulate savefig(string(r.results_dir,"vt.",s.format)) end
  return vt
end

"""
axp=axLimsPlot(n,r,s,pa,idx)
axp=axLimsPlot(n,r,s,pa,idx,axp;(:append=>true))
# this plot adds the nonlinear limits on acceleration to the plot
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/11/2017, Last Modified: 3/11/2017 \n
--------------------------------------------------------------------------------------\n
"""
function axLimsPlot(n::NLOpt,r::Result,s::Settings,pa::VehicleModels.Vpara,idx::Int64,args...;kwargs...)
  kw = Dict(kwargs);
  if !haskey(kw,:append); kw_ = Dict(:append => false); append = get(kw_,:append,0);
  else; append = get(kw,:append,0);
  end
  if !append; axp=plot(0,leg=:false); else axp=args[1]; end

  @unpack_Vpara pa

  if !s.MPC && r.dfs[idx]!=nothing
    t_vec=linspace(r.dfs[1][:t][1],max(5,round(r.dfs[end][:t][end]/5)*5),s.L);
	else
    t_vec=linspace(r.dfs_plant[1][:t][1],max(5,round(r.dfs_plant[end][:t][end]/5)*5),s.L);
	end

  if r.dfs[idx]!=nothing
    U = r.dfs[idx][:ux]
    plot!(r.dfs[idx][:t],@Ax_min(),w=s.lw1,label="min-mpc");
    plot!(r.dfs[idx][:t],@Ax_max(),w=s.lw1,label="max-mpc");
  end
  if s.MPC
    temp = [r.dfs_plant[jj][:ux] for jj in 1:idx]; # ux
    U=[idx for tempM in temp for idx=tempM];

    # time
    temp = [r.dfs_plant[jj][:t] for jj in 1:idx];
    time=[idx for tempM in temp for idx=tempM];

    plot!(time,@Ax_min(),w=s.lw2,label="min-plant");
    plot!(time,@Ax_max(),w=s.lw2,label="max-plant");
  end
  plot!(size=(s.s1,s.s1));
  if !s.simulate savefig(string(r.results_dir,"axp.",s.format)) end
  return axp
end


"""
mainS=mainSim(n,r,s,c,pa,idx)
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/11/2017, Last Modified: 3/27/2017 \n
--------------------------------------------------------------------------------------\n
"""
function mainSim(n,r,s,c,pa,idx)
  sap=statePlot(n,r,s,idx,6)
  longv=statePlot(n,r,s,idx,7)
  axp=axLimsPlot(n,r,s,pa,idx); # add nonlinear acceleration limits
  axp=statePlot(n,r,s,idx,8,axp;(:lims=>false),(:append=>true));
  #srp=controlPlot(n,r,s,r.eval_num,1)
  pp=statePlot(n,r,s,idx,1,2;(:lims=>false));
  pp=obstaclePlot(n,r,s,c,idx,pp;(:append=>true)); # add obstacles
  pp=vehiclePlot(n,r,s,c,idx,pp;(:append=>true)); # add the vehicle
  tp=tPlot(n,r,s,idx)
  vt=vtPlot(n,r,s,pa,idx)
  l = @layout [a{0.3w} [grid(2,2)
                        b{0.2h}]]
  mainS=plot(pp,sap,vt,longv,axp,tp,layout=l,size=(1800,1200));
  annotate!(166,105,text(string(@sprintf("Final Time:  %0.2f", r.dfs_plant[idx][:t][end])," s"),16,:red,:center))
  annotate!(166,100,text(string("Iteration # ", idx),16,:red,:center))
  annotate!(166,95,text(string(r.status[idx]," | ", n.solver),16,:red,:center))
  annotate!(166,90,text(string(@sprintf("Obj. Val: %0.2f", r.obj_val[idx])),16,:red,:center))

  return mainS
end


"""
mainS=mainSimPath(n,r,s,c,pa,idx)
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/28/2017, Last Modified: 3/28/2017 \n
--------------------------------------------------------------------------------------\n
"""
function mainSimPath(n,r,s,c,pa,idx)
  sap=controlPlot(n,r,s,idx,1)

  vp=statePlot(n,r,s,idx,3)
  rp=statePlot(n,r,s,idx,4)
  #psip=statePlot(n,r,s,idx,5)
  pp=trackPlot(r,s,c,idx)
  pp=statePlot(n,r,s,idx,1,2,pp;(:lims=>false),(:append=>true));
  pp=obstaclePlot(n,r,s,c,idx,pp;(:append=>true)); # add obstacles
  pp=vehiclePlot(n,r,s,c,idx,pp;(:append=>true)); # add the vehicle
  tp=tPlot(n,r,s,idx)
  vt=vtPlot(n,r,s,pa,idx)
  l = @layout [a{0.3w} [grid(2,2)
                        b{0.2h}]]
  mainS=plot(pp,sap,vt,rp,vp,tp,layout=l,size=(1800,1200));
  annotate!(166,105,text(string(@sprintf("Final Time:  %0.2f", r.dfs_plant[idx][:t][end])," s"),16,:red,:center))
  annotate!(166,100,text(string("Iteration # ", idx),16,:red,:center))
  annotate!(166,95,text(string(r.status[idx]," | ", n.solver),16,:red,:center))
  annotate!(166,90,text(string(@sprintf("Obj. Val: %0.2f", r.obj_val[idx])),16,:red,:center))

  return mainS
end

"""
pp=pSimPath(n,r,s,c,idx)
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/28/2017, Last Modified: 3/28/2017 \n
--------------------------------------------------------------------------------------\n
"""
function pSimPath(n,r,s,c,idx)
  pp=trackPlot(r,s,c,idx)
  pp=statePlot(n,r,s,idx,1,2,pp;(:lims=>false),(:append=>true));
  pp=obstaclePlot(n,r,s,c,idx,pp;(:append=>true)); # add obstacles
  pp=vehiclePlot(n,r,s,c,idx,pp;(:append=>true)); # add the vehicle

  if !s.simulate savefig(string(r.results_dir,"pp.",s.format)) end
  return pp
end

"""

pp=trackPlot(r,s,c,idx);
pp=trackPlot(r,s,c,idx,pp;(:append=>true));
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/28/2017, Last Modified: 3/28/2017 \n
--------------------------------------------------------------------------------------\n
"""
function trackPlot(r,s,c,idx,args...;kwargs...)
  kw = Dict(kwargs);

  # check to see if user would like to add to an existing plot
  if !haskey(kw,:append); kw_ = Dict(:append => false); append = get(kw_,:append,0);
  else; append = get(kw,:append,0);
  end
  if !append; pp=plot(0,leg=:false); else pp=args[1]; end

  f(y)=c.t.a0 + c.t.a1*y + c.t.a2*y^2 + c.t.a3*y^3 + c.t.a4*y^4;
  if s.MPC
    #temp = [r.dfs_plant[jj][:y] for jj in 1:idx]; # Y
    temp = [r.dfs_plant[jj][:y] for jj in 1:r.eval_num]; # Y
    Y=[idx for tempM in temp for idx=tempM];
  else
    Y=r.X[:,2];
  end

  X=f.(Y);

  plot!(X,Y,w=s.lw1*5,label="Road")
  return pp
end

end # module
