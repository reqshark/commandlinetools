require 'rubygems'
require 'eventmachine'
require 'em-http'
require 'awesome_print'

$stdout.sync = true

class KeyboardHandler < EM::Connection
  include EM::Protocols::LineText2
  
  def post_init
    print "> "
  end
  
  def receive_line(line)
    line.chomp!
    line.gsub!(/^\s+/, '')
  
    case(line)
    when /^get (.*)$/ then
      site = $1.chomp
      sites = site.split(',')
      
      multi = EM::MultiRequest.new
      sites.each do |s|
        multi.add(EM::HttpRequest.new(s).get)
      end
      multi.callback {
        multi.responses[:succeeded].each do |h|
          puts ""
          awesome_print h.response_header.status
          awesome_print h.response_header
          print "> "
        end
        multi.responses[:failed].each do |h|
          puts "#{h.inspect} failed"
        end
      }
      print "> "
      
    when /^exit$/ then  
      EM.stop

    when /^help$/ then
      puts "get URL   - gets a URL"
      puts "exit      - exits the app"
      puts "help      - this help"
      print "> "
    end
  end
end


EM::run {
  EM.open_keyboard(KeyboardHandler)
}
puts "Finished"