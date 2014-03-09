require 'sinatra'
require 'sinatra/jbuilder'
require 'mathn'
Dir['./models/*.rb', './helpers/*.rb'].each {|file| require file }

include FileUtils::Verbose

get '/test1-walk' do
  begin
    # calculate_all_directions(File.read('public/test/accelerometer.txt'), File.read('public/test/gravity.txt'))
    # calculate_all_directions(File.read('public/test/walkpocket_100_1.txt'), File.read('public/test/walkpocket_100_2.txt'))
    # calculate_all_directions(File.read('public/test/bagwalk_100_1.txt'), File.read('public/test/bagwalk_100_2.txt'))
    calculate_all_directions(File.read('public/test/bagwalk_300_1.txt'), File.read('public/test/bagwalk_300_2.txt'))
    
    erb :test1
  rescue Exception => e
    [400, e.message]
  end  
end

get '/test2-walk' do
  begin
    # calculate_x_direction(File.read('public/test/accelerometer.txt'), File.read('public/test/gravity.txt'))
    # calculate_x_direction(File.read('public/test/walkpocket_100_1.txt'), File.read('public/test/walkpocket_100_2.txt'))
    # calculate_x_direction(File.read('public/test/bagwalk_100_1.txt'), File.read('public/test/bagwalk_100_2.txt'))
    calculate_x_direction(File.read('public/test/bagwalk_300_1.txt'), File.read('public/test/bagwalk_300_2.txt'))

    erb :test2
  rescue Exception => e
    [400, e.message]
  end  
end

get '/test1-5' do
  begin
    calculate_all_directions(File.read('public/test/experiments_5_1.txt'), File.read('public/test/experiments_5_2.txt'))

    erb :test1
  rescue Exception => e
    [400, e.message]
  end  
end

get '/test2-5' do
  begin
    calculate_x_direction(File.read('public/test/experiments_5_1.txt'), File.read('public/test/experiments_5_2.txt'))

    erb :test2
  rescue Exception => e
    [400, e.message]
  end  
end

get '/test1-100' do
  begin
    calculate_all_directions(File.read('public/test/experiments_100_1.txt'), File.read('public/test/experiments_100_2.txt'))

    erb :test1
  rescue Exception => e
    [400, e.message]
  end  
end

get '/test2-100' do
  begin
    calculate_x_direction(File.read('public/test/experiments_100_1.txt'), File.read('public/test/experiments_100_2.txt'))

    erb :test2
  rescue Exception => e
    [400, e.message]
  end  
end

def calculate_all_directions(data_1, data_2)
    user_1      = User.new(:gender => 'female', :height => 167)
    @device_1   = Device.new(:data => data_1, :rate => 100)
    @parser_1   = Parser.new(@device_1)
    @analyzer_1 = Analyzer.new(@parser_1, user_1)
    @analyzer_1.measure

    user_2      = User.new(:gender => 'female', :height => 167)
    @device_2   = Device.new(:data => data_2, :rate => 100)
    @parser_2   = Parser.new(@device_2)
    @analyzer_2 = Analyzer.new(@parser_2, user_2)
    @analyzer_2.measure

    # x, y, z user acceleration
    @x_1 = @parser_1.parsed_data.collect { |d| d[:x] }
    @y_1 = @parser_1.parsed_data.collect { |d| d[:y] }
    @z_1 = @parser_1.parsed_data.collect { |d| d[:z] }

    @x_2 = @parser_2.parsed_data.collect { |d| d[:x] }
    @y_2 = @parser_2.parsed_data.collect { |d| d[:y] }
    @z_2 = @parser_2.parsed_data.collect { |d| d[:z] }

    # x, y, z gravity acceleration
    @xg_1 = @parser_1.parsed_data.collect { |d| d[:xg] }
    @yg_1 = @parser_1.parsed_data.collect { |d| d[:yg] }
    @zg_1 = @parser_1.parsed_data.collect { |d| d[:zg] }

    @xg_2 = @parser_2.parsed_data.collect { |d| d[:xg] }
    @yg_2 = @parser_2.parsed_data.collect { |d| d[:yg] }
    @zg_2 = @parser_2.parsed_data.collect { |d| d[:zg] }

    # magnitude of x, y, z user acceleration
    @xyz_1 = @parser_1.parsed_data.collect { |d| Math.sqrt((d[:x]*d[:x])+(d[:y]*d[:y])+(d[:z]*d[:z])) }
    @xyz_2 = @parser_2.parsed_data.collect { |d| Math.sqrt((d[:x]*d[:x])+(d[:y]*d[:y])+(d[:z]*d[:z])) }

    # magnitude of x, y, z gravity acceleration
    @xyzg_1 = @parser_1.parsed_data.collect { |d| Math.sqrt((d[:xg]*d[:xg])+(d[:yg]*d[:yg])+(d[:zg]*d[:zg])) }
    @xyzg_2 = @parser_2.parsed_data.collect { |d| Math.sqrt((d[:xg]*d[:xg])+(d[:yg]*d[:yg])+(d[:zg]*d[:zg])) }

    # Raw total acceleration in each of x, y, z (from accelerometer)
    @x_raw_1 = @device_1.data.split(';').inject([]) {|a, data| a << data.split(',')[0].to_f }
    @y_raw_1 = @device_1.data.split(';').inject([]) {|a, data| a << data.split(',')[1].to_f }
    @z_raw_1 = @device_1.data.split(';').inject([]) {|a, data| a << data.split(',')[2].to_f }

    # Total acceleration in each of x, y, z (calculated by x + xg, y + yg, z + zg from device motion)
    @x_plus_xg_2 = @parser_2.parsed_data.collect { |d| d[:x] + d[:xg] }
    @y_plus_yg_2 = @parser_2.parsed_data.collect { |d| d[:y] + d[:yg] }
    @z_plus_zg_2 = @parser_2.parsed_data.collect { |d| d[:z] + d[:zg] }

    # Magnitude of total acceleration (from accelerometer)
    @magnitude_total_1 = @device_1.data.split(';').inject([]) do |a, data| 
      x = data.split(',')[0].to_f
      y = data.split(',')[1].to_f
      z = data.split(',')[2].to_f
      a << Math.sqrt((x*x)+(y*y)+(z*z))
    end

    # Magnitude of total acceleration (calculated by x + xg, y + yg, z + zg from device motion)
    @magnitude_total_2 = @parser_2.parsed_data.collect do |d| 
      x = d[:x] + d[:xg]
      y = d[:y] + d[:yg]
      z = d[:z] + d[:zg]
      Math.sqrt((x*x)+(y*y)+(z*z))
    end
