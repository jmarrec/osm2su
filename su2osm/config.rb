# initial test of moving OpenStudio SketchUp Plugin Experimental Workflow into a light weight stand alone script

require 'sketchup.rb'

module Sketchup::Su2osm

  def self.set_path_to_openstudio

    puts ""
    puts ">>Set and Store the Path used for OpenStudio installation"
       
    # gather user input
    prompt = "Path to openstudio.rb"
    
    # Try to read the stored value first
    test = Sketchup.read_default("su2osm","openstudio_path")
    if !test.nil?
      default_path = test
      default_dir = File.dirname(test)
      puts "Default path from sketchup's read_default: #{default_path}"
    else
      # Look at the $LOAD_PATH to infer location of openstudio.rb
      
      # 2.x stores as openstudio-x.y.z: eg C:/openstudio-2.5.1/Ruby/openstudio.rb
      defaults = $LOAD_PATH.grep(/openstudio-\d\.\d\.\d[\/\\]Ruby/).map{|x| File.expand_path(x)}
      # 1.x stores as OpenStudio x.y.z: eg C:/Program Files/OpenStudio 1.5.3/Ruby/openstudio.rb
      defaults += $LOAD_PATH.grep(/OpenStudio \d\.\d\.\d[\/\\]Ruby/).map{|x| File.expand_path(x)}
      
      # Default directory
      if !defaults.empty?
        default_dir = defaults[0]
        # Default openstudio.rb from LOAD_PATH is probably the right one
        # Better than inferring when multiple versions are installed
        default_path = File.join(default_dir.split('Ruby')[0], 'Ruby', 'openstudio.rb')
        puts "Default path from $LOAD_PATH: #{default_path}"
      else
        # TODO: that's windows only... but at least it won't find anything and will
        # end up using root of drive, so it won't cause real problems
        # Start by greping at root of drive, 2.x style
        candidates = Dir[File.join(File.expand_path('/'), 'openstudio*/Ruby/openstudio.rb')]
        if !candidates.empty?
          default_path = candidates[0]
          default_dir = File.dirname(default_path)
          puts "Default path from grep 2.x style: #{default_path}"
        else
          # Grep in program files, 1.x style
          candidates = Dir[File.join(File.expand_path('/'), 'Program Files/OpenStudio*/Ruby/openstudio.rb')]
          if !candidates.empty?
            default_path = candidates[0]
            default_dir = File.dirname(default_path)
            puts "Default path from grep 1.x style: #{default_path}"
          else
            # We couldn't find anything, default_dir is root of drive
            default_dir = File.expand_path('/')
            puts "Default path cannot be inferred, using root: #{default_path}"
          end
        end
      end
    end
    
    # Inputbox option: asks for string
    # input = UI.inputbox([prompt], [default_path], "su2osm Configure Dialog.")
    # openstudio_path = input[0]
    
    # OpenPanel (file browser option: better)
    openstudio_path = UI.openpanel(prompt, default_dir, "OpenStudio rb|openstudio.rb;||")
    # Normalize path (slashes)
    openstudio_path = File.expand_path(openstudio_path)
    result = Sketchup.write_default "su2osm","openstudio_path", openstudio_path

    test = Sketchup.read_default("su2osm","openstudio_path")
    puts "Path to OpenStudio set to #{test}"

    begin
      require test.to_s
    rescue LoadError
      UI.messagebox('Could not load OpenStudio, please verify the path.')
    end
  end

end # module Sketchup::Su2osm
