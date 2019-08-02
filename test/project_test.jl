using CommonLH.ProjectLH
using CommonLH

@testset "projectLH" begin
	test_header("ProjectLH")
    pName = "test";
    @test isdir(ProjectLH.project_dir(2018));
    proj = ProjectLH.Project(pName, pwd(), [pwd()]);
    show(proj);
    
    proj2 = ProjectLH.get_project(pName);
    @test proj2.name == pName;
    project_start(pName)
end
