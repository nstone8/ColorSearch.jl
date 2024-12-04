module ColorSearch

using DataFrames, FileIO, CSVFiles, Colors, Plots

export closecolors, listcolors, showcolor

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
getcolorant(colorname)
```
Get the `Colorant` corresponding to `colorname`
"""
function getcolorant(colorname::String)
    color = lowercase(colorname)
    colorrow = filter(allcolors) do row
        row.name == color
    end
    @assert size(colorrow)[1] == 1 "color name not found"
    return colorrow.colorant[1]
end

"""
```julia
closecolors(colorname)
```
Sort the `color-names` dataset for colors closest to `colorname`
"""
function closecolors(color::String)
    target = getcolorant(color)
    distframe = transform(allcolors, :colorant => ByRow(function(c)
                                                       colordiff(target,c) |> abs
                                                        end) => :colordiff)
    select!(distframe,:name,:colordiff)
    sort!(distframe,:colordiff)
end

"""
```julia
listcolors()
```
Return a `DataFrame` containing all the colors in the dataset
"""
listcolors() = copy(allcolors)

"""
```julia
showcolor(colorname)
```
Display the color corresponding to `colorname`
"""
function showcolor(color::String)
    c = getcolorant(color)
    plot(Shape([0,0,1,1],[0,1,1,0]),
         fill=c,legend=false,axis=false,grid=false)
end

end # module ColorSearch
