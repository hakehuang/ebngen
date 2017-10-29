
require 'nokogiri'


module UVMWP
    @@data_provider = {
        "SchemaVersion" => "2.1",
        "Header" => "### uVision Project, (C) Keil Software",
        "WorkspaceName" => "WorkSpace"
    }
    @@data_remove = ["Sle7"]
    def add_node(pnode, hash_data, use_old: false)
        hash_data.each do |key,value|
            if use_old
                sv = pnode.at_xpath(key)
            end
            unless (sv)
                sv = Nokogiri::XML::Node.new(key, xml)
                pnode << sv
            end
            if value.class == Hash
                add_node(sv, value, use_old)
            elsif value.class == Array
                value.each do |va|
                    nsv = Nokogiri::XML::Node.new(key, xml)
                    sv << nsv
                    nsv.content = va                    
                end
            else
                sv.content = value
            end
        end
    end

    def travesernode(node)
        if node.children
            tname  = node.name
            if @@data_provider.has_key?(tname)
                node.content =  @@data_provider[tname]
            end
        end
        node.children.each do |subnode|
            next if subnode.nil?
            travesernode(subnode)
        end
    end
    def init_project_set(xml, settings)
        workspace_node = xml.at_xpath("ProjectWorkspace")
        travesernode(workspace_node)
        workspace_node.set_attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
        workspace_node.set_attribute("xsi:noNamespaceSchemaLocation","project_mpw.xsd")
        dummy_project = workspace_node.at_xpath("/ProjectWorkspace/project")
        dummy_project.set_attribute("template","1")
        @@data_remove.each do |node|
          nt = workspace_node.at_xpath(node)
          nt.remove if ! nt.nil?
        end
    end


    def add_project(xml , project_path)
        # find <ProjectWorkspace>
        workspace_node = xml.at_xpath("/ProjectWorkspace")
        Core.assert(workspace_node, "no <workspace> present")
        templat_project = workspace_node.at_xpath("project[@template='1']")
        new_project = templat_project.dup
        # add <PathAndName>
        path_node = new_project.at_xpath("PathAndName")
        path_node.content = project_path
        workspace_node << new_project
        new_project.at_xpath("NodeIsActive").content = 0
        new_project.at_xpath("NodeIsExpanded").content = 0
        new_project.remove_attribute("template")
        # add project into existing lists
        #@projects[ project_path ] = project_node
    end

	def save(xml, path)
		Core.assert(path.is_a?(String)) do
		    "param is not a string #{path.class.name}"
		end
        workspace_node = xml.at_xpath("/ProjectWorkspace")
        Core.assert(workspace_node, "no <workspace> present")
        #remove old project
        templat_project = workspace_node.at_xpath("project[@template='1']")
        templat_project.remove if ! templat_project.nil?
        FileUtils.mkdir_p File.dirname(path) if ! File.exist?(File.dirname(path))
		File.write(path, xml.to_xml)
	end

end