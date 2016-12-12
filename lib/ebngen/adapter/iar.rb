
require_relative '_base'
require_relative '_yml_helper'
require_relative '_path_modifier'
require_relative 'iar/eww'
require_relative 'iar/ewp'
require_relative 'iar/ewd'

#replace me when yml_merger becomes gem
require 'yml_merger'
require 'nokogiri'
require 'uri'
require 'open-uri'

module IAR
class Project
	TOOLCHAIN='iar'
	include Base
	include EWP
	include EWD

	def initialize(project_data, generator_variable)
		@paths = PathModifier.new(generator_variable["paths"])
		@iar_project_files = {".ewp" => nil, ".dni" => nil, ".ewd" => nil}
		return nil if project_data['templates'].nil?
		project_data['templates'].each do |template|
			ext = File.extname(template)
			if @iar_project_files.keys.include?(ext)
				path = @paths.fullpath("default_path",template)
				
				case ext
					when ".ewp"
						doc = Nokogiri::XML(open(path))
						@iar_project_files[ext] = doc
					when ".ewd"
						doc = Nokogiri::XML(open(path))
						@iar_project_files[ext] = doc
					when ".dni"
						doc = Nokogiri::XML(open(path))
						@iar_project_files[ext] = doc
				end
			end
		end
	end

  	def generator(filter, project_data, generator_variable)
    	create_method( Project::TOOLCHAIN ,project_data, generator_variable)
    	process(project_data, generator_variable)
  	end

  	def source(project_data, generator_variable)
  		#add sources to target
  		return if @iar_project_files['.ewp'].nil?


  	end

  	def templates(project_data, generator_variable)
  		#load tempaltes

  	end

  	def document(project_data, generator_variable)
  		#set prototype

    end

  	def type(project_data, generator_variable)
  		#set project type
  	end

	def targets(project_data, generator_variable)
		project_data[Project::TOOLCHAIN]['targets'].each_key do |key, value|
			#add target for ewp

			#do the target settins
			value.each_key do |subkey|
				methods = instance_methods(false)
          		if methods.include(subkey.to_sym)
            		send(subkey.to_sym, value[subkey], generator_variable)
          		else
            		puts "#{key} is not processed"
          		end
			end
		end
	end

	def cp_defines(subkey_data, generator_variable)

	end

	def as_predefines(subkey_data, generator_variable)

	end

	def as_defines(subkey_data, generator_variable)

	end

	def as_include(subkey_data, generator_variable)

	end

	def as_flags(subkey_data, generator_variable)

	end

	def cc_predefines(subkey_data, generator_variable)

	end

	def cc_preincludes(subkey_data, generator_variable)

	end

	def cc_defines(subkey_data, generator_variable)

	end

	def cc_include(subkey_data, generator_variable)

	end

	def cc_flags(subkey_data, generator_variable)

	end

	def cxx_predefines(subkey_data, generator_variable)

	end

	def cxx_preincludes(subkey_data, generator_variable)

	end

	def cxx_defines(subkey_data, generator_variable)

	end

	def cxx_include(subkey_data, generator_variable)

	end

	def cxx_flags(subkey_data, generator_variable)

	end

	def ld_flags(subkey_data, generator_variable)

	end

	def libraries(subkey_data, generator_variable)

	end

	def linker_file(subkey_data, generator_variable)

	end

	def outdir(subkey_data, generator_variable)

	end

end

class Project_set
	include EWW
	include UNI_Project
	TOOLCHAIN='iar'

	# initialize EWW class
    # PARAMS:
    # - project_data: specific project data format for a application/library
    # - generator_variable: all dependency in hash
	def initialize(project_data, generator_variable)
		set_hash(project_data)
		@project_name = get_project_name()
		@board = get_board()
		@paths = PathModifier.new(generator_variable["paths"])
		@all_projects_hash = generator_variable["all"]
		@iar_project_files = {".eww" => nil}
		return nil if get_template(Project_set::TOOLCHAIN).nil?
		get_template(Project_set::TOOLCHAIN).each do |template|
			ext = File.extname(template)
			if @iar_project_files.keys.include?(ext)
				path = @paths.fullpath("default_path",template)
				doc = Nokogiri::XML(open(path))
				case ext
					when ".eww"
						@iar_project_files[ext] = doc
					else
						puts "#{ext} not processed"
				end
			end
		end
		#clean the wrkspace in template
	 	@iar_project_files[".eww"].css("workspace/project").each do |node|
        	node.remove
    	end
	 	@iar_project_files[".eww"].css("workspace/batchBuild/batchDefinition").each do |node|
        	node.remove
    	end  	
	end

	def generator()
		add_project_to_set()
		save_set()
	end


	def add_project_to_set()
		return if @iar_project_files.nil?
		return if @iar_project_files['.eww'].nil?
		ext = ".eww"

		#batch build mode is add
		get_targets(Project_set::TOOLCHAIN).each do |target|	
			add_batch_project_target(@iar_project_files[ext], "all", @project_name, target)
			add_batch_project_target(@iar_project_files[ext], target, @project_name, target)
			next if get_libraries(Project_set::TOOLCHAIN).nil?
			get_libraries(Project_set::TOOLCHAIN).each do |lib|
				add_batch_project_target(@iar_project_files[ext], "all", lib, target)
				add_batch_project_target(@iar_project_files[ext], target, lib, target)				
			end
		end
		#add projects
		file = "#{@project_name}_#{@board}.ewp"
		path = File.join('$WS_DIR$',file)
		add_project(@iar_project_files[ext], path)
		#add library projects here
		#get from dependency['libraries'][library_name]
		ustruct = @all_projects_hash
		return if get_libraries(Project_set::TOOLCHAIN).nil?
		get_libraries(Project_set::TOOLCHAIN).each do |lib|
			if ustruct[lib].nil?
				puts "#{lib} information is missing in all hash"
				next
			end
			libname = "#{@project_name}.ewp"
            root = @paths.rootdir_table[@ustruct[library][tool_key]['outdir']['root-dir']]
            lib_path = File.join(root, @ustruct[library][tool_key]['outdir']['path'], libname)
            if @ustruct[ project_name ][ tool_key ].has_key?('outdir')
                ewwpath = File.join(@output_rootdir, @ustruct[ project_name ][ tool_key ][ 'outdir' ] )
            else
                ewwpath = @output_rootdir
            end
            path = Pathname.new(lib_path).relative_path_from(Pathname.new(ewwpath))
			#more to come
		end

	end

	def save_set()
		path = get_output_dir(Project_set::TOOLCHAIN, @paths.rootdir_table)
		puts @paths.rootdir_table['output_root']
		puts path
		puts "#{@project_name}_#{@board}.eww"
		save(@iar_project_files['.eww'], File.join(@paths.rootdir_table['output_root'], path, "#{@project_name}_#{@board}.eww"))
	end

end

end # end Module IAR