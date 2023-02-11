#=
Created on 31/12/2022 16:30:00
Last update: 01/01/2023

@author: Michiel Stock
michielfmstock@gmail.com

Perfect loop / Infinite loop / endless GIFs
=#

using DrWatson

@quickactivate "Genuary2023"

using Luxor, Colors, Random

Random.seed!(43)

col1 = "#57ba94"
col2 = "#7b8ce0"
col3 = "#ffc800"

R = 20
n = 12 
m = 5
w = 2R * cos(π/6)
h = 1.5R


function tricolhex(pos, R, c1, c2, c3)
    pg = ngon(pos, R, 6, π/6, vertices=true)
    top = vcat(pos, pg[[3, 4, 5]])
    left = vcat(pos, pg[[1, 2, 3]])
    right = vcat(pos, pg[[5, 6, 1]])
    sethue(c1)
    poly(top, action=:fill, close=true,)
    sethue(c2)
    poly(right, action=:fill, close=true)
    sethue(c3)
    poly(left, action=:fill, close=true)
end

orients = Dict((i,j)=>rand((0, 1, 2)) for i in -n:n for j in -n:n)

function drawtiles(orients)
    for i in -n:n
        for j in -n:n
            pgon= hextile(HexagonCubic(i, j, -i -j, 1.5R))
            pos = (pgon[1] + pgon[4]) / 3
            s = orients[(i,j)]
            tricolhex(pos, R, circshift([col1, col2, col3], s)...)
        end
    end
end

# test tiling

Drawing(500, 500, plotsdir("1_tiling.svg"))
origin()
drawtiles(orients)
finish()
preview()

# movie
 
inds = [(i,j) for i in -n:n for j in -n:n for _ in 1:3] |> shuffle!

orients = Dict((i,j)=>0 for i in -n:n for j in -n:n)

n_frames = length(inds) ÷ 20

function frame(scene::Scene, framenumber::Int64, n_change=20)
    norm_framenumber = rescale(framenumber,
        scene.framerange.start,
        scene.framerange.stop,
        0, 1)
    for _ in 1:n_change
        isempty(inds) && break
        i,j = pop!(inds)
        δ = isodd(i+j) ? -1 : 1
        orients[(i,j)] += δ
    end
    drawtiles(orients)
end

mymovie = Movie(500, 500, "tiles shuffling", 1:n_frames)

animate(mymovie,
        [
            Scene(mymovie, frame, 1:n_frames)
        ],
    creategif=true, framerate=10,
    pathname=plotsdir("1_tilinganim.gif"))