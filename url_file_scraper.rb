require 'rubygems'
require 'nokogiri'
require 'pp'
require 'open-uri'
require 'uri'
require 'selenium-webdriver'
require_relative 'SimpleMailerurl'

# To run script
# $:~/urlfilescraper$ irb -r ./url_file_scraper.rb
# irb(main):001:0> run

def get_xml_url(url)
  driver = Selenium::WebDriver.for :firefox
  driver.navigate.to 'http://www.webpagetest.org'
  wait = Selenium::WebDriver::Wait.new(timeout: 450)
  option = Selenium::WebDriver::Support::Select.new(driver.find_element(name: 'browser'))
  option.select_by(:value, 'IE11') # Select browser type
  input_url = driver.find_element(:id, 'url')
  input_url.clear
  input_url.send_keys(url.to_s)
  driver.find_element(:id, 'start_test-container').click
  # Wait until results to appear
  wait.until { driver.find_element(:id, 'test_results-container') }
  # Change 'result' url parameter into 'xmlResult' to read XML Version of webpagetest.org
  result_url = driver.current_url
  driver.close
  result_url.gsub('result', 'xmlResult')
end

##########################################################
# Create a function in this section?
# Pass an argument here to the XML Parser from Mail
# THIS WILL BE THE MAIN CONTROL STATEMENT
#########################################################

# You need to MATCH SPECIFIC NODE NAME and NODE TEXT
# The fields that I need to extract the data
# Load Time, First Byte,
# Start Render, Speed Index, DOM Elements, Time (Fully
# Loaded)

###################################################
# REDUCED results TO ONE BLOCK
####################################################
def return_results(xml_url)
  doc = Nokogiri::XML(open(xml_url))
  results = {}
  results[:load_time] = doc.xpath('response//data//median//firstView//loadTime').text
  results[:first_byte] = doc.xpath('response//data//median//firstView//TTFB').text
  results[:start_render] = doc.xpath('response//data//median//firstView//render').text
  results[:speed_index] = doc.xpath('response//data//median//firstView//SpeedIndex').text
  results[:dom_elements] = doc.xpath('response//data//median//firstView//domElements').text
  results[:time_fully_loaded] = doc.xpath('response//data//median//firstView//fullyLoaded').text
  results
end


def run
  all_results = {}
  File.open('urls.txt', 'r') do |file_handle|
    file_handle.each_line do |line|
      xml_url = get_xml_url(line)
      host = URI.parse(line.strip).host.downcase # need to refactor for malform links
      all_results[host] = return_results(xml_url)
    end
  end
  all_results
  # runs barely with this included hack
  email = SimpleMailer.simple_message('albert@fougy.com '\
                                      , 'email trail run of hashes'\
                                      , " #{all_results}")
  email.deliver
end

# Results recieved by mail

# irb(main):001:0> run
# => {"google.com"=>{:load_time=>"985", :first_byte=>"767", :start_render=>"1083",
#  :speed_index=>"1371",:dom_elements=>"375", :time_fully_loaded=>"2114"},
#  "www.techcrunch.com"=>{:load_time=>"10848",
#  :first_byte=>"569", :start_render=>"4286", :speed_index=>"4779",
# :dom_elements=>"3571", :time_fully_loaded=>"18624"}}

# Pretty printed email send results to console 

# => <Mail::Message:70237463212660, Multipart: false, Headers: <Date: Fri, 22 Dec 
# 2017 18:48:20 -0500>, <From: MYEMAILADDRESS>, <To: RECIPIENT EMAILADDRESS >, 
# <Message-ID: <5a3d99c41f89a_11a0b3fe16f4417a070239@Als-iMac.fios-router.home.mail>>,
#  <Subject: email trail run of hashes>, <Mime-Version: 1.0>, <Content-Type: text/plain>, 
#  <Content-Transfer-Encoding: 7bit>> 

#########################################################################
# Extract Data and assign to a hash
# assign a hash to a variable containing data
# use the variable and pass it the email container
#########################################################################
# def print_console(simple_message)
#   web_results = ''
#   results.each do |key, value|
#     value.each do |attri, info|
#       puts "#{key}: #{attri} is #{info}"
#       web_results += "#{key}: #{attri} is #{info}"
#     end
#   end
#   puts web_results
# end


#########################################################################
# MAIL SECTION
#########################################################################

# def email_send(simple_message)
#   email = SimpleMailer.simple_message('albert@fougy.com '\
#                                       , 'email trail run of hashes'\
#                                       , print_console(simple_message))
#   email.deliver
# end
##########################################################################
