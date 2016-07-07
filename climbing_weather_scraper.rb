require 'HTTParty'
require 'Nokogiri'
require 'JSON'
require 'pry'

# this app scrapes the Mountain Project links
# from the climbingweather.com area pages

areas_page = HTTParty.get("http://www.climbingweather.com/forecast-by-state")

parse_page = Nokogiri::HTML(areas_page)

# nodeset of state links
states = parse_page.css('h2 a')
state_hash = Hash.new
# hash of state names with relative hrefs as values
states.each { |s| state_hash[s.content] = s['href'] }
# delete last item since empty
state_hash.delete("")
# => h (state hash)

# state_hash.keys
# => ["Alabama", "Alaska", ... , "Wyoming"]
# h.values
# => ["/Alabama", "/Alaska", ..., "/Wyoming"]



links = parse_page.xpath("//div[@style='margin-bottom: 10px']/div/a")
# select valid climbing area links, those without "//" in the url path
areas = links.select{|link| link['href'][1] != "/"}
area_hash = Hash.new
# populate hash with area names/urls as keys/vals respectively
areas.each { |a| area_hash[a.content] = {path: a['href'], mp: nil} }

# area_hash.keys
# => ["areas"]
# area_hash.values
# => ["urls"]


# individual area pages
area_hash.each do |area, urls|
  puts "checking #{area} page"
  # for each iteration through our areas hash we set the doc to the area page
  current_page = HTTParty.get("http://www.climbingweather.com" + urls[:path])
  doc = Nokogiri::HTML(current_page)
  # grab all links with the rightBoxContent class
  links = doc.css('div.rightBoxContent a')
  # select link to MP
  mp = links.select {|link| link.content == "Mountain Project"}
  # grab url from mp array
  mp[0].nil? ? mp_url = "none found" : mp_url = mp[0]['href']
  # set mp url path in area_hash for current area
  urls[:mp] = mp_url
end

Pry.start(binding)
