require 'nokogiri'
#require 'FileUtils'

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

  def target_xml_to_hash(doc, taget = 'debug')
  	@target_hash = Hash.new if @target_hash.nil?
  	@target_hash[target] = Hash.new if @target_hash[target].nil?
  	options = content.xpath("//option")
  	options.each do |option|
  		name = option.css('name').text
  		state = option.css('state').text
		@target_hash[target][name] = Hash.new if @target_hash[target][name].nil?
		@target_hash[target][name]['xpath'] = Nokogiri::CSS.xpath_for option.css_path
		@target_hash[target][name]['value'] = state
	end
  end

  def set_specific(target_node, doc, xpath_table)
  	doc.each do |key, value|
  		options = target_node.xpath("//option")
      if ! xpath_table[key].nil?
        #can retrieve from talbe directly
        node = target_node.xpath(xpath_table[key]['xpath'][0])
        value.each do |subkey, subvalue|
          node.css(key).text = value
        end
        next
      end
  		options.each do |option|
  			if option.css('name').text == key
  				value.each do |subkey, subvalue|
  					option.css(key).text = value
  				end
          #processing done
          break
  			end 
  		end
  	end
  end
end