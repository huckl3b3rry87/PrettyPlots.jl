"""
# to visualize the current obstacle in the field
obstaclePlot(n,c)

# to run it after a single optimization
pp=obstaclePlot(n,c,1);

# to create a new plot
pp=obstaclePlot(n,c,idx);

# to add to an exsting position plot
pp=obstaclePlot(n,c,idx,pp;(:append=>true));

# posterPlot
pp=obstaclePlot(n,c,ii,pp;(:append=>true),(:posterPlot=>true)); # add obstacles

--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/11/2017, Last Modified: 4/3/2017 \n
--------------------------------------------------------------------------------------\n
"""

function obstaclePlot(n,c,idx,args...;kwargs...)
  r=n.r;
  kw = Dict(kwargs);

  # check to see if is a basic plot
  if !haskey(kw,:basic); kw_ = Dict(:basic => false); basic = get(kw_,:basic,0);
  else; basic=get(kw,:basic,0);
  end

  # check to see if is a poster plot
  if !haskey(kw,:posterPlot); kw_ = Dict(:posterPlot=>false); posterPlot= get(kw_,:posterPlot,0);
  else; posterPlot=get(kw,:posterPlot,0);
  end

  # check to see if user wants to reduce the size of the markers TODO get ride of this eventually
  if !haskey(kw,:smallMarkers);smallMarkers=false;
  else;smallMarkers=get(kw,:smallMarkers,0);
  end

  # check to see if user wants to crash
  if !haskey(kw,:obstacleMiss);obstacleMiss=false;
  else;obstacleMiss=get(kw,:obstacleMiss,0);
  end

  if basic
    s=Settings();
    pp=plot(0,leg=:false)
    if !isempty(c.o.A)
      for i in 1:length(c.o.A)
          # create an ellipse
          pts = Plots.partialcircle(0,2π,100,c.o.A[i])
          x, y = Plots.unzip(pts)
          tc=0;
          x += c.o.X0[i] + c.o.s_x[i]*tc;
          y = c.o.B[i]/c.o.A[i]*y + c.o.Y0[i] + c.o.s_y[i]*tc;
          pts = collect(zip(x, y))
          if i==1
            scatter!((c.o.X0[i],c.o.Y0[i]),marker=(:circle,:red,4.0,1),label="Obstacles")
          end
          plot!(pts,line=(4.0,0.0,:solid,:red),fill=(0, 1, :red),leg=true,label="")
      end
    end
  else
    # check to see if user would like to add to an existing plot
    if !haskey(kw,:append); kw_ = Dict(:append => false); append = get(kw_,:append,0);
    else; append = get(kw,:append,0);
    end
    if !append; pp=plot(0,leg=:false); else pp=args[1]; end

    # plot the goal; assuming same in x and y
    if c.g.name!=:NA
      if isnan(n.XF_tol[1]); rg=1; else rg=n.XF_tol[1]; end
      if !posterPlot || idx ==r.eval_num
        pts = Plots.partialcircle(0,2π,100,rg);
        x, y = Plots.unzip(pts);
        x += c.g.x_ref;  y += c.g.y_ref;
        pts = collect(zip(x, y));
        if !smallMarkers  #TODO get ride of this-> will not be a legend for this case
          scatter!((c.g.x_ref,c.g.y_ref),marker=_pretty_defaults[:goal_marker],label="Goal")
        end
        plot!(pts,line=_pretty_defaults[:goal_line],fill=_pretty_defaults[:goal_fill],leg=true,label="")
      end
    end

    if c.o.name!=:NA
      for i in 1:length(c.o.A)
        # create an ellipse
        pts = Plots.partialcircle(0,2π,100,c.o.A[i])
        x, y = Plots.unzip(pts)
        if _pretty_defaults[:plant]
          x += c.o.X0[i] + c.o.s_x[i]*r.dfs_plant[idx][:t][end];
          y = c.o.B[i]/c.o.A[i]*y + c.o.Y0[i] + c.o.s_y[i]*r.dfs_plant[idx][:t][end];
        else
          if r.dfs[idx]!=nothing
            tc=r.dfs[idx][:t][end];
          else
            tc=0;
            if idx!=1; warn("\n Obstacles set to inital condition for current frame. \n") end
          end
          x += c.o.X0[i] + c.o.s_x[i]*tc;
          y = c.o.B[i]/c.o.A[i]*y + c.o.Y0[i] + c.o.s_y[i]*tc;
        end
        pts=collect(zip(x, y))
        X=c.o.X0[i] + c.o.s_x[i]*r.dfs_plant[idx][:t][end];
        Y=c.o.Y0[i] + c.o.s_y[i]*r.dfs_plant[idx][:t][end];
        if posterPlot
          shade=idx/r.eval_num;
          if idx==r.eval_num && i==1
            scatter!((X,Y),marker=_pretty_defaults[:obstacle_marker],label="Obstacles")
          end
          plot!(pts,line=_pretty_defaults[:obstacle_line],fill=(0,shade,:red),leg=true,label="")
          annotate!(X,Y,text(string(idx*c.m.tex,"s"),10,:black,:center))
        else
          if i==1 && !smallMarkers
            scatter!((X,Y),marker=_pretty_defaults[:obstacle_marker],label="Obstacles")
          end
          plot!(pts,line=_pretty_defaults[:obstacle_line],fill=_pretty_defaults[:obstacle_fill],leg=true,label="") #line=(3.0,0.0,:solid,:red)
          if obstacleMiss && i>8
            annotate!(X,Y+5,text("obstacle not seen!"),14,:red,:center)
          end
        end
      end
    end

    xaxis!(n.state.description[1]);
    yaxis!(n.state.description[2]);
    if !_pretty_defaults[:simulate] savefig(string(r.results_dir,"/",n.state.name[1],"_vs_",n.state.name[2],".",_pretty_defaults[:format])); end
  end
  return pp
