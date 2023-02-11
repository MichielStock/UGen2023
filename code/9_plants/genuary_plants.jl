using Pkg
Pkg.activate(".")

using Plots

import Unicode.isuppercase, Unicode.islowercase

function isuppercase(c::String)
    return "A" <= c <= "Z"
end

function islowercase(c::String)
    return "a" <= c <= "z"
end

function rewrite_string(word::Matrix{Any}, grammar::Vector{Tuple{String, Matrix{Any}, Function}}; iters::Integer = 1)
    for _ in 1:iters
        new_word = [word[i:i, :] for i in 1:size(word)[1]] # note: word[i, :] returns a vector while word[i:i, :] returns a matrix
        for rules in grammar
            letters = join(word[:, 1])
            params = word[:, 2]
            match_idxs = eachmatch(Regex("\\Q$(rules[1])\\E"), letters) |> collect .|> x -> getfield(x, :offset)
            valid_condition_idxs = rules[3].(params[match_idxs])
            match_idxs = match_idxs[valid_condition_idxs]

            rules_chosen_idx = [findfirst(rand() .<= cumsum(rules[2][:, 1])) for _ in eachindex(match_idxs)]
            rules_chosen = rules[2][:, 2][rules_chosen_idx]

            new_word[match_idxs] .= [rules_chosen[match_nr](params[match_idxs[match_nr]]) for match_nr in eachindex(match_idxs)]
        end
        word = reduce(vcat, new_word)
    end
    return word
end

function visualize_plants(words::Vector{Matrix{Any}}, x0s::Vector{<:Real}, y0s::Vector{<:Real}; alpha0::Real = 0, length::Real = 1, width = 1::Real, delta::Real = pi/2,
    xlims = (-2, 2), ylims = (0, 3), ground_height = 1, plant_color = :green, bg_color = :blue, ground_color = :yellow, opacity::Real = 1, size::Tuple = (1200, 900))
    
    fig = plot(background_color = bg_color, xlims = xlims, ylims = ylims, legend = false, ticks = false, axis = false, aspect_ratio = :equal, margins = 0Plots.mm, borders = false, size = size)
    plot!(Shape([xlims[1], xlims[2], xlims[2], xlims[1]], [ylims[1], ylims[1], ylims[1]+ground_height, ylims[1]+ground_height]), color = ground_color, linecolor = ground_color)

    for (word, x0, y0) in zip(words, x0s, y0s)
        x, y = x0, y0
        x_prev, y_prev = x0, y0
        alpha = deepcopy(alpha0)

        memory_stack = []

        for (letter, param) in eachrow(word)
            x_prev, y_prev = x, y
            if isuppercase(letter) # Move forward and add new point to those to draw
                x += get(param, "length", length) * cos(alpha)
                y += get(param, "length", length) * sin(alpha)
                plot!([x, x_prev], [y, y_prev], width = get(param, "width", width), color = get(param, "color", plant_color), alpha = get(param, "opacity", opacity))
            elseif islowercase(letter) # Move forward but don't draw a line, thus breaking the current one
                x += get(param, "length", length) * cos(alpha)
                y += get(param, "length", length) * sin(alpha)
            elseif letter == "+"
                alpha += get(param, "delta", delta)
            elseif letter == "-"
                alpha -= get(param, "delta", delta)
            elseif letter == "["
                push!(memory_stack, (x, y, alpha))
            elseif letter == "]"
                x, y, alpha = pop!(memory_stack)
            end
        end
    end

    return fig
end

function animate_plants(words::Vector{Matrix{Any}}, grammars, x0s::Vector{<:Real}, y0s::Vector{<:Real}; iters::Integer = 1, alpha::Real = 0, 
    length::Real = 1, width = 1::Real, delta::Real = pi/2, xlims = (-2, 2), ylims = (0, 3), ground_height = 1,
    plant_color = :green, bg_color = :blue, ground_color = :yellow, opacity::Real = 1)

    anim = @animate for iter in 1:iters
        visualize_plants(words, x0s, y0s, alpha0 = alpha, length = length, width = width, delta = delta, xlims = xlims, ylims = ylims,
        ground_height = ground_height, plant_color = plant_color, bg_color = bg_color, ground_color = ground_color, opacity = opacity)
        [words[i] = rewrite_string(words[i], grammars[i], iters = 1) for i in eachindex(words)]
        print("Iteration $(iter) done!\n")
    end
    return anim
