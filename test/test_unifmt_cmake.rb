#! ruby -I../

require 'yaml'

require 'awesome_print'
require 'lib/ebngen'

options = {
    :config => "debug",
    :tool_chain => "cmake",
    :type => "application",
    :board => "demo_board",
    :project_name => "demo_project",
    :project_root_dir => "default_root_dir"
}

myunifmt = Unifmt.new(options)
myunifmt.outdir =  "build"
myunifmt.cp_defines = {"CPU_MK64FN1M0VMD12" =>  nil}
myunifmt.cc_defines = {  
          "CPU_MK64FN1M0VMD12" => nil, 
          "DEBUG" => nil, 
          "TWR_K64F120M" => nil,
          "TOWER" => nil}
myunifmt.cc_flags = [ "-g", "-mthumb", "-mapcs", "-std=gnu99",
        "-mcpu=cortex-m4",
        "-mfloat-abi=hard",
        "-mfpu=fpv4-sp-d16",
        "-MMD",
        "-MP"]
myunifmt.as_defines = ["DEBUG"]
myunifmt.as_flags = [ "--cpu=cortex-m4",
        "--fpu=vfpv4_sp_d16",
        "-s",
        "-M'<>'",
        "-w+",
        "-j",
        "-S"]
myunifmt.linker_file = {
	        "path" => "devices/MK64F12/gcc/MK64FN1M0xxx12_flash.ld",
          "rootdir" => "default_path"        
}

myunifmt.libraries = ["-m"]

myunifmt.binary_file = "test_debug"

myunifmt.cc_include = [
  {
    "path" =>  "test", 
    "rootdir" => "default_path",
  }
]


myunifmt.sources = [
	{
	 "path" =>  "hello_world.c", 
	 "rootdir" => "default_path",
   "virtual_dir" => "src"
	},
	{
	 "path" =>  "hello_world.h", 
	 "rootdir" => "default_path",
   "virtual_dir" => "include"
	},	
]
myunifmt.update
options = {
    :config => "release",
    :tool_chain => "cmake",
    :type => "application",
    :board => "demo_board",
    :project_name => "demo_project"
}
myunifmt2 = Unifmt.new(options)
myunifmt2.outdir =  "build"
myunifmt2.cp_defines = {"CPU_MK64FN1M0VMD12" =>  nil}
myunifmt2.cc_defines = {  
          "CPU_MK64FN1M0VMD12" => nil, 
          "DEBUG" => nil, 
          "TWR_K64F120M" => nil,
          "TOWER" => nil}
myunifmt2.cc_flags = [ "-g", "-mthumb", "-mapcs", "-std=gnu99",
        "-mcpu=cortex-m4",
        "-mfloat-abi=hard",
        "-mfpu=fpv4-sp-d16",
        "-MMD",
        "-MP"]
myunifmt2.as_defines = ["RELEASE"]
myunifmt2.as_flags = [ "--cpu=cortex-m4",
        "--fpu=vfpv4_sp_d16",
        "-s",
        "-M'<>'",
        "-w+",
        "-j",
        "-S"]
myunifmt2.linker_file = {
          "path" => "devices/MK64F12/gcc/MK64FN1M0xxx12_flash.ld",
          "rootdir" => "default_path"        
}

myunifmt2.cc_include = [
  {
    "path" =>  "test", 
    "rootdir" => "default_path",
  }
]

myunifmt2.libraries = ["-m"]
myunifmt2.binary_file = "test_release"

myunifmt2.sources = [
  {
   "path" =>  "hello_world.c", 
   "rootdir" => "default_path",
   "virtual_dir" => "src"
  },
  {
   "path" =>  "hello_world.h", 
   "rootdir" => "default_path",
   "virtual_dir" => "include"
  },  
]
myunifmt2.update
myunifmt << myunifmt2

File.write('./unified_data.yml', YAML.dump(myunifmt.output_info))


options = {
  "paths" => {
   "default_path" => Dir.pwd,
   "output_root" => Dir.pwd
  },
  "all" => myunifmt.output_info
}

mygenerator = Generator.new(options)
mygenerator.generate_projects('cmake', '', myunifmt.output_info['demo_project'])