
require_relative 'adapter/iar'

class Generator
  attr_accessor :generator_variable
  def initialize(options)
    @generator_variable = options
    if @generator_variable.class != Hash
      puts "failure options shall be a hash"
      return
    end
    if @generator_variable.has_key?('all') and @generator_variable.has_key?('paths')
      puts "input setting is ok"
    else
      puts "input settings is wrong"
    end
  end

  def generate_projects(tool_chain, filter, project_data)
    case tool_chain.downcase
    when 'iar'
    	IAR::Project.new(project_data, @generator_variable).generator(filter, project_data)
    when 'mdk'
    	puts "mdk"
    when 'armgcc'
    	puts "armgcc"
	end
  end

  def generate_project_set(tool_chain, project_data)
    case tool_chain.downcase
    when 'iar'
    	IAR::Project_set.new(project_data, @generator_variable).generator()
    when 'mdk'
    	puts "mdk"
    when 'armgcc'
    	puts "armgcc"
	end  
  end

end