# Compile with Crystal compiler running on local Linux server.

require 'rake'

USER_IP = IO.read("config.txt").chomp!

sh "echo crystal #{ARGV[1]} -o #{ARGV[2]} > compile.sh"
sh "pscp -pw #{ARGV[0]} -r src compile.sh #{ARGV[3]} #{USER_IP}:job"
sh "plink -ssh #{USER_IP} -pw #{ARGV[0]} -m compiler.txt -t"
