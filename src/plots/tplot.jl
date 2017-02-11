function tplot(dfs_opt::Array{DataFrames.DataFrame,1},dfs::Array{DataFrames.DataFrame,1},label_string::Array{String,1},simulate::Bool)

num = length(label_string)
idx_end =Array(Int64,num)
s=1000
s=1000
# initialize arrays with zeros
for j in 1:num
	idx_end[j] = find(dfs_opt[j][:t_solve])[end]
end
idx_max = maximum(idx_end);
if (simulate && idx_max < 10) idx_max = 10 end
T_solve = zeros(num,idx_max);
T_total = zeros(Float64,num);
t_e = zeros(Float64,num);

tp = plot(0,leg=:false)
for j in 1:num
	# define variables
	T_solve[j,1:length(dfs_opt[j][:t_solve])] = dfs_opt[j][:t_solve]
	T_total =  sum(T_solve[j,:]);
	t_e = dfs[j][:t][end]

	plot!(T_solve[j,2:end],w=4,label=string(label_string[j], " opt. times"))
	str1 = string(label_string[j], @sprintf(" total solve time  = %0.2f", T_total), " s");
	annotate!([(  maximum(xlims())/2, (maximum(ylims())*1.8 + (j-1)*2), text(str1,16,:black,:center)  )])
	str2 = string(label_string[j], @sprintf(" total sim. time = %0.2f", t_e), " s");
	annotate!([(  maximum(xlims())/2, (maximum(ylims())*1.4 + (j-1)*2), text(str2,16,:black,:center)  )])
end
plot!(1:length(T_solve[1,2:end]),0.5*ones(length(T_solve[1,2:end]),1), w=4, leg=:true,label="real-time threshhold",leg=:right,size=(s,s))

ylims!((0,maximum(ylims())*2.1))
yaxis!("Optimization Time (s)")
xaxis!("Evaluation Number")

if !simulate savefig("tplot.png") end

return tp

end

#=
function tplot(t::Array{Float64,1},t_solve::Array{Float64,1},execution_horizon::Float64,simulate::Bool)

	temp = find(t_solve);  num=temp[end]; if (num < 10) num = 10 end
	tp = plot(t_solve[1:num],w=4,label="optimization times")
	plot!(1:num,execution_horizon*ones(num,1), w=4, leg=true,label="real-time threshhold",leg=:topright)
	t_total = sum(t_solve)
	t_e = t[end]
	yaxis!("Optimization Time (s)")
	xaxis!("Evaluation Number")
	str1 = string(@sprintf("Total Solve Time  = %0.2f", sum(t_solve)), " s");
	#str1 = "Total Solve Time (s) = $(t_total)[e.2]"
	annotate!([(num/2,maximum(t_solve)/1.5,text(str1,16,:red,:center))])
	str2 = string(@sprintf("Total Simulation Time = %0.2f", t[end]), " s");
	annotate!([(num/2,maximum(t_solve)/2.5,text(str2,16,:red,:center))])

 if !simulate savefig("tplot.png") end

 return tp
end
=#
