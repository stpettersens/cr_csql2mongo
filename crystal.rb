# Compile with Crystal compiler running on local Linux server.

require 'rake'

c = IO.read("config.txt").chomp!
USER_IP = c.split("@")

sh "echo crystal #{ARGV[1]} -o #{ARGV[2]} > compile.sh"
sh "pscp -pw #{ARGV[0]} -r src compile.sh #{ARGV[3]} #{USER_IP[0]}@#{USER_IP[1]}:job"
sh "plink -ssh #{USER_IP[0]}@#{USER_IP[1]} -pw #{ARGV[0]} -m compiler.txt -t"
