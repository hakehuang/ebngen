#! ruby -I../

require 'yaml'

require 'awesome_print'
require_relative '../lib/ebngen'

options = {
    :config => "debug",
    :tool_chain => "mdk",
    :type => "application",
    :board => "demo_board",
    :project_name => "demo_project",
    :project_root_dir => "default_root_dir"
}

myunifmt = Unifmt.new(options)
myunifmt.outdir =  "build"
myunifmt.cp_defines = {"MK64FN1M0xxx12" =>  "NXP MK64FN1M0xxx12"}
myunifmt.cc_defines = {  
          "CPU_MK64FN1M0VMD12" => nil, 
          "PRINTF_FLOAT_ENABLE" => 0, 
          "SCANF_FLOAT_ENABLE" => 0, 
          "PRINTF_ADVANCED_ENABLE" => 0,
          "SCANF_ADVANCED_ENABLE" => 0, 
          "TWR_K64F120M" => nil,
          "TOWER" => nil}
myunifmt.cc_flags = [ "--misra2004",
        "--cpu=cortex-m4",
        "--fpu=vfpv4_sp_d16",
        "--diag_suppress Pa082,Pa050",
        "--endian=little",
        "-e",
        "--use_c++_inline",
        "--silent"]
myunifmt.as_flags = [ "--cpu=cortex-m4",
        "--fpu=vfpv4_sp_d16",
        "-s",
        "-M'<>'",
        "-w+",
        "-j",
        "-S"]
myunifmt.linker_file = {
  "path" => "devices/MK64F12/arm/MK64FN1M0xxx12_flash.scf"         
}

myunifmt.templates = [ 
# "templates/iar/general.ewd",
    "templates/mdk/k64f120m.uvprojx",
#    "templates/iar/general.dni",
    "templates/mdk/project_mpw.xsd"]

=begin
myunifmt.tool_chain_set_spec = {
  'GOutputBinary' => {
    'state' => '1'
  },
  'IlinkOutputFile' => {
    'state' => "demo_project.out"
  }
}
=end

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
    :tool_chain => "mdk",
    :type => "application",
    :board => "demo_board",
    :project_name => "demo_project"
}
myunifmt2 = Unifmt.new(options)
myunifmt2.cp_defines = {"MK64FN1M0xxx12" =>  "NXP MK64FN1M0xxx12"}
myunifmt2.cc_defines = {
          "NODEBUG" => nil,
          "CPU_MK64FN1M0VMD12" => nil, 
          "PRINTF_FLOAT_ENABLE" => 0, 
          "SCANF_FLOAT_ENABLE" => 0, 
          "PRINTF_ADVANCED_ENABLE" => 0,
          "SCANF_ADVANCED_ENABLE" => 0, 
          "TWR_K64F120M" => nil,
          "TOWER" => nil }
myunifmt2.cc_flags = [ "--misra2004",
        "--cpu=cortex-m4",
        "--fpu=vfpv4_sp_d16",
        "--diag_suppress Pa082,Pa050",
        "--endian=little",
        "-e",
        "--use_c++_inline",
        "--silent"]
myunifmt2.as_flags = [ "--cpu=cortex-m4",
        "--fpu=vfpv4_sp_d16",
        "-s",
        "-M'<>'",
        "-w+",
        "-j",
        "-S"]
myunifmt2.cc_include = [
  {
    "path" =>  "test", 
    "rootdir" => "default_path",
  }
]
myunifmt2.linker_file = {
          "path" => "devices/MK64F12/arm/MK64FN1M0xxx12_flash.scf"         
}
myunifmt2.outdir = "build"
myunifmt2.update
myunifmt << myunifmt2

File.write('./unified_data.yml', YAML.dump(myunifmt.output_info))


options = {
  "paths" => {
   "default_path" => Dir.pwd + '/test',
   "output_root" => Dir.pwd + '/build',
  },
  "all" => myunifmt.output_info
}

mygenerator = Generator.new(options)
#mygenerator.generate_project_set('iar',myunifmt.output_info['demo_project'])
#mygenerator.generate_projects('iar', '', myunifmt.output_info['demo_project'])
mygenerator.generate_project_set('mdk',myunifmt.output_info['demo_project'])
mygenerator.generate_projects('mdk', '', myunifmt.output_info['demo_project'])