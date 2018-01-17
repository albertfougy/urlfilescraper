require 'rubygems'
require 'nokogiri'
require 'pp'
require 'open-uri'
require 'uri'
require 'selenium-webdriver'
require_relative 'Simple-Mailer'


def get_xml_url(url)
  driver = Selenium::WebDriver.for :firefox
  driver.navigate.to 'http://www.webpagetest.org'
  wait = Selenium::WebDriver::Wait.new(timeout: 300)
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

# Parsing the webpage performance server response
# Extracting data values

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
      print "Successfully read #{line}"
      all_results[host] = return_results(xml_url)
    end
  end
  puts "\n\n"

  # print the results on separate lines
  all_results.each do |domain, value|
    print "#{domain}: "
    web_results +="#{domain}: "
    value.each do |attri, info|
      print "The #{attri} result is: #{info} "
      web_results +="The #{attri} result is: #{info} "
    end
    puts "\n"
  end

  # send results to recipient via email
  email = SimpleMailer.simple_message('albert@fougy.com'\
                                      ,'printed not puts the results per domain'\
                                      , "#{web_results}")
  email.deliver
end

# this starts the script.
# Run the script: ruby url_file_scraper.rb
run



