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


# first let's try by selecting by element instead of xpath
# Xpath version
# element of the browser
# //*[(@id = "browser")]
# path of the selection
# //*[@id="browser"]/option[6]

# select and click dropdown menu
# dropDownMenu = @driver.find_element(:class, 'browser')
# option = Selenium::WebDriver::Support::Select.new(dropDownMenu)
# option.select_by(:text, 'Billing to Shipping')
# option.select_by(:value, 'Billing to Shipping')



# strip down version from above without looping
option = Selenium::WebDriver::Support::Select.new(@driver.find_element(name: 'browser'))
option.select_by(:value, 'IE11')


@driver.find_element(:id, 'start_test-container').click

wait = Selenium::WebDriver::Wait.new(:timeout => 450) # seconds
wait.until {
  @driver.find_element(:id, 'test_results-container')
}

result_url= @driver.current_url
xml_url = result_url.gsub('result', 'xmlResult')
doc = Nokogiri::XML(open(xml_url))

##########################################################
# Create a function in this section
# Pass an argument here to the XML Parser from Mail
# THIS WILL BE THE MAIN CONTROL STATEMENT
#########################################################



# You need to MATCH SPECIFIC NODE NAME and NODE TEXT

# The fields that I need to extract the data

# Load Time, First Byte,
# Start Render, Speed Index, DOM Elements, Time (Fully
# Loaded)


###################################
# DO NOT USE THIS SAMPLE CODE
##################################


=begin
You are well on your way to learning the basics of coding for real :-) 
What you are doing is looping over all of the nodes of the API response. 
It is actually much simpler than that, down the road you will need to iterate over the entire API response for solving issues. 
For now though all you do is grab the couple of values that we care about ( just a few from the UI ), like LoadTime, TimeToFirstByte...etc.

parsed_res = Crack::XML.parse(response)          #Parse web page test response NOTE: you don't have to use Crack I am just giving an example
status = parsed_res["response"]["statusCode"]    # Assigns the HTTP code to status - this is referred to "walking the tree"
=end

# Code is for every node inside the tree that is NOT empty
# Will not use to solve this solution

#leaves = doc.xpath('response//data//median//firstView//*[not(*)]')


leaves = doc.xpath('response//data//median//firstView//loadTime')

leaves.each do |node|
  puts "#{node.name}: #{node.text}" unless node.text.empty?
end

leaves = doc.xpath('response//data//median//firstView//TTFB')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" unless node.text.empty?
  # => First Byte
end

leaves = doc.xpath('response//data//median//firstView//render')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" unless node.text.empty?
  # => Start Render
end


leaves = doc.xpath('response//data//median//firstView//SpeedIndex')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" unless node.text.empty?
  # => Speed Index
end

################################
# DOM Elements
################################

leaves = doc.xpath('response//data//median//firstView//docComplete')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" unless node.text.empty?
  # => Time
end


leaves = doc.xpath('response//data//median//firstView//bytesInDoc')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" unless node.text.empty?
  # => Requests
end

leaves = doc.xpath('response//data//median//firstView//requestsDoc')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" unless node.text.empty?
  # => Bytes In
end

leaves = doc.xpath('response//data//median//firstView//fullyLoaded')
leaves.each do |node|
  puts "#{node.name}: #{node.text}" unless node.text.empty?
  # => Time (Fully Loaded)
end






################################################################
# ORIGINAL CODE IDEA FOR ITERATION OF XML NODE 
################################################################
# doc.xpath('response//data//median//firstView').each do |firstview_element|
#   puts firstview_element.text
#   puts firstview_element.xpath('loadTime').text
  #putsfirstview_element.xpath[0].text
  # count=1
  # sitcom_element.xpath('characters/character').each do
  #   |character_element|
  #   puts "    #{count}.character : " + character_element.text
  #   count=count+1
  # end
# end


####################################################

# I think I need to separate the ‘content’ into ‘url’ and ‘load_time’
# content = doc
#           .xpath('response//data//testUrl'\
#           , 'response//data//average//firstView//loadTime')
#           .map(&:text).join(' ')

# #########################################################
# xpath of the main table we want to grab the results from
# #########################################################

# rows =doc.xpath('//*[@id="tableResults"]/tbody')
# rows =doc.xpath('response//data//average//firstView')
# //*[@id="tableResults"]/tbody/tr[2]/th[2]




# details = rows.collect do |row|
#   detail = {}
#   [
#     [:LoadTime, 'response//data//average//firstView//loadTime'],

# # //*[@id="LoadTime"]

# #     [:name, 'td[3]/div[2]/span/a/text()'],
# #     [:date, 'td[4]/text()'],
# #     [:time, 'td[4]/span/text()'],
# #     [:number, 'td[5]/a/text()'],
# #     [:views, 'td[6]/text()'],


# ].each do |name, xpath|
#     detail[name] = row.at_xpath(xpath).to_s.strip
#   end
#   detail
# end
# pp details


# => [{:time=>"23:35",
# =>   :title=>"Vb4 Gold Released",
# =>   :number=>"24",
# =>   :date=>"06 Jan 2010",
# =>   :views=>"1,320",
# =>   :name=>"Paul M"}]

# #########################################################



############################################################################

# CURRENT WORKING CODE SNIPPET
# LOAD VIEW ONLY

############################################################################

# url = doc.xpath('response//data//testUrl').text
# load_time = doc.xpath('response//data//average//firstView//loadTime').text

############################################################################



# <loadTime> is the name of the tag. Would like to output tag as a string
# output desired is: => google.com Load Time seconds_in_numbers

##########################################################################
# Call a function inside mail script to XML Parser
# DELIVER MAIL SECTION
#########################################################################

# email = SimpleMailer.simple_message('al@fougy.com'\
#                                    , 'The script works for me.'\
#                                    , "#{url} Load Time #{load_time}")
#                                      #,"#{details}")
# email.deliver
##########################################################################

# dirty string interpolation
# will refactor inserting HTML header one day.

# working on new script
# puts "#{details}"
##################
# PRINT TO SCREEN
##################
# puts "#{url} Load Time #{load_time}"

@driver.close