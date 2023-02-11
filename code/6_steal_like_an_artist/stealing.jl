using Images, Luxor, ImageSegmentation

im = load("rechters.jpg")

segs = Vector{SegmentedImage{Matrix{Int64}, RGB{Float32}}}()
curr_length = 0
k_min = 0.1
k_max = 400
m_min = 1
m_max = 400
ks = exp.(LinRange(log(m_max), log(k_min), 50))
curr_length = 0
for k in ks
    m = Int64(round((399/399.9)*(k-0.1)+1))
    seg = felzenszwalb(im, k, m)
    if length(seg.segment_labels) > curr_length
        curr_length = length(seg.segment_labels)
        push!(segs, seg)
    end
end

segi = j -> map(i->segment_mean(segs[j],i), labels_map(segs[j]))

length(segs)
segi(20)

segsa = vcat(segs[1:20], segs[21:2:end])

first_frame = fill(segment_mean(segs[1], 1), (560, 362))
all_frames = [first_frame]

nb_changed = 401
for s in segsa[2:end]
    println(length(s.segment_labels))
    for label in s.segment_labels
        if nb_changed > 400
            push!(all_frames, copy(all_frames[end]))
            nb_changed = 0
        end
        all_frames[end][labels_map(s).==label] .= segment_mean(s, label)
        nb_changed += count(labels_map(s).==label)
    end
end

length(all_frames)

for i = 1:5
    demo = Movie(362, 560, "test")
    function frame(scene::Scene, framenumber::Int64)
        background("white")
        placeimage(all_frames[framenumber], Luxor.Point(-181, -280))
    end

    animate(demo, [Scene(demo, frame, i*1000-999:min(i*1000, length(all_frames)))], creategif=true,pathname="$i.gif")
end

