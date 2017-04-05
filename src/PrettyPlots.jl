module PrettyPlots

#include("utils.jl")
include("NLOptControl_plots.jl")
include("VehicleModels_plots.jl")

#using .utils
using .NLOptControl_plots
using .VehicleModels_plots

export
    # utils.jl
    minDF,
    maxDF,

    # NLOptControl.jl plots
    statePlot,
    controlPlot,
    allPlots,
    adjust_axis,
    tPlot,

    # OCP.jl & VehicleModel.jl plots
    obstaclePlot,
    trackPlot,
    vehiclePlot,
    vtPlot,
    axLimsPlot,
    mainSim,
    mainSimPath,
    pSimPath

end # module
