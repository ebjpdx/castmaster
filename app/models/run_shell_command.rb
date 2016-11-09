require 'open4'

def run_shell_command(command,options={})
  options[:raise_on_failure] ||= true
  
  pid, stdin, stdout, stderr = Open4::popen4(command)
  pid, status = Process::waitpid2 pid
  result = {:pid => pid, :stdout => stdout.read, :stderr => stderr.read, :exit_code => status.to_i}
  
  if result[:exit_code] != 0 && options[:raise_on_failure]
    raise "Command Failed:#{command}\nOutput:\n#{result[:stdout]}\n#{result[:stderr]}"
  else
    result
  end
end