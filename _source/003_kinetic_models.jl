#md ---
#md layout: post
#md title: "kinetic models part 3"
#md date: 2019-11-01 00:00:00 +0000
#md categories: blog
#md mathjax: true
#md ---

# # kinetic models part 3

# >In this post I'll introduce **an intuitive approach to kinetic models** and how they can be used for interaction problems.

# >Suppose you want to study how a virus is spreading. When two people come in contact the virus infect the non sick person. We can use a kinetic-based maths model to track: how many sick individuals we have, where are they localised and eventually the stage of the sickness (in other words: for how long they had been infected).

# >While statistics tell you that there will be a Martin Luther King every 100 years, kinetic modelling is trying to tell you who's gonna be.

# I believe this is not the place, nor yet the time, to use a full maths formalism to explain kinetic modelling. Instead, I prefer to walk you through the code so you can build
# the model in your mind via a practical example.
# To simplify the problem, avoind complex scenarios, we assume all people are in a room and their motion is limited therein. We also assume we have an initial stage where some people are sick. We can assume they contracted the virus outside and
# are bringing the infection in the room.

# Here I definie the main variable (with a *mutable struct*):
# * dt             = evolving timestep
# * ρ              = collision-distance, distance below which two individuals interact - in other words the virus is passed over
# * total_infected = a total infected counter
# * people         = the population. People is a tensor with 4 rows: (**x** position on the plane, **y** position on the plane, **flag** that identify if the person is infected on not, **stage** of infection if infected)
using Plots
mutable struct boltzmann
    dt; ρ; total_infected; people;
end

# We initialize the population
function initialize_population(n_people)
    x, y, flag, stage = rand(n_people), rand(n_people), zeros(n_people), ones(n_people)
    people = zeros(n_people,4)
    flag[1]=1
    [people[i,:]=[x[i],y[i],flag[i],stage[i]] for i=1:n_people]
    return people
end

# This is where the people move. Given a position, they are asked to step forward. Here, for simplicity, we assumed that each person moves in accordance with a normal distribution, in other words he/she can pick any angle and just make a step in that direction.
# It is rather obvious to assume that we are dealing with persons, they are probably moving straight until an obstacle stop them. However, that said it includes a concept of *objective*: I am going somewhere to do something. Since we are using, again for simplicity, a square room, such a concept is wider than the present scope.
# We include also some coundary conditions, people cannnot exit the room, they are bounced back in.
function advance(b::boltzmann)
    b.people[:,1]= b.people[:,1] + randn(size(b.people)[1]) * b.dt
    b.people[:,2]= b.people[:,2] + randn(size(b.people)[1]) * b.dt
    b.people[b.people[:,1] .< 0., 1] .*= -1
    b.people[b.people[:,2] .< 0., 2] .*= -1
    b.people[b.people[:,1] .> 1., 1]  .= 1
    b.people[b.people[:,2] .> 1., 2]  .= 1
    # b.people[b.people[:,1] .> 1, 1] .= 1-(b.people[b.people[:,1] .> 1, 1]-1)
end

# When two people are very close apart, the infection spreads. The distance at which the virus spread is ρ.
function infect(b::boltzmann)
    #loop only on infected individuals to speed up calculations
    b.people[b.people[:,3].==1,4] .+= 1
    originally_infected = b.people[b.people[:,3].==1,:]
    not_infected        = b.people[b.people[:,3].!=1,:]
    for idx = 1:size(originally_infected)[1]
        for jdx = 1:size(not_infected)[1]
            d = sqrt( (originally_infected[idx,1]-not_infected[jdx,1])^2 + (originally_infected[idx,2]-not_infected[jdx,2])^2 )
            if d < b.ρ
                not_infected[jdx,3]=1
            end
        end
    end
    b.people[1:size(originally_infected)[1],:] = originally_infected
    b.people[size(originally_infected)[1]+1:end,:] = not_infected
end

# We are also considering healing: after a person has been ill for a given *time*, he/she recovers.
function heal(b::boltzmann, time)
    #after a person has been ill for a while he/she heals
    identify = (b.people[:,4] .> time)
    b.people[identify,3] .= 0
    b.people[identify,4] .= 0
end


function count_infect(b::boltzmann)
    push!(b.total_infected, sum(b.people[:,3]) )
end

