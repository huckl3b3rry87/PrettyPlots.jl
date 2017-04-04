using PrettyPlots
using Base.Test

# write your own tests here

# plot an obstacle feild and test the position plot
@test 1 == 2


# obstacle plotting tests
using OCP
using NLOptControl

n=NLOpt();
c=defineCase();
obstaclePlot(n,c);



#@test obstaclePlot
