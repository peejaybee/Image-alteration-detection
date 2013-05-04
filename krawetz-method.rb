require 'RMagick'
include Magick

#Sanity check to make sure we have a filename
if ARGV.length < 1
  puts "Filename needed"
  exit
end

#The errors are small and to make them visible, we need to multiply them by a scale factor
#Get the scale factor, or use a default of 40
if ARGV.length < 2 
  scale_factor = 40 
else
  scale_factor = ARGV[1].to_i
end

#resave quality from command line

if ARGV.length < 3
  resave_quality = 75
else
    resave_quality = ARGV[2].to_i
end
  
tempname = "temp.jpg"
output_name = ARGV.first.gsub("jpg","tif")


#Read the input image and get its pixels
#Array contains three entries for pixel, red then green then blue
img_orig = Image.read(ARGV.first).first
pixels = img_orig.export_pixels

#resave the image at the resave quality
img_orig.write(tempname) {self.quality = resave_quality}

#read the resaved image back in and get its pixels
img_degraded = Image.read(tempname).first
pixels_degraded = img_degraded.export_pixels

#lazy man's initialization of an array
pixels_diff = pixels_degraded

#Get the error for each pixel channel
pixels_diff.each_index  do |i| 
  pixels_diff[i] = scale_factor * (pixels[i] - pixels_degraded[i]).abs
  if pixels_diff[i] > MaxRGB 
    pixels_diff[i] = MaxRGB
  end
end

#Make this into a new image.  Use TIFF to avoid introducing JPEG artifacts into the result
img_diff = Image.new(img_orig.columns, img_orig.rows)
img_diff.format = "TIF"
img_diff.import_pixels(0,0,img_diff.columns, img_diff.rows, "RGB", pixels_diff)
img_diff.write(output_name)
