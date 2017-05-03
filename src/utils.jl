# Credit: this was inspired by Plots.jl
#lc=distinguishable_colors(10);
const _pretty_defaults = Dict(
    :mpc_lines    =>Array[[4.0,:blueviolet,:solid],[4.0,:blueviolet,:dash]],
    :plant_lines  =>Array[[3.0,:darkgreen,:solid],[3.0,:darkgreen,:solid]],
    :limit_lines  =>Array[[2.0,:turquoise,:solid],[2.0,:violet,:solid],[2.0,:orchid,:solid],[2.0,:darksalmon,:solid]],
    :size         =>(1800,1200),
    :marker_size  =>[1.0,5.0],
    :format       =>:png,
    :plantOnly    =>false,
    :simulate     =>true,
    :save         =>true,
    :MPC          =>false,
)

"""
plotSettings(;(:mpc_color=>:blue),(:size=>(1000,1000)))
"""
function plotSettings(;kwargs...)
  kw = Dict(kwargs);
  for (key,value) in kw
    if haskey(_plot_defaults,key)
      _plot_defaults[key]=value
    else
      error("Unknown key: ", kw)
    end
  end
end

#=
using Plots
using PrettyPlots
plot(rand(10),line=_plot_defaults[:mpc_lines][1])
=#
