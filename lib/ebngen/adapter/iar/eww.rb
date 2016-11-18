
require 'nokogiri'

module EWW

    def add_batch_project_target(xml, batchname, project, target)
        definition_node = xml.at_xpath("/workspace/batchBuild/batchDefinition[name[text()='#{batchname}']]")
        unless (definition_node)
            build_node = xml.at_xpath("/workspace/batchBuild")
            unless (build_node)
                workspace_node = xml.at_xpath("/workspace")
                Core.assert(workspace_node, "no <workspace> present")
                # <batchBuild>
                build_node = Nokogiri::XML::Node.new("batchBuild", xml)
                workspace_node << build_node
            end
            # <batchDefinition>
            definition_node = Nokogiri::XML::Node.new("batchDefinition", xml)
            build_node << definition_node
            # <name>
            name_node = Nokogiri::XML::Node.new("name", xml)
            name_node.content = batchname
            definition_node << name_node
        end
        # <member>
        member_node = Nokogiri::XML::Node.new("member", xml)
        definition_node << member_node
        # <project>
        project_node = Nokogiri::XML::Node.new("project", xml)
        project_node.content = project
        member_node << project_node
        # <configuration>
        configuration_node = Nokogiri::XML::Node.new("configuration", xml)
        configuration_node.content = target
        member_node << configuration_node
    end


    def add_project(xml , project_path)
        # find <ProjectWorkspace>
        workspace_node = xml.at_xpath('/workspace')
        # add <project>
        project_node = Nokogiri::XML::Node.new("project", xml)
        workspace_node << project_node
        # add <PathAndName>
        path_node = Nokogiri::XML::Node.new("path", xml)
        path_node.content = project_path
        project_node << path_node
        # add project into existing lists
        @projects[ project_path ] = project_node
    end

	def save(xml, path)
		Core.assert(path.is_a?(String)) do
		    "param is not a string #{path.class.name}"
		end
		File.force_write(path, xml.to_s)
	end

end