function display(b::boltzmann)
    rectangle(x, y, w, h) = Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])

    p1 = plot(rectangle(0,0,1,1), fill="rgb(22,55,66)", xlim=(-.2,1.2), ylim=(-.2,1.2), background_color=RGB(0.2,0.2,0.2), label="room", xaxis=false, yaxis=false)
    p1 = scatter!( b.people[ findall(x->x==0., b.people[:,3]) ,1], b.people[ findall(x->x==0., b.people[:,3]) ,2], color="rgb(34,31,26)", shape=:circle, ms=4, alpha=1.0, label="ok")
    p1 = scatter!( b.people[ findall(x->x==1., b.people[:,3]) ,1], b.people[ findall(x->x==1., b.people[:,3]) ,2], color="rgb(255,114,217)", markerstrokecolor="rgb(240,229,92)", shape=:square, ms=3 .+ 0.02.*b.people[ findall(x->x==1., b.people[:,3]) ,4], alpha=1.0, label="infected")
    p1 = xlims!(0,1)
    p1 = ylims!(0,1)

    plot(p1)
end

function display2(b1::boltzmann,b2::boltzmann)
    rectangle(x, y, w, h) = Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])

    p1 = plot(rectangle(0,0,1,1), fill="rgb(22,55,66)", xlim=(-.2,1.2), ylim=(-.2,1.2), background_color=RGB(0.2,0.2,0.2), xaxis=false, yaxis=false, dpi=500)
    p1 = scatter!( b1.people[ findall(x->x==0., b1.people[:,3]) ,1], b1.people[ findall(x->x==0., b1.people[:,3]) ,2], color="rgb(34,31,26)", shape=:circle, ms=4, alpha=1.0)
    p1 = scatter!( b1.people[ findall(x->x==1., b1.people[:,3]) ,1], b1.people[ findall(x->x==1., b1.people[:,3]) ,2], color="rgb(255,114,217)", markerstrokecolor="rgb(240,229,92)", shape=:square, ms=3 .+ 0.02.*b1.people[ findall(x->x==1., b1.people[:,3]) ,4], alpha=1.0)
    p1 = xlims!(0,1)
    p1 = ylims!(0,1)

    p2 = plot(rectangle(0,0,1,1), fill="rgb(22,55,66)", xlim=(-.2,1.2), ylim=(-.2,1.2), background_color=RGB(0.2,0.2,0.2), xaxis=false, yaxis=false, dpi=500)
    p2 = scatter!( b2.people[ findall(x->x==0., b2.people[:,3]) ,1], b2.people[ findall(x->x==0., b2.people[:,3]) ,2], color="rgb(34,31,26)", shape=:circle, ms=4, alpha=1.0)
    p2 = scatter!( b2.people[ findall(x->x==1., b2.people[:,3]) ,1], b2.people[ findall(x->x==1., b2.people[:,3]) ,2], color="rgb(255,114,217)", markerstrokecolor="rgb(240,229,92)", shape=:square, ms=3 .+ 0.02.*b2.people[ findall(x->x==1., b2.people[:,3]) ,4], alpha=1.0)
    p2 = xlims!(0,1)
    p2 = ylims!(0,1)

    p3 = plot(b1.total_infected, dpi=500)
    p3 = xlims!(0,200)
    p3 = ylims!(0,30)
    p4 = plot(b2.total_infected, dpi=500)
    p4 = xlims!(0,200)
    p4 = ylims!(0,300)

    plot(p1,p2,p3,p4, legend=false, layout = grid(2,2,heights=[0.7,0.3,0.7,0.3]) )
end


small = boltzmann((dt = 0.01, ρ = 0.05, total_infected=ones(1), people=initialize_population(30))...)
large = boltzmann((dt = 0.01, ρ = 0.05, total_infected=ones(1), people=initialize_population(300))...)

@mp4 for i=1:200
    advance(small), advance(large)
    infect(small), infect(large)
    heal(small,100), heal(large,2)
    count_infect(small), count_infect(large)
    display2(small,large)
end every 1



########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
##############################
###################################









######-----------------------
using Plots
# define the Lorenz attractor
mutable struct Lorenz
    dt; σ; ρ; β; x; y; z
end

function step!(l::Lorenz)
    dx = l.σ*(l.y - l.x)       ; l.x += l.dt * dx
    dy = l.x*(l.ρ - l.z) - l.y ; l.y += l.dt * dy
    dz = l.x*l.y - l.β*l.z     ; l.z += l.dt * dz
