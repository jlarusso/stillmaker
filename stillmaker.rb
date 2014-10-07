require 'rubygems'
require 'streamio-ffmpeg'
require 'benchmark'
require 'pry'

class Stillmaker
  attr_reader :video, :choices
  attr_accessor :selection, :interval, :strategy

  def initialize(params = nil)
    set_params(params) if params
    build_choices
    print_choices
    get_input unless @selection
    load_video
    get_interval unless @interval
    start_prompt
  end

  def set_params(params)
    params.each do |k, v|
      send("#{k}=", v)
    end
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

    if @video_file
      @video_name = @video_file.split('.').first
      @shot_path = "#{Time.now.to_i}-#{@video_name}-#{@strategy.to_s}"
      @video = FFMPEG::Movie.new(@video_file)
    else
      raise "Video file not found"
    end
  end

  def get_interval
    puts "Video duration: #{@video.duration} seconds"
    cprint "Enter interval between screenshots in seconds:"
    @interval = gets.chomp.to_i
    puts ''
  end

  def start_prompt
    @num_of_shots = (@video.duration / @interval).to_i
    Dir.mkdir(@shot_path)
    run_strategy
    puts "Screenshot count: #{@num_of_shots}"
  end

  def run_strategy
    case @strategy
    when :seek
      seek_strategy
    when :scan
      scan_strategy
    end
  end

  # a good strategy if you have large intervals
  # uses streamio-ffmpeg ruby wrapper
  # skips to each interval starting at beginning each time
  def seek_strategy
    @num_of_shots.times do |i|
      seek_time = i * @interval
      shot_name = "#{@shot_path}/#{seek_time}_#{@video_name}.jpg"
      video.screenshot(shot_name, seek_time: seek_time)
    end
  end

  # a good strategy if you have very short intervals
  # scans through video
  def scan_strategy
    `ffmpeg -i #{@video_file} -f image2 -vf fps=fps=1/#{@interval} #{@shot_path}/%05d.png`
  end
end

# params = { selection: 0, interval: 50, strategy: :seek }
# params = { selection: 0, interval: 50, strategy: :scan }
Stillmaker.new({ strategy: :scan })

# Benchmark.bm do |x|
#   x.report("scan:") { Stillmaker.new({ selection: 0, interval: 100, strategy: :scan }) }
#   x.report("seek:") { Stillmaker.new({ selection: 0, interval: 100, strategy: :seek }) }
# end