end

obstaclePlot(n,c)=obstaclePlot(n,1,1,c,1,;(:basic=>true))

#=
using Plots
import Images
#ENV["PYTHONPATH"]="/home/febbo/.julia/v0.5/Conda/deps/usr/bin/python"
img=Images.load(Pkg.dir("PrettyPlots/src/humvee.png"));
plot(img)
=#
"""
pp=vehiclePlot(n,c,idx);
pp=vehiclePlot(n,c,idx,pp;(:append=>true));
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/11/2017, Last Modified: 4/4/2017 \n
--------------------------------------------------------------------------------------\n
"""
function vehiclePlot(n,c,idx,args...;kwargs...)
  r=n.r;

  kw = Dict(kwargs);

  # check to see if user wants to zoom
  if !haskey(kw,:zoom); kw_=Dict(:zoom => false); zoom=get(kw_,:zoom,0);
  else; zoom=get(kw,:zoom,0);
  end

  # check to see if user would like to add to an existing plot
  if !haskey(kw,:append); kw_ = Dict(:append => false); append = get(kw_,:append,0);
  else; append = get(kw,:append,0);
  end
  if !append; pp=plot(0,leg=:false); else pp=args[1]; end

  # check to see if is a poster plot
  if !haskey(kw,:posterPlot); kw_ = Dict(:posterPlot=>false); posterPlot=get(kw_,:posterPlot,0);
  else; posterPlot=get(kw,:posterPlot,0);
  end

  # check to see if we want to set the limits to the position constraints
  if !haskey(kw,:setLims);setLims=false;
  else;setLims=get(kw,:setLims,0);
  end

  # check to see if user wants to reduce the size of the markers TODO get ride of this eventually
  if !haskey(kw,:smallMarkers);smallMarkers=false;
  else;smallMarkers=get(kw,:smallMarkers,0);
  end

  w=_pretty_defaults[:vehicle_width]; h=_pretty_defaults[:vehicle_length]
  XQ = [-w/2 w/2 w/2 -w/2 -w/2];
  YQ = [h/2 h/2 -h/2 -h/2 h/2];

  # plot the vehicle
  if _pretty_defaults[:plant]
    X_v = r.dfs_plant[idx][:x][end]  # using the end of the simulated data from the vehicle model
    Y_v = r.dfs_plant[idx][:y][end]
    PSI_v = r.dfs_plant[idx][:psi][end]-pi/2
  else
   #TODO condider eliminating option to plot mpc only
    X_v = r.dfs[idx][:x][1] # start at begining
    Y_v = r.dfs[idx][:y][1]
    PSI_v = r.dfs[idx][:psi][1]-pi/2
  end

  P = [XQ;YQ];
  ct = cos(PSI_v);
  st = sin(PSI_v);
  R = [ct -st;st ct];
  P2 = R * P;
  if !posterPlot || idx==r.eval_num
    if !smallMarkers # for legend
      scatter!((X_v,Y_v),marker=_pretty_defaults[:vehicle_marker], grid=true,label="Vehicle")
    end
  end
  scatter!((P2[1,:]+X_v,P2[2,:]+Y_v),ms=0,fill=_pretty_defaults[:vehicle_fill],leg=true,grid=true,label="")

  if !zoom && !setLims
    if _pretty_defaults[:plant]  # TODO push this to a higher level
      xL=minDF(r.dfs_plant,:x);xU=maxDF(r.dfs_plant,:x);
      yL=minDF(r.dfs_plant,:y);yU=maxDF(r.dfs_plant,:y);
    else
      xL=minDF(r.dfs,:x);xU=maxDF(r.dfs,:x);
      yL=minDF(r.dfs,:y);yU=maxDF(r.dfs,:y);
    end
      dx=xU-xL;dy=yU-yL; # axis equal
      if dx>dy; yU=yL+dx; else xU=xL+dy; end
      xlims!(xL,xU);
      ylims!(yL,yU);
  else
    xlims!(X_v-20.,X_v+80.);
    ylims!(Y_v-50.,Y_v+50.);
  end

  if posterPlot
    t=idx*c.m.tex;
    annotate!(X_v,Y_v-4,text(string("t=",t," s"),10,:black,:center))
  end

  if setLims || posterPlot
    xlims!(c.m.Xlims[1],c.m.Xlims[2]);
    ylims!(c.m.Ylims[1],c.m.Ylims[2]);
  end

  if !_pretty_defaults[:simulate]; savefig(string(r.results_dir,"x_vs_y",".",_pretty_defaults[:format])); end
  return pp
