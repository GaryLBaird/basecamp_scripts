require 'json'
require 'base64'
file = File.read('basecampConfiguration.json')
data = JSON.parse(file)
config = {"authorization" => nil, "username" => nil, "password" => nil, "subscribers" => nil,
          "User_Agent" => nil, "company_id" => nil, "project_id" => nil, "base64Hash" => nil
          }
data['companies']['company'].each { |id|
  if id['default']
    config['company_id'] = id['id']
    puts id['id']
    puts id['name']
    puts id['default']
  end
}
data['projects']['project'].each { |id|
  if id['default']
    config['project_id'] = id['id']
    puts id['id']
    puts id['name']
    puts id['default']
  end
}
data['users']['user'].each { |id|
  puts id["id"]
  puts id["name"]
  puts id["email_address"]
  puts id["User_Agent"]
  puts id["default"]
  puts id["upload"]
  id["login_credentials"].each { |user|
    if id['upload']
      if not user["username"].nil?
        if not user["password"].nil?
          config['base64Hash'] = "Basic " + (Base64.encode64("#{user['username']}:#{user['password']}"))
        end
      end
      config['username'] = user["username"].to_s
      config['password'] = user["password"].to_s
      config['authorization'] = id["authorization"].to_s
    end
    puts user["username"]
    puts user["password"]
  }
  puts id["authorization"]
  if id['default']
    puts id['id']
    if config['subscribers'].nil?
      config['subscribers'] = "#{id['id']}"
    else
      config['subscribers'] = "#{config['subscribers']}, #{id['id']}"
    end
  end
}
data['files']['file'].each { |id|
  puts id["fname"]
  puts id["fdir"]
  puts id["fullpath"]
}
puts data['content']
puts config['subscribers']
if not config['base64Hash'].nil?
  if config['authorization'].nil?
    config['authorization'] = config['base64Hash']
  end
end
puts "base64Hash=" + config['base64Hash'].to_s
puts "authorization=" + config['authorization'].to_s