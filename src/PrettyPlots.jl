module PrettyPlots

using Plots
using DataFrames
using VehicleModels
using NLOptControl

# plotting functionality
include("NLOptControl_plots.jl")

export
    # basic functions
    resultsDir, adjust_axis,

    # NLOptControl.jl plots
    statePlot, controlPlot, allPlots

end # module
