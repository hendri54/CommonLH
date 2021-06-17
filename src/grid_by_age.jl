"""
	$(SIGNATURES)

Stores a grid by age.
Paramterized by 
- V: type of value (e.g. Float64)
- T: no of periods (Integer)
"""
struct GridByAge{V, T}
    # Grid by age
    gridV :: Vector{Vector{V}}
end


"""
Constructor using no of grid points and ranges.
Grid starts with `k0`, followed by grids of length `nPointsV` in range `[kMinV, kMaxV]`.

# Arguments
- spacing
- intervalRatio: only matters for power spaced grid.
"""
function GridByAge(k0 :: V, nPointsV :: Vector{T2},
    kMinV :: AbstractVector{V}, kMaxV :: AbstractVector{V}; 
    spacing :: Symbol = :linear, intervalRatio = 1.1) where  {V, T2 <: Integer}

    @assert all(nPointsV .>= 2)
    @assert all(kMinV .< kMaxV)
    if spacing == :log
        @assert all(kMinV .> 0.000001)
    end

    T = length(kMinV) + 1;
    gridV = Vector{Vector{V}}(undef, T);
    gridV[1] = [k0];

    for t = 2 : T
        if spacing == :power
            gridV[t] = make_power_spaced_grid(kMinV[t-1], kMaxV[t-1], nPointsV[t-1], 
                intervalRatio);
        elseif spacing == :log
            gridV[t] = exp.(LinRange{V}(log(kMinV[t-1]), log(kMaxV[t-1]), nPointsV[t-1]));
    	elseif spacing == :linear
            gridV[t] = LinRange{V}(kMinV[t-1], kMaxV[t-1], nPointsV[t-1]);
        else
            error("Invalid spacing: $spacing")
		end
    end
   
    return GridByAge{V,T}(gridV)
end


function make_power_spaced_grid(kMin, kMax, nPoints, intervalRatio)
    g = PowerSpacedGrid(kMin, kMax, nPoints, intervalRatio);
    return CommonLH.grid(g)
end

# function make_linspaced_grid(kMin, kMax, nPoints, intervalRatio)
#     g = LinSpaced


## Validate grid properties
function validate(g :: GridByAge, nV :: Vector{T2}, kMinV :: Vector{Double},
    kMaxV :: Vector{Double})  where  T2 <: Integer

    T = length(nV);
    isValid =  (T == n_periods(g));
    for t = 1 : T
        gridV = grid_t(g, t);
        isValid = isValid  &&  (gridV[1] ≈ kMinV[t])  &&
            (gridV[end] ≈ kMaxV[t])  &&  (length(gridV) == nV[t])
    end
    return isValid
end


function make_test_grid(T :: Integer)
    nV = collect(3 .+ (1 : T));
    kMinV = collect(range(-2.0, -3.0, length = T));
    kMaxV = kMinV .+ 4.0;

    gridV = Vector{Vector{Double}}(undef, T);
    for t = 1 : T
        gridV[t] = LinRange{Double}(kMinV[t], kMaxV[t], nV[t]);
    end
    kg = GridByAge(gridV);

    @assert CollegeStrat.validate(kg, nV, kMinV, kMaxV)
    return kg
end



# ------------------  Retrieve

"""
	$(SIGNATURES)

Length of grid in periods.
"""
function n_periods(g :: GridByAge)
    return length(g.gridV)
end


"""
	$(SIGNATURES)

Return the date `t` grid.
"""
function grid_t(g :: GridByAge, t :: Integer)
    return g.gridV[t]
end


"""
	$(SIGNATURES)

Return points on the date `t` grid, selected by indices `idxV`.
"""
function grid_points(g :: GridByAge, t :: T1, idxV) where
    T1 <: Integer

    return @inbounds g.gridV[t][idxV]
end

grid_points(g :: GridByAge, t :: T1) where T1 <: Integer =
    g.gridV[t];


## Number of grid points at a t
function n_points(g :: GridByAge, t :: Integer)
    return length(g.gridV[t])
end


## Round to nearest grid point
function round_to_grid(g :: GridByAge, t :: Integer, inM :: Array{Double})
    return round_to_grid(inM,  g.gridV[t])
end

"Scalar input"
function round_to_grid(g :: GridByAge, t :: Integer, x :: Double)
    # Need to call function for array and return first element
    return round_to_grid([x], g.gridV[t])[1]
end


## ---------  Display

# Simple summary of the grid for each age
function show_grids(g :: GridByAge; io = stdout)
    for t = 1 : n_periods(g)
        show_grid(g, t; io = io);
    end
end

function show_grid(g :: GridByAge, t :: Integer; io = stdout)
    np = n_points(g, t);
    print(io,  "Grid for t=$t ($np points):  ");
    gridV = round.(grid_t(g, t), digits = 2);
    if np < 7
        println(io, gridV);
    else
        print(io, gridV[1 : 3]);
        print(io, " ... ");
        println(io, gridV[(np-2) : np]);
    end
end


## --------  Copied from MatrixLH

"""
round_to_grid()

Round a matrix to the nearest points on a grid
"""
function round_to_grid(xM :: Array{T}, gridV :: Vector{T}) where T <: AbstractFloat
    idxM = similar(xM, Int);
    for (i1, x) in enumerate(xM)
        iMin = findmin(abs.(gridV .- x));
        idxM[i1] = iMin[2];
    end
    return idxM
end



# ----------------