{ pkgs
}:
pkgs.writeScriptBin "summarize" ''
  #!${pkgs.ruby}/bin/ruby

  require 'uri'
  require 'json'
  require 'net/http'

  url = URI("https://api.edenai.run/v2/text/summarize")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(url)
  request["accept"] = 'application/json'
  request["content-type"] = 'application/json'
  request["authorization"] = "Bearer #{ENV['EDENAI_API_KEY']}"
  request.body = { providers: "openai",
                   text: ARGV.join(' '),
                   language: nil
                 }.to_json

  puts JSON.parse(http.request(request).read_body).dig("openai", "result")
''
