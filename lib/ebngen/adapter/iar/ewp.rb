require 'nokogiri'
#require 'FileUtils'

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
 end #end to_xml
end #end Hash

module EWP
  def load_node(doc, xpath)
  	return doc.xpath(xpath)
  end

  def new_target(target, doc, name = 'debug')
	nset = load_node(doc, "/project/configuration")
	#use existing one
	nset.each do |element|
		if element.xpath("name").text.downcase == target.downcase
			return element
		end
	end
	#create new one
	nset.each do |element|
		#use the first available configuration
		t = element.dup
		t.xpath('name').text = target
			#doc.xpath("/project") << t
		element.add_previous_sibling(t)
		return t
	end
	nil
  end
  
  # remove_targets remove unused targets
  # Params:
  # - doc: the xml node project file
  # - targets_in: used target array
  def remove_targets(doc, targets_in)
  	#remove the target that not in the targets_in
  	nset = load_node(doc, "//project/configuration")
  	targets_in.collect{|x| x.downcase}
    nset.each do |element|
  	  target = element.xpath("name").text.downcase
  	  if !targets_in.include?(target)
  	  	element.remove
  	  end	
	  end
  end

  def remove_sources(doc)
    puts "remove source"
    groups = load_node(doc, "//group")
    groups.each do |ele|
      ele.remove
    end
    files = load_node(doc, "//file")
    files.each do |ele|
      ele.remove
    end   
  end

  def remove_unused(doc, xpath, **names)
  	nset = load_node(doc, xpath)
 	  nset.each do |element|
 		  names.each do |key, value|
			  if element.xpath(key).text.downcase == value.downcase
				  element.remove
			  end
		  end
	  end
  end

  def create_node(doc, hash_value)
    hash_value.to_xml(doc)
  end

  def set_specific(target_node, doc, xpath_table)
  	doc.each do |key, value|
      checked = false
  		options = target_node.xpath("//option")
      if ! xpath_table[key].nil?
        #can retrieve from talbe directly
        node = target_node.xpath(xpath_table[key]['xpath'][0])
        value.each do |subkey, subvalue|
          node.css(subkey).text = subvalue
        end
        checked = true
        next
      end
  		options.each do |option|
  			if option.css('name').text == key
  				value.each do |subkey, subvalue|
  					option.css(subkey).text = subvalue
  				end
          #processing done
          checked = true
          break
  			end
  		end
      if !checked
        #not an exist option need create new node
        names = target_node.xpath('name')
        names.each do |nn|
          if nn.text == key
            create_node(nn.parent, value)
            checked = true
            break
          end
        end
      end
      if !checked
        puts "can not find match for #{key}"
      end
  	end
  end

  def save(xml, path)
    Core.assert(path.is_a?(String)) do
        "param is not a string #{path.class.name}"
    end
    FileUtils.mkdir_p File.dirname(path) if ! File.exist?(File.dirname(path))
    File.write(path, xml.to_xml)
  end


end