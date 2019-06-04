---
layout: post
title: "Numerize me!"
date: 2019-01-01 00:00:00 +0000
categories: blog
mathjax: true
---

# Numerize me!

>This post is the first tentative post on programming with Julia language. The focus is not on programming, or coding, instead it is on the *mathematical modelling* that drastically leverage nowadays on computer resources.

A typical problem in *data science* is **identifying correlations**.

To find an example to understand the importance of pseudo-causality (correlation) we can use the case study *when it rains shops sell more*. Clearly you cannot control weather but at least by knowling the such a correlation you know how much to buy in rain seasons.
Sometimes variables are stored in the computer with a human readable approach, e.g. for weather conditions we can use the strings *rain* *sun* *cloudy*, while a more cryptic approach would be to use integer numbers such as 0 1 2. Strings are the best choice when dealing with data-frames with lots of variables since we do not have to memorize the meaning of integer numbers for different columns. However, computers cannot handle strings and for most commands require to have data-frames of numbers only. It is thus left to the user to adjust data to be handled by analysis functions.

In this blog post I'd like to show you how to replace a *strings column* with *numeric values* in a *Julia data-frame*.

Let's create a very simple, examplar example, data-frame to play with,

```julia
using DataFrames

df = DataFrame(weather=String[],selling=Float64[])
push!(df,["rain",100.])
push!(df,["rain",200.])
push!(df,["sun",300.])
```

The created data-frame looks like

index | `weather` | `selling` |
--- | --- | --- |
1 | rain | 100 |
2 | rain | 200 |
3 | sun | 300 |

this data-frame contains only two columns `weather` and `selling`, the first column is a string-column that cannot be accepted for example by the Julia **corrplot** stats plot.
We want simply to substitute rain=1 and sun=2, while this is a simple operation with the simple data-frame created the operation become more cumbersome when playing with big-data.
In order to solve this code requirements we proceed as follow,

step | `action`|
 --- | --- |
1    | list the values that appear in column `weather` |
->   | listing=[rain,sun], cardinality=2 |
2    | assign 1 to rain, 2 to sun |
->   | creating a vector **v** of integer values from 1 to the length of the vector [rain,sun], v=[1,2] |
3    | loop over each `weather` column entry, for each value find the corresponding position in listing and substitute the listing argument position value |
->   | v=[1,1,2] |
4    | include the new vector to the data-frame, or create a new data-frame with the new numeric column |

The above procedure is summarised in these few Julia lines,

```julia
listing = unique(df[:weather])              # listing = ["rain","sun"]
value   = collect(1:length(listing))        # value   = [1,2]
v       = Float64[]                         # v       = [ ]
for element in df[:weather]
    p=findall(x -> x==element,listing)      # sun  > p = 2
    append!(v,value[p])                     # value[p] = 2
    println(p,element)                      # printing---
end
df[:weather_num] = v                        # add the column to data-frame
```

The new dataframe now looks like,

index | `weather` | `selling` | `weather_num` | 
--- | --- | --- | --- | 
1 | rain | 100 | 1 | 
2 | rain | 200 | 1 | 
3 | sun | 300 | 2 | 

With the new numerical column we can use the corrplot command,

```julia
using StatPlots
@df correlation_plot = df corrplot([:weather_num :selling], grid = false)
cd("C:\\Users\\a.marocchino\\Documents\\codes\\github.io\\_img\\001_dataframe_string_removal")
savefig(".\\001_dataframe_string_removal_01.png")
```

that for the given data-set is pretty pretty meaningless
![Julia corrplot](/_img/001_dataframe_string_removal/001_dataframe_string_removal_01.png)

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

