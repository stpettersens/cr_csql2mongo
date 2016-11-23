# Run compiled Crystal program on local Linux server.

require 'rake'

USER = "compiler"
IP = "192.168.0.18"

args = []
for i in 1..ARGV.size do
    args.push(ARGV[i])
end

sh "echo #{args.join(" ")} > prog.sh"
sh "pscp -pw #{ARGV[0]} prog.sh #{USER}@#{IP}:job"
sh "plink -ssh #{USER}@#{IP} -pw #{ARGV[0]} -m runner.txt -t"
