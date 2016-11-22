# Compile with Crystal compiler running on local linux server.
USER = "compiler"
IP = 192.168.0.18
exec("echo crystal #{ARGV[2]} -o #{ARGV[3]} > compile.sh") 
exec("pscp -pw #{ARGV[1]} -r src compile.sh #{ARGV[4]} #{USER}@#{IP}:job")
exec("plink -ssh #{USER}@#{IP} -pw #{ARGV[1]} -m compiler.txt -t")
