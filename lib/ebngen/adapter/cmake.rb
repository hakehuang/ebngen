
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

	def initialize(project_data, generator_variable, logger = nil)
		@logger = logger 
    	unless (logger)
        	@logger = Logger.new(STDOUT)
        	@logger.level = Logger::WARN
    	end
		set_hash(project_data)
		@project_name = get_project_name()
		@board = get_board()
		@paths = PathModifier.new(generator_variable["paths"])
		@cmake_project_files = {".txt" => nil, ".bat" => nil, ".sh" => nil}
		@project = Hash.new if @project.nil?
		@project["document"] = {"project_name" => @project_name, "board" => @board }
	end

  	def generator(filter, project_data)
  		return if not is_toolchain_support(Project::TOOLCHAIN)
    	create_method(Project::TOOLCHAIN)
    	send(Project::TOOLCHAIN.to_sym, project_data)
    	save_project()
  	end

  	def source()
  		#add sources to target
  		sources = get_src_list(Project::TOOLCHAIN)
  		o_path = get_output_dir(Project::TOOLCHAIN, @paths.rootdir_table)
  		proj_path = File.join(@paths.rootdir_table['output_root'], o_path)
  		@project['sources'] = Array.new
  		sources.each do |src|
			if file['rootdir']
			  if file.has_key? 'path'
			    full_path = path_mod.fullpath(file['rootdir'],file['path'])
			  else
			    full_path = path_mod.fullpath(file['rootdir'],file['source'])
			  end
			else
			  if file.has_key? 'path'
			    full_path = path_mod.fullpath('default_path',file['path'])
			  else
			    full_path = path_mod.fullpath('default_path',file['source'])
			  end
			end
          	ipath = File.join("$ProjDirPath$", @paths.relpath(proj_path, full_path))
		  	@project['sources'].insert(-1, ipath)
		end

  	end

  	def templates()
  		#load tempaltes
  	end

  	def type()
  		@project['type'] = get_type(Project::TOOLCHAIN)
  	end

  	def outdir()
  		@logger.info "#{get_output_dir(Project::TOOLCHAIN, @paths.rootdir_table)}"
  	end

	def targets()
		get_targets(Project::TOOLCHAIN).each do |key, value|
			return if value.nil?
			@project["target"] = Hash.new if @project["target"].nil?
			ta = key.upcase
			@project["target"][ta] = Hash.new if @project["target"][ta].nil?
			#do the target settings
			value.each_key do |subkey|
				methods = self.class.instance_methods(false)
          		if methods.include?("target_#{subkey}".to_sym)
            		send("target_#{subkey}".to_sym, key, value[subkey])
          		else
            		@logger.info "#{key} is not processed"
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
		path = get_output_dir(Project::TOOLCHAIN, @paths.rootdir_table)
		save(File.join(@paths.rootdir_table['output_root'], path, "CMakeLists.txt"), @project)
	end

	def target_cp_defines(target, doc)
		ta = target.upcase
		@project["target"][ta]['cp_defines'] = Array.new
		doc.each do |d, v|
		  if v.nil? 
		  	st_def = "SET(CMAKE_C_FLAGS_#{ta} \"${CMAKE_C_FLAGS_#{ta}} -D#{d} \""
		  else
		  	st_def = "SET(CMAKE_C_FLAGS_#{ta} \"${CMAKE_C_FLAGS_#{ta}} -D#{d}=#{v} \""
		  end
		  @project["target"][ta]['cp_defines'].insert(-1, st_def)
		end
	end

	def target_as_predefines(target, doc)

	end

	def target_as_defines(target, doc)
		ta = target.upcase
		@project["target"][ta]['as_defines'] = Array.new
		doc.each do | d, v|
		  if v.nil? 
		  	st_def = "SET(CMAKE_ASM_FLAGS_#{ta} \"${CMAKE_ASM_FLAGS_#{ta}} -D#{d} \""
		  else
		  	st_def = "SET(CMAKE_ASM_FLAGS_#{ta} \"${CMAKE_ASM_FLAGS_#{ta}} -D#{d}=#{v} \""
		  end
		  @project["target"][ta]['as_defines'].insert(-1, st_def)
		end
	end

	def target_as_include(target, doc)
		ta = target.upcase
		o_path = get_output_dir(Project::TOOLCHAIN, @paths.rootdir_table)
  		proj_path = File.join(@paths.rootdir_table['output_root'], o_path)
		@project["target"][ta]['as_include'] = Array.new
		doc.each do |inc|
          if inc['rootdir']
            full_path = @paths.fullpath(inc['rootdir'],inc['path'])
          else
            full_path = @paths.fullpath('default_path',inc['path'])
          end
          ipath = File.join("$ProjDirPath$", @paths.relpath(proj_path, full_path))
		  inc_str = "include_directories(#{ipath})"
		  @project["target"][ta]['as_include'].insert(-1, inc_str)
		end
	end

	def target_as_flags(target, doc)
		ta = target.upcase
		@project["target"][ta]['as_flags'] = Array.new
		doc.each do |flag|
		  @project["target"][ta]['as_flags'].insert(-1, "SET(CMAKE_ASM_FLAGS_#{ta} \"\$\{CMAKE_ASM_FLAGS_#{ta}\} #{flag}\")")
		end
	end

	def target_cc_predefines(target, doc)

	end

	def target_cc_preincludes(target, doc)

	end

	def target_cc_defines(target, doc)
		ta = target.upcase
		@project["target"][ta]['cc_defines'] = Array.new
		doc.each do |d, v|
		  if v.nil? 
		  	st_def = "SET(CMAKE_C_FLAGS_#{ta} \"${CMAKE_C_FLAGS_#{ta}} -D#{d} \""
		  else
		  	st_def = "SET(CMAKE_C_FLAGS_#{ta} \"${CMAKE_C_FLAGS_#{ta}} -D#{d}=#{v} \""
		  end
		  @project["target"][ta]['cc_defines'].insert(-1, st_def)
		end
	end

	def target_cc_include(target, doc)
		ta = target.upcase
		o_path = get_output_dir(Project::TOOLCHAIN, @paths.rootdir_table)
  		proj_path = File.join(@paths.rootdir_table['output_root'], o_path)
		@project["target"][ta]['cc_include'] = Array.new
		doc.each do |inc|
          if inc['rootdir']
            full_path = @paths.fullpath(inc['rootdir'],inc['path'])
          else
            full_path = @paths.fullpath('default_path',inc['path'])
          end
          ipath = File.join("$ProjDirPath$", @paths.relpath(proj_path, full_path))
		  inc_str = "include_directories(#{ipath})"
		  @project["target"][ta]['cc_include'].insert(-1, inc_str)
		end
	end

	def target_cc_flags(target, doc)
		ta = target.upcase
		@project["target"][ta]['cc_flags'] = Array.new
		doc.each do |flag|
		  @project["target"][ta]['cc_flags'].insert(-1, "SET(CMAKE_C_FLAGS_#{ta} \"\$\{CMAKE_C_FLAGS_#{ta}\} #{flag}\")")
		end
	end

	def target_cxx_predefines(target, doc)

	end

	def target_cxx_preincludes(target, doc)

	end

	def target_cxx_defines(target, doc)
		ta = target.upcase
		@project["target"][ta]['cxx_defines'] = Array.new
		doc.each do |d, v|
		  if v.nil? 
		  	st_def = "SET(CMAKE_CXX_FLAGS_#{ta} \"${CMAKE_CXX_FLAGS_#{ta}} -D#{d} \""
		  else
		  	st_def = "SET(CMAKE_CXX_FLAGS_#{ta} \"${CMAKE_CXX_FLAGS_#{ta}} -D#{d}=#{v} \""
		  end
		  @project["target"][ta]['cxx_defines'].insert(-1, st_def)
		end
	end

	def target_cxx_include(target, doc)
		ta = target.upcase
		o_path = get_output_dir(Project::TOOLCHAIN, @paths.rootdir_table)
  		proj_path = File.join(@paths.rootdir_table['output_root'], o_path)
		@project["target"][ta]['cxx_include'] = Array.new
		doc.each do |inc|
          if inc['rootdir']
            full_path = @paths.fullpath(inc['rootdir'],inc['path'])
          else
            full_path = @paths.fullpath('default_path',inc['path'])
          end
          ipath = File.join("$ProjDirPath$", @paths.relpath(proj_path, full_path))
		  inc_str = "include_directories(#{ipath})"
		  @project["target"][ta]['cxx_include'].insert(-1, inc_str)
		end
	end

	def target_cxx_flags(target, doc)
		ta = target.upcase
		@project["target"][ta]['cxx_flags'] = Array.new
		doc.each do |flag|
		  @project["target"][ta]['cxx_flags'].insert(-1, "SET(CMAKE_CXX_FLAGS_#{ta} \"\$\{CMAKE_CXX_FLAGS_#{ta}\} #{flag}\")")
		end
	end

	def target_ld_flags(target, doc)
		ta = target.upcase
		@project["target"][ta]['ld_flags'] = Array.new
		doc.each do |flag|
		  @project["target"][ta]['ld_flags'].insert(-1, "SET(CMAKE_EXE_LINKER_FLAGS_#{ta} \"\$\{CMAKE_EXE_LINKER_FLAGS_#{ta}\} #{flag}\")")
		end
	end

	def target_libraries(target, doc)
		ta = target.upcase
		convert_string = {'DEBUG' => 'debug', 'RELEASE' => 'optimized'}
		@project["target"][ta]['libraries'] = Array.new
		header = "TARGET_LINK_LIBRARIES(#{project_name}.elf -Wl,--start-group)"
		@project["target"][ta]['libraries'].insert(-1, header)
		doc.each do |library|
		  lib = "target_link_libraries(#{project_name}.elf #{convert_string[ta]} #{library})"
		  @project["target"][ta]['libraries'].insert(-1, lib)
		end
		footer = "TARGET_LINK_LIBRARIES(#{project_name}.elf -Wl,--end-group)"
		@project["target"][ta]['libraries'].insert(-1, footer)
	end

	def target_linker_file(target, doc)
		ta = target.upcase
		o_path = get_output_dir(Project::TOOLCHAIN, @paths.rootdir_table)
  		proj_path = File.join(@paths.rootdir_table['output_root'], o_path)
		@project["target"][ta]['linker_file'] = Array.new
	    if doc['rootdir']
	      full_path = @paths.fullpath(doc['rootdir'],doc['path'])
	    else
	      full_path = @paths.fullpath('default_path',doc['path'])
	    end
	    link = File.join("${ProjDirPath}", @paths.relpath(proj_path, full_path))
		linkstr = "set(CMAKE_EXE_LINKER_FLAGS_#{ta} \"${CMAKE_EXE_LINKER_FLAGS_#{ta}} -T#{link} -static\")"
		@project["target"][ta]['linker_file'].insert(-1, linkstr)
	end

	def target_binary_file(target, doc)
		ta= target.upcase
		@project["target"][ta]["binary_file"] = doc
	end

	def target_outdir(target, doc)

	end
  end
end # end Module IAR