end

## Shared variables

n = 60
young_w_frac = 0.7
young_l_frac = 0.6
plantcol = RGB(([190, 227, 123]./255)...)
plantcol_old = RGB(([190, 190, 150]./255)...)
plantcol_mixingratio = 0.01
flowercol = RGB(([234, 103, 71]./255)...)
bgcol = RGB(([186, 246, 225]./255)...)
groundcol = RGB(([200, 235, 140]./255)...)
alpha = pi/2
ground_height = 0.5

## Main plant

len = 1.1
width = 6
width_increase = 0.01
delta1 = 60/180*pi

word1 = [
    "Y" Dict("length" => len, "width" => width, "age" => 1, "color" => plantcol);
]

flower_delta = 15/180 * pi

grammar1 = [
    (
        "Y", 
        [
            1.0 prev -> [
                "+" Dict("delta" => 0);
                "A" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"]);
                "[" Dict();
                "+" Dict("delta" => delta1, "age" => prev["age"] + 1);
                "Y" Dict("length" => young_l_frac * prev["length"], "width" => young_w_frac * prev["width"], "age" => prev["age"] + 1, "color" => plantcol);
                "]" Dict();
                "[" Dict();
                "-" Dict("delta" => delta1, "age" => prev["age"] + 1);
                "Y" Dict("length" => young_l_frac * prev["length"], "width" => young_w_frac * prev["width"], "age" => prev["age"] + 1, "color" => plantcol);
                "]" Dict();
                "Y" Dict("length" => young_l_frac * prev["length"], "width" => young_w_frac * prev["width"], "age" => prev["age"] + 1, "color" => plantcol)
            ]
        ],
        prev -> prev["age"] < 5
    ), (
        "A",
        [
            1.0 prev -> [
                "A" Dict("length" => prev["length"], "width" => (1 + width_increase) * prev["width"], "color" => plantcol_mixingratio * plantcol_old + (1-plantcol_mixingratio) * prev["color"])
            ]
        ],
        prev -> true
    ), (
        "Y", 
        [
            0.9 prev -> [
                "Y" Dict("length" => prev["length"], "width" => prev["width"], "age" => prev["age"] + 1, "color" => plantcol)
            ];
            0.02 prev -> [
                "A" Dict("length" => prev["length"], "width" => prev["width"], "age" => prev["age"] + 1, "color" => plantcol)
            ];
            0.03 prev -> [
                "+" Dict("delta" => 0);
                "A" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"]);
                "[" Dict();
                "+" Dict("delta" => delta1, "age" => prev["age"] + 1);
                "Y" Dict("length" => young_l_frac * prev["length"], "width" => young_w_frac * prev["width"], "age" => prev["age"] + 1, "color" => plantcol);
                "]" Dict();
                "[" Dict();
                "-" Dict("delta" => delta1, "age" => prev["age"] + 1);
                "Y" Dict("length" => young_l_frac * prev["length"], "width" => young_w_frac * prev["width"], "age" => prev["age"] + 1, "color" => plantcol);
                "]" Dict();
                "Y" Dict("length" => young_l_frac * prev["length"], "width" => young_w_frac * prev["width"], "age" => prev["age"] + 1, "color" => plantcol)
            ]
            0.05 prev -> [
                "A" Dict("length" => prev["length"], "width" => prev["width"], "color" => plantcol);
                "P" Dict("length" => 0.05*prev["length"], "width" => 0.5*prev["width"], "color" => flowercol, "age" => 1)
            ]
        ],
        prev -> prev["age"] >= 5
    ), (
        "P", 
        [
            1.0 prev -> [
                "X" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1); 
                "Q" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1);
                "Z" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1);
                "P" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1)
            ]
        ],
        prev -> prev["age"] <= 10
    ), ( 
        "X",
        [
            1.0 prev -> [
                repeat(["F" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1)], 4); 
                repeat(["+" Dict("delta" => flower_delta)], 2);
                repeat(["F" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1)], 4); 
                repeat(["+" Dict("delta" => flower_delta)], 2);
                repeat(["F" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1)], 2); 
                repeat(["+" Dict("delta" => flower_delta)], 2);
                repeat(["F" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1)], 2); 
                repeat(["+" Dict("delta" => flower_delta)], 2);
                repeat(["F" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1)], 4); 
                repeat(["+" Dict("delta" => flower_delta)], 2);
                repeat(["F" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1)], 1); 
                repeat(["+" Dict("delta" => flower_delta)], 2);
                repeat(["F" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1)], 1); 
                repeat(["+" Dict("delta" => flower_delta)], 2);
                repeat(["F" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1)], 2)               
            ]
        ],
        prev -> prev["age"] <= 10
    ), (
        "Q",
        [
            1.0 prev -> [
                "-" Dict("delta" => flower_delta)
            ]
        ],
        prev -> prev["age"] <= 10
    ), (
        "Z",
        [
            1.0 prev -> [
                repeat(["F" Dict("length" => prev["length"], "width" => prev["width"], "color" => prev["color"], "age" => prev["age"] + 1)], 4, 1);
            ]
        ],
        prev -> prev["age"] <= 10
    ), (
        "+",
        [
            0.7 prev -> [
                "+" Dict("delta" => prev["delta"])
            ];
            0.3 prev -> [
                "+" Dict("delta" => prev["delta"] + randn()/100)
            ]
        ],
        prev -> true        
    ), (
        "-",
        [
            0.7 prev -> [
                "-" Dict("delta" => prev["delta"])
            ];
            0.3 prev -> [
                "-" Dict("delta" => prev["delta"] + randn()/100)
            ]
        ],
        prev -> true
    )
]

