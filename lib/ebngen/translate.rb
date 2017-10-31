require 'deep_merge'
require 'rubygems'
require 'pathname'
require 'fileutils'
require 'logger'

module Utils_set
  def nodes_exist?(node, subnodes)
    return if subnodes.class != 'Array'
    subnodes.each do |key|
      return false if ! node.has_key?(key)
    end
    return true
  end
end

class Translator
  attr_accessor :data_in, :data_out, :reference_path

  include Utils_set

  def initialize(node, logger = nil)
      @logger = logger 
      unless (logger)
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO
      end
      @data_in = deep_copy(node)
      @data_in_component = deep_copy(node)
      @data_out = Hash.new
      merge_by_add(@data_in)
  end

  def deep_copy(o)
    Marshal.load(Marshal.dump(o))
  end

  def deep_add_merge(struct, subnode, addon)
    return if Hash != struct.class
    if struct[addon]['__add__'].nil?
      #we do not want the addon module to change the status
      struct[addon]['attribute'] = ""
      struct[subnode] = struct[subnode].deep_merge(deep_copy(struct[addon]))
      struct[addon]['attribute'] = 'required'
      return
    end
    #if has more addon
    if struct[addon]['__add__'].count != 0     
       struct[addon]['__add__'].each do |submodule|
         deep_add_merge(struct, addon, submodule)
       end
       struct[subnode] = struct[subnode].deep_merge(deep_copy(struct[addon]))
       struct[addon]['attribute'] = 'required'
    else
      struct[addon]['attribute'] = ""
      struct[subnode] = struct[subnode].deep_merge(deep_copy(struct[addon]))
      struct[addon]['attribute'] = 'required'     
    end
  end

    # perform merge by "__add__" node only applys to application type
  def merge_by_add(struct)
      #only scan the top level
      return if Hash != struct.class
      struct.each_key do |subnode|
        if struct[subnode]['__add__'] != nil
          struct[subnode]['__add__'].each do |addon|
            next if struct[addon].class != Hash
          begin
            next if struct[subnode]['configuration']['section-type'] != "application"
            if struct[addon]['configuration']['section-type'] != "component"
              @logger.warn "WARNING #{addon} is required as component but has not a component attribute"
            end
          rescue
            @logger.error "error with the merge_by_add with #{subnode} add #{addon}"
          end
            deep_add_merge(struct, subnode, addon)
          end
          #struct[subnode].delete('__add__')
        end
      end
  end

  def translate
     translate_project()
     return [@data_out, @data_in_component, @data_in]
     #puts @data_out.to_yaml
  end

  def output_path(proj, comp)
    if @data_in[proj].has_key?('outdir')
      board = @data_in[proj]['configuration']['board']
      if @data_out[proj][comp]['type'] == "library"
        if comp == 'uv4'
          @data_out[proj][comp]['outdir'] = File.join(@data_in[proj]['outdir'], proj, "mdk")
        else
          @data_out[proj][comp]['outdir'] = File.join(@data_in[proj]['outdir'], proj, comp)
        end
      else
        if comp == "uv4"
          @data_out[proj][comp]['outdir'] = File.join(board, @data_in[proj]['outdir'], "mdk")
        else
          @data_out[proj][comp]['outdir'] = File.join(board, @data_in[proj]['outdir'], comp)
        end
      end
    end
  end

  private

  def convert_rules(proj, comp = 'iar')
    if @data_in[proj]['configuration']['section-type'] == "virtual-library"
        if @data_in[proj].has_key?(comp)
            @data_out[proj] = @data_in[proj]
            board = @data_in[proj]['configuration']['board']
            path = @data_out[proj][comp]['outdir']['path']
            return if !  @data_out[proj].has_key?('chip-convert')
            @data_out[proj][comp]['outdir']['path'] = path + @data_out[proj]['chip-convert'][board]
            return
        end
    end

    if @data_in[proj]['configuration']['section-type'] == "component"
      return
    end

    if @data_in[proj]['configuration'].has_key?('meta_components')
      @data_out[proj]['meta_components'] = @data_in[proj]['configuration']['meta_components']
    end

    if @data_in[proj]['configuration']['tools'].has_key?(comp)
      compiler = @data_in[proj]['configuration']['tools'][comp]
      @data_out[proj][comp] = Hash.new
      @data_out[proj][comp]['targets'] = Hash.new
      @data_out[proj][comp]['type'] = @data_in[proj]['configuration']['section-type']

      @data_out[proj][comp]['templates'] = compiler['project-templates']
      if compiler.has_key?("group")
         @data_out[proj][comp]['group'] =  compiler['group']
      end
      output_path(proj, comp)
  	  compiler['config'].each_key do |target|
          next if compiler['load-to'].nil?
          next if compiler['load-to'][target].nil?
          create_and_deep_merge(@data_out[proj][comp]['targets'], target, compiler['config'][target])
          @data_out[proj][comp]['targets'][target]['linker_file'] = Hash.new
          @data_out[proj][comp]['targets'][target]['linker_file']['path'] = compiler['load-to'][target]['linker-file']
          @data_out[proj][comp]['targets'][target]['linker_file']['rootdir'] = compiler['load-to'][target]['rootdir']
          create_and_deep_merge(@data_out[proj][comp]['targets'][target]['binary_file'], target, compiler['binary-file'])
          @data_out[proj][comp]['targets'][target]['identifier'] = compiler['load-to'][target]['identifier']
          @data_out[proj][comp]['targets'][target]['config'] = compiler['load-to'][target]['config']
          @data_out[proj][comp]['targets'][target]['target'] = compiler['load-to'][target]['target']
          @data_out[proj][comp]['targets'][target]['libraries'] = Array.new
          if ! @data_in[proj]['configuration']['section-depends'].nil?
             @data_in[proj]['configuration']['section-depends'].each do |dep|
               @data_out[proj][comp]['targets'][target]['libraries'].insert(-1, dep)
             end
          end
      end
  	  #now translate the source
  	  return if ! @data_in[proj].has_key?('modules')

      if @data_in[proj].has_key?('tools')
        #process compile depend files here
        if @data_in[proj]['tools'].has_key?(comp) and @data_in[proj].has_key?('modules') and  @data_in[proj]["configuration"]["section-type"] == "application"
          @data_in[proj]['tools'][comp]['files'].each do |file|
            puts file
            next ! file.has_key?("virtual-dir")
            file['virtual_dir'] = file.delete "virtual-dir"
          end
          create_and_deep_merge(@data_out[proj][comp], 'source', @data_in[proj]['tools'][comp]['files'])
        end
      end
      @data_in[proj]['modules'].each_key do |mod|
        if @data_in[proj]['modules'][mod].class == Hash and @data_in[proj]['modules'][mod].has_key?('virtual-dir')
		      temp = Marshal.load(Marshal.dump(@data_in[proj]['modules'][mod]['files']))
          temp.each do |file|
            #puts "old virtual-dir is #{mod} #{file['virtual-dir']}"
            #puts "current #{@data_in[proj]['modules'][mod]['virtual-dir'].to_s}"
            if file['virtual-dir'] == nil
              file['virtual-dir'] = @data_in[proj]['modules'][mod]['virtual-dir'].to_s
            else
              if ! file.has_key?("processed")
                #puts proj,mod,file
                #puts file['virtual-dir']
                #puts @data_in[proj]['modules'][mod]['virtual-dir'].to_s
                file['virtual-dir'] = "#{@data_in[proj]['modules'][mod]['virtual-dir']}:#{file['virtual-dir']}"
                file['processed'] = "true"
              end
            end
            #puts "new virtual-dir is #{file['virtual-dir']} for #{proj}"
            if comp == 'uv4' || comp == 'mdk'
                file['virtual-dir'] = file['virtual-dir'].gsub(':','-')
            end
            file['virtual_dir'] = file.delete "virtual-dir"
          end
          create_and_deep_merge(@data_out[proj][comp], 'source', temp)

        else
          if @data_in[proj]['modules'][mod].class == Hash and @data_in[proj]['modules'][mod].has_key?('files')
            @data_in[proj]['modules'][mod]['files'].each do |file|
              next ! file.has_key?("virtual-dir")
              file['virtual_dir'] = file.delete "virtual-dir"
            end
            create_and_deep_merge(@data_out[proj][comp], 'source', @data_in[proj]['modules'][mod]['files'])
          end
        end
  	  end

     if @data_in[proj].has_key?('document')
       create_and_deep_merge(@data_out[proj],'document',  @data_in[proj]['document'])
     end
    end
  end

  def create_and_deep_merge(a, b, c)
     return if c == nil
     if c.class == Array
        a[b] = Array.new if a[b] == nil
       a[b] = a[b] + c.dup
     else
       a[b] = Hash.new if a[b] == nil
       a[b].deep_merge(c)
     end
  end

  def translate_project
     @data_in.each_key do |proj|
      next if @data_in[proj].nil?
      if @data_in[proj].has_key?('configuration')
        next if @data_in[proj]['configuration']['section-type'] == "component"
      end
      @data_out[proj] = Hash.new
      if @data_in[proj].has_key?('section-type')
        @data_out[proj]['type'] = @data_in[proj]['section-type']
      end
      convert_rules(proj,'iar')
      convert_rules(proj,'mdk')
      convert_rules(proj,'cmake')
      #convert_rules(proj,'armgcc')
      #convert_rules(proj,'kds')
      #convert_rules(proj,'atl')
      #convert_rules(proj,'lpcx')
    end
    @data_in_component.each_key do |proj|
     # puts "#{proj} TBD"
    end
  end
end
