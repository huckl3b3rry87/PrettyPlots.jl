function x_to_DataFrame(t::Vector,x::Vector,y::Vector,sa::Vector,ax::Vector,psi::Vector,u::Vector,v::Vector,r::Vector,jx::Vector,sr::Vector)

  dfs=DataFrame()
  dfs[:t]=t
  dfs[:X]=x
  dfs[:Y]=y
  dfs[:SA]=sa
  dfs[:Ax]=ax
  dfs[:PSI]=psi
  dfs[:U]=u
  dfs[:V]=v
  dfs[:r]=r

  if length(r) == length(jx) # need a better check here
    dfs[:Jx]=jx
    dfs[:SR]=sr
  else # append zeros on the end of the control vectors
    dfs[:Jx]=[jx;0]
    dfs[:SR]=[sr;0]
  end

  return dfs
end
