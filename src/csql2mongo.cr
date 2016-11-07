#
# csql2mongo
# Utility to convert a SQL dump to a MongoDB JSON dump.
#
# Copyright 2016 Sam Saint-Pettersen.
# Licensed under the MIT/X11 License.
#
# Crystal port of a Rust program, which was itself
# a port of a Python program (1.0.6).
#

require "./csql2mongo/*"

module Csql2mongo
  class Util
    def convert_sql_to_json(input : String, output : String, tz : Bool, mongo_types : Bool, 
    array : Bool, verbose : Bool)

    end

    def check_extensions(program : String, input : String, output : String)
      if !/\.sql$/.match(input)
        display_error(program, "Input file '#{input}' does not have SQL as its extension")
      end
      if !/\.json$/.match(output)
        display_error(program, "Output file '#{output}' does not have JSON as its extension")
      end
    end

    def display_error(program : String, err : String)
      puts "Error: #{err}."
      display_usage(program, -1)
    end

    def display_version()
      puts "csql2mongo #{VERSION} [Crystal] (https://github.com/stpettersens/cr_csql2mongo)"
      exit(0)
    end

    def display_usage(program : String, code : Int32)
      puts "\ncsql2mongo"
      puts "Utility to convert a SQL dump to a MongoDB JSON dump."
      puts "\nCopyright 2016 Sam Saint-Pettersen."
      puts "Licensed under the MIT/X11 License."
      puts "Usage: #{program} -f|--file <input.sql> -o|--out <output.json>"
      puts "-t|--tz -n|--no-mongo-types -a|--array -i|--ignore-ext -l|--verbose [-v|--version][-h|--help]"
      puts "\n-f|--file: SQL file to convert."
      puts "-o|--out: MongoDB JSON file as output."
      puts "-t|--tz: Use \"Z\" as timezone for timestamps rather than +0000."
      puts "-n|--no-mongo-types: Do not use MongoDB types in output."
      puts "-a|--array: Output MongoDB records as a JSON array."
      puts "-i|--ignore-ext: Ignore file extensions for input/output."
      puts "-l|--verbose: Display console output on conversion."
      puts "-v|--version: Display program version and exit."
      puts "-h|--help: Display this help information and exit."
      exit(code)
    end

    def main()
      i = 0
      input = String.new
      output = String.new
      tz = false
      mongo_types = true
      array = false
      extensions = true
      verbose = false
      ARGV.each do |arg|
        if /-h|--help/.match(arg)
          display_usage($0, 0)
        elsif /-v|--version/.match(arg)
          display_version()
        elsif /-f|--file/.match(arg)
          input = ARGV[i + 1]
        elsif /-o|--out/.match(arg)
          output = ARGV[i + 1]
        elsif /-tz|--tz/.match(arg)
          tz = true
        elsif /-n|--no-mongo-types/.match(arg)
          mongo_types = false
        elsif /-a|--array/.match(arg) 
          array = true
        elsif /-i|--ignore-ext/.match(arg)
          extensions = false
        elsif /-l|--verbise/.match(arg)
          verbose = true
        end
        i += 1      
      end

      if ARGV.size == 0
        display_error($0, "No options specified")
      elsif input.size == 0
        display_error($0, "No input file specified")
      elsif output.size == 0
        display_error($0, "No output file specified")
      end

      if extensions
        check_extensions($0, input, output)
      end
      convert_sql_to_json(input, output, tz, mongo_types, array, verbose)
    end
  end
end

app = Csql2mongo::Util.new 
app.main()
