module ColorSearch

using DataFrames, FileIO, CSVFiles, Colors

export closecolors

function loadcolors()
    datapath = joinpath(dirname(@__FILE__) |> dirname, "data","colornames.csv")
    dataset = load(datapath) |> DataFrame
    transform!(dataset,:hex => ByRow((x) -> parse(Colorant, x)) => :colorant)
    dataset[!,:name] = lowercase.(dataset.name)
    return dataset
end

allcolors = loadcolors()

"""
```julia
closecolors(colorname)
```
Sort the `color-names` dataset for colors closest to `colorname`
"""
function closecolors(color::String)
    colorrow = filter(allcolors) do row
        row.name == color
    end
    @assert size(colorrow)[1] == 1 "color name not found"
    target = colorrow.colorant[1]
    distframe = transform(allcolors, :colorant => ByRow(function(c)
                                                       colordiff(target,c) |> abs
                                                        end) => :colordiff)
    select!(distframe,:name,:colordiff)
    sort!(distframe,:colordiff)
end

end # module ColorSearch
