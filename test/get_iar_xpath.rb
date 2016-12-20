#! ruby -I../
require 'nokogiri'
require 'yaml'

if ARGV[0] == '-h'
	puts "ruby get_iar_xpath.rb iar.ewp"
	exit
end

def load_node(doc, xpath)
	return doc.xpath(xpath)
end

  def remove_targets(doc, targets_in)
  	#remove the target that not in the targets_in
  	nset = load_node(doc, "/project/configuration")
  	targets_in.collect{|x| x.downcase}
    nset.each do |element|
	  target = element.xpath("name").text.downcase
	  if !targets_in.include?(target)
	  	element.remove
	  end	
	end
  end

@doc = Nokogiri::XML(File.open(ARGV[0]))
content = @doc.xpath("/project/configuration")
puts content.count
remove_targets(@doc,["debug"])
content = @doc.xpath("/project/configuration")
options = content.xpath("//option")
hh = Hash.new

options.each do |option|
	#puts Nokogiri::CSS.xpath_for option.css_path
	hh[option.css('name').text] = Hash.new
	hh[option.css('name').text]['xpath'] = Nokogiri::CSS.xpath_for option.css_path
	#hh[option.css('name').text]['state'] = option.css('state').text
	#puts option.css('state').text
end
puts hh.to_yaml




