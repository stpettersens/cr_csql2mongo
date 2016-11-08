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
    sh "crystal #{src} -o #{target}"
end

task :test do
    sh "#{target} --help"
    puts
    sh "#{target} -f sample.sql -o out.json"
    sh "touch out.json"
    puts
    if OS.windows? then
        sh "type out.json"
    else
        sh "cat out.json"
    end
end

task :clean do
    FileUtils.rm_rf("target")
end
