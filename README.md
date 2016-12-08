# PrettyPlots.jl

[![Latest](http://prettyplotsjl.readthedocs.io/en/latest/)

This package contains all of the plotting functionality that I have created.

Goals:
* Remove superfluous functionality

  * min_DF.jl ?

* Turn ``compare_results.jl`` into a function
* Make it work out of the box with
  * VehicleModels.jl
  * Current OCP

Ultimate goals:
* Currently it is pretty basic stuff that is specific to my current data sets, but eventually I want to make the functionality more general, which would include:
 * removing dependency on VehicleModels.jl
    * all the macros
    
## Documentation

The full documentation can be found [here](http://prettyplotsjl.readthedocs.io/en/latest/).


## Installation

In Julia, you can install the NLOptControl.jl package by typing:
```julia
 julia>Pkg.clone("https://github.com/huckl3b3rry87/PrettyPlots.jl")
```
