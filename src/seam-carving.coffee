canvas = document.getElementById "canvas"
context = canvas.getContext "2d"

loadImage = () ->
    img = new Image
    img.onload = () ->
        w = @width
        h = @height
        canvas.width = w
        canvas.height = h
        context.drawImage img, 0, 0, w, h

    img.src = "tower.jpg"

gradient = (image) ->
    gradient = context.createImageData image
    energy = []

    for x in [0..image.width-1]
        energy[x] = []
        for y in [0..image.height-1]
            here = getPixel image, x, y

            left =  if x == 0              then here else getPixel image, x-1, y
            right = if x == image.width-1  then here else getPixel image, x+1, y
            above = if y == 0              then here else getPixel image, x, y-1
            below = if y == image.height-1 then here else getPixel image, x, y+1

            energy[x][y] = magnitude(left, right) + magnitude(above, below)

            setPixel gradient, x, y, grayscale(energy[x][y])
    [energy, gradient]

computeVerticalSeams = (energy, image) ->
    seams = []
    for x in [0..image.width-1]
        seams[x] = []
        seams[x][0] = energy[x][0]

    for y in [1..image.height-1]
        for x in [0..image.width-1]
            seams[x][y] = energy[x][y]

            if x == 0
                seams[x][y] += Math.min seams[x][y-1], seams[x+1][y-1]
            else if x == image.width-1
                seams[x][y] += Math.min seams[x][y-1], seams[x-1][y-1]
            else
                seams[x][y] += Math.min seams[x-1][y-1], seams[x][y-1], seams[x+1][y-1]

    seams

traceVertical = (seams, image, howMany) ->
    i = 0
    for x in [0..image.width-1]
        console.log i++, seams[x][image.height-1]

    for runs in [0..howMany-1]
        minX = 0
        for x in [0..image.width-1-runs]
            if seams[x][image.height-1] <= seams[minX][image.height-1]
                minX = x

        for y in [image.height-1..0]
            for x in [0..image.width-1]
                if x is minX
                    setPixel image, x, y, [255, 0, 0, 255]
                    seams[x][y] = NaN

            if y > 0
                nextMinX = seams[minX][y-1]

                if minX > 0 and seams[minX-1][y-1] <= nextMinX
                    minX--
                else if minX < image.width-1 and seams[minX+1][y-1] <= nextMinX
                    minX++

    image

magnitude = (pixel1, pixel2) ->
    r = pixel1[0] - pixel2[0]
    g = pixel1[1] - pixel2[1]
    b = pixel1[2] - pixel2[2]
    Math.sqrt r*r + g*g + b*b

grayscale = (v) -> [v, v, v, 255]

getPixel = (img, x, y) ->
    index = (y * img.width + x) * 4
    return [img.data[index], img.data[index + 1], img.data[index + 2], img.data[index + 3]]

setPixel = (img, x, y, value) ->
    [r, g, b, a] = value
    index = (y * img.width + x) * 4
    img.data[index] = r
    img.data[index + 1] = g
    img.data[index + 2] = b
    img.data[index + 3] = a

convertToGrayscale = (image) ->
    grayscaleImage  = context.createImageData image

    for x in [0..image.width-1]
        for y in [0..image.height-1]
            [r, g, b] = getPixel image, x, y
            setPixel grayscaleImage, x, y, grayscale((r+g+b)/3)

    grayscaleImage

onResize = () ->
    [w, h] = [canvas.width, canvas.height]

    image = context.getImageData 0, 0, w, h
    grayscaleImage = convertToGrayscale image
    [energy, gradient] = gradient grayscaleImage
    seams = computeVerticalSeams energy, image
    seamsImage = traceVertical seams, image, 1
    context.putImageData seamsImage, 0, 0

window.onload = () ->
    loadImage()
    resize = document.getElementById "resize"
    resize.addEventListener "click", onResize
