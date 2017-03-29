module PrettyPlots

include("NLOptControl_plots.jl")
include("VehicleModels_plots.jl")

using .NLOptControl_plots
using .VehicleModels_plots

export

    # NLOptControl.jl plots
    statePlot,
    controlPlot,
    allPlots,
    adjust_axis,
    tPlot,

    # OCP.jl & VehicleModel.jl plots
    obstaclePlot,
    vehiclePlot,
    vtPlot,
    axLimsPlot,
    mainSim,
    mainSimPath,
    pSimPath

end # module
