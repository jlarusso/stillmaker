require 'rubygems'
require 'streamio-ffmpeg'
require 'pry'

class Stillmaker
  attr_reader :selection, :video, :choices

  def initialize
    build_choices
    print_choices
    get_input
    load_video
    get_interval
    start_prompt
  end

  def cprint(str)
    puts "\033[34m#{str}\033[0m"
  end

  def build_choices
    @choices = Dir.glob("*.mp4")
  end

  def print_choices
    @choices.each_with_index do |choice, i|
      puts "#{i}: #{choice}"
    end
  end

  def get_input
    cprint "Enter selection number:"
    @selection = gets.chomp.to_i
    puts ''
  end

  def load_video
    @video_file = @choices[@selection]
    @video_name = @video_file.split('.').first
    @shot_path = "#{Time.now.to_i}-#{@video_name}"
    @video = FFMPEG::Movie.new(@video_file)
  end

  def get_interval
    puts "Video duration: #{@video.duration} seconds"
    cprint "Enter interval between screenshots in seconds:"
    @interval = gets.chomp.to_i
    puts ''
  end

  def start_prompt
    @num_of_shots = (@video.duration / @interval).to_i
    puts "Screenshot count: #{@num_of_shots}"
    cprint "Enter (y) to continue"
    if gets.chomp == "y"
      Dir.mkdir(@shot_path)
      take_interval
    end
  end

  # a good strategy if you have large intervals
  # skips to each interval starting at beginning each time
  def take_screenshots
    @num_of_shots.times do |i|
      seek_time = i * @interval
      shot_name = "#{@shot_path}/#{seek_time}_#{@video_name}.jpg"
      video.screenshot(shot_name, seek_time: seek_time)
    end
  end

  # a good strategy if you have very short intervals
  # scans through video
  def take_interval
    take_screenshots
    # `ffmpeg -i #{@video_file} -f image2 -vf fps=fps=#{@interval} #{@video_name}/%05d.png`
  end
end

s = Stillmaker.new
