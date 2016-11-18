require 'rubygems'
require "yaml"
require "deep_merge"
require 'fileutils'
require 'open-uri'
require 'uri'

def UNI_File

  def initialize(options)
     @projects_hash = options
  end

  def get_output_dir(project_name, toolchain,  path_helper, **args)
    rootdir = path_helper[@projects_hash['document']['project_root_dir'].to_sym]
    if args.length == 0
    return File.join(rootdir,
      @projects_hash[toolchain]["outdir"], toolchain)
      elsif ! args[:dir].nil?
    return Pathname.new(File.join(rootdir,
      @projects_hash[toolchain]["outdir"], toolchain)).relative_path_from(Pathname.new(args[:dir])).to_s
      end
  end

  def get_src_list(toolchain)
    return @projects_hash[toolchain]["source"]
  end

  def get_libraries(toolchain)
    return @projects_hash[toolchain]["libraries"]
  end

end