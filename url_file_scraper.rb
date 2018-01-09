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
      host = URI.parse(line.strip).host.downcase
      all_results[host] = return_results(xml_url)
    end
  end

  all_results.each do |key, value|
    value.each do |attri, info|
      puts "#{key.chomp}: The #{attri} result is: #{info}"
      web_results += "#{key.chomp}: The #{attri} result is: #{info}\n"
    end
  end

  # hack
  email = SimpleMailer.simple_message('joshuakemp85@gmail.com'\
                                      , 'Formatted the results. Fixed urls.txt problem.'\
                                      , "#{web_results}")
  email.deliver
end





