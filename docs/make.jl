using Documenter, CommonLH

makedocs(
    modules = [CommonLH],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    checkdocs = :exports,
    sitename = "CommonLH.jl",
    pages = Any["index.md"]
)

# deploydocs(
#     repo = "github.com/hendri54/CommonLH.jl.git",
# )

# ----------------