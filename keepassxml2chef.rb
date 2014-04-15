#!/usr/bin/env ruby

# help on nokogiri
# http://ruby.bastardsbook.com/chapters/html-parsing/

if ARGV.empty?
  puts "Please provide exported xml keepassx plaintext passwords file as first argument."
  exit
end

unless system("test -f #{ARGV[0]}")
  puts "File not found! Exiting. Please provide correct xml keepassx db file"
  exit
end

require 'nokogiri'

doc = Nokogiri::HTML(open(ARGV[0]))

doc.css('group entry').each do |entry|
  bag = entry.parent.css('title')[0].text
  item = entry.css('username').text
  pass = entry.css('password').text
  acc = entry.css('comment').text.empty? ? "name:admin"  : entry.css('comment').text
  adm = entry.css('url').text.empty? ? "admin" : entry.css('url').text

  puts ""
  puts "Found databag item     : #{bag} #{item}"
  puts "	found username : #{item}"
  puts "	found password : #{pass.gsub(/./,'#')}"
  puts "	found admins   : #{adm}"
  puts "	found accessor : #{acc}"
  cmd_create="knife vault create #{bag} #{item} '{\"password\":\"#{pass}\" }' --admins #{adm} -S #{acc} >/dev/null 2>&1"
  cmd_update="knife vault update #{bag} #{item} '{\"password\":\"#{pass}\" }' --admins #{adm} -S #{acc} >/dev/null 2>&1"
  if system("knife data bag show #{bag} >/dev/null 2>&1")
    unless system(cmd_update)
	puts "Error update bag       : #{bag} #{item}"
    else 
    	puts "Success updated        : #{bag} #{item}"
    end
  elsif system(cmd_create)
	puts "Success created bag    : #{bag} #{item}"
  else
    puts "Error create bag       : #{bag} #{item}"
  end
end

puts ""
puts "Remove not required bags manually via knife data bag remove or web ui if you need."
puts "Chef vault only update/add values to server."
puts ""
puts "Don't forget to remove plaintext exported keepassx db at file: #{ARGV[0]}"
puts ""
