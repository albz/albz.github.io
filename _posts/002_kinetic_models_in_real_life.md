```julia
---
layout: post
title: "kinetic models in real life"
date: 2019-01-10 00:00:00 +0000
categories: blog
mathjax: true
---
```

# kinetic models in real life

>In this post I'll introduce **computer based kinetic models** and how to apply them to real-life problems.

>To give an intuitive hint about *kinetic models* and their applications we might think about gossip spreading. There are more relevant examples, e.g. the epidemiologic study of virus diffusion, but for the moment I'd rather keep a general and *nice* example. Classial statistics woulg give an overall interpretation suggesting that 1% of the people are gossip aware. Classical statistics, at least in its simpler form, cannot identify who knows the gossip and who does not know. On the contrary, kinetic models try to fill this gap by identifying, exactly, who is gossip aware.

>While statistics tell you that there will be a Martin Luther King every 100 years, kinetic modelling is trying to tell you who's gonna be.

Instead of giving a formal mathematical definition, we might want to uvail this concept by constructing together an example. Instead of referring to some epidemiologic model, e.g. a hillness speading, despite pertinet sounds less dramatic and sillier to image how a given gossip can spread from person to person.
Intuitively what we are planning to do is rather simple. One person, in a room, knows a gossip and meeting with a colleague share such a piece of gossip. Now te two people moving in room will eventually meet with other two colleagues and the gossip will be shared among four people. And clearly, so on.
The room example is intuitive enought and allow for smooth programming without many technicalities, still it misses the most of the model: the gossip being broght outside of the room to a pub, to a different building, to people above some age since the too youngs cannot be interested, and so on.
It is rather important that while the kinetic effects are important, we still want to measure some fluid (or aggregated) quantities, such as the total number of people aware of the gossip and
the radius of influence of the gossip. How far is the gossip spreading? These models can answer this question.

let's place 100 people in a room,

```julia
using Plots
n_people=1000
x, y, flag=rand(n_people), rand(n_people), zeros(n_people)
people = zeros(n_people,3)
flag[1]=1
[people[i,:]=[x[i],y[i],flag[i]] for i=1:n_people]
```

and gather the information in a matrix *people* with 3 columns. The first column contains the person position along the *x* direction, the second along the *y* direction and the third a flag that track if the person is a ware of the gossip *flag=1* or not *flag=0*.
We want to set up this function to plot people position,

```julia
function plot_(people)
    rectangle(x, y, w, h) = Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])
    plot(rectangle(0,0,1,1), fill="white", xlim=(-.2,1.2), ylim=(-.2,1.2), background_color=RGB(0.2,0.2,0.2), label="room")
    scatter!( people[ findall(x->x==0., people[:,3]) ,1], people[ findall(x->x==0., people[:,3]) ,2], color="rgb(234, 153, 153)", shape=:circle, ms=8, label="not aware")
    scatter!( people[ findall(x->x==1., people[:,3]) ,1], people[ findall(x->x==1., people[:,3]) ,2], color="rgb(119, 221, 119)", shape=:square, ms=8, label="aware")
end
plot_(people)
savefig(".\\002_kinetic_models_in_real_life_01.svg")
```

![dots and squares](/_img/002_kinetic_models_in_real_life/002_kinetic_models_in_real_life_01.svg)

We plot with a circle a person that is not aware of the gossip and with a *square* the persons that are aware.

We now create a function *move_()* that advance people position.

```julia
function move_(people)
    for idx = 1:size(people)[1]
        people[idx,:]= [ people[idx,1]+rand()*0.01, people[idx,2]+rand()*0.01, people[idx,3] ]
        if people[idx,1] > 1.
            people[idx,1] = 1-people[idx,1]
        end
        if people[idx,1] < 0.
            people[idx,1] = -people[idx,1]
        end
        if people[idx,2] > 1.
            people[idx,2] = 1-people[idx,2]
        end
        if people[idx,2] < 0.
            people[idx,2] = -people[idx,2]
        end
    end
    return people
end
```

Despite a person trajectory depends on what the person is doing, the person is going to a colleague or to the printer, so shoud have a given trajectory depending on the schope we simplify by assuming that
a person new position only depends on the present position and his advancment is normal distributed both in *x* and *y*. This assumption, goes, alongside with the assumption (for the moment) that points are volumeless and do not hit one another.
These simplifications are operated to focus our attention on the *collision operator*, when two points are close enought the two people interact and if one of the persons is aware of the gossip shares it.

```julia
function collision_(people)
    new_flag = zeros( size(people)[1] )
    for idx = 1:size(people)[1]
        if people[idx,3] == 1.
            distances = ( (people[:,1].-people[idx,1]).^2 .+ (people[:,2].-people[idx,2]).^2 ).^0.5
            distances = (distances .< 0.05)
            new_flag[distances] .= 1
        end
    end
    people[:,3] = new_flag
    return people
end
```

Let's adavance the system and let's check its evolution.

```julia
for time = 1:10
    move_(people)
    collision_(people)
end
plot_(people)
savefig(".\\002_kinetic_models_in_real_life_02.svg")
```
![dots and squares evolved](/_img/002_kinetic_models_in_real_life/002_kinetic_models_in_real_life_02.svg)


# A brief disquisition on the underlying math
What I personally like about kinetic models is the possibility to explain them in simple words with down to heath example.
I reckon the gossip example is rather simple, eventually funny, and intuitively simple. The underlying math follow a different formalism known as Bolzmann's statistics.
A person, that we have represented with a circle or eventually a square, can be modelled mathematically as a Dirac Delta centered where the person is,
```math
p(x_i) = \delta(x-x_i) , i=1,...,N
```
Since each person p(x_i) has also a velocity, he/she moves, we can also add a velocity attribute with the same appraoch,
```math
p(x_i) = \delta(x-x_i) \delta(v-v_i) , i=1,...,N
```

-----------------

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*
