function min_DF(dfs,k,varb)
  # find the minimum
  tmp = Array(Float32,(k,1))

  if varb == 't'
    for i in 1:k
      tmp[i] = minimum(dfs[i][:t])
    end
  elseif varb == 'V'
    for i in 1:k
      tmp[i] = minimum(dfs[i][:V])
    end
  elseif varb == 'P'
    for i in 1:k
      tmp[i] = minimum(dfs[i][:PSI])
    end
  elseif varb == 'r'
    for i in 1:k
      tmp[i] = minimum(dfs[i][:r])
    end
  else
  println("Make sure that you define your variable! \n")
  end
  minimum(tmp)
end
