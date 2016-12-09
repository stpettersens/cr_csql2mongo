# Run compiled Crystal program on local Linux server.

require 'rake'

USER_IP = IO.read("config.txt").chomp!

args = []
for i in 1..ARGV.size do
    args.push(ARGV[i])
end

sh "echo #{args.join(" ")} > prog.sh"
sh "pscp -pw #{ARGV[0]} prog.sh #{USER_IP}:job"
sh "plink -ssh #{USER_IP} -pw #{ARGV[0]} -m runner.txt -t"
