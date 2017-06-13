module PrettyPlots

using Colors
using DataFrames
using Plots
gr(); # default backend
using VehicleModels
using NLOptControl

include("PrettyUtils.jl")
include("NLOptControl_plots.jl")
include("VehicleModels_plots.jl")

export
    # PrettyUtils.jl
    minDF,
    maxDF,
    plotSettings,
    _pretty_defaults,
    currentSettings,

    # NLOptControl.jl plots
    statePlot,
    controlPlot,
    allPlots,
    adjust_axis,
    tPlot,

    # MAVs.jl & VehicleModel.jl plots
    obstaclePlot,
    trackPlot,
    mainSim,
    posterP,
    posPlot,
    vtPlot

end # module