## Background plants

delta2 = 22.5/180*pi
bg_opacity = 0.6

word2 = [
    "[" Dict();
    "-" Dict("delta" => pi/4, "age" => 1);
    "Y" Dict("length" => len/5, "width" => width/2, "age" => 1, "opacity" => bg_opacity);
    "]" Dict();
    "[" Dict();
    "Y" Dict("length" => len/5, "width" => width/2, "age" => 1, "opacity" => bg_opacity);
    "]" Dict();
    "[" Dict();
    "+" Dict("delta" => pi/4, "age" => 1);
    "Y" Dict("length" => len/5, "width" => width/2, "age" => 1, "opacity" => bg_opacity);
    "]" Dict();
]

word2_fg = [
    "[" Dict();
    "-" Dict("delta" => pi/4, "age" => 1);
    "Y" Dict("length" => len/3, "width" => 2*width/3, "age" => 1, "opacity" => 1, "color" => plantcol);
    "]" Dict();
    "[" Dict();
    "Y" Dict("length" => len/3, "width" => 2*width/3, "age" => 1, "opacity" => 1, "color" => plantcol);
    "]" Dict();
    "[" Dict();
    "+" Dict("delta" => pi/4, "age" => 1);
    "Y" Dict("length" => len/3, "width" => 2*width/3, "age" => 1, "opacity" => 1, "color" => plantcol);
    "]" Dict();
]

