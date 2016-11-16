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
    if OS.windows? then
        sh "crystal.cmd #{IO.read("pass.txt").chomp!} #{src} #{target} sample.sql"
    else
        sh "crystal #{src} -o #{target}"
    end
end

task :test do
    if OS.windows? then
        rtarget = "run.cmd #{IO.read("pass.txt").chomp!} #{target}"
        sh "#{rtarget} --help"
        puts
        sh "#{rtarget} -f sample.sql -o out.json -l"
    else
        sh "#{target} --help"
        puts
        sh "#{target} -f world.sql -o out.json --loud"
        puts
        sh "cat out.json"
    end
end

task :clean do
    FileUtils.rm_rf("target")
end
