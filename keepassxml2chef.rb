#!/usr/bin/env ruby

require 'nokogiri'
# help on nokogiri
# http://ruby.bastardsbook.com/chapters/html-parsing/
# export PATH="/opt/chefdk/embedded/bin:$PATH"

#added for interact with server throught ruby.
require 'rubygems'
require 'chef/config'
require 'chef/log'
require 'chef/rest'


class String
def black;          "\033[30m#{self}\033[0m" end
def red;            "\033[31m#{self}\033[0m" end
def green;          "\033[32m#{self}\033[0m" end
def brown;          "\033[33m#{self}\033[0m" end
def blue;           "\033[34m#{self}\033[0m" end
def magenta;        "\033[35m#{self}\033[0m" end
def cyan;           "\033[36m#{self}\033[0m" end
def gray;           "\033[37m#{self}\033[0m" end
def bg_black;       "\033[40m#{self}\033[0m" end
def bg_red;         "\033[41m#{self}\033[0m" end
def bg_green;       "\033[42m#{self}\033[0m" end
def bg_brown;       "\033[43m#{self}\033[0m" end
def bg_blue;        "\033[44m#{self}\033[0m" end
def bg_magenta;     "\033[45m#{self}\033[0m" end
def bg_cyan;        "\033[46m#{self}\033[0m" end
def bg_gray;        "\033[47m#{self}\033[0m" end
def bold;           "\033[1m#{self}\033[22m" end
def reverse_color;  "\033[7m#{self}\033[27m" end
end


# This is required parametrs
# Define chef server parameters
  chef_server_url="https://chef.cvision.lab"

# This may be client or user. Default chef server admin is "admin".
  client_name = "admin"
  home = ENV['HOME']
  signing_key_filename="#{home}/.chef/admin.pem"

if ARGV.empty?
  puts "Please provide exported xml keepassx plaintext passwords file as first argument."
  exit
end

unless File.file?(signing_key_filename)
  puts "Client private key #{signing_key_filename} not found! Exiting.".bg_red
  puts "This tool can operate with default chef server admin user 'admin' and reads private key from file - #{signing_key_filename}".bg_red
  exit
  else
  puts "Using default client name - #{client_name}".cyan
  puts "Client key founded. Using default private key file - #{signing_key_filename}.".cyan
end

begin
doc = Nokogiri::HTML(open(ARGV[0]))
puts "Parsing input xml file - #{ARGV[0]}".cyan
rescue
 puts "Cannot read/parse xml source - #{ARGV[0]}".bg_red
 exit
end

doc.css('group entry').each do |entry|
  bag = entry.parent.css('title')[0].text
  item = entry.css('username').text
  pass = entry.css('password').text
  acc = entry.css('comment').text.empty? ? "name:admin"  : entry.css('comment').text
  adm = entry.css('url').text.empty? ? "admin" : entry.css('url').text

  puts ""
  puts "Found XML item     : #{bag} #{item}".cyan
  puts "  username : #{item}"
  puts "  password : #{pass.gsub(/./,'#')}"
  puts "  admins   : #{adm}"
  puts "  accessor : #{acc}"

  found = true

  begin
    rest = Chef::REST.new(chef_server_url, client_name, signing_key_filename)
    rest.get_rest("/data/#{bag}/#{item}")
  rescue
   found = false
  end

  if (found)

    puts "Found existing data bag: #{bag}, item: #{item}".cyan
    cmd_update="knife vault update #{bag} #{item} '{ \"password\":\"#{pass}\" }' --admins #{adm} -S #{acc} >/dev/null 2>&1"
    #puts cmd_update
    unless system(cmd_update)
	puts "Error updating  #{bag} #{item}".red
    else  
    	puts "Success updated #{bag} #{item}".green
    end

  else

    puts "Not found data bag: #{bag}, item: #{item}".cyan
    cmd_create="knife vault create #{bag} #{item} '{ \"password\":\"#{pass}\" }' --admins #{adm} -S #{acc} >/dev/null 2>&1"
    #puts cmd_create
    unless system(cmd_create)
         puts "Error creating #{bag} #{item}".red
    else
 	 puts "Success created #{bag} #{item}".green
    end

  end

end

puts ""
puts "Remove not required bags manually via knife data bag remove or web ui if you need."
puts "Chef vault only update/add values to server."
puts ""
puts "Don't forget to remove plaintext exported keepassx db at file: #{ARGV[0]}".bg_red.bold
puts ""
