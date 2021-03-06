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
    def preprocess_sql(lines : Array(String)) : Array(String)
      processed = Array(String).new
      patterns = [ "VALUES \\(", ",", "\\),", "\\(", "\n\n", "--.*" ]
      repls = [ "VALUES (\n", ",\n", "\nINSERT INTO `null` VALUES (\n", "", "\n", "" ]
      lines.each do |l|
        i = 0
        nl = String.new
        patterns.each do |p|
          re = Regex.new(p)
          nl = l.gsub(re){ |r| repls[i] }
          i += 1
        end
        if nl.size > 1 && !/\//.match(nl)
          processed.push(nl)
        end
      end
      puts processed.size # !!!
      File.write("out.sql", processed.join(""))
      return processed
    end

    def convert_sql_to_json(input : String, output : String, tz : Bool, mongo_types : Bool, 
    array : Bool, verbose : Bool)
      lines = Array(String).new
      File.each_line(input) do |l|
        lines.push(l)
      end
      processed = preprocess_sql(lines)
      fields = Array(String).new
      values = Array(String).new
      inserts = Array(Array(String)).new
      headers = false
      z = 0
      processed.each do |l|
	      #puts "z index: #{z}" # !!!
	      #puts "p: #{l}"
        re = Regex.new("CREATE TABLE|UNLOCK TABLES")
        if re.match(l)
          headers = true
        end
        if headers
          re = Regex.new("(^[\`a-zA-Z0-9_]+)")
          f = re.match(l).try &.[1] 
          if f != Nil
            fields.push(f.to_s)
          end
        else
	        re = Regex.new("(^[0-9\.]+)")
	        v = re.match(l).try &.[1]
	        if v != Nil
	          values.push(v.to_s)
          end
	        re = Regex.new("'([a-zA-Z0-9]+)'")
	        v = re.match(l).try &.[1]
	        if v != Nil
	          values.push(v.to_s)
	        end
          re = Regex.new("(TRUE|FALSE|NULL)")
          v = re.match(l).try &.[1]
          if v != Nil
            values.push(v.to_s.downcase)
          end
	        re = Regex.new("([0-9]{4}\-[0-9]{2}\-[0-9]{2} [0-9]{2}\:[0-9]{2}\:[0-9]{2})")
	        v = re.match(l).try &.[1]
	        if !/--/.match(l) && v != Nil
	          values.push(v.to_s.gsub(" ", "T"))
	        end
        end
        re = Regex.new("INSERT INTO")
        if re.match(l)
          headers = false
        end
        z += 1 # !!!
      end
      ffields = Array(String).new
      fvalues = Array(String).new
      fields.each do |f|
        re = Regex.new("CREATE|ENGINE|INSERT|PRIMARY|LOCK")
        if !re.match(f)
          if f.size == 0
            break
          end
          ffields.push(f)
        end
      end
      values.each do |v|
        if !/DROP|INSERT|TRUE|FALSE|NULL/.match(v) && v.size > 0
          fvalues.push(v)
        end
      end
      fvalues.each_slice(ffields.size) do |v|
        inserts.push(v) 
      end
      
      json = Array(String).new
      ac = String.new
      inserts.each do |r|
        fr = Array(String).new
        x = 0
        r.each do |v|
          if /T[0-9]{2}:/.match(v)
            v = v + ".000"
            if tz 
              v = v + "Z"
            else
              v = v + "+0000"
            end
            if mongo_types
              v = "{\"$date\":\"#{v}\"}"
            else
              v = "\"#{v}\""
            end
          elsif /true|false|null/.match(v)
            # ...
          elsif /[a-zA-Z]/.match(v)
            if ffields[x] == "_id"
              v = "{\"$oid\":\"#{v}\"}"
            else
              v = "\"#{v}\""
            end
          end
          fr.push("\"#{ffields[x]}\":#{v}")
          if array
            ac = ","
          end
          x += 1
        end
        json.push("{#{fr.join(",")}}#{ac}")
      end

      if array
        json.insert(0, "[")
        last = json[json.size - 1]
        json[json.size - 1] = last[0..last.size - 2]
        json.push("]")
      end
      json.push(String.new)

      if verbose 
        puts "Generating MongoDB JSON dump file '#{output}' from"
        puts "SQL dump file: '#{input}'.\n"
      end

      File.write(output, json.join("\n"))
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
      puts "\nUsage: #{program} -f|--file <input.sql> -o|--out <output.json>"
      puts "-t|--tz -n|--no-mongo-types -a|--array -i|--ignore-ext -l|--loud [-v|--version][-h|--help]"
      puts "\n-f|--file: SQL file to convert."
      puts "-o|--out: MongoDB JSON file as output."
      puts "-t|--tz: Use \"Z\" as timezone for timestamps rather than +0000."
      puts "-n|--no-mongo-types: Do not use MongoDB types in output."
      puts "-a|--array: Output MongoDB records as a JSON array."
      puts "-i|--ignore-ext: Ignore file extensions for input/output."
      puts "-l|--loud: Display console output on conversion."
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
      puts ARGV
      ARGV.each do |a|
        if /-h|--help/.match(a)
          display_usage($0, 0)
        elsif /-v|--version/.match(a)
          display_version()
        elsif /-f|--file/.match(a)
          input = ARGV[i + 1]
        elsif /-o|--out/.match(a)
          output = ARGV[i + 1]
        elsif /-tz|--tz/.match(a)
          tz = true
        elsif /-n|--no-mongo-types/.match(a)
          mongo_types = false
        elsif /-a|--array/.match(a) 
          array = true
        elsif /-i|--ignore-ext/.match(a)
          extensions = false
        elsif /-l|--loud/.match(a)
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
