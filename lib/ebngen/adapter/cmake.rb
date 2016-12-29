
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
			@project = Hash.new if @project.nil?
			@project[ta] = Hash.new if @project[ta].nil?
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
		ta = target.upcase
		@project[ta]['as_defines'] = Array.new
		doc.each do | d, v|
		  if value.nil? 
		  	st_def = "SET(CMAKE_ASM_FLAGS_#{ta} \"${CMAKE_ASM_FLAGS_#{ta}} -D#{d} \""
		  else
		  	st_def = "SET(CMAKE_ASM_FLAGS_#{ta} \"${CMAKE_ASM_FLAGS_#{ta}} -D#{d}=#{v} \""
		  end
		  @project[ta]['as_defines'].insert(-1, st_def)
		end
	end

	def target_as_include(target, doc)
		ta = target.upcase
		o_path = get_output_dir(Project_set::TOOLCHAIN, @paths.rootdir_table)
  		proj_path = File.join(@paths.rootdir_table['output_root'], o_path)
		@project[ta]['as_include'] = Array.new
		doc.each do |inc|
          if inc['rootdir']
            full_path = path_mod.fullpath(inc['rootdir'],inc['path'])
          else
            full_path = path_mod.fullpath('default_path',inc['path'])
          end
          ipath = File.join("$ProjDirPath$", path_mod.relpath(proj_path, full_path))
		  @project[ta]['as_include'].insert(-1, ipath)
		end
	end

	def target_as_flags(target, doc)
		ta = target.upcase
		@project[ta]['as_flags'] = Array.new
		doc.each do |flag|
		  @project[ta]['as_flags'] .insert(-1, "SET(CMAKE_ASM_FLAGS_#{ta} \"\$\{CMAKE_ASM_FLAGS_#{ta}\} #{flag}\")")
		end
	end

	def target_cc_predefines(target, doc)

	end

	def target_cc_preincludes(target, doc)

	end

	def target_cc_defines(target, doc)
		ta = target.upcase
		@project[ta]['cc_defines'] = Array.new
		doc.each do |d, v|
		  if value.nil? 
		  	st_def = "SET(CMAKE_C_FLAGS_#{ta} \"${CMAKE_C_FLAGS_#{ta}} -D#{d} \""
		  else
		  	st_def = "SET(CMAKE_C_FLAGS_#{ta} \"${CMAKE_C_FLAGS_#{ta}} -D#{d}=#{v} \""
		  end
		  @project[ta]['cc_defines'].insert(-1, st_def)
		end
	end

	def target_cc_include(target, doc)
		ta = target.upcase
		o_path = get_output_dir(Project_set::TOOLCHAIN, @paths.rootdir_table)
  		proj_path = File.join(@paths.rootdir_table['output_root'], o_path)
		@project[ta]['cc_include'] = Array.new
		doc.each do |inc|
          if inc['rootdir']
            full_path = path_mod.fullpath(inc['rootdir'],inc['path'])
          else
            full_path = path_mod.fullpath('default_path',inc['path'])
          end
          ipath = File.join("$ProjDirPath$", path_mod.relpath(proj_path, full_path))
		  @project[ta]['cc_include'].insert(-1, ipath)
		end
	end

	def target_cc_flags(target, doc)
		ta = target.upcase
		@project[ta]['cc_flags'] = Array.new
		doc.each do |flag|
		  @project[ta]['cc_flags'] .insert(-1, "SET(CMAKE_C_FLAGS_#{ta} \"\$\{CMAKE_C_FLAGS_#{ta}\} #{flag}\")")
		end
	end

	def target_cxx_predefines(target, doc)

	end

	def target_cxx_preincludes(target, doc)

	end

	def target_cxx_defines(target, doc)

	end

	def target_cxx_include(target, doc)
		ta = target.upcase
		o_path = get_output_dir(Project_set::TOOLCHAIN, @paths.rootdir_table)
  		proj_path = File.join(@paths.rootdir_table['output_root'], o_path)
		@project[ta]['cxx_include'] = Array.new
		doc.each do |inc|
          if inc['rootdir']
            full_path = path_mod.fullpath(inc['rootdir'],inc['path'])
          else
            full_path = path_mod.fullpath('default_path',inc['path'])
          end
          ipath = File.join("$ProjDirPath$", path_mod.relpath(proj_path, full_path))
		  @project[ta]['cxx_include'].insert(-1, ipath)
		end
	end

	def target_cxx_flags(target, doc)
		ta = target.upcase
		@project[ta]['cc_flags'] = Array.new
		doc.each do |flag|
		  @project[ta]['cc_flags'] .insert(-1, "SET(CMAKE_CXX_FLAGS_#{ta} \"\$\{CMAKE_CXX_FLAGS_#{ta}\} #{flag}\")")
		end
	end

	def target_ld_flags(target, doc)
		ta = target.upcase
		@project[ta]['cc_flags'] = Array.new
		doc.each do |flag|
		  @project[ta]['cc_flags'] .insert(-1, "SET(CMAKE_EXE_LINKER_FLAGS_#{ta} \"\$\{CMAKE_EXE_LINKER_FLAGS_#{ta}\} #{flag}\")")
		end
	end

	def target_libraries(target, doc)
		ta = target.upcase
		convert_string = {'DEBUG' => 'debug', 'RELEASE' => 'optimized'}
		@project[ta]['libraries'] = Array.new
		header = "TARGET_LINK_LIBRARIES(#{project_name}.elf -Wl,--start-group)"
		@project[ta]['libraries'].insert(-1, header)
		doc.each do |library|
		  lib = "target_link_libraries(#{project_name}.elf #{convert_string[ta]} #{library})"
		  @project[ta]['libraries'].insert(-1, lib)
		end
		footer = "TARGET_LINK_LIBRARIES(#{project_name}.elf -Wl,--end-group)"
		@project[ta]['libraries'].insert(-1, footer)
	end

	def target_linker_file(target, doc)
		ta = target.upcase
		o_path = get_output_dir(Project_set::TOOLCHAIN, @paths.rootdir_table)
  		proj_path = File.join(@paths.rootdir_table['output_root'], o_path)
		@project[ta]['link_file'] = Array.new
		doc.each do |link|
          if link['rootdir']
            full_path = path_mod.fullpath(link['rootdir'],link['path'])
          else
            full_path = path_mod.fullpath('default_path',link['path'])
          end
          link = File.join("${ProjDirPath}", path_mod.relpath(proj_path, full_path))
		  linkstr = "set(CMAKE_EXE_LINKER_FLAGS_#{ta} \"${CMAKE_EXE_LINKER_FLAGS_#{ta}} -T#{link} -static\")"
		  @project[ta]['link_file'].insert(-1, ipath)
		end		

	end

	def target_outdir(target, doc)

	end
  end
end # end Module IAR