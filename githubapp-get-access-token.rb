require 'openssl'
require 'jwt'  # https://rubygems.org/gems/jwt
require 'net/http'
# load OpenURI
require 'open-uri'


# Write a usage message to the console
def usage
  puts "Usage: ruby githubapp-get-access-token.rb"
  puts "This script will generate a JWT and use it to get an installation access token for a github app"
  puts "3 environment variables must be set:"
  puts "APP_SLUG - the app slug of the github app"
  puts "URL_OF_GITHUB_ENTERPRISE - the url of the github enterprise server"
  puts "PRIVATE_KEY_FILE - the path to the private key file for the GitHub app"
end

# Read Constants from environment variables
if (ENV["APP_SLUG"]) then
  App_slug = ENV["APP_SLUG"]
else
  App_slug = ""
end
if (ENV["URL_OF_GITHUB_ENTERPRISE"]) then
  Url_of_github_enterprise = ENV["URL_OF_GITHUB_ENTERPRISE"]
else
  Url_of_github_enterprise = ""
end
if (ENV["PRIVATE_KEY_FILE"]) then
  Private_key_file = ENV["PRIVATE_KEY_FILE"]
else
  Private_key_file = ""
end

# If App_slug is not set or is empty then exit with a message and an error code
if (App_slug == "" || Private_key_file == "" || Url_of_github_enterprise = "" ) then
  usage()
  exit 1
end

# Private key contents
private_pem = File.read(Private_key_file)
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
# puts "The JWT is \"#{jwt}\"\n\n"

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
# puts "The token url is #{token_url} \n\n"
# puts "The installation id is #{installation_id} \n\n"

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
# puts response_json

token = response_json["token"]

puts "The access token that has been returned by the Github App \"#{token}\""
puts "The access token can be used to access the Github Enterprise Server at \"#{Url_of_github_enterprise}\""
puts "Where subsiquent requests need it the access token has been set in the enviornment variable \"GHES_TOKEN\""

# set enviornment variable GHES_TOKEN to the access token
ENV["GHES_TOKEN"] = token


