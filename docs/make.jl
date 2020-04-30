using Documenter, CommonLH

makedocs(
    modules = [CommonLH],
    format = :html,
    checkdocs = :exports,
    sitename = "CommonLH.jl",
    pages = Any["index.md"]
)

# deploydocs(
#     repo = "github.com/hendri54/CommonLH.jl.git",
# )

# ----------------