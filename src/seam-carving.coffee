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

    for x in [0..image.width-1]
        for y in [0..image.height-1]
            here = getPixel(image, x, y)

            left = if x == 0 then here else getPixel(image, x-1, y)
            right = if x == image.width-1 then here else getPixel(image, x+1, y)

            setPixel(gradient, x, y, grayscale(magnitude(left, right)))
    gradient

magnitude = (pixel1, pixel2) ->
    r = pixel1[0] - pixel2[0]
    g = pixel1[1] - pixel2[1]
    b = pixel1[2] - pixel2[2]
    Math.sqrt(r*r + g*g + b*b)

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

onResize = () ->
    [w, h] = [canvas.width, canvas.height]

    image = context.getImageData 0, 0, w, h
    gradient = gradient image
    context.putImageData gradient, 0, 0

window.onload = () ->
    loadImage()
    resize = document.getElementById "resize"
    resize.addEventListener "click", onResize
