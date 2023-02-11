using Luxor, Colors, Images, SignalAnalysis, SignalAnalysis.Units, DSP

# functions
function f_resp(x,y,pars)
    return (pars[1]*x*y^pars[3])/(1+pars[1]*pars[2]*x*y^pars[3])
end

function standardize(vector)
    return (vector .- minimum(vector))/(maximum(vector) - minimum(vector))
end

# Load image
buffer = load("./figures/king-2.jpg")
buffer = convert.(Colors.ARGB32, buffer)

# loop over columns, translate red and blue signal, perform circular convolution on green channel
for i in 1:size(buffer)[2]-50
    if noise(0.01*i)>0.5
        
        red_signal = (red.(buffer[:,i+25]))
        green_signal = circconv(green.(buffer[:,i]))
        blue_signal = (blue.(buffer[:,i+50]))

        for j in 1:size(buffer)[1]
            buffer[j,i] = Colors.ARGB32(red_signal[j],green_signal[j],blue_signal[j],alpha(buffer[j,i]))
        end
    end
end

#Parameters for grid
pars = [0.02, 0.9, 0.01]
xspacing = 5
yspacing = 5
x_dims = size(buffer)[1]
y_dims = size(buffer)[2]
gridpoints = zeros(Point,x_dims+1, y_dims+1)

Drawing((x_dims*xspacing)-200,(y_dims*yspacing)-200,:png)
background("black")
#Assign points with offset following pattern
i = 1
j = 1
freq = 0.0015
for x in 0:xspacing:x_dims*xspacing
    j=1
    for y in 0:yspacing:y_dims*yspacing
        offset = ((f_resp(x,y,pars)*noise(freq*x,freq*y))*200)-200
        gridpoints[i,j] = Point(x+offset, y+offset)
        j+=1
    end
    i+=1
end

# color points of grid with pixels from buffer
for i in 1:x_dims
    for j in 1:y_dims
        setcolor(buffer[i,j])
        box(gridpoints[i,j], 5, 5, action=:fill)
    end
end

finish()
preview()