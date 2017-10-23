require 'rubygems'
require "yaml"


module UNI_Project
  def is_toolchain_support(tool_chain)
    return @projects_hash.has_key?(tool_chain)
  end

  def set_hash(options)
     @projects_hash = options
  end

  def get_output_dir(toolchain,  path_hash)
    @projects_hash[toolchain]["outdir"]
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

  def get_type(toolchain)
    return @projects_hash[toolchain]["type"]
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

  def get_default_projectset_settings(toolchain) 
    return @projects_hash[toolchain]['projectset_settings']
  end

  def get_default_project_settings(toolchain) 
    return @projects_hash[toolchain]['project_settings']
  end
end