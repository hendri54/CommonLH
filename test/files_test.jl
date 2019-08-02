using Test

using CommonLH.FilesLH

struct saveS
    x1
    x2
    x3
end

function file_path()
    return joinpath(testDir, "load_save_test.jld")
end

@testset "FilesLH" begin
    xS = saveS(1.23, "abc", [1.2 2.3; 3.4 4.5]);

    fPath = file_path();

    FilesLH.save(fPath, xS);

    yS = FilesLH.load(fPath);

    @test isequal(xS.x1, yS.x1)
    @test isequal(xS.x2, yS.x2)
end

# -------------
