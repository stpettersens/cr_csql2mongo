# 
# Rakefile to build cr_csql2mongo
#

require 'os'
require 'fileutils'

app = "csql2mongo"
out = "target/release"
src = "src/#{app}.cr"
target = "#{out}/#{app}"

task :default do
    puts "Building #{app}..."
    FileUtils.mkdir_p(out)
    if OS.windows? or ARGV[1] == "remote" then
        pass = IO.read("pass.txt").chomp!
        ruby "crystal.rb #{pass} #{src} #{target} sample.sql"
    else
        sh "crystal #{src} -o #{target}"
    end
end

task :test do
    if OS.windows? or ARGV[1] == "remote" then
        pass = IO.read("pass.txt").chomp!
        run = "run.rb #{pass}"
        ruby "#{run} #{target} --help"
        puts
        ruby "#{run} #{target} -f sample.sql -o out.json --loud"
        puts
        ruby "#{run} cat out.json"
    else
        sh "#{target} --help"
        puts
        sh "#{target} -f sample.sql -o out.json --loud"
        puts
        sh "cat out.json"
    end
end

task :clean do
    FileUtils.rm_rf("target")
end
