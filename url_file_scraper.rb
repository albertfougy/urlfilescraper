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
  results[:"Load Time"] = doc.xpath('response//data//median//firstView//loadTime').text
  results[:"First Byte"] = doc.xpath('response//data//median//firstView//TTFB').text
  results[:"Start Render"] = doc.xpath('response//data//median//firstView//render').text
  results[:"Speed Index"]= doc.xpath('response//data//median//firstView//SpeedIndex').text
  results[:"DOM Elements"] = doc.xpath('response//data//median//firstView//domElements').text
  results[:"Time"] = doc.xpath('response//data//median//firstView//fullyLoaded').text
  results
end

def run
  all_results = {}
  web_results = ""

  File.open('urls.txt','r') do |file_handle|
    file_handle.each_line do |line|
      xml_url = get_xml_url(line)
      host = URI.parse(line.strip).host.downcase # need to refactor for malform links
      all_results[host] = return_results(xml_url)
      all_results.each do |key, value|
        value.each do |attri, info|
          puts "#{key}: #{attri} is #{info}"
          web_results += "#{key}: The #{attri} result is #{info} \n"
        end
      end
     web_results
    end
  end

  # hack
  email = SimpleMailer.simple_message('albert@fougy.com'\
                                      , 'More urls for good measure'\
                                      , "#{web_results}")
  email.deliver
end

# Results by console and email

# google.com: Load Time is 955
# google.com: First Byte is 552
# google.com: Start Render is 1178
# google.com: Speed Index is 1470
# google.com: DOM Elements is 375
# google.com: Time is 2263
# www.techcrunch.com: Load Time is 10698
# www.techcrunch.com: First Byte is 670
# www.techcrunch.com: Start Render is 8790
# www.techcrunch.com: Speed Index is 12270
# www.techcrunch.com: DOM Elements is 3556
# www.techcrunch.com: Time is 28637
# albertfougy.com: Load Time is 3818
# albertfougy.com: First Byte is 319
# albertfougy.com: Start Render is 1391
# albertfougy.com: Speed Index is 1576
# albertfougy.com: DOM Elements is 597
# albertfougy.com: Time is 3895
# codebuddies.org: Load Time is 4189
# codebuddies.org: First Byte is 1087
# codebuddies.org: Start Render is 4570
# codebuddies.org: Speed Index is 4684
# codebuddies.org: DOM Elements is 360
# codebuddies.org: Time is 16632

# Pretty printed email send results to console

# => #<Mail::Message:70334122941920, Multipart: false, Headers: <Date: Fri, 22 Dec 2017 20:27:25 -0500>,
# <From: myemailaddress>, <To: recipient's email address >, <Message-ID:
# <gobblygook@my-iMac.fios-router.home.mail>>,
# <Subject: email trail run of hashes>, <Mime-Version: 1.0>, <Content-Type: text/plain>,
# <Content-Transfer-Encoding: 7bit>>

