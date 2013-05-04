require 'RMagick'
include Magick

#Sanity check to make sure we have a filename
if ARGV.length < 1
  puts "Filename needed"
  exit
end

#Read the input image and get its pixels
#Array contains three entries for pixel, red then green then blue
img_orig = Image.read(ARGV.first).first
pixels = img_orig.export_pixels


# read the individual channel values, and convert them into a 2-d array of more conventional 24-bit RGB values
# I am not sure whether (0,0) is upper left or lower left -- seems like these coordinate schemes are never standard -- PJB

rgb = Array.new(img_orig.rows, Array.new(img_orig.columns))

print "working"
0.upto(img_orig.rows - 1) do |i|
#  print "."
  if i.modulo(100) == 99 
#    print "\n",  i + 1
  end
  
  0.upto(img_orig.columns - 1) do |j|
    red_location = 3 * (i * img_orig.columns + j) #0 at (0,0), 3 at (0,1) 
    rgb[i][j] = 256 **2 * pixels[red_location] + 256 * pixels[red_location + 1] + pixels[red_location + 2]
  end
end

printf "\n0,0 %#6x \n", rgb[0][0]