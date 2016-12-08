function max_DF(dfs,k,varb)
  # find the maximum
  tmp = Array(Float32,(k,1))

  if varb == 't'
    for i in 1:k
      tmp[i] = maximum(dfs[i][:t])
    end
  elseif varb == 'V'
    for i in 1:k
      tmp[i] = maximum(dfs[i][:V])
    end
  elseif varb == 'P'
    for i in 1:k
      tmp[i] = maximum(dfs[i][:PSI])
    end
  elseif varb == 'r'
    for i in 1:k
      tmp[i] = maximum(dfs[i][:r])
    end
  else
  println("Make sure that you define your variable! \n")
  end
  maximum(tmp)
end
