require 'nokogiri'
require 'pathname'
#require 'FileUtils'

class Hash
 def to_xml(doc)
   return if doc.nil?
   self.each do |key, value|
     mynode = Nokogiri::XML::Node.new key, doc
     doc.add_child mynode
     value.to_xml(mynode) if value.class == Hash
     mynode.content = value if value.class == String or value.class == Fixnum
   end
   return doc
 end #end to_xml
 def to_xml!(doc)
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
 end #end to_xml!
end #end Hash

module EWP
  def load_node(doc, xpath)
  	return doc.xpath(xpath)
  end

  def new_target(target, doc, name = 'debug')
  	nset = load_node(doc, "/project/configuration")
  	#use existing one
  	nset.each do |element|
  		if element.css("/name").text.downcase == target.downcase
        puts "find existing #{element.css("/name").text.downcase}"
        return element
  		end
  	end
  	#create new one
  	nset.each do |element|
  		#use the first available configuration
  		t = element.dup
  		t.at_css('/name').content = target
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
    hash_value.to_xml!(doc)
  end

  def append_node(doc, hash_value)
    hash_value.to_xml(doc)
  end

  def add_specific(target_node, doc)
    doc.each do |key, value|
      checked = false
      options = target_node.xpath(".//option")
      options.each do |option|
        if option.css('name').text == key
          value.each do |subkey, subvalue|
            if subvalue.class == String
              if option.css(subkey)[0].content.nil?
                option.css(subkey)[0].content = subvalue
              else
                create_node(option, {subkey => subvalue})
              end
            elsif subvalue.class == Array
              subvalue.each do |line|
                append_node(option, {subkey => line})
              end
            else
              puts "not supported format must be string or array"
              next
            end
          end
          #processing done
          checked = true
          break
        end
      end
      if !checked
        #not an exist option need create new node
        data_node = target_node.xpath('data')
        option_node = create_node(data_node, "option" => nil)
        create_node(option_node, {"name" => key})
        value.each do |subkey, subvalue|
          if subvalue.class == String
            create_node(option_node, {subkey => subvalue})
          elsif subvalue.class == Array
            subvalue.each do |line|
              append_node(option_node, {subkey => line})
            end
          else
            puts "not supported format must be string or array"
            next
          end
        end
      end
      if !checked
        puts "can not find match for #{key}"
      end
    end
  end

  def set_specific(target_node, doc)
  	doc.each do |key, value|
      checked = false
  		options = target_node.xpath(".//option")
  		options.each do |option|
  			if option.css('name').text == key
  				value.each do |subkey, subvalue|
            if subvalue.class == String
              if option.css(subkey)[0].content.nil?
                option.css(subkey)[0].content = subvalue
              else
                create_node(option, {subkey => subvalue})
              end
            elsif subvalue.class == Array
              subvalue.each do |line|
                append_node(node, {subkey => line})
              end
            else
              puts "not supported format must be string or array"
              next
            end
  				end
          #processing done
          checked = true
          break
  			end
  		end
      if !checked
        #not an exist option need create new node
        #not an exist option need create new node
        data_node = target_node.xpath('data')
        option_node = create_node(data_node, "option" => nil)
        create_node(option_node, {"name" => key})
        value.each do |subkey, subvalue|
          if subvalue.class == String
            create_node(option_node, {subkey => subvalue})
          elsif subvalue.class == Array
            subvalue.each do |line|
              append_node(option_node, {subkey => line})
            end
          else
            puts "not supported format must be string or array"
            next
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

  def add_sources(doc, source_hash, path_mod, proj_path)
    groups_existing = Array.new
    files_hash = Hash.new
    source_hash.each do |src|
      rootdir = src['rootdir']
      virtual_dir = src['virtual_dir'] if src.has_key? 'virtual_dir'
      virtual_dir = src['virtual-dir'] if src.has_key? 'virtual-dir'
      if src.has_key?('path')
        path = src['path']
      else
        path = src['source']
      end
      if virtual_dir
        if ! groups_existing.include?(virtual_dir)
          groups_existing.insert(-1, virtual_dir)
          node = Nokogiri::XML::Node.new 'group', doc
          node << "<name>#{virtual_dir}</name>"
          doc.root << node
        end
        files_hash[virtual_dir] = Array.new if files_hash[virtual_dir].nil?
        files_hash[virtual_dir].insert(-1, {'path' => path, 'rootdir' => rootdir})
      else
        files_hash["_"] = Array.new if files_hash["_"].nil?
        files_hash["_"].insert(-1, {'path' => path, 'rootdir' => rootdir})
      end
    end #end source_hash
    doc.css("//group").each do |node|
      files_hash[node.text].each do |file|
        gfiles = Nokogiri::XML::Node.new('file', node)
        sfile = Nokogiri::XML::Node.new('name', gfiles)
        if file['rootdir']
          full_path = path_mod.fullpath(file['rootdir'],file['path'])
        else
          full_path = path_mod.fullpath('default_path',file['path'])
        end
        sfile.content = File.join("$PROJ_DIR$", path_mod.relpath(proj_path, full_path))
        gfiles << sfile
        node << gfiles
      end
    end
    return if files_hash["_"].nil?
    files_hash["_"].each do |file|
      gfiles = Nokogiri::XML::Node.new('file', doc)
      sfile = Nokogiri::XML::Node.new('name', gfiles)
      if file['rootdir']
        full_path = path_mod.fullpath(file['rootdir'],file['path'])
      else
        full_path = path_mod.fullpath('default_path',file['path'])
      end
      sfile.content = File.join("$PROJ_DIR$", path_mod.relpath(proj_path, full_path))
      gfiles << sfile
      doc.root << gfiles
    end
  end
end