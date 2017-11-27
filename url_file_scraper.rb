require 'rubygems'
require 'nokogiri'
require 'pp'
require 'open-uri'
require 'uri'
require 'selenium-webdriver'
require_relative 'SimpleMailerurl'

# To run script
# $:~/urlfilescraper$ irb -r ./url_file_scraper.rb
# irb(main):001:0> email_send(results)


def get_xml_url(url)

  @driver = Selenium::WebDriver.for :firefox
  @driver.navigate.to 'http://www.webpagetest.org'
  wait = Selenium::WebDriver::Wait.new(:timeout => 450)


  #input = wait.until do
  input_url = @driver.find_element(:id, 'url')
  #  element if element.displayed?
  #end
  input_url.clear();
  input_url.send_keys(url.to_s)
  @driver.find_element(:id, 'start_test-container').click

  # Wait until results to appear
  wait.until {@driver.find_element(:id, 'test_results-container')}
  ################################################
  # Change 'result' url parameter into 'xmlResult' 
  # to read XML Version of webpagetest.org
  ################################################
  result_url= @driver.current_url
  @driver.close
  result_url.gsub('result', 'xmlResult')
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

######################################################################
# strip down version from above without looping. Select browser type
########################################################################
# option = Selenium::WebDriver::Support::Select.new(@driver.find_element(name: 'browser'))
# option.select_by(:value, 'IE11')
# @driver.find_element(:id, 'start_test-container').click
# wait = Selenium::WebDriver::Wait.new(:timeout => 450) # seconds








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

#############################################################
# ATTEMPTED REFACTOR : FAIL!
#############################################################

# doc.xpath('response//data//median//firstView//*[not(*)]').each do |webtest|
#   information = {
#     'Load Time':webtest.at_xpath("response//data//median//firstView//*[text()='loadTime']")
#     }.to_a.join(":#{webtest.text} ")
#   puts information

# end


# Extract Data and assign to a hash
# assign a hash to a variable containing data
# use the variable and pass it the email container

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
  puts results
end

# {:load_time=>"1839", :first_byte=>"370", :start_render=>"669", :speed_index=>"1173",\
# :dom_elements=>"379", :time_fully_loaded=>"4524"}


############################################################################

# CURRENT WORKING CODE SNIPPET
# WORKS FOR 1 NODE 'loadTime'

############################################################################

# url = doc.xpath('response//data//testUrl').text
# load_time = doc.xpath('response//data//average//firstView//loadTime').text

############################################################################



# <loadTime> is the name of the tag. Would like to output tag as a string
# output desired is: => google.com Load Time seconds_in_numbers

##########################################################################
# MAIL SECTION
#########################################################################

#email = SimpleMailer.simple_message('al@fougy.com '\
#                                    ,'email trail run of hash. 1 domain only'\
#                                    ,"#{results}")
#email.deliver
##########################################################################

########################################
# PRINT TO SCREEN. WORKS ONLY FOR 1 NODE
#########################################
# puts "#{url} Load Time #{load_time}"

