require 'pathname'


class PathModifier

    attr_reader    :rootdir_table

    def initialize(rootdir_table)
        @rootdir_table = rootdir_table
    end

    def fullpath(rootdir_name, relpath)
        Core.assert(@rootdir_table.has_key?(rootdir_name)) do
            "rootdir '#{rootdir_name}' is not present in table '@{rootdir_table}'"
        end
        if (@rootdir_table[ rootdir_name ] && !@rootdir_table[ rootdir_name ].empty?)
            relpath = File.join(
                @rootdir_table[ rootdir_name ].gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR), relpath.gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
            )
        end
        return relpath.gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
    end

    def relpath(project_full_path, root_dir_path)
       return Pathname.new(root_dir_path.gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)).relative_path_from(Pathname.new(project_full_path.gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR))).to_s
    end
end

