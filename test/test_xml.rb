#! ruby -I../
require 'nokogiri'
require 'yaml'

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

@doc = Nokogiri::XML(File.open("./templates/iar/general.ewp"))
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
#puts hh.to_yaml
puts content.css("/settingss").count

class Hash
 def to_xml(doc)
   return if doc.nil?
   self.each do |key, value|
     if doc.css("/#{key}").count == 0
       mynode = Nokogiri::XML::Node.new key, doc
     else
       mynode = doc.css("/#{key}")[0]
     end
     doc.add_child mynode
     value.to_xml(mynode) if value.class == Hash
     mynode.content = value if value.class == String or value.class == Fixnum
   end
   return doc
 end
end

doc = @doc.xpath("//project/configuration/settings[position() = 1]/data/option[position() = 2]")
myhash = {'a' => {'b' => "b", 'c' => "c"}}
myhash.to_xml(doc[0])
puts doc



