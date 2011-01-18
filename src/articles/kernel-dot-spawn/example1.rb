# Use :in for standard input, :out for standard output,
# and :err for standard error
pid = Kernel.spawn("ls -lA", {:out => any_io_object})

# You'll have to wait for the subprocess after that. Remember that 
# wait sets $? to a Process::Status object containing information 
# on that process, including the exit code.
Process.wait pid