end
"""
vt=vtPlot(n,pa,c,idx)
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/11/2017, Last Modified: 3/11/2017 \n
--------------------------------------------------------------------------------------\n
"""
function vtPlot(n,pa,c,idx::Int64)
  r=n.r;

	@unpack_Vpara pa

  if r.dfs[idx]!=nothing
    t_vec=linspace(0.0,max(5,ceil(r.dfs[end][:t][end]/1)*1),_pretty_defaults[:L]);
  else
    t_vec=linspace(0.0,max(5,ceil(r.dfs_plant[end][:t][end]/1)*1),_pretty_defaults[:L]);
  end

	vt=plot(t_vec,Fz_min*ones(_pretty_defaults[:L],1),line=_pretty_defaults[:limit_lines][2],label="min")

  if r.dfs[idx]!=nothing && !_pretty_defaults[:plantOnly]
    V=r.dfs[idx][:v];R=r.dfs[idx][:r];SA=r.dfs[idx][:sa];
    if c.m.model!=:ThreeDOFv1
      Ax=r.dfs[idx][:ax]; U=r.dfs[idx][:ux];
    else # constain speed (the model is not optimizing speed)
      U=c.m.UX*ones(length(V)); Ax=zeros(length(V));
    end
    plot!(r.dfs[idx][:t],@FZ_RL(),line=_pretty_defaults[:mpc_lines][1],label="RL-mpc");
    plot!(r.dfs[idx][:t],@FZ_RR(),line=_pretty_defaults[:mpc_lines][2],label="RR-mpc");
  end
  if _pretty_defaults[:plant]
    temp = [r.dfs_plant[jj][:v] for jj in 1:idx]; # V
    V=[idx for tempM in temp for idx=tempM];

    if c.m.model!=:ThreeDOFv1
      temp = [r.dfs_plant[jj][:ux] for jj in 1:idx]; # ux
      U=[idx for tempM in temp for idx=tempM];

      temp = [r.dfs_plant[jj][:ax] for jj in 1:idx]; # ax
      Ax=[idx for tempM in temp for idx=tempM];
    else # constain speed ( the model is not optimizing speed)
      U=c.m.UX*ones(length(V)); Ax=zeros(length(V));
    end

    temp = [r.dfs_plant[jj][:r] for jj in 1:idx]; # r
    R=[idx for tempM in temp for idx=tempM];

    temp = [r.dfs_plant[jj][:sa] for jj in 1:idx]; # sa
    SA=[idx for tempM in temp for idx=tempM];

    # time
    temp = [r.dfs_plant[jj][:t] for jj in 1:idx];
    time=[idx for tempM in temp for idx=tempM];

    plot!(time,@FZ_RL(),line=_pretty_defaults[:plant_lines][1],label="RL-plant");
    plot!(time,@FZ_RR(),line=_pretty_defaults[:plant_lines][2],label="RR-plant");
  end
  plot!(size=_pretty_defaults[:size]);
	adjust_axis(xlims(),ylims());
  xlims!(t_vec[1],t_vec[end]);
  ylims!(_pretty_defaults[:tire_force_lims])
	title!("Vertical Tire Forces"); yaxis!("Force (N)"); xaxis!("time (s)")
	if !_pretty_defaults[:simulate] savefig(string(r.results_dir,"vt.",_pretty_defaults[:format])) end
  return vt
