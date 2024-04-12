using PolyhedralOmega
using Documenter

DocMeta.setdocmeta!(PolyhedralOmega, :DocTestSetup, :(using PolyhedralOmega); recursive=true)

makedocs(;
    modules=[PolyhedralOmega],
    authors="Alcyon Lab",
    repo="https://github.com/alcyon-lab/PolyhedralOmega.jl/blob/{commit}{path}#{line}",
    sitename="PolyhedralOmega.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
