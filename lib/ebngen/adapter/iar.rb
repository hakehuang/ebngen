
require_relative 'base'
#replace me when yml_merger becomes gem
require_relative '../yml_merger'

require 'nokogiri'
require 'open-uri'
require 'uri'
require '_path_modifier'
require 'eww'
require 'ewp'
require 'ewd'


module IAR
class Project
	TOOLCHAIN='iar'
	extend Base
	extend EWP
	extend EWD

	def initialize(project_data, generator_variable)
		@paths = PathModifier.new(generator_variable["paths"])
		@iar_project_files = {".ewp" => nil, ".dni" => nil, ".ewd" => nil}
		return nil if project_data['templates'].nil?
		project_data['templates'].each do |template|
			ext = File.extname(template)
			if @iar_project_files.keys.include?(ext)
				path = @paths.fullpath("default_path",template)
				file  = open(path){|f| f.read}
				case ext
					when ".eww"
						@iar_project_files[ext] = Nokogiri::XML(file) {|x| x.noblanks }
					when ".ewp"
						@iar_project_files[ext] = Nokogiri::XML(file) {|x| x.noblanks }
					when ".ewd"
						@iar_project_files[ext] = Nokogiri::XML(file) {|x| x.noblanks }
					when ".dni"
						@iar_project_files[ext] = path
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
	extend EWW
	TOOLCHAIN='iar'
	def initialize(project_data, *generator_variable)
		@project_name = project_data['document']['project_name']
		@board = project_data['document']['board']
		@unifmt = Unifmt.new({})
		@unifmt.load(project_data)
		@paths = PathModifier.new(generator_variable["paths"])
		@all_projects_hash = generator_variable["all"]
		@iar_project_sets = {".eww" => nil}
		return nil if project_data['templates'].nil?
		project_data['templates'].each do |template|
			ext = File.extname(template)
			if @iar_project_files.keys.include?(ext)
				path = @paths.fullpath("default_path",template)
				file  = open(path){|f| f.read}
				case ext
					when ".eww"
						@iar_project_files[ext] = Nokogiri::XML(file) {|x| x.noblanks }
					else
						puts "#{ext} not processed"
				end
			end
		end
		#clean the wrkspace in template
	 	@iar_project_files[ext].css("workspace").each do |node|
        	node.remove
    	end
	end

	def generator(project_data)
		add_project_to_set(project_data)
		save_set(project_data)
	end


	def add_project_to_set(project_data)
		return if @iar_project_files[ext].nil?

		#batch build mode is add
		project_data[Project_set::TOOLCHAIN]['targets'].each_key do |target|
			add_batch_project_target(@iar_project_files[ext], "all", project, target)
			add_batch_project_target(@iar_project_files[ext], target, project, target)
			project_data[Project_set::TOOLCHAIN]['targets'][target]['libraries'].each do |lib|
				add_batch_project_target(@iar_project_files[ext], "all", lib, target)
				add_batch_project_target(@iar_project_files[ext], target, lib, target)				
			end
		end
		#add projects
		rootdir = @paths[:output_root]
		file = "#{@project_name}_#{@board}.ewp"
		path = File.join('$WS_DIR$',file)
		add_project(@iar_project_files[ext], path)
		#add library projects here
		#get from dependency['libraries'][library_name]
		ustruct = @all_projects_hash
		project_data[Project_set::TOOLCHAIN]['libraries'].each do |lib|
			if ustruct[lib].nil?
				puts "#{lib} information is missing in all hash"
				next
			end
			libname = "#{@project_name}.ewp"
            root = @refer_paths[@ustruct[library][tool_key]['outdir']['root-dir']]
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

	def save_set(project_data, )
		path = @unifmt.get_output_dir(Project_set::TOOLCHAIN, @project_name, )
		save(File.join(@paths[:output_root], path, "#{@project_name}_#{@board}.eww"))
	end

end

end