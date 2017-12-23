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


# def run
#   all_results = {}
#   File.open('urls.txt', 'r') do |file_handle|
#     file_handle.each_line do |line|
#       xml_url = get_xml_url(line)
#       host = URI.parse(line.strip).host.downcase # need to refactor for malform links
#       all_results[host] = return_results(xml_url)
#     end
#   end
#   all_results
#   # runs barely with this included hack
#   email = SimpleMailer.simple_message('albert@fougy.com '\
#                                       , 'email trail run of hashes'\
#                                       , " #{all_results}")
#   email.deliver
# end

# Need to be broken into two more methods. Too long.
def run
  all_results = {}
  web_results = ""
  File.open('urls.txt', 'r') do |file_handle|
    file_handle.each_line do |line|
      xml_url = get_xml_url(line)
      host = URI.parse(line.strip).host.downcase # need to refactor for malform links
      all_results[host] = return_results(xml_url)
      all_results.each do |key, value|
        value.each do |attri, info|
          puts "#{key}: #{attri} is #{info}"
          web_results += "#{key}: #{attri} is #{info} \n"
        end
      end
      web_results
    end
  end
  all_results

  # hack
  email = SimpleMailer.simple_message('albert@fougy.com '\
                                      , 'email trail run of hashes'\
                                      , "#{web_results}")
  email.deliver
end

# Results by console and email

# 2.4.1 :001 > run
# google.com: load_time is 1507
# google.com: first_byte is 513
# google.com: start_render is 789
# google.com: speed_index is 965
# google.com: dom_elements is 375
# google.com: time_fully_loaded is 1679
# google.com: load_time is 1507
# google.com: first_byte is 513
# google.com: start_render is 789
# google.com: speed_index is 965
# google.com: dom_elements is 375
# google.com: time_fully_loaded is 1679
# www.techcrunch.com: load_time is 10679
# www.techcrunch.com: first_byte is 465
# www.techcrunch.com: start_render is 8562
# www.techcrunch.com: speed_index is 8584
# www.techcrunch.com: dom_elements is 3607
# www.techcrunch.com: time_fully_loaded is 17264

# Pretty printed email send results to console

# => #<Mail::Message:70334122941920, Multipart: false, Headers: <Date: Fri, 22 Dec 2017 20:27:25 -0500>,
# <From: alfougy@gmail.com>, <To: albert@fougy.com >, <Message-ID:
# <5a3db0fd788a8_11e8e3ff7f043f78811978@Als-iMac.fios-router.home.mail>>,
# <Subject: email trail run of hashes>, <Mime-Version: 1.0>, <Content-Type: text/plain>,
# <Content-Transfer-Encoding: 7bit>>

#########################################################################
# Refactor section that need to be reworked
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
