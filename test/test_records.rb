#! ruby -I../

require 'yaml'
require 'yml_merger'

require 'awesome_print'
require_relative '../lib/ebngen'


@entry_yml = "test.yml"
@search_path  = (Pathname.new(File.dirname(__FILE__)).realpath + 'records_test/').to_s
merge_unit      = YML_Merger.new(
    @entry_yml, @search_path
)
merged_data     = merge_unit.process()

options = {
  "paths" => {
   "default_path" => Dir.pwd + '/test',
   "output_root" => Dir.pwd + '/build',
  },
  "all" => merged_data
}

mygenerator = Generator.new(options)
mygenerator.generate_project_set('iar',merged_data['demo_project'])
mygenerator.generate_projects('iar', '', merged_data['demo_project'])
mygenerator.generate_project_set('mdk',merged_data['demo_project'])
mygenerator.generate_projects('mdk', '', merged_data['demo_project'])
mygenerator.generate_projects('cmake', '', merged_data['demo_project'])