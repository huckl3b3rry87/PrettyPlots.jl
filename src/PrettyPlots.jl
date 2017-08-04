module PrettyPlots

using Colors
using DataFrames
using Plots
gr(); # default backend
using VehicleModels # need for parameters
using NLOptControl  # need for resultsDir!()

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
    optPlot,

  # MAVs.jl & VehicleModel.jl plots
    obstaclePlot,
    trackPlot,
    mainSim,
    posterP,
    posPlot,
    vtPlot,

    # Plots.jl exported functions
    xlims!,
    ylims!
end # module
