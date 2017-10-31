Gem::Specification.new do |s|
  s.name        = 'ebngen'
  s.version     = '1.1.0'
  s.date        = '2017-10-30'
  s.summary     = "ebngen"
  s.description = "embedded project generator"
  s.authors     = ["Hake Huang", "Marian Cingel"]
  s.email       = 'hakehuang@gmail.com'
  s.files       = ["lib/ebngen.rb", 
                  "lib/ebngen/assembly.rb",
                   "lib/ebngen/ebngen.rb", 
                   "lib/ebngen/generate.rb", 
                   "lib/ebngen/translate.rb", 
                   "lib/ebngen/unifmt.rb",
                   "lib/ebngen/adapter/_assert.rb",
                   "lib/ebngen/adapter/_base.rb", 
                   "lib/ebngen/adapter/_path_modifier.rb", 
                   "lib/ebngen/adapter/_yml_helper.rb",
                   "lib/ebngen/adapter/cmake.rb", 
                   "lib/ebngen/adapter/iar.rb",
                   "lib/ebngen/adapter/mdk.rb", 
                   "lib/ebngen/adapter/cmake/CMakeList.txt", 
                   "lib/ebngen/adapter/cmake/txt.rb",
                   "lib/ebngen/adapter/iar/ewd.rb", 
                   "lib/ebngen/adapter/iar/ewp.rb", 
                   "lib/ebngen/adapter/iar/eww.rb",
                   "lib/ebngen/adapter/mdk/uvmwp.rb", 
                   "lib/ebngen/adapter/mdk/uvprojx.rb",                   
                   "lib/ebngen/settings/tool_chains.rb", 
                   "lib/ebngen/settings/target_types.rb"]
  s.homepage    =
    'http://rubygems.org/gems/ebngen'
  s.license       = 'Apache-2.0'
end
