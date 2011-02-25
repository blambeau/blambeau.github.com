# Runs a command, returns result on STDOUT. If the exit status was no 0,
# a RuntimeError is raised. 
def shell_safe_exec(cmd)
  puts cmd
  unless system(cmd)
    raise RuntimeError, "Error while executing #{cmd}" 
  end
  $?
end

desc "Stage the official version"
task :stage => [:book, :test] do
  shell_safe_exec("git commit -a -m 'Regenerating revision-zero' && git push origin")  
  shell_safe_exec("aello-invoke revzero")
end