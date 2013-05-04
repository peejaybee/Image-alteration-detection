require 'RMagick'
include Magick


class RasterImage
  
  def initialize(filename)
    @img = Image.read(filename).first
    @pixels = @img.export_pixels
    @size = @pixels.length
    @sqrt_onethird = Math.sqrt(1/3)
  end
  
  def rows
    return @img.rows
  end
  
  def columns
    return @img.columns
  end
  
  
  def getRed(row, col)
    red_location = 3 * (row * @img.columns + col) #0 at (0,0), 3 at (0,1) 
    return @pixels[ red_location]
  end

  def getGreen(row, col)
    red_location = 3 * (row * @img.columns + col) #0 at (0,0), 3 at (0,1) 
    return @pixels[ red_location + 1]
  end

  def getBlue(row, col)
    red_location = 3 * (row * @img.columns + col) #0 at (0,0), 3 at (0,1) 
    return @pixels[ red_location + 2]
  end
  
  def normalize!
    0.step(@size - 1, 3) do |i|
      square_length = @pixels[i] ** 2 + @pixels[i + 1] ** 2 + @pixels[i + 2] ** 2
      if square_length > 0 
        vector_length = Math.sqrt(square_length)
        @pixels[i] = @pixels[i] / vector_length
        @pixels[i + 1] = @pixels[i + 1] / vector_length
        @pixels[i + 2] = @pixels[i + 2] / vector_length
      else  # Treat black like very dark grey
        @pixels[i] = @sqrt_onethird
        @pixels[i + 1] = @sqrt_onethird
        @pixels[i + 2] = @sqrt_onethird
      end
    end
  end

end


#Sanity check to make sure we have a filename
if ARGV.length < 1
  puts "Filename needed"
  exit
end

image_filename = ARGV.first

print "start ", image_filename, " ", Time.new, "\n"

#Read the input image and get its pixels
#Array contains three entries for pixel, red then green then blue
img_orig = RasterImage.new(image_filename)
img_orig.normalize!

avg_distance = Array.new(img_orig.rows){ |dummy| Array.new(img_orig.columns){|dummy2| 0}}


output_filename = ARGV.first + ".txt"
outfile = open(output_filename, "w")

(2).upto((img_orig.rows) - 3) do |x0|
  (2).upto((img_orig.columns) -3) do |y0|
    (x0-2).upto(x0+2) do |x|
      (y0-2).upto(y0+2) do |y|
        begin
          avg_distance[x0][y0] = avg_distance[x0][y0] + Math.sqrt( (img_orig.getRed(x,y) - img_orig.getRed(x0,y0)) **2 +  (img_orig.getGreen(x,y) - img_orig.getGreen(x0,y0)) **2 + (img_orig.getBlue(x,y) - img_orig.getBlue(x0,y0)) **2 )
#        rescue StandardError
#          print "Square Root problem : ", (img_orig.getRed(x,y) - img_orig.getRed(x0,y0)) **2 +  (img_orig.getGreen(x,y) - img_orig.getGreen(x0,y0)) **2 + (img_orig.getBlue(x,y) - img_orig.getBlue(x0,y0)) **2, "\n"
        end
    
      end
    end
    avg_distance[x0][y0] = avg_distance[x0][y0] / 25
    outfile.print(image_filename, ",", x0, ",", y0, ",", avg_distance[x0][y0], "\n")
  end
end
outfile.close
print "end ", Time.new, "\n"