end

"""
axp=axLimsPlot(n,pa,idx)
axp=axLimsPlot(n,pa,idx,axp;(:append=>true))
# this plot adds the nonlinear limits on acceleration to the plot
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/11/2017, Last Modified: 3/11/2017 \n
--------------------------------------------------------------------------------------\n
"""
function axLimsPlot(n,pa,idx::Int64,args...;kwargs...)
  r=n.r;

  kw = Dict(kwargs);
  if !haskey(kw,:append); kw_ = Dict(:append => false); append = get(kw_,:append,0);
  else; append = get(kw,:append,0);
  end
  if !append; axp=plot(0,leg=:false); else axp=args[1]; end

  @unpack_Vpara pa

  if !_pretty_defaults[:plant] && r.dfs[idx]!=nothing && !_pretty_defaults[:plantOnly]
    t_vec=linspace(0.0,max(5,ceil(r.dfs[end][:t][end]/1)*1),_pretty_defaults[:L]);
  else
    t_vec=linspace(0,max(5,ceil(r.dfs_plant[end][:t][end]/1)*1),_pretty_defaults[:L]);
  end

  if r.dfs[idx]!=nothing && !_pretty_defaults[:plantOnly]
    U = r.dfs[idx][:ux]
    plot!(r.dfs[idx][:t],@Ax_max(),line=_pretty_defaults[:limit_lines][2],label="max-mpc");
    plot!(r.dfs[idx][:t],@Ax_min(),line=_pretty_defaults[:limit_lines][1],label="min-mpc");
  end
  if _pretty_defaults[:plant]
    temp = [r.dfs_plant[jj][:ux] for jj in 1:idx]; # ux
    U=[idx for tempM in temp for idx=tempM];

    # time
    temp = [r.dfs_plant[jj][:t] for jj in 1:idx];
    time=[idx for tempM in temp for idx=tempM];

    plot!(time,@Ax_max(),line=_pretty_defaults[:limit_lines][4],label="max-plant");
    plot!(time,@Ax_min(),line=_pretty_defaults[:limit_lines][3],label="min-plant");
  end
  ylims!(_pretty_defaults[:ax_lims]);
  plot!(size=_pretty_defaults[:size]);
  if !_pretty_defaults[:simulate] savefig(string(r.results_dir,"axp.",_pretty_defaults[:format])) end
  return axp
end


