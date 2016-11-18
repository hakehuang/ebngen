
require_relative 'adapter/iar'

class Generator
  attr_accessor :generator_variable
  def initialize(options)
    @generator_variable = Hash.new
    @generator_variable['options'] = options
  end

  def generate_projects(too_chain, filter, project_data)
    case too_chain.downcase
    when 'iar'
    	IAR::Project.new(project_data).generator(filter, project_data, @generator_variable)
    when 'mdk'
    	puts "mdk"
    when 'armgcc'
    	puts "armgcc"
	end
  end

  def generate_project_set(project, *dependency)
    case too_chain.downcase
    when 'iar'
    	IAR::Project_set.new(project_data).generator(project, *dependency)
    when 'mdk'
    	puts "mdk"
    when 'armgcc'
    	puts "armgcc"
	end  
  end

end