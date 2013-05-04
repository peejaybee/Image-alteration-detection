require 'RMagick'
include Magick

qualVals = [45,50,55,60,65,70,75,80]


if ARGV.length < 1
  puts "Filename needed"
  exit
end

if ARGV.length < 2 
  scale_factor = 40 
else
  scale_factor = ARGV[1].to_i
end

img_orig = Image.read(ARGV.first).first
pixels = img_orig.export_pixels

qualVals.each do |resave_quality|
  
  tempname = "temp.jpg"
  output_name = resave_quality.to_s + ARGV.first.gsub("jpg","tif")


  img_orig.write(tempname) {self.quality = resave_quality}

  img_degraded = Image.read(tempname).first
  pixels_degraded = img_degraded.export_pixels

  pixels_diff = pixels_degraded
  pixels_diff.each_index  do |i| 
    pixels_diff[i] = scale_factor * (pixels[i] - pixels_degraded[i]).abs
    if pixels_diff[i] > MaxRGB 
      pixels_diff[i] = MaxRGB
    end
  end

  img_diff = Image.new(img_orig.columns, img_orig.rows)
  img_diff.format = "TIF"
  img_diff.import_pixels(0,0,img_diff.columns, img_diff.rows, "RGB", pixels_diff)
  img_diff.write(output_name)
end