"""
# to visualize the current track in the field
trackPlot(c)

pp=trackPlot(c,pp;(:append=>true));
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/28/2017, Last Modified: 5/1/2017 \n
--------------------------------------------------------------------------------------\n
"""
function trackPlot(c,args...;kwargs...)
  kw = Dict(kwargs);
  s=Settings();

  # check to see if user would like to add to an existing plot
  if !haskey(kw,:append); append=false;
  else; append = get(kw,:append,0);
  end

  # check to see if user wants to reduce the size of the markers TODO get ride of this eventually
  if !haskey(kw,:smallMarkers);smallMarkers=false;
  else;smallMarkers=get(kw,:smallMarkers,0);
  end

  if !append; pp=plot(0,leg=:false); else pp=args[1]; end

  if c.t.func==:poly
    f(y)=c.t.a[1] + c.t.a[2]*y + c.t.a[3]*y^2 + c.t.a[4]*y^3 + c.t.a[5]*y^4;
    Y=c.t.Y;
    X=f.(Y);
  elseif c.t.func==:fourier
    ff(x)=c.t.a[1]*sin(c.t.b[1]*x+c.t.c[1]) + c.t.a[2]*sin(c.t.b[2]*x+c.t.c[2]) + c.t.a[3]*sin(c.t.b[3]*x+c.t.c[3]) + c.t.a[4]*sin(c.t.b[4]*x+c.t.c[4]) + c.t.a[5]*sin(c.t.b[5]*x+c.t.c[5]) + c.t.a[6]*sin(c.t.b[6]*x+c.t.c[6]) + c.t.a[7]*sin(c.t.b[7]*x+c.t.c[7]) + c.t.a[8]*sin(c.t.b[8]*x+c.t.c[8])+c.t.y0;
    X=c.t.X;
    Y=ff.(X);
  end

  if !smallMarkers; L=40; else L=4; end

  plot!(X,Y,label="Road",line=(L,0.3,:solid,:black))
  return pp
end

"""

pp=lidarPlot(r,c,idx);
pp=lidarPlot(r,c,idx,pp;(:append=>true));
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 4/3/2017, Last Modified: 4/3/2017 \n
--------------------------------------------------------------------------------------\n
"""
function lidarPlot(r,c,idx,args...;kwargs...)
  kw = Dict(kwargs);

  # check to see if user would like to add to an existing plot
  if !haskey(kw,:append); kw_ = Dict(:append => false); append = get(kw_,:append,0);
  else; append = get(kw,:append,0);
  end
  if !append; pp=plot(0,leg=:false); else pp=args[1]; end

  # plot the LiDAR
  if _pretty_defaults[:plant]
    X_v = r.dfs_plant[idx][:x][1]  # using the begining of the simulated data from the vehicle model
    Y_v = r.dfs_plant[idx][:y][1]
    PSI_v = r.dfs_plant[idx][:psi][1]-pi/2
  else
    X_v = r.dfs[idx][:x][1]
    Y_v = r.dfs[idx][:y][1]
    PSI_v = r.dfs[idx][:psi][1]-pi/2
  end

  pts = Plots.partialcircle(PSI_v-pi,PSI_v+pi,50,c.m.Lr);
  x, y = Plots.unzip(pts);
  x += X_v;  y += Y_v;
  pts = collect(zip(x, y));
  plot!(pts,line=_pretty_defaults[:lidar_line],fill=_pretty_defaults[:lidar_fill],leg=true,label="LiDAR Range")
  return pp
end
"""
# to plot the second solution
pp=posPlot(n,c,2)
pp=posPlot(n,c,idx)
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/28/2017, Last Modified: 5/1/2017 \n
--------------------------------------------------------------------------------------\n
"""
function posPlot(n,c,idx;kwargs...)
  r=n.r;

  kw = Dict(kwargs);
  if !haskey(kw,:zoom); zoom=false;
  else; zoom=get(kw,:zoom,0);
  end
  # check to see if we want to set the limits to the position constraints
  if !haskey(kw,:setLims);setLims=false;
  else;setLims=get(kw,:setLims,0);
  end

  # check to see if user wants to reduce the size of the markers TODO get ride of this eventually
  if !haskey(kw,:smallMarkers);smallMarkers=false;
  else;smallMarkers=get(kw,:smallMarkers,0);
  end

  # check to see if user wants to crash
  if !haskey(kw,:obstacleMiss);obstacleMiss=false;
  else;obstacleMiss=get(kw,:obstacleMiss,0);
  end

  if !isempty(c.t.X); pp=trackPlot(c;(:smallMarkers=>smallMarkers)); else pp=plot(0,leg=:false); end  # track
  if !isempty(c.m.Lr); pp=lidarPlot(r,c,idx,pp;(:append=>true)); end  # lidar

  pp=statePlot(n,idx,1,2,pp;(:lims=>false),(:append=>true)); # vehicle trajectory
  pp=obstaclePlot(n,c,idx,pp;(:append=>true),(:smallMarkers=>smallMarkers),(:obstacleMiss=>obstacleMiss));               # obstacles
  pp=vehiclePlot(n,c,idx,pp;(:append=>true),(:zoom=>zoom),(:setLims=>setLims),(:smallMarkers=>smallMarkers));  # vehicle

  if !_pretty_defaults[:simulate] savefig(string(r.results_dir,"pp.",_pretty_defaults[:format])) end
  return pp
