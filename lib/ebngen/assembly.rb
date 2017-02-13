require 'pathname'
require "deep_merge" 

class Assembly
	def initialize(options)
		@internal_hash = options
	end
	def assembly(project_name, key = "__add__")
		@internal_hash[project_name][key].each do |submodule|
			@internal_hash[project_name].deep_merge(deep_copy(@internal_hash[submodule]))
		end
		@internal_hash[project_name].delete(key)
		@internal_hash.keys.each do |subkey|
			next if subkey == project_name
			@internal_hash.delete(subkey)
		end
	end

	def deep_copy(o)
      Marshal.load(Marshal.dump(o))
    end
end
