# Exports

export Shape, PostOpObj, create, combine, unpack, repack, repack!

abstract type Shape end

mutable struct PostOpObj 
    objs::Vector{Any}
    operations::Array{Function}
    function PostOpObj(obj, func) 
        if ~isa(obj, Vector)
            obj = [obj]
        end
        if ~isa(func, Vector)
                func = [func]
        end
        new(obj, func)
    end    
end

function Base.copy(x::T) where T<:Union{Shape, PostOpObj}
    T(copy.([getfield(x, fn) for fn in fieldnames(T)])...)
end



"""
    create(shape::T; resolution=nothing, rand_=0.0, type::Int64=1) where T <: Shape

Abstact function for creating **Shape** objects.

## Returns
    - X : Initial reference position 
    - V : Initial velocity 
    - Y : Initial position 
    - volume : Volume per particle point 
    - type: Type of particle point

"""
function create(shape::T; resolution=nothing, rand_=0.0, type::Int64=1) where T <: Shape
    error("Not implemented for type **$(typeof(shape))** yet.")
end 

function mycat(a, b)
    if length(size(a))==1
        return vcat(a, b)
    else
        return hcat(a, b)
    end
end

function create(pobj::PostOpObj, args...; kwargs...)
    temp = nothing
    out = nothing
    for obj in pobj.objs
        temp = create(obj, args...; kwargs...)
        if isa(out, Nothing)
            out = temp
        else
            out = mycat.(out, temp)
        end
    end
    for func in pobj.operations
        out = func(out)
    end
    return out
end

function combine(obj1::T1, obj2::T2) where {T1<:Union{Shape, PostOpObj}, T2<:Union{Shape, PostOpObj}}
    PostOpObj([obj1, obj2], []) 
end


function unpack(d::Dict)
    return d[:x], d[:v], d[:y], d[:volume], d[:type]
end

function repack(args...; keys_ = (:x, :v, :y, :volume, :type))
    d = Dict()
    for i in 1:5
        d[keys_[i]] = args[i]
    end
    d
end

function repack!(d::Dict, keys_, vals)
    if length(keys_)==length(vals)
        for i in 1:length(vals)
            d[keys_[i]] = vals[i]
        end
    else
        error("Lengths are not same.")
    end
    d
end


include("./cuboid.jl")
include("./sphere.jl")
include("./disk.jl")
include("./cylinder.jl")
include("./cone.jl")