end

"""
main=mainPlot(n,c,idx;kwargs...)
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 3/11/2017, Last Modified: 6/22/2017 \n
--------------------------------------------------------------------------------------\n
"""
function mainPlot(n,c,idx;kwargs...)
  r=n.r;
  pa=n.params[1];

  kw = Dict(kwargs);
  if !haskey(kw,:mode);error("select a mode for the simulation \n")
  else; mode=get(kw,:mode,0);
  end

  if mode==:path1
    sap=statePlot(n,idx,6)
    vp=statePlot(n,idx,3)
    rp=statePlot(n,idx,4)
    vt=vtPlot(n,pa,c,idx)
    pp=posPlot(n,c,idx)
    pz=posPlot(n,c,idx;(:zoom=>true))
    if _pretty_defaults[:plant]; tp=tPlot(n,idx); else; tp=plot(0,leg=:false); end
    l = @layout [a{0.3w} [grid(2,2)
                          b{0.2h}]]
    mainS=plot(pp,sap,vt,pz,rp,tp,layout=l,size=_pretty_defaults[:size]);
  elseif mode==:path2
    sap=statePlot(n,idx,6);plot!(leg=:topleft)
    vp=statePlot(n,idx,3);plot!(leg=:topleft)
    vt=vtPlot(n,pa,c,idx);plot!(leg=:bottomleft)
    pz=posPlot(n,c,idx;(:zoom=>true));plot!(leg=:topleft)
    if _pretty_defaults[:plant]; tp=tPlot(n,idx);plot!(leg=:topright) else; tp=plot(0,leg=:false);plot!(leg=:topright) end
    l=@layout([a{0.6w} [b;c]; d{0.17h}])
    mainS=plot(pz,vt,sap,tp,layout=l,size=_pretty_defaults[:size]);
  elseif mode==:path3
    sap=statePlot(n,idx,6);plot!(leg=:topleft)
    vp=statePlot(n,idx,3);plot!(leg=:topleft)
    vt=vtPlot(n,pa,c,idx);plot!(leg=:bottomleft)
    pp=posPlot(n,c,idx;(:setLims=>true),(:smallMarkers=>true),(:obstacleMiss=>false));plot!(leg=false);
    pz=posPlot(n,c,idx;(:zoom=>true),(:obstacleMiss=>false));plot!(leg=:topleft)
    if _pretty_defaults[:plant]; tp=tPlot(n,idx);plot!(leg=:topright) else; tp=plot(0,leg=:false);plot!(leg=:topright) end
    l=@layout([[a;
                b{0.2h}] [c;d;e]])
    mainS=plot(pz,pp,vt,sap,tp,layout=l,size=_pretty_defaults[:size]);
  elseif mode==:open1
    sap=statePlot(n,idx,6);plot!(leg=:topleft)
    longv=statePlot(n,idx,7);plot!(leg=:topleft)
    axp=axLimsPlot(n,pa,idx);# add nonlinear acceleration limits
    axp=statePlot(n,idx,8,axp;(:lims=>false),(:append=>true));plot!(leg=:bottomright);
    pp=posPlot(n,c,idx;(:setLims=>true));plot!(leg=:topright);
    if _pretty_defaults[:plant]; tp=tPlot(n,idx); else; tp=plot(0,leg=:false); end
    vt=vtPlot(n,pa,c,idx)
    l = @layout [a{0.5w} [grid(2,2)
                          b{0.2h}]]
    mainS=plot(pp,sap,vt,longv,axp,tp,layout=l,size=_pretty_defaults[:size]);
  end

  return mainS
end


"""
mainSim(n,c;(:mode=>:open1))
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 4/13/2017, Last Modified: 6/22/2017 \n
--------------------------------------------------------------------------------------\n
"""

