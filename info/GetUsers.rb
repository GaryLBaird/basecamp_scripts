def GetProjectUsers(options, debug = nil)
  # Method gets user information using accesses.json Basecamp II API. Returns
  #  the options defined in basecampupload.rb
  # options = {
  #   :subscribers => nil,
  #   :user_agent => "email_address",
  #   :company_id => company_id,
  #   :project_id => project_id,
  #   :authorization => "Basic base64Encode",
  #   :debug => nil,
  #   :ini => nil,
  #   :json_out => nil
  # }
  # debug = [nil/true]

  # require gems:
  require 'net/http'
  require 'uri'
  require 'json'
  
  exit(1) if check(options)
  
  # Setup URI connection:
  uri = URI.parse("https://basecamp.com/#{options[:company_id]}/api/v1/projects/#{options[:project_id]}/accesses.json")
  request = Net::HTTP::Get.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = options[:authorization]
  request["User-Agent"] = options[:user_agent] # TBD: user_agent needs regx email validation that removes unsupported text and check email structure.
  # Require https ssl
  req_options = {
    use_ssl: uri.scheme == "https",
  }
  
  # Start the http: request
  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
  
  # If in debug mode than print the response code.
  puts response.code if not options[:debug].nil?

  options[:json_out] = JSON.parse(response.body)
  if not options[:json_out].nil?
    # Output is ini format for easy external parsing.
    output = {:count => 0, :val => nil, :subscribers => nil}
    options[:json_out].each do |id|
      output[:subscribers] = if output[:subscribers].nil? then "#{id['id']}" else "#{output[:subscribers]},#{id['id']}" end
      output[:val] = "#{output[:val]}\r\n[#{id['id']}]"
      output[:val] = "#{output[:val]}\r\nid=#{id['id']}"
      output[:val] = "#{output[:val]}\r\nname=#{id['name']}"
      output[:val] = "#{output[:val]}\r\nemail_address=#{id['email_address']}"
      output[:val] = "#{output[:val]}\r\n"
      output[:count] = output[:count]+1
    end
    options[:subscribers] = output[:subscribers]
    # INI:Section:[lookup]
    options[:ini] = "\r\n[lookup]"
    # section lookup? sections,
    # Sections = section,section,section
    options[:ini] = "#{options[:ini]}\r\nSections=#{output[:subscribers]}"
    # Count = number of section(s)
    options[:ini] = "#{options[:ini]}\r\nCount=#{output[:count]}"
    # Keys = keys available in a given section.
    # keys = key,key,key
    options[:ini] = "#{options[:ini]}\r\nKeys=id,name,email_address"
    options[:ini] = "#{options[:ini]}\r\n#{output[:val]}"
  end
  return options
end

def check(options)
  # Basic check options:
  if options[:user_agent].nil?
    puts "Failed to provide a valid user_agent."
    return true
  end
  if options[:project_id].nil?
    puts "Failed to provide a valid project_id."
    return true
  end
  if options[:company_id].nil?
    puts "Failed to provide a valid company_id."
    return true
  end
  if options[:authorization].nil?
    puts "Failed to provide a valid authorization."
    return true
  end
  return false
end