grammar2 = [
    (
        "Y", 
        [
            0.5 prev -> [
                "A" Dict("length" => prev["length"], "width" => prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol); 
                "-" Dict("delta" => delta2, "age" => prev["age"] + 1);
                "[" Dict();
                "[" Dict();
                "Y" Dict("length" => young_l_frac*prev["length"], "width" => young_w_frac*prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
                "]" Dict();
                "+" Dict("delta" => delta2, "age" => prev["age"] + 1);
                "Y" Dict("length" => young_l_frac*prev["length"], "width" => young_w_frac*prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
                "]" Dict();
                "+" Dict("delta" => delta2, "age" => prev["age"] + 1);
                "A" Dict("length" => prev["length"], "width" => prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
                "[" Dict();
                "+" Dict("delta" => delta2, "age" => prev["age"] + 1);
                "A" Dict("length" => prev["length"], "width" => prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
                "Y" Dict("length" => young_l_frac*prev["length"], "width" => young_w_frac*prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
                "]" Dict();
                "-" Dict("delta" => delta2, "age" => prev["age"] + 1);
                "Y" Dict("length" => young_l_frac*prev["length"], "width" => young_w_frac*prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
            ];
            0.5 prev -> [
                "Y" Dict("length" => prev["length"], "width" => prev["width"], "age" => prev["age"], "opacity" => prev["opacity"], "color" => plantcol)
            ]
        ],
        prev -> prev["age"] <= 4
    ), (
        "Y", 
        [
            0.1 prev -> [
                "A" Dict("length" => prev["length"], "width" => prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol); 
                "-" Dict("delta" => delta2, "age" => prev["age"] + 1);
                "[" Dict();
                "[" Dict();
                "Y" Dict("length" => young_l_frac*prev["length"], "width" => young_w_frac*prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
                "]" Dict();
                "+" Dict("delta" => delta2, "age" => prev["age"] + 1);
                "Y" Dict("length" => young_l_frac*prev["length"], "width" => young_w_frac*prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
                "]" Dict();
                "+" Dict("delta" => delta2, "age" => prev["age"] + 1);
                "A" Dict("length" => prev["length"], "width" => prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
                "[" Dict();
                "+" Dict("delta" => delta2, "age" => prev["age"] + 1);
                "A" Dict("length" => prev["length"], "width" => prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
                "Y" Dict("length" => young_l_frac*prev["length"], "width" => young_w_frac*prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
                "]" Dict();
                "-" Dict("delta" => delta2, "age" => prev["age"] + 1);
                "Y" Dict("length" => young_l_frac*prev["length"], "width" => young_w_frac*prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol);
            ];
            0.9 prev -> [
                "T" Dict("length" => prev["length"] * 1.2, "width" => young_w_frac*prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"])
            ]
        ],
        prev -> prev["age"] > 4
    ), (
        "A",
        [
            1.0 prev -> [
                "A" Dict("length" => 1.001 * prev["length"], "width" => (1 + width_increase) * prev["width"], "age" => prev["age"] + 1, "opacity" => prev["opacity"], "color" => plantcol_mixingratio/2 * plantcol_old + (1-plantcol_mixingratio/2) * prev["color"])
            ]
        ],
        prev -> true
    ), (
        "+",
        [
            0.7 prev -> [
                "+" Dict("delta" => prev["delta"], "age" => prev["age"] + 1)
            ];
            0.3 prev -> [
                "+" Dict("delta" => prev["delta"] + randn()/10, "age" => prev["age"] + 1)
            ]
        ],
        prev -> prev["age"] <= 5        
    ), (
        "+",
        [
            0.7 prev -> [
                "+" Dict("delta" => prev["delta"], "age" => prev["age"] + 1)
            ];
            0.3 prev -> [
                "+" Dict("delta" => prev["delta"] + randn()/100, "age" => prev["age"] + 1)
            ]
        ],
        prev -> prev["age"] > 5        
    ), (
        "-",
        [
            0.7 prev -> [
                "-" Dict("delta" => prev["delta"], "age" => prev["age"] + 1)
            ];
            0.3 prev -> [
                "-" Dict("delta" => prev["delta"] + randn()/10, "age" => prev["age"] + 1)
            ]
        ],
        prev -> prev["age"] <= 5
    ), (
        "-",
        [
            0.7 prev -> [
                "-" Dict("delta" => prev["delta"], "age" => prev["age"] + 1)
            ];
            0.3 prev -> [
                "-" Dict("delta" => prev["delta"] + randn()/100, "age" => prev["age"] + 1)
            ]
        ],
        prev -> prev["age"] > 5
    )
]

## RUN IT BABY!

words = [word2, word2, word2, word1, word2_fg]
grammars = [grammar2, grammar2, grammar2, grammar1, grammar2]
x0s = [-1.6, -0.7, 1.2, -0.2, 1.4]
y0s = [0.45, 0.30, 0.39, 0.2, -0.1]

anim = animate_plants(words, grammars, x0s, y0s, iters = n, alpha = alpha, ground_height = ground_height, plant_color = plantcol, ground_color = groundcol, bg_color = bgcol)
gif(anim, "genuary_plants.gif", fps = 4)