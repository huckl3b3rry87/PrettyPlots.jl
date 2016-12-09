module PrettyPlots
# plotting options
#TODO make these global s = 700; global w1 = 7; global w2 = 4;
# global results_folder
using Media
using Plots
using DataFrames
using VehicleModels
using ImplicitEquations  # to plot obstacles

#dirty
############
# includes #
############

# data functionality
include("data/x_to_DataFrame.jl")
include("data/opt_to_DataFrame.jl")
include("data/data_sets.jl")   #TODO might remove
include("data/export_data.jl")#TODO might remove
include("data/max_DF.jl")#TODO might remove
include("data/min_DF.jl")#TODO might remove

# plotting functionality
include("plots/adjust_axis.jl")
include("plots/all_plots.jl")
include("plots/anim_funs.jl")
include("plots/axplot.jl")
#include("plots/compare_results.jl")
include("plots/jxplot.jl")
include("plots/latvplot.jl")
include("plots/longvplot.jl")
include("plots/ltplot.jl")
include("plots/optplot.jl")
include("plots/pplot.jl")
include("plots/saplot.jl")
include("plots/srplot.jl")
include("plots/tplot.jl")
include("plots/vtplot.jl")
include("plots/yawplot.jl")
include("plots/yawrplot.jl")

###########
# imports #
###########
#import x_to_DataFrame

###########
# exports #
###########
export
# Objects

# Functions
    # Data related
    export_data, max_DF, min_DF, data_sets, x_to_DataFrame, opt_to_DataFrame,
    # Plot manipulation
    adjust_axis,
    # Plot functionality
    all_plots, panim_fun, axplot, jxplot, latvplot, longvplot, ltplot, pplot,
    saplot, srplot, tplot, vtplot, yawplot, optplot,

    bar2
# Macros

#############################
# types/functions/constants #
#############################
function bar2(x)
  println("in bar $x")
  return x
end


# abstract types #
#----------------#


end # module
