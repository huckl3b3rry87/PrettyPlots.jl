function data_sets(k,set)
  dfs = Vector{DataFrame}(k) # create am empty DataFrame
  for i in 1:k
    cd(path[i])
    dfs[i] = readtable(string(set,".csv"))
  end
  cd(main_dir)
  return dfs
end
