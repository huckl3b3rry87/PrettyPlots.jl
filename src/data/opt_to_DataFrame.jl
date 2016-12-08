function opt_to_DataFrame(t_solve::Array{Float64,1},obj_val::Array{Float64,1},status::Array{Symbol,1})

  id = find(t_solve)
  idx = id[end]
  dfs_opt=DataFrame()
  dfs_opt[:t_solve]=t_solve[1:idx]
  dfs_opt[:obj_val]=obj_val[1:idx]
  dfs_opt[:status]=status[1:idx]

  return dfs_opt
end
