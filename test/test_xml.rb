#! ruby -I../
require 'nokogiri'

@doc = Nokogiri::XML(File.open("./templates/iar/general.ewp"))
content = @doc.xpath("//option")
puts content


