#! ruby -I../
require 'nokogiri'
require 'yaml'
require 'xsd_populator'
require 'xsd_reader'
require 'nokogiri'

reader = XsdPopulator.new(:xsd => 'templates/mdk/project_projx.xsd')

#reader = XsdPopulator.new(:xsd => 'ddex-ern-v36.xsd')
#puts reader.populated_xml # => XML-string
dom = Nokogiri::XML(reader.populated_xml)

hash = dom.root.element_children.each_with_object(Hash.new) do |e, h|
  h[e.name.to_sym] = e.content
end

value_array = []

hash.values().each do |v|
	v.each_line do |vl|
	  if ! vl.strip!().nil?
	  	if vl.length > 0
          value_array.insert(-1, vl)
        end
	  end
    end
end

puts value_array.uniq!