end

def calculate_x_direction(data_1, data_2)
  user_1      = User.new(:gender => 'female', :height => 167)
  @device_1   = Device.new(:data => data_1, :rate => 100)
  @parser_1   = Parser.new(@device_1)
  @analyzer_1 = Analyzer.new(@parser_1, user_1)
  @analyzer_1.measure

  user_2      = User.new(:gender => 'female', :height => 167)
  @device_2   = Device.new(:data => data_2, :rate => 100)
  @parser_2   = Parser.new(@device_2)
  @analyzer_2 = Analyzer.new(@parser_2, user_2)
  @analyzer_2.measure

  # x user acceleration
  @x_user_1 = @parser_1.parsed_data.collect { |d| d[:x] }
  @x_user_2 = @parser_2.parsed_data.collect { |d| d[:x] }

  # x gravity acceleration
  @x_gravity_1 = @parser_1.parsed_data.collect { |d| d[:xg] }
  @x_gravity_2 = @parser_2.parsed_data.collect { |d| d[:xg] }

  # x total acceleration
  @x_total_1 = @parser_1.parsed_data.collect { |d| d[:x] + d[:xg] }
  @x_total_2 = @parser_2.parsed_data.collect { |d| d[:x] + d[:xg] }

  # x dot product
  @x_dot_1 = @parser_1.parsed_data.collect { |d| d[:x]*d[:xg] }
  @x_dot_2 = @parser_2.parsed_data.collect { |d| d[:x]*d[:xg] }
end

# TODO: 
# - Capture exceptions and redirect to /data
post '/create' do
  begin
    file = params[:device][:file][:tempfile]
    user_params = params[:user].symbolize_keys
    device_params = {data: File.read(file)}.merge(params[:device].symbolize_keys)
    build_with_params(user_params, device_params)

    @file_name = FileHelper.generate_file_name(@user, @device)
    cp(file, "public/uploads/" + @file_name + '.txt')

    erb :detail
  rescue Exception => e
    [400, e.message]
  end
end

get '/data' do
  begin
    @data = []
    files = Dir.glob(File.join('public/uploads', "*"))
    files.each do |file|
      user_params, device_params = FileHelper.parse_file_name(file).values
      device_params = {:data => File.read(file)}.merge(device_params)
      build_with_params(user_params, device_params)

      @data << {:file => file, :device => @device, :steps => @analyzer.steps, :user => @user}
    end

    erb :data
  rescue Exception => e
    [400, e.message]
  end
end

get '/detail/*' do
  begin
    @file_name = params[:splat].first
    user_params, device_params = FileHelper.parse_file_name(@file_name).values
    device_params = {:data => File.read(@file_name)}.merge(device_params)
    build_with_params(user_params, device_params)

    files = Dir.glob(File.join('public/uploads', "*"))
    files.delete(@file_name)
    match = files.select { |f| @file_name == f.gsub('-a.', '-g.').gsub('-g.', '-a.') }.first
    if match
      device = Device.new(:data => File.read(match))
      parser = Parser.new(device)
      @match_filtered_data = parser.filtered_data
    end

    erb :detail
  rescue Exception => e
    [400, e.message]
  end
end

def build_with_params(user_params, device_params)
  @user     = User.new(user_params)
  @device   = Device.new(device_params)
  @parser   = Parser.new(@device)
  @analyzer = Analyzer.new(@parser, @user)
  @analyzer.measure
end
