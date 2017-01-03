require 'pathname'
require "deep_merge" 
#this is for contraucture a uniformat input hierarchy hash
require_relative 'settings/tool_chains'
require_relative 'settings/target_types'

class UfBaseClass
  def self.attr_accessor(*vars)
    @attributes ||= []
    @attributes.concat vars
    super(*vars)
  end

  def self.attributes
    @attributes
  end

  def attributes
    self.class.attributes
  end
end

module Validate
	def validate_array(name)
		@validate_hash = Hash.new if @validate_hash.nil?
		@validate_hash[name] = Array
	end

	def validate_string(name)
		@validate_hash = Hash.new if @validate_hash.nil?
		@validate_hash[name] = String
	end

	def validate_hash(name)
		@validate_hash = Hash.new if @validate_hash.nil?
		@validate_hash[name] = Hash
	end

	def validate(name, value)
		if @validate_hash.has_key?(name)
			return  @validate_hash[name] == value.class
		end
		true
	end

	def get_validate(name)
		if @validate_hash.has_key?(name)
			return @validate_hash[name]
		end
	end

end

class Unifmt < UfBaseClass
	#the soc definitons
	attr_accessor :cp_defines
	#the asm defintions
	attr_accessor :as_predefines, :as_preincludes, :as_defines, :as_include, :as_flags
	#the c code definitons
	attr_accessor :cc_predefines, :cc_preincludes, :cc_defines, :cc_include, :cc_flags
	#the Cxx code difintios 
	attr_accessor :cxx_predefines, :cxx_preincludes, :cxx_defines, :cxx_include, :cxx_flags
	#link flags
	attr_accessor :ld_flags
	#dependant libraries information
	attr_accessor :libraries
	#link files
	attr_accessor :linker_file 
	#meta_components dependency
	attr_accessor :meta_components
	#source
	attr_accessor :sources
	#template
	attr_accessor :templates
	#project_name
	attr_accessor :project_name
	#project_name
	attr_accessor :outdir
	#tool_chain_set_spec
	attr_accessor :tool_chain_set_spec
	#tool_chain_add_apec
	attr_accessor :tool_chain_add_spec
	#binary_file
	attr_accessor :binary_file

    #the keys that used in the uniformat
	@@UNIFY_KEYS = ["meta_components", 
		            "targets",
		            "path",
		            "rootdir",
		            "type",
					"templates",
					"outdir", 
					"source", 
					"virtual_dir", 
					"document", 
					"board", 
					"identifier", 
					"linker_file", 
					"sectiontype", 
					"binaryfile", 
					"release_dir"]

	@@CONFIG_SETTINGS = [
	:cp_defines ,
	:as_predefines,
	:as_defines,
	:as_flags,
	:as_preincludes ,
	:as_include,
	:cc_predefines,
	:cc_defines,
	:cc_flags,
	:cc_preincludes,
	:cc_include,
	:cxx_predefines,
	:cxx_defines,
	:cxx_flags,
	:cxx_preincludes,
	:cxx_include,
	:ld_flags,
	:linker_file,
	:outdir,
    :binary_file,
    :tool_chain_set_spec,
    :tool_chain_add_spec
	]

	extend Validate

	#constrains of the variables
	validate_hash  :cp_defines
	validate_hash :as_predefines
	validate_hash :as_defines
	validate_array :as_flags
	validate_array :as_preincludes
	validate_array :as_include

	validate_hash :cc_predefines
	validate_hash :cc_defines
	validate_array :cc_flags
	validate_array :cc_preincludes
	validate_array :cc_include

	validate_hash :cxx_predefines
	validate_hash :cxx_defines
	validate_array :cxx_flags
	validate_array :cxx_preincludes
	validate_array :cxx_include

	validate_array :ld_flags
	validate_array :meta_components
	
	validate_array :libraries
	
	validate_hash :linker_file


	validate_hash :sources

	validate_array :templates

	validate_string :project_name
	validate_string :outdir
	validate_string :binary_file
	validate_hash :tool_chain_set_spec
	validate_hash :tool_chain_add_spec
	
	def initialize(options)
		@options_default = {
		:config => "debug",
		:tool_chain => "iar",
		:type => "application",
		:board => "dummy_board",
		:project_name => "dummy_project",
		:project_root_dir => nil,
		}

		if options.class.to_s != "Hash" and not options.nil?
			puts "#{options} shall be in hash format like { :targets => [\"release\", \"debug\"]}"
			return
		end
		options.each do |key, value|
			@options_default[key] = value
		end

		@projects_hash = Hash.new
		@projects_hash[@options_default[:project_name]] = Hash.new

		if not $TARGET_TYPES.include?(@options_default[:type])
			puts "Error type #{@options_default[:type]} is not in allowable list, should be #{$TARGET_TYPES}"
			return
		end

		if not $TOOL_CHAINS.include?(@options_default[:tool_chain])
			puts "Error tool_chain #{@options_default[:tool_chain]} is not supported"
			return
		end

    	
    	self.attributes.each do |item|
    		if @@CONFIG_SETTINGS.include?(item)
    		  instance_variable_set("@#{item}",Unifmt.get_validate(item).new)
    		  #@projects_hash[tc]["targets"][config][item.to_s] = instance_variable_get("@#{item}")
    	    end
    	end
	end

	def update
		#some mandatory sections
		@subhash = @projects_hash[@options_default[:project_name]]
		@subhash["document"] = Hash.new
		@subhash["document"]["board"] = @options_default[:board]
		@subhash["document"]["project_name"] = @options_default[:project_name]
		@subhash["document"]["project_root_dir"] = @options_default[:project_root_dir]
		tc = @options_default[:tool_chain]
		@subhash[tc] = Hash.new
		@subhash[tc]["targets"] = Hash.new
		@subhash[tc]["templates"] = instance_variable_get("@templates")
        @subhash[tc]["type"] = @options_default[:type]
	    config = @options_default[:config]
    	if not $CONFIG_TYPES.include?(config)
    		puts "the config type #{config} is not supported"
    		return
    	end
		@subhash[tc]["targets"][config] = Hash.new
		self.attributes.each do |item|
    		if @@CONFIG_SETTINGS.include?(item)
    		  @subhash[tc]["targets"][config][item.to_s] = instance_variable_get("@#{item}")
    	    end
    	end
    	#other need special process features
    	@subhash[tc]["source"] = instance_variable_get("@sources")
    	@subhash[tc]["outdir"] = instance_variable_get("@outdir")
    	@subhash[tc]["libraries"] = instance_variable_get("@libraries")
	end
	
	def output_info
		@projects_hash
	end

	def merge_target(project_data)
		@projects_hash.deep_merge(project_data)
	end

    def <<(other)
    	@projects_hash.deep_merge(other.output_info)
    end

    def load(project_data)
    	@projects_hash = project_data
    end

	def help
		puts @@UNIFY_KEYS
	end


    def as_preincludes_unit
    	return {"path" => "",  "rootdir" => ""}
    end

    def as_include_unit
    	return {"path" => "",  "rootdir" => ""}
    end

    def cc_preincludes_unit
    	return {"path" => "",  "rootdir" => ""}
    end

    def cc_include_unit
    	return {"path" => "",  "rootdir" => ""}
    end

    def cxx_preincludes_unit
    	return {"path" => "",  "rootdir" => ""}
    end

    def cxx_include_unit
    	return {"path" => "",  "rootdir" => ""}
    end

    def linker_file_unit
    	return {"path" => "",  "rootdir" => ""}
    end

    def sources_unit
    	return {"source" => "", "virtual_dir" => "" ,"rootdir" => "", "release_dir" => ""}
    end
end
