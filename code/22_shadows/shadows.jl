using DrWatson
@quickactivate
using Colors, Plots, Statistics
using Plots.PlotMeasures
using Images, TestImages, ImageSegmentation


"""
- method=mean, n=5, directions="all", include_self=false => wide diagnonal streaks (*BEST*)
- method=mean, n=50, directions="all", include_self=true => smokey
- method=median, n=20, directions="hor", include_self=false => horizontal streaking
"""
function smooth_array(matrix; method=mean, n=5, directions="all", include_self=false)
    rows, cols = size(matrix)
    for it in 1:n
        for i in 2:rows-1
            for j in 2:cols-1
                if directions == "all"
                    to_smooth = [matrix[i-1, j], matrix[i-1, j-1], matrix[i, j-1], matrix[i+1, j-1], matrix[i+1, j+1], matrix[i+1, j], matrix[i-1, j+1]]
                elseif directions == "vert"
                    to_smooth = [matrix[i-1, j], matrix[i+1, j]]
                elseif directions == "hor"
                    to_smooth = [matrix[i, j-1], matrix[i, j+1]]
                elseif directions == "neg_diag"
                    to_smooth = [matrix[i+1, j-1], matrix[i-1, j+1]]
                elseif directions == "pos_diag"
                    to_smooth = [matrix[i-1, j-1], matrix[i+1, j+1]]
                elseif directions == "X"
                    to_smooth = [matrix[i+1, j-1], matrix[i-1, j+1], matrix[i-1, j-1], matrix[i+1, j+1]]
                elseif directions == "+"
                    to_smooth = [matrix[i-1, j], matrix[i+1, j], matrix[i, j-1], matrix[i, j+1]]
                end
                if include_self
                    push!(to_smooth, matrix[i, j])
                end
                matrix[i, j] = method(to_smooth)
            end
        end
    end
    return matrix
end


function foggy_gradient(matrix; percentage::Float64=0.1)
    output_matrix = deepcopy(matrix)
    n_rows = first(size(output_matrix))
    for row in 1:n_rows
        output_matrix[row, :] *= ((n_rows-row)/n_rows)*exp(percentage)
    end
    return output_matrix
end

"""
Based on the perpective of a camera at a certain position, project a 3D matrix into a plane.
Z - Zc = F
X' = ((X - Xc) * (F/Z)) + Xc
Y' = ((Y - Yc) * (F/Z)) + Yc
"""
function camera_perspective_projection(input_in_3d, camera_position; canvas_size::Tuple{Int64, Int64}=(625,625))
    xc, yc, zc = camera_position
    x_lim, y_lim, z_lim = size(input_in_3d)
    shadow_in_2d = zeros(Int, canvas_size)
    for x in 1:x_lim
        for y in 1:y_lim
            for z in 1:z_lim
                if input_in_3d[x, y, z] != 0
                    F = z - zc
                    projected_x = ((x - xc)*(F÷z)) + xc |> Int
                    projected_y = ((y - yc)*(F÷z)) + yc |> Int
                    if (projected_x > 0 && projected_x <= first(canvas_size)) &&
                        (projected_y > 0 && projected_y <= last(canvas_size))
                        shadow_in_2d[projected_x, projected_y] = +1
                    end
                end
            end
        end
    end
    return shadow_in_2d
end


function pixels_to_indices(pixels_in_2d)
    x_indices = []
    y_indices = []
    x_lim, y_lim = size(pixels_in_2d)
    for x in 1:x_lim
        for y in 1:y_lim
            if pixels_in_2d[x, y] != 0
                push!(x_indices, x)
                push!(y_indices, y)
            end
        end
    end
    return x_indices, y_indices
end


### BACKGROUND
CANVAS = (1000, 1000)
color_palette_3 = [
    colorant"#9AA5A0"
    colorant"#E29C2D"
    colorant"#B25A20"
    colorant"#16535E"
    colorant"#060606"
    ]

image_matrix = rand(Float64, CANVAS)
background = smooth_array(image_matrix, method=median, n=5, directions="all", include_self=false)
background = foggy_gradient(background; percentage=0.0001)

p = plot(
    xaxis = false, yaxis = false,
    xticks = false, yticks = false,
    grid = false, legend = false,
    left_margin=0px,
    right_margin=0px,
    top_margin=0px,
    bottom_margin=0px, 
    dpi=500
    )

