require 'pathname'

$CMAKE_HEADER = %Q{
INCLUDE(CMakeForceCompiler)
# CROSS COMPILER SETTING
SET(CMAKE_SYSTEM_NAME Generic)
CMAKE_MINIMUM_REQUIRED (VERSION 2.6)

# THE VERSION NUMBER
SET (Tutorial_VERSION_MAJOR 1)
SET (Tutorial_VERSION_MINOR 0)

# ENABLE ASM
ENABLE_LANGUAGE(C ASM)

SET(CMAKE_STATIC_LIBRARY_PREFIX)
SET(CMAKE_STATIC_LIBRARY_SUFFIX)

SET(CMAKE_EXECUTABLE_LIBRARY_PREFIX)
SET(CMAKE_EXECUTABLE_LIBRARY_SUFFIX)

 
# CURRENT DIRECTORY
SET(ProjDirPath ${CMAKE_CURRENT_SOURCE_DIR})
}

$CONFIG_SETTINGS = [
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
	:linker_file
	]


module TXT
  def save(path, data_hash)
  	FileUtils.mkdir_p File.dirname(path) if ! File.exist?(File.dirname(path))
  	File.open(path, 'w+') do |file| 
  		file.write($CMAKE_HEADER)
  		data_hash["target"].each_key do |target|
  			$CONFIG_SETTINGS.each do |key|
  				next if ! data_hash["target"][target].has_key?(key.to_s)
  				data_hash["target"][target][key.to_s].each do |line|
  					file.puts(line)
  				end
  			end
  		end
  		binary = data_hash["document"]["project_name"]
  		case data_hash["type"].upcase
  		when "APPLICATION"
  			file.puts("add_executable(#{binary}.elf") 
  		else
  			file.puts("add_library(STATIC #{binary}.a")
  		end
  		data_hash["sources"].each do |line|
  			file.puts line
  		end
  		file.puts(")")
  	end
  end
end
