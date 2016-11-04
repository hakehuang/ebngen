#! ruby -I../

require 'lib/ebngen/unifmt'
require 'awesome_print'

myunifmt = Unifmt.new({})
myunifmt.cp_defines = {"MK64FN1M0xxx12" =>  "Freescale MK64FN1M0xxx12"}
myunifmt.cc_defines = {  
          "CPU_MK64FN1M0VMD12" => "", 
          "PRINTF_FLOAT_ENABLE" => 0, 
          "SCANF_FLOAT_ENABLE" => 0, 
          "PRINTF_ADVANCED_ENABLE" => 0,
          "SCANF_ADVANCED_ENABLE" => 0, 
          "TWR_K64F120M" => "",
          "TOWER" => "" }
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
	        "path" => "devices/MK64F12/iar/MK64FN1M0xxx12_flash.icf"         
}

myunifmt.templates = [ "templates/iar/app_peswd/generic.ewd",
    "templates/iar/app_peswd/generic.ewp",
    "templates/iar/app_peswd/generic.dni",
    "templates/iar/general.eww" ]

myunifmt.sources = [
	{
	 "path" =>  "hello_world.c", 
	 "rootdir" => "default_path"
	},
	{
	 "path" =>  "hello_world.h", 
	 "rootdir" => "default_path"
	},	
]
myunifmt.update
ap myunifmt.output_info