for frame in 1:9
    # print background
    heatmap!(
        background,
        c=color_palette_3,
        legend=false, 
        xticks=false,
        yticks=false,
        xaxis=false,
        yaxis=false,
        left_margin=0px,
        right_margin=0px,
        top_margin=0px,
        bottom_margin=0px, 
        )

    if frame > 3
        # load foreground 3D figure
        starting_image = load("man_in_void.jpeg");
        segments = unseeded_region_growing(starting_image, 0.5)
        segmented_image = map(i->segment_mean(segments,i), labels_map(segments));
        grayscale_segmented_image = Gray.(segmented_image);
        image_matrix = transpose(transpose(reverse(convert(Matrix{Float32}, grayscale_segmented_image))))[181:384, 1:256]
        image_matrix = map(x -> x<0.5, image_matrix)
        person = zeros(Float64, (204,256,30));
        person[:, :, 10:20] .= image_matrix;

        # project shadow
        canvas_lims = (1000, 1000)
        camera_pos = (10, -20, -10)
        person_shadow = camera_perspective_projection(person, camera_pos; canvas_size=canvas_lims)
        person_shadow[1:200, 1:130] .= 0
        person_shadow = person_shadow[100:1000, 150:1000]
        person_long_shadow = []
        for row in 1:400    # a bit hacky 
            isolated_row = person_shadow[row, :]
            for its in 1:(row÷(10-frame))
                pushfirst!(isolated_row, 0)
                pop!(isolated_row);
            end
            for its in 1:(row÷(65*(10-frame)))
                push!(person_long_shadow, isolated_row)
            end
        end
        person_long_shadow = mapreduce(permutedims, vcat, person_long_shadow)

        # plot
        person_shadow_x, person_shadow_y = pixels_to_indices(person_long_shadow)
        plot!(
            person_shadow_y, person_shadow_x, 
            c=RGBA(0, 0, 0, 0.5),
            lw=0.5
            )
    end

    if frame > 7
        # load foreground 3D figure
        starting_image = load("pyramid_in_distance.jpeg");
        segments = unseeded_region_growing(starting_image, 0.7);
        segmented_image = map(i->segment_mean(segments,i), labels_map(segments));
        grayscale_segmented_image = Gray.(segmented_image);
        image_matrix = transpose(transpose(reverse(convert(Matrix{Float32}, grayscale_segmented_image))))[232:800, :][:,end:-1:1];
        pyramid_shadow = map(x -> x<0.3, image_matrix);
        n, m = size(pyramid_shadow)

        # project shadow
        long_pyramid_shadow = []
        for row in 1:n    # a bit hacky 
            isolated_row = pyramid_shadow[row, :]
            for its in 1:(row÷3)
                pushfirst!(isolated_row, 0)
                pop!(isolated_row);
            end
            for its in 1:(row÷(220))
                push!(long_pyramid_shadow, isolated_row)
            end
        end
        long_pyramid_shadow = mapreduce(permutedims, vcat, long_pyramid_shadow)
        if first(size(long_pyramid_shadow)) > 1000
            long_pyramid_shadow = long_pyramid_shadow[1:1000, :]
        end
        if last(size(long_pyramid_shadow)) > 1000
            long_pyramid_shadow = long_pyramid_shadow[:, 1:1000]
        end

        # plot
        pyramid_shadow_x, pyramid_shadow_y = pixels_to_indices(long_pyramid_shadow')
        plot!(
            pyramid_shadow_x, pyramid_shadow_y, 
            c=RGBA(0, 0, 0, 0.5),
            lw = 0.2
            )
    end

    if frame > 8
        starting_image = load("lofi_skyline.jpeg");
        segments = unseeded_region_growing(starting_image, 0.7);
        segmented_image = map(i->segment_mean(segments,i), labels_map(segments));
        grayscale_segmented_image = Gray.(segmented_image);
        image_matrix = transpose(transpose(reverse(convert(Matrix{Float32}, grayscale_segmented_image))))[220:480, :];
        image_matrix = map(x -> x<0.5, image_matrix);
        n, m = size(image_matrix)
        city_shadow = zeros(Float64, (n, m+488));
        city_shadow[1:n, 488:m+487] = image_matrix;

        # project shadow
        city_long_shadow = []
        for row in 1:n    # a bit hacky 
            isolated_row = city_shadow[row, :]
            for its in 1:(row÷2)
                pushfirst!(isolated_row, 0)
                pop!(isolated_row);
            end
            for its in 1:(row÷32*(10-frame))
                push!(city_long_shadow, isolated_row)
            end
        end
        city_long_shadow = mapreduce(permutedims, vcat, city_long_shadow)[:, 1:1000]

        # plot
        city_shadow_x, city_shadow_y = pixels_to_indices(city_long_shadow')
        p = plot!(
            city_shadow_x, city_shadow_y, 
            c=RGBA(0, 0, 0, 0.5),
            lw = 0.15
            )
    end
    name = "figures/gif/shadow_frame_" * string(frame) * ".png"
    #savefig(p, name)
    display(p)
end