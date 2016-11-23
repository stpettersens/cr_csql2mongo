# Compile with Crystal compiler running on local Linux server.

require 'rake'

USER = "compiler"
IP = "192.168.0.18"

sh "echo crystal #{ARGV[1]} -o #{ARGV[2]} > compile.sh"
sh "pscp -pw #{ARGV[0]} -r src compile.sh #{ARGV[3]} #{USER}@#{IP}:job"
sh "plink -ssh #{USER}@#{IP} -pw #{ARGV[0]} -m compiler.txt -t"
