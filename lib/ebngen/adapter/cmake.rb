
require_relative '_base'
require_relative '_yml_helper'
require_relative '_path_modifier'
require_relative 'cmake/txt'


#replace me when yml_merger becomes gem
require 'yml_merger'
require 'nokogiri'
require 'uri'
require 'open-uri'

module CMAKE
class Project
	TOOLCHAIN='cmake'
	include Base
	include TXT
	include UNI_Project

	def initialize(project_data, generator_variable)
		set_hash(project_data)
		@project_name = get_project_name()
		@board = get_board()
		@paths = PathModifier.new(generator_variable["paths"])
		@cmake_project_files = {".txt" => nil, ".bat" => nil, ".sh" => nil}
		return nil if get_template(Project_set::TOOLCHAIN).nil?
		get_template(Project_set::TOOLCHAIN).each do |template|
			ext = File.extname(template)
			if @cmake_project_files.keys.include?(ext)
				path = @paths.fullpath("default_path",template)
			end
		end
	end

  	def generator(filter, project_data)
    	create_method( Project::TOOLCHAIN ,project_data)
    	send(Project::TOOLCHAIN.to_sym, project_data)
    	save_project()
  	end

  	def source(project_data)
  		#add sources to target
  		return if @iar_project_files['.txt'].nil?
  		remove_sources(@iar_project_files['.txt'])
  		set_hash(project_data)
  		sources = get_src_list(Project::TOOLCHAIN)
  		o_path = get_output_dir(Project_set::TOOLCHAIN, @paths.rootdir_table)
  		proj_path = File.join(@paths.rootdir_table['output_root'], o_path)
  		add_sources(@iar_project_files['.txt'], sources, @paths, proj_path)
  	end

  	def templates(project_data)
  		#load tempaltes
  	end

  	def document(project_data)
  		#set prototype

    end

  	def type(project_data)
  		#set project type
  	end

  	def outdir(project_data)

  	end

	def targets(project_data)
		get_targets(Project_set::TOOLCHAIN).each do |key, value|
			return if value.nil?
			#do the target settings
			value.each_key do |subkey|
				methods = instance_methods(false)
          		if methods.include("target_#{subkey}".to_sym)
            		send("target_#{subkey}".to_sym, key, value[subkey])
          		else
            		puts "#{key} is not processed"
          		end
			end
		end
		remove_targets(@cmake_project_files['.txt'], project_data[Project::TOOLCHAIN]['targets'].keys)
	end

    # tool_chain_specific attribute for each target
    # Params:
    # - target: the name for the target
    # - doc: the hash that holds the data
	def target_tool_chain_specific(target, doc)
		#no specific for cmake
	end

	def save_project()
		path = get_output_dir(Project_set::TOOLCHAIN, @paths.rootdir_table)
		save(@cmake_project_files['.txt'], File.join(@paths.rootdir_table['output_root'], path, "CMakeLists.txt"))
	end

	def target_cp_defines(target, doc)

	end

	def target_as_predefines(target, doc)

	end

	def target_as_defines(target, doc)

	end

	def target_as_include(target, doc)

	end

	def target_as_flags(target, doc)
		ta = target.upcase
		@as_flags = Array.new
		doc.each do |flag|
		  @as_flags.insert(-1, "SET(CMAKE_ASM_FLAGS_#{ta} \"\$\{CMAKE_ASM_FLAGS_#{ta}\} -DDEBUG\")")
		end
	end

	def target_cc_predefines(target, doc)

	end

	def target_cc_preincludes(target, doc)

	end

	def target_cc_defines(target, doc)

	end

	def target_cc_include(target, doc)

	end

	def target_cc_flags(target, doc)

	end

	def target_cxx_predefines(target, doc)

	end

	def target_cxx_preincludes(target, doc)

	end

	def target_cxx_defines(target, doc)

	end

	def target_cxx_include(target, doc)

	end

	def target_cxx_flags(target, doc)

	end

	def target_ld_flags(target, doc)

	end

	def target_libraries(target, doc)

	end

	def target_linker_file(target, doc)

	end

	def target_outdir(target, doc)

	end

end

end # end Module IAR