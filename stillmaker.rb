require 'rubygems'
require 'streamio-ffmpeg'

def color(str)
  "\033[34m#{str}\033[0m"
end

class Stillmaker
  attr_reader :video_str, :video

  def initialize
    puts "Enter video file name:"
    @video_str = gets.chomp
  end

  def self.print_intro
    puts ""
    ignored = ['stillmaker.rb', 'README.md', 'Gemfile', 'Gemfile.lock']
    Dir.glob("*") do |file|
      unless ignored.include? file
        puts color(file)
      end
    end
  end

  def load_video
    @video_name = @video_str.split('.').first
    Dir.mkdir(@video_name)

    @video = FFMPEG::Movie.new(video_str)
  end

  def get_interval
    puts "", color("Video duration: #{@video.duration}")
    puts "Enter interval between screenshots in seconds:"
    @interval = gets.chomp.to_i
  end

  def take_screenshots
    num_of_shots = (@video.duration / @interval).round
    num_of_shots.times do |i|
      seek_time = i * @interval
      shot_name = "#{@video_name}/#{seek_time}_#{@video_name}.jpg"
      video.screenshot(shot_name, seek_time: seek_time)
    end
  end

  def take_interval
    `ffmpeg -i #{@video_str} -f image2 -vf fps=fps=#{@interval} #{@video_name}/%05d.png`
  end
end

Stillmaker.print_intro
s = Stillmaker.new
s.load_video
s.get_interval
# s.take_screenshots
s.take_interval
