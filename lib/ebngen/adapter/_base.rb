module Base
  def process(project_data)
  	project_data.each_key do |key|
  		methods = instance_methods(false)
  		if methods.include(key.to_sym)
  			send(key.to_sym, project_data)
  		else
  			puts "#{key} is not processed"
  		end
  	end
  end

  def create_method(name)
    self.class.send(:define_method, name){|project_data|
      project_data[name].each_key do |key|
        methods = self.class.instance_methods(false)
        if methods.include?(key.to_sym)
          puts "process #{key}"
          send(key.to_sym)
        else
          puts "#{key} is not processed"
        end
      end
    }
  end
end