function mainSim(n,c;kwargs...)
  r=n.r;

  kw = Dict(kwargs);
  if !haskey(kw,:mode);error("select a mode for the simulation \n")
  else; mode=get(kw,:mode,0);
  end

  if n.r.eval_num>2;
     anim = @animate for idx in 1:n.r.eval_num
       mainPlot(n,c,idx;(:mode=>mode))
    end
    cd(n.r.results_dir)
      gif(anim,"mainSim.gif",fps=Int(ceil(1/n.mpc.tex)));
      run(`ffmpeg -f gif -i mainSim.gif RESULT.mp4`)
    cd(n.r.main_dir)
  else
    warn("the evaluation number was not greater than 2. Cannot make animation. Plotting a static plot.")
    warn("\n Modifying current plot settings! \n")
    plotSettings(;(:simulate=>false),(:plant=>false));
    mainPlot(n,c,1;(:mode=>mode))
  end
  return nothing
end

"""

--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 4/13/2017, Last Modified: 5/1/2017 \n
--------------------------------------------------------------------------------------\n
"""

function pSim(n,c)
  r=n.r;

  anim = @animate for ii in 1:length(r.dfs)
    posPlot(n,c,ii);
  end
  gif(anim, string(r.results_dir,"posSim.gif"), fps=Int(ceil(1/n.mpc.tex)) );
  return nothing
end


"""

--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 4/13/2017, Last Modified: 4/13/2017 \n
--------------------------------------------------------------------------------------\n
"""

function pSimGR(n,c)

  ENV["GKS_WSTYPE"]="mov"
  gr(show=true)
  for ii in 1:length(n.r.dfs)
    posPlot(n,c,ii);
  end
end

"""
default(guidefont = font(17), tickfont = font(15), legendfont = font(12), titlefont = font(20))
s=Settings(;save=true,MPC=true,simulate=false,format=:png,plantOnly=true);
posterP(n,c)
--------------------------------------------------------------------------------------\n
Author: Huckleberry Febbo, Graduate Student, University of Michigan
Date Create: 4/13/2017, Last Modified: 6/22/2017 \n
--------------------------------------------------------------------------------------\n
"""

function posterP(n,c)
  r=n.r;
  pa=n.params[1];
  if n.r.status==:Infeasible
    warn("\n Current solution is infeasible! Will try to plot, but it may fail... \n")
  end
  warn("\n Modifying current plot settings! \n")
  plotSettings(;(:simulate=>false),(:plant=>true),(:plantOnly=>true));

  # static plots for each frame
  idx=r.eval_num;
  sap=statePlot(n,idx,6)
  longv=statePlot(n,idx,7)
  axp=axLimsPlot(n,pa,idx); # add nonlinear acceleration limits
  axp=statePlot(n,idx,8,axp;(:lims=>false),(:append=>true));
  pp=statePlot(n,idx,1,2;(:lims=>false));
  if _pretty_defaults[:plant]; tp=tPlot(n,idx); else; tp=plot(0,leg=:false); end
  vt=vtPlot(n,pa,c,idx)

  # dynamic plots ( maybe only update every 5 frames or so)
  v=Vector(1:5:r.eval_num); if v[end]!=r.eval_num; append!(v,r.eval_num); end
  for ii in v
    if ii==1
      st1=1;st2=2;
      # values
  		temp = [r.dfs_plant[jj][n.state.name[st1]] for jj in 1:r.eval_num];
  		vals1=[idx for tempM in temp for idx=tempM];

  		# values
  		temp = [r.dfs_plant[jj][n.state.name[st2]] for jj in 1:r.eval_num];
  		vals2=[idx for tempM in temp for idx=tempM];

  		pp=plot(vals1,vals2,line=_pretty_defaults[:plant_lines][1],label="Vehicle Trajectory");

      pp=obstaclePlot(n,c,ii,pp;(:append=>true),(:posterPlot=>true)); # add obstacles
      pp=vehiclePlot(n,c,ii,pp;(:append=>true),(:posterPlot=>true));  # add the vehicle
    else
      pp=obstaclePlot(n,c,ii,pp;(:append=>true),(:posterPlot=>true));  # add obstacles
      pp=vehiclePlot(n,c,ii,pp;(:append=>true),(:posterPlot=>true));  # add the vehicle
    end
  end
  l = @layout [a{0.5w} [grid(2,2)
                        b{0.2h}]]
  poster=plot(pp,sap,vt,longv,axp,tp,layout=l,size=_pretty_defaults[:size]);
  savefig(string(r.results_dir,"poster",".",_pretty_defaults[:format]));
  return nothing
end
