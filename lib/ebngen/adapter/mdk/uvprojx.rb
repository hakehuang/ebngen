require 'nokogiri'
require 'pathname'

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

module UVPROJX
  def travesernode(node)
    if node.children
      content  = node.content
      if @@data_provider.has_key?(content.strip)
        node.content =  @@data_provider[content.strip]
      end
    end
    node.children.each do |subnode|
      next if subnode.nil?
      travesernode(subnode)
    end
 
  end
  def init_project(xml, settings)
    project_node = xml.at_xpath("Project")
    travesernode(project_node)
    #puts workspace_node
    #puts xml
    #mdkProvider.take(:title) # => 'The Monkey Wrench Gang'
    #mdkProvider.take(:author) # => 'Edward Abbey'
    #mdkProvider.take(:display_title) # => 'Edward Abbey - The Monkey Wrench Gang'
    #mdkProvider.take(:price) # => 9.99
  end

  def load_node(doc, xpath)
  	return doc.xpath(xpath)
  end

  def new_target(target, doc, name = 'debug')
  	nset = load_node(doc, "//Targets/Target")
  	#use existing one
  	nset.each do |element|
  		if element.css("TargetName").text.downcase == target.downcase
        puts "find existing #{element.css("/TargetName").text.downcase}"
        return element
  		end
  	end
  	#create new one
  	nset.each do |element|
  		#use the first available configuration
      @logger.info "add target #{target}"
  		t = element.dup
  		t.at_css("TargetName").content = target
  			#doc.xpath("/project") << t
  		element.add_previous_sibling(t)
  		return t
  	end
	 nil
  end
  
  # remove_targets remove unused targets
  # Params:
  # - doc: the xml node project file
  # - targets_in: used target array (will keep)
  def remove_targets(doc, targets_in)
  	#remove the target that not in the targets_in
  	nset = load_node(doc, "//Targets/Target")
  	targets_in.collect{|x| x.downcase} 
    nset.each do |element|
  	  target = element.xpath("TargetName").text.downcase
  	  if !targets_in.include?(target)
  	  	element.remove
  	  end	
	  end
  end

  # remove_sources remove source files
  # Params:
  # - doc: the xml node project file
  def remove_sources(doc)
    groups = load_node(doc, "//Group")
    groups.each do |ele|
      ele.remove
    end
    files = load_node(doc, "//File")
    files.each do |ele|
      ele.remove
    end   
  end
  # remove_sources remove unused node
  # Params:
  # - doc: the xml node project file
  # - xpath: xpath to the node
  # - **names: node attribute that need to remove defined in hash
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

  # create_node convert hash to xml and add to doc
  # Params:
  # - doc: the xml node project file
  # - hash_value: hash that defines the nodes structure
  def create_node(doc, hash_value)
    hash_value.to_xml!(doc)
  end

  # append_node convert hash to xml and append to doc
  # Params:
  # - doc: the xml node project file
  # - hash_value: hash that defines the nodes structure
  def append_node(doc, hash_value)
    hash_value.to_xml(doc)
  end

  # add_specific 
  # Params:
  # - doc: hash to add to target
  # - target_node: node to be added to
  # - note: 
  #     can not add none exist node for mdk xml
  def add_specific(target_node, doc)
    doc.each do |key, value|
      options = target_node.xpath(key)
      options.each do |option|
        if value.class == Hash
          value.each do |subnode|
              add_specific(option, subnode)
          end
        elsif value.class == String
            option.content += ";#{value}"
        elsif value.class == Array
            value.each do |line|
              option.content += ";#{line}"
            end
        else
          puts "not support by set_specific #{value}"
        end
      end
    end
  end
  # set_specific 
  # Params:
  # - doc: hash to add to target
  # - target_node: node to be added to
  # - note: 
  #     can not add none exist node for mdk xml
  def set_specific(target_node, doc)
    doc.each do |key, value|
      options = target_node.xpath(key)
      options.each do |option|
        if value.class == Hash
          value.each do |subnode|
              add_specific(option, subnode)
          end
        elsif value.class == String
            option.content = value
            break
        elsif value.class == Array
            option.content = ""
            value.each do |line|
              option.content += ";#{line}"
            end
            break
        else
          puts "not support by set_specific #{value}"
        end
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
          node << "<GroupName>#{virtual_dir}</GroupName>"
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
      gfiles = Nokogiri::XML::Node.new('File', doc)
      sfile = Nokogiri::XML::Node.new('FileName', gfiles)
      spfile = Nokogiri::XML::Node.new('FilePath', gfiles)
      if file['rootdir']
        full_path = path_mod.fullpath(file['rootdir'],file['path'])
      else
        full_path = path_mod.fullpath('default_path',file['path'])
      end
      spfile.content = File.join("$PROJ_DIR$", path_mod.relpath(proj_path, full_path))
      sfile.content = File.basename(file['path'])
      gfiles << spfile
      gfiles << sfile
      doc.root << gfiles
    end
  end
end