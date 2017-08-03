# required gems
require 'net/http'
require 'uri'
require 'json'
require 'optparse'
require 'date'
require 'base64'
require 'pp'
require "../info/GetUsers.rb"

def parseArgs()
  # Method gets command line arguments needed for Basecamp II API. Returns
  # set of options defined below:
  options = {:fname => nil, :fdir => nil,	:subscribers => nil, :fullpath => nil,
    :user_agent => nil, :content => nil, :filedate => nil, :company_id => nil,
    :project_id => nil, :authorization => nil, :content_type => "application/zip",
    :username => nil , :password => nil, :get_users => nil, :debug => nil,
    :ini => nil, :json_out => nil, :nofile => nil}

  if not ENV['debug'].nil?
      puts "Args: #{ARGV.to_s}"
      options[:debug] = ENV['debug']
    end
  # Parse args
  parser = OptionParser.new do|opts|
    opts.banner = "Usage: basecampupload.rb [options]\r\n" + " Example:\r\n" + "\t ruby basecampupload.rb" + "\r\n\t\t\t-f filename.zip" + "\r\n\t\t\t-C 1111111" + "\r\n\t\t\t-P 2222222" + "\r\n\t\t\t-s '1234, 4321, 1221'" + "\r\n\t\t\t-m 'Your Message Here'" + "\r\n\r\n\t\t\t-a 'email@address.com'" + "\r\n\t\t\t-u 'email@address.com'" + "\r\n\t\t\t-p 'p@ssword'"
    
    # Parse File Params
    opts.on('-f', '--filename filename', 'Full name and path for the zip.') do |fname|
      options[:fullpath] = fname;
      options[:fname] = File.basename(fname);
      options[:fdir] = File.dirname(fname);
    end
    
    # Parse content type
    opts.on('-t', "--content_type type", "The file type being uploaded.\r\n\t\t\t\t     Like:\r\n\t\t\t\t     'application/zip'") do |content_type|
      options[:content_type] = content_type;
    end
    
    # Parse Company ID
    opts.on('-C', "--company #", 'Your basecamp company ID') do |company_id|
      options[:company_id] = company_id;
    end
    
    # Parse Project ID
    opts.on('-P', "--project #", 'Your basecamp project ID') do |project_id|
      options[:project_id] = project_id;
    end
    
    # Parse auth base64encode
    opts.on('-h', "--authorization base64encode", "Basecamp user:pass base64 encode string. Optional authentication methods: username and password or base46 encoded string. \r\n\t\t\t\t     Like:\r\n\t\t\t\t     'Basic base46encode'") do |authorization|
      options[:authorization] = authorization;
    end
    
    # Parse Subscribers List i.e. "#, #" Requires user to pass in with quotes
    opts.on('-s', "--subscribers #", "Subscribers are user id's for those who will be informed that a file has been uploaded.\r\n\t\t\t\t     Like:\r\n\t\t\t\t     '1, 2, 3'") do |subscribers|
      options[:subscribers] = subscribers;
    end
    
    # Parse Message that will discribe the file
    opts.on('-m', "--message message", 'Latest zip file.') do |content|
      options[:content] = content;
    end
    
    # Parse the user_agent email parameter. Required for file upload only.
    opts.on('-a', "--user_agent email", "User account used for base64 encode email@company.ext") do |user_agent|
      options[:user_agent] = user_agent;
    end
    
    # Parse the username. Only required if not using -h base64encoded. This
    #  is encoded below if provided.
    opts.on('-u', "--username username", "User account. Optional authentication methods: username and password or base46 encode.") do |username|
      options[:username] = username;
    end
    
    # Parse the password. Only required if not using -h base64encoded. This
    #  is encoded below if provided.
    opts.on('-p', "--password password", "User password. Optional authentication methods: username and password or base46 encode.") do |password|
      options[:password] = password;
    end
    
    # Parse the get_users parameter. If passed it will bypass the file upload
    #  even if a valid file in the -f filename.ext parameter is passed.
    opts.on('-g', "--get_users true", "Bypass file upload and displays users for a project in json output.") do |get_users|
      options[:nofile] = true
      options[:get_users] = get_users;
    end
    
    #Parse debug options. 
    opts.on('-d', "--debug true", "Prints values set.") do |debug|
      options[:debug] = debug;
    end
    
    opts.on('-h', '--help', 'Displays Help') do
      puts opts
      exit
    end
  end

  parser.parse!

  # Check args 

  # Check file args
  if options[:nofile].nil?
    if options[:fname] == nil
      puts 'Enter directory and file name: something like c:\zip\myfile.zip'
      puts " Note: You must specify the content type if uploading anything other than zip files."
      puts " i.e. if your filename is: --filename 'c:\images\image.jpg'"
      puts "                      then --content_type 'image/jpeg'"
      options[:fullpath] = gets.chomp
      options[:fname] = File.file(fullpath);
      options[:fdir] = File.dirname(fullpath);
    end

    # Check for missing subscribers TBD: verify type is int or number >= 4 digits
    if options[:subscribers] == nil
      puts 'Enter subscribers: '
      options[:subscribers] = gets.chomp
    end
    
    # Format the content upload date. TBD: perhaps this should be optional.
    if options[:content] == nil
      d = DateTime.now()
      options[:content] = d.strftime("Logs %Y-%d-%m %I:%M%p").to_s
      options[:filedate] = "#{options[:content]}"
    end
  end

  # Check for a company ID. This is critical and must be provided. TBD: Need to check validity and prevent script if not provided.
  if options[:company_id] == nil
    puts 'Enter your company id. Hint? Open a browser and login to basecamp it will be https://basecamp.com/{your company id is here}/'
    options[:company_id] = gets.chomp
  end
  # Check for a project ID. This is critical and must be provided. TBD: Need to check validity and prevent script if not provided.
  if options[:project_id] == nil
    puts 'Enter your project id. Hint? Open a browser and login to basecamp it will be https://basecamp.com/{company_id}/projects/{your project id is here}'
    options[:project_id] = gets.chomp
  end

  # Check for authentication base64 encode and if missing ask for user and pass and convert it to a base64
  if options[:authorization].nil?
    # Check for username and ask if missing.
    if options[:username].nil?
      puts "Please enter a username for authentication to the basecamp server."
      options[:username] = gets.chomp
    end
    # Check for password and ask if missing.
    if options[:password].nil?
      puts "Please enter a password for authentication to the basecamp server."
      options[:password] = gets.chomp
    end
    # Convert the user and password into a base64 encoded string. TBD: Need to check validity of options[:authorization] converted string.
    options[:authorization] = "Basic " + Base64.encode64("#{options[:username]}:#{options[:password]}")
  end

  # If debug enabled display all the values as key=value pairs.
  if not options[:debug].nil?
    options.each { |key, value| print "#{key}=#{value}\n" } 
  end
  return options
