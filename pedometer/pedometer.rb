require 'sinatra'
require 'sinatra/jbuilder'
Dir['./models/*.rb', './helpers/*.rb'].each {|file| require file }

include FileUtils::Verbose

get '/test' do
  begin
    data_a = File.read('public/test/accelerometer.txt')
    data_g = File.read('public/test/gravity.txt')

    user_a     = User.new(:gender => 'female', :height => 167)
    @device_a   = Device.new(:data => data_a, :rate => 100)
    @parser_a   = Parser.new(@device_a)
    @analyzer_a = Analyzer.new(@parser_a, user_a)
    @analyzer_a.measure

    user_g     = User.new(:gender => 'female', :height => 167)
    @device_g   = Device.new(:data => data_g, :rate => 100)
    @parser_g   = Parser.new(@device_g)
    @analyzer_g = Analyzer.new(@parser_g, user_g)
    @analyzer_g.measure    

    erb :test
  rescue Exception => e
    [400, e.message]
  end  
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
