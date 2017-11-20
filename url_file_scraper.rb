require 'rubygems'
require 'nokogiri'
require 'pp'
require 'open-uri'
require 'uri'
require 'selenium-webdriver'
require_relative 'SimpleMailerurl'


# @driver is an instance variable
@driver = Selenium::WebDriver.for :firefox
@driver.navigate.to 'http://www.webpagetest.org'
wait = Selenium::WebDriver::Wait.new(:timeout => 5)

input = wait.until {
  element = @driver.find_element(:id, 'url')
  element if element.displayed?
}
@driver.find_element(:id, 'url').clear


File.open("urls.txt", "r") do |file_handle|
  file_handle.each_line do |line|
  input.send_keys(line)
  end
end



# strip down version from above without looping
option = Selenium::WebDriver::Support::Select.new(@driver.find_element(name: 'browser'))
option.select_by(:value, 'IE11')


@driver.find_element(:id, 'start_test-container').click

wait = Selenium::WebDriver::Wait.new(:timeout => 450) # seconds
wait.until {
  @driver.find_element(:id, 'test_results-container')
}

################################################
# Change 'result' url parameter into 'xmlResult' 
# to read XML Version of webpagetest.org
################################################
result_url= @driver.current_url
xml_url = result_url.gsub('result', 'xmlResult')
doc = Nokogiri::XML(open(xml_url))

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

###############################################################
# OUTPUTTING AS NORMAL, BUT CANNOT PASS TO EMAIL SCRIPT WITHOUT
# FIGURING OUT HOW TO REFACTOR ASSIGN ALL THE DATA TO A VARIABLE
# THEN PASS TO EMAIL BLOCK BELOW
###############################################################

leaves = doc.xpath('response//data//median//firstView//loadTime')

leaves.each do |node|
  puts "#{node.name}: #{node.text}" 
end

leaves = doc.xpath('response//data//median//firstView//TTFB')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" 
  # => First Byte
end

leaves = doc.xpath('response//data//median//firstView//render')
leaves.each do |node|
  puts "#{node.name}: #{node.text}"
  # => Start Render
end


leaves = doc.xpath('response//data//median//firstView//SpeedIndex')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" 
  # => Speed Index
end

# ################################
# # DOM Elements
# ################################

leaves = doc.xpath('response//data//median//firstView//docTime')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" #unless node.text.empty?
  # => Time
end


leaves = doc.xpath('response//data//median//firstView//bytesInDoc')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" 
  # => Requests
end

leaves = doc.xpath('response//data//median//firstView//requestsDoc')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" #
  # => Bytes In
end

leaves = doc.xpath('response//data//median//firstView//fullyLoaded')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" 
  # => Time (Fully Loaded)
end


# Extract Data and assign to a hash
# assign a hash to a variable containing data
# use the variable and pass it the email container

###################################################
# OLD SCRIPT ATTEMPT FOR 1 NODE. OBSOLETE, BUT KEPT
# AS AN IDEA FOR REFACTORING ON THIS IDEA. 
# PLEASE IGNORE

####################################################

# I think I need to separate the ‘content’ into ‘url’ and ‘load_time’
# content = doc
#           .xpath('response//data//testUrl'\
#           , 'response//data//average//firstView//loadTime')
#           .map(&:text).join(' ')

# #########################################################



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
# Call a function TO MAIL OR PASS A VARIABLE FROM XML Parser
# WORKS ONLY FOR 1 NODE => 'loadTime'
# MAIL SECTION
#########################################################################

# email = SimpleMailer.simple_message('al@fougy.com'\
#                                    , 'The script works for me.'\
#                                    , "#{url} Load Time #{load_time}")
#                                      #,"#{details}")
# email.deliver
##########################################################################

########################################
# PRINT TO SCREEN. WORKS ONLY FOR 1 NODE
#########################################
# puts "#{url} Load Time #{load_time}"

@driver.close