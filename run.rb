# Run compiled Crystal program on local Linux server.

require 'rake'

c = IO.read("config.txt").chomp!
uh = c.split("@")

USER = uh[0]
IP = uh[1]

args = []
for i in 1..ARGV.size do
    args.push(ARGV[i])
end

sh "echo #{args.join(" ")} > prog.sh"
sh "pscp -pw #{ARGV[0]} prog.sh #{USER}@#{IP}:job"
sh "plink -ssh #{USER}@#{IP} -pw #{ARGV[0]} -m runner.txt -t"