end

def attachments(options)
  # Method uploads files using attachemens.json and upload.json Basecamp II API. Returns
  #  the options defined in parseArgs method.
  # options = {
  #  :fname => filename,
  #  :fdir => directory where filename if found,
  #  :subscribers => subscriber id's "111,222,333",
  #  :fullpath => directory/filename,
  #  :user_agent => email,
  #  :content => content message,
  #  :filedate => date of this upload default:auto,
  #  :company_id => Company ID,
  #  :project_id => Project ID,
  #  :authorization => auth string:"Basic Base64Encoded:,
  #  :content_type => "application/zip",
  #  :username => Not used here Default: nil,
  #  :password => Not used here Default: nil,
  #  :get_users => Not used here Default: nil,
  #  :debug => [nil/true] default:nil meaning off,
  #  :ini => Not used here Default: nil,
  #  :json_out => Not used here Default: nil,
  #  :nofile => Not used here Default: nil
  #  }
  # Upload attachements.
  if check(options)
    puts "Cannot continue. Please fix errors and try again."
    exit(1)
  end
  if options[:get_users].nil?
    uri = URI.parse("https://basecamp.com/#{options[:company_id]}/api/v1/attachments.json")
    fname = options[:fname]
    fdir = options[:fdir]
    fjoin = options[:fullpath]
    puts fjoin
    content = options[:content]
    subscribers = options[:subscribers]
    user_agent = options[:user_agent]
    request = Net::HTTP::Post.new(uri)
    request.content_type = options[:content_type].to_s
    request["authorization"] = options[:authorization].to_s
    request["User-Agent"] = user_agent
    request["Accept"] = "application/json"
    request["Content-Length"] = File.size(fjoin)
    request.body = ""
    request.body << File.read(fjoin).delete("\r\n")

    req_options = {
      use_ssl: uri.scheme == "https",
    }
    # Start the attachment post which uploads the actual file to the company but is not visable until the second part.
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    if not options[:debug].nil?
      puts response.code
    end
    # Grab the token if successful to use in the next step where this file will be assigned to the project and become visable to the users.
    # TBD: Need to check for a valid token and error out if this step fails. 
    token = JSON.parse(response.body)['token']
    if not options[:debug].nil?
      puts token
    end

    uri = URI.parse("https://basecamp.com/#{options[:company_id]}/api/v1/projects/#{options[:project_id]}/uploads.json")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["authorization"] = options[:authorization].to_s
    request["Cache-Control"] = "no-cache"
    request["User-Agent"] = user_agent
    request.body = "
    {
      \"content\": \"#{content}\",
      \"attachments\": [
        { \"token\": \"#{token}\",
          \"name\": \"#{options[:filedate]} #{fname}\"
        }
      ],
      \"subscribers\": [#{options[:subscribers]}]
    }"
    if not options[:debug].nil?
      puts request.body
    end
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    # Start the upload post which uses the token recieved in the first post to assign the file to the project according.
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    # If in debug mode than print the response code.
    if not options[:debug].nil?
      # Note: Anything other than a response.code of '200' would be a failure. 
      puts response.code
    end
    puts response.body
    # Note: Anything other than a response.code of '200' would be a failure. 
    exit(response.code)
  else
    options = GetProjectUsers(options)
    if not options.nil?
      # Print the default ini format.
      puts options[:ini]
      if not options[:debug].nil?
        # Pretty print out the full json
        pp options[:json_out]
      end
    end
  end
  return options
end

if ARGV.count >= 1
  attachments(parseArgs())
end