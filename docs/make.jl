Pkg.activate("./docs");

using Documenter, CommonLH, FilesLH

makedocs(
    modules = [CommonLH],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    checkdocs = :exports,
    sitename = "CommonLH.jl",
    pages = Any["index.md"]
)

pkgDir = rstrip(normpath(@__DIR__, ".."), '/');
@assert endswith(pkgDir, "CommonLH")
deploy_docs(pkgDir);

Pkg.activate(".");

# deploydocs(
#     repo = "github.com/hendri54/CommonLH.jl.git",
# )

# ----------------