end

attractor = Lorenz((dt = 0.02, σ = 10., ρ = 28., β = 8//3, x = 1., y = 1., z = 1.)...)


# initialize a 3D plot with 1 empty series
plt = plot3d(1, xlim=(-25,25), ylim=(-25,25), zlim=(0,50),
                title = "Lorenz Attractor", marker = 2)

# build an animated gif by pushing new points to the plot, saving every 10th frame
@gif for i=1:1500
    step!(attractor)
    push!(plt, attractor.x, attractor.y, attractor.z)
end every 10
######-----------------------






x = zeros(0)
append!( x, rand(10) )


    for idx = 1:size(people)[1]
        if people[idx,3] > 1.
            originally_infected.append(people[idx,:])
        end
    end




        people[idx,:]= [ people[idx,1]+rand()*delta_movement, people[idx,2]+rand()*delta_movement, people[idx,3] ]
    end
    return people
end

delta_movement = 1e-4
move_(people,delta_movement)


delta_movement = 1e-4
function move_(people)
    for idx = 1:size(people)[1]
        people[idx,:]= [ people[idx,1]+rand()*delta_movement, people[idx,2]+rand()*delta_movement, people[idx,3] ]
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
# Despite a person trajectory depends on what the person is doing, the person is going to a colleague or to the printer, so shoud have a given trajectory depending on the schope we simplify by assuming that
# a person new position only depends on the present position and his advancment is normal distributed both in *x* and *y*. This assumption, goes, alongside with the assumption (for the moment) that points are volumeless and do not hit one another.
# These simplifications are operated to focus our attention on the *collision operator*, when two points are close enought the two people interact and if one of the persons is aware of the gossip shares it.
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

# Let's adavance the system and let's check its evolution.
for time = 1:10
    move_(people)
    collision_(people)
end
plot_(people)
savefig(".\\_img\\002_kinetic_models_in_real_life\\002_kinetic_models_in_real_life_02.svg")
# ![time evolution](IMAGEFOLDER/002_kinetic_models_in_real_life_02.svg)


# # A brief disquisition on the underlying maths
# What I personally like about kinetic models is the possibility to explain them in simple words with down to heath example.
# I reckon the gossip example is rather simple, eventually funny, and intuitively simple. The underlying math follow a different formalism known as Bolzmann's statistics.
# A person, that we have represented with a circle or eventually a square, can be modelled mathematically as a Dirac Delta centered where the person is,
# ```math
# p(x_i) = \delta(x-x_i)  \:\:  :: i=1,...,N
# ```
# since each person p(x_i) is also moving is also characterised by a velocity, that using the same notation,
# ```math
# p(x_i) = \delta(x-x_i) \: \delta(v-v_i)  \:\:   :: i=1,...,N
# ```
# and to describe the entire population we sum all over the people,
# ```math
# P = \Sum_{i=0}_N \delta(x-x_i) \delta(v-v_i)
# ```
# The complexity of the problem scales linearly with the number of people *N*, and analytically we quickly encount a calculation obstaacle whether we wish to solve the system evolution by hand.
# To be able to treat analytically such a problem it is convenient to treat the ansemble behaviour of *P*, ansembled over infinitesimal volumes and infinitesimal time-intervals.


# -----------------
cd("/Users/alberto/codes/albz.github.io/_source")                                                                         #src
using Literate                                                                                                            #src
# preprocess for notebooks                                                                                                #src
function setimagefolder(content)                                                                                          #src
    content = replace(content, "IMAGEFOLDER" => "$IMAGEFOLDER")                                                           #src
    return content                                                                                                        #src
end                                                                                                                       #src
# for Jupyter notebook, put images in subfolder                                                                           #src
IMAGEFOLDER = "_img/003_kinetic_models"                                                                                   #src
Literate.notebook("_source/003_kinetic_models.jl", "notebooks", preprocess = setimagefolder)                              #src
# # for Markdown/Jekyll notebook, put images in "/images"                                                                 #src
# IMAGEFOLDER = "/_img/002_kinetic_models_in_real_life"                                                                   #src
Literate.markdown("_source/003_kinetic_models.jl", ".", name="_posts/0023_kinetic_models",                                #src
 preprocess = setimagefolder,                                                                                             #src
 documenter=false)                                                                                                        #src
