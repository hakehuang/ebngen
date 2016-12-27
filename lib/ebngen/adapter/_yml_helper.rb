require 'rubygems'
require "yaml"


module UNI_Project

  def set_hash(options)
     @projects_hash = options
  end

  def get_output_dir(toolchain,  path_hash, **args)
    if args.length == 0
      return File.join(@projects_hash[toolchain]["outdir"], toolchain)
    elsif ! args[:dir].nil?
      return Pathname.new(File.join(
      @projects_hash[toolchain]["outdir"], toolchain)).relative_path_from(Pathname.new(args[:dir])).to_s
    end
  end

  def get_src_list(toolchain)
    return @projects_hash[toolchain]["source"]
  end

  def get_libraries(toolchain)
    return @projects_hash[toolchain]["libraries"]
  end

  def get_target_list(toolchain)
   return @projects_hash[toolchain]["targets"].keys
  end

  def get_targets(toolchain)
   return @projects_hash[toolchain]["targets"]
  end

  def get_project_name()
    return @projects_hash['document']['project_name']
  end

  def get_board()
    return @projects_hash['document']['board']
  end

  def get_template(toolchain)
    return @projects_hash[toolchain]['templates']
  end


end