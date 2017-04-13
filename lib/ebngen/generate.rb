
require_relative 'adapter/iar'
require_relative 'adapter/cmake'
require 'logger'

class Generator
  attr_accessor :generator_variable
  def initialize(options, logger = nil)
    @logger = logger 
    unless (logger)
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO
    end
    @generator_variable = options
    if @generator_variable.class != Hash
      puts "failure options shall be a hash"
      return
    end
    if @generator_variable.has_key?('all') and @generator_variable.has_key?('paths')
      @logger.info "input setting is ok"
    else
      @logger.info "input settings is wrong"
    end
  end

  def generate_projects(tool_chain, filter, project_data)
    case tool_chain.downcase
    when 'iar'
    	IAR::Project.new(project_data, @generator_variable, @logger).generator(filter, project_data)
    when 'mdk'
    	@logger.info "mdk TBD"
    when 'cmake'
    	CMAKE::Project.new(project_data, @generator_variable, @logger).generator(filter, project_data)
	end
  end

  def generate_project_set(tool_chain, project_data)
    case tool_chain.downcase
    when 'iar'
    	 IAR::Project_set.new(project_data, @generator_variable, @logger).generator()
    when 'mdk'
    	@logger.info "mdk TBD"
    when 'armgcc'
    	@logger.info "armgcc TBD"
	end  
  end

end