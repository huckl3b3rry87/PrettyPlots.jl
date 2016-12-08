function export_data(dfs,name::String)
  if !isassigned(dfs,1) # in this case the program should be just finishing the optimization
    dfs=x_to_DataFrame(t,getvalue(x),getvalue(y),getvalue(sa),getvalue(ax),getvalue(psi),getvalue(u),getvalue(v),getvalue(r),getvalue(jx),getvalue(sr)); # get dfs for the plots
    writetable(name,dfs)
  else
    writetable(name,dfs[1])
  end
end
