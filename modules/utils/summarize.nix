{ pkgs
}:
pkgs.writeScriptBin "summarize" ''
  #!${pkgs.ruby}/bin/ruby

  require 'uri'
  require 'json'
  require 'net/http'
  require 'optparse'

  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: summarize [options]"

    opts.on("-s", "--[no-]speak", "Speak out the summary") do |s|
      options[:speak] = s
    end

    opts.on("-o", "--[no-]output", "Print out the summary") do |p|
      options[:print] = p
    end
  end.parse!

  exit if options.empty?

  url = URI('https://api.edenai.run/v2/text/summarize')

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(url)
  request['accept'] = 'application/json'
  request['content-type'] = 'application/json'
  request['authorization'] = 'Bearer ${(import ../../secrets).edenAI}'
  request.body = { providers: 'openai',
                   text: ARGV.join(' ').lines.join(' '),
                   language: nil
                 }.to_json

  response = http.request(request).read_body

  puts response if options[:print]
  system('speak', JSON.parse(response).dig('openai', 'result')) if options[:speak]
''
