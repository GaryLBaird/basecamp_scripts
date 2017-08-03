def getConfig()
  require 'json'
  require 'base64'
  file = File.read('basecampConfiguration.json')
  data = JSON.parse(file)
  config = {:fname => nil, :fdir => nil,	:subscribers => nil, :fullpath => nil,
            :user_agent => nil, :content => nil, :filedate => nil, :company_id => nil,
            :project_id => nil, :authorization => nil, :content_type => "application/zip",
            :username => nil , :password => nil, :get_users => nil, :debug => nil,
            :ini => nil, :json_out => nil, :nofile => nil, :base64Hash => nil}
  config[:debug] = ENV['debug']
  data['companies']['company'].each { |id|
    if id['default']
      config[:company_id] = id['id']
    end
  }
  data['projects']['project'].each { |id|
    if id['default']
      config[:project_id] = id['id']
    end
  }
  data['users']['user'].each { |id|
    
    if not config[:debug].nil? then puts id["id"] end
    if not config[:debug].nil? then puts id["name"] end
    if not config[:debug].nil? then puts id["email_address"] end
    if not config[:debug].nil? then puts id["User_Agent"] end
    if id["default"] = true
      config[:subscribers] = if config[:subscribers].nil? then "#{id['id']}" else "#{config[:subscribers]},#{id['id']}" end
    end
    if not config[:debug].nil? then puts id["upload"] end
    id["login_credentials"].each { |user|
      if id['upload']
      config[:user_agent] = id["email_address"].to_s
        if not user["username"].nil?
          if not user["password"].nil?
            config[:base64Hash] = "Basic " + (Base64.encode64("#{user['username']}:#{user['password']}"))
          end
        end
        config[:username] = user["username"].to_s
        config[:password] = user["password"].to_s
        config[:authorization] = id["authorization"].to_s
      end
      if not config[:debug].nil? then puts user["username"] end
      if not config[:debug].nil? then puts user["password"] end
    }
    if not config[:debug].nil? then puts id["authorization"] end
  }
  data['files']['file'].each { |id|
    if not config[:debug].nil? then puts id["fname"] end
    if not config[:debug].nil? then puts id["fdir"] end
    if not config[:debug].nil? then puts id["fullpath"] end
  }
  if not config[:debug].nil? then puts data['content'] end
  if not config[:debug].nil? then puts config[:subscribers] end
  if not config[:base64Hash].nil?
    if config[:authorization].nil?
      config[:authorization] = config[:base64Hash]
    end
  end
  if not config[:debug].nil? then puts "base64Hash=" + config[:base64Hash].to_s end
  if not config[:debug].nil? then puts "authorization=" + config[:authorization].to_s end
  if not config[:debug].nil? then puts config.to_s end
  return config
end