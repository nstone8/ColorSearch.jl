module ColorSearch

using DataFrames, FileIO, CSVFiles, Colors, Plots, Scratch
import Downloads

export closecolors, listcolors, showcolor, updatecolors!

datadir = @get_scratch!("colordata")
datafile = joinpath(datadir,"colors.csv")

function downloadcolors()
    Downloads.download("https://raw.githubusercontent.com/meodai/color-names/refs/heads/master/dist/colornames.csv",
                       datafile)
end

function loadcolors()
    if !isfile(datafile)
        downloadcolors()
    end
    dataset = load(datafile) |> DataFrame
    transform!(dataset,:hex => ByRow((x) -> parse(Colorant, x)) => :colorant)
    dataset[!,:name] = lowercase.(dataset.name)
    return dataset
end

allcolors::DataFrame = loadcolors()

"""
```julia
updatecolors!()
```
Update the list of color names from the `github.com/meodai/color-names` repository
"""
function updatecolors!()
    #get the new colors
    downloadcolors()
    #load them
    newcolors = loadcolors()
    #replace our global valuse
    global allcolors = newcolors
    return nothing
end

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
