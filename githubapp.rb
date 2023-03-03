require 'openssl'
require 'jwt'  # https://rubygems.org/gems/jwt
require 'net/http'
# load OpenURI
require 'open-uri'



# Constants
App_slug = "samstestgithubapp"
Url_of_github_enterprise = "https://sam-rowe-1677599078.ghe-test.com"

# Private key contents
private_pem = File.read("./samstestgithubapp.private-key.pem")
private_key = OpenSSL::PKey::RSA.new(private_pem)

# Generate the JWT
payload = {
  # issued at time, 60 seconds in the past to allow for clock drift
  iat: Time.now.to_i - 60,
  # JWT expiration time (10 minute maximum)
  exp: Time.now.to_i + (10 * 60),
  # GitHub App's identifier
  iss: "2"
}

jwt = JWT.encode(payload, private_key, "RS256")
puts "The JWT is \"#{jwt}\"\n\n"

response_unparsed = ""
URI.open("#{Url_of_github_enterprise}/api/v3/app/installations",  "Authorization" => "Bearer #{jwt}", "Accept" => "application/vnd.github+json" ) {|http|

  http.each_line {|line| 
    response_unparsed += line
    # puts line
  }

}

response_json = JSON.parse(response_unparsed)

# find the installation id that corrosponds to the app_slug in the response_json object
installation_id = 0
token_url = ""
response_json.each { |installation| 
  if (installation["app_slug"] == App_slug) then
     installation_id = installation["id"]
     token_url = installation["access_tokens_url"]
  end
}

# puts installation_id
puts "The token url is #{token_url} \n\n"
puts "The installation id is #{installation_id} \n\n"

response = ""

# Make a HTTPS POST to the token_url to get the token with the Authroization header set to "Bearer #{jwt}" and return the intstallation access token
uri = URI.parse(token_url)
Net::HTTP.start(uri.host, uri.port, :use_ssl => true ) { |https|
  request = Net::HTTP::Post.new(uri.request_uri, headers = {
    "Authorization" => "Bearer #{jwt}", 
    "Accept" => "application/vnd.github+json"
  })
  response = https.request(request)
}

# puts response.body
response_json = JSON.parse(response.body)
puts response_json

token = response_json["token"]

puts token

# set enviornment variable GHES_TOKEN to the access token
ENV["GHES_TOKEN"] = token
