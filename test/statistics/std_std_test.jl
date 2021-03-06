@testset "std_std" begin
	dbg = true;
	Random.seed!(123);
	nRep = 200;

	# Define samples
	nObsV = [100, 200, 500, 5000];
	nSamples = length(nObsV);
	# Std dev of Normal for each sample
	tgStdV = collect(Float64, range(1.0, 3.0, length = nSamples));
	trueStdStdV = zeros(Float64, nSamples);

	# Iterate over samples
	for i1 = 1 : nSamples
	  # Generate samples and compute std for each
	  stdV = zeros(nRep);
	  for iRep = 1 : nRep
		stdV[iRep] = std(Float64(tgStdV[i1]) .* randn(nObsV[i1]));
	  end
	  trueStdStdV[i1] = std(stdV);
	end

	# Check

	stdOutV = std_std(tgStdV, nObsV, dbg);

	diffV = stdOutV - trueStdStdV;
	if any(abs.(diffV) .> 1e-2)
	  println("Large deviations from target std std")
	  println(tgStdV)
	  println(stdOutV)
	  println(diffV)
	end

	@test all(abs.(diffV) .< 1e-2)
end

# ----------
