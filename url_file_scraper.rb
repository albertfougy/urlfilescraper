require 'rubygems'
require 'nokogiri'
require 'pp'
require 'open-uri'
require 'uri'
require 'selenium-webdriver'
require_relative 'SimpleMailerurl'

# To run script
# $:~/urlfilescraper$ irb -r ./url_file_scraper.rb
# irb(main):001:0> run()


def get_xml_url(url)

  driver = Selenium::WebDriver.for :firefox
  driver.navigate.to 'http://www.webpagetest.org'
  wait = Selenium::WebDriver::Wait.new(:timeout => 450)


######################################################################
# Select browser type . Need work into this script somehow.
########################################################################
  option = Selenium::WebDriver::Support::Select.new(driver.find_element(name: 'browser'))
  option.select_by(:value, 'IE11')
  input_url = driver.find_element(:id, 'url')
  input_url.clear();
  input_url.send_keys(url.to_s)
  driver.find_element(:id, 'start_test-container').click

  # Wait until results to appear
  wait.until {
    driver.find_element(:id, 'test_results-container')
  }
  ################################################
  # Change 'result' url parameter into 'xmlResult'
  # to read XML Version of webpagetest.org
  ################################################
  result_url= driver.current_url
  driver.close
  result_url.gsub('result', 'xmlResult')
end



###################################################################################################
# https://stackoverflow.com/questions/6674230/how-would-you-parse-a-url-in-ruby-to-get-the-main-domain
###################################################################################################
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
# REDUCED RESULTS TO ONE BLOCK
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
  File.open("urls.txt", "r") do |file_handle|
    file_handle.each_line do |line|
      xml_url = get_xml_url(line)
      host = URI.parse(line.strip).host.downcase # need to refactor for malform links
      all_results[host] = return_results(xml_url)
    end
  end
  all_results
end

# {:load_time=>"1891", :first_byte=>"401", :start_render=>"793", :speed_index=>"996", :dom_elements=>"420", :time_fully_loaded=>"3825"}
# {:load_time=>"17029", :first_byte=>"567", :start_render=>"2184", :speed_index=>"13849", :dom_elements=>"3617", :time_fully_loaded=>"48256"}
# => {"www.google.com"=>nil, "www.techcrunch.com"=>nil}

#############################################################################
# Extract Data and assign to a hash
# assign a hash to a variable containing data
# use the variable and pass it the email container
##########################################################################
# MAIL SECTION
#########################################################################

#email = SimpleMailer.simple_message('al@fougy.com '\
#                                    ,'email trail run of hash. 1 domain only'\
#                                    ,"#{results}")
#email.deliver
##########################################################################


