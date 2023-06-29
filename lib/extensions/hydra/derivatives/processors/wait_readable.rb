module Extensions
  module Hydra
    module Derivatives
      module Processors
        module WaitReadable
          def self.prepended(base)
            base.class_eval do
              # Unmodified execute_without_timeout from hydra-derivatives
              def self.execute_without_timeout(command, context)
                err_str = ''
                stdin, stdout, stderr, wait_thr = popen3(command)
                context[:pid] = wait_thr[:pid]
                files = [stderr, stdout]
                stdin.close

                until all_eof?(files)
                  ready = IO.select(files, nil, nil, 60)

                  next unless ready
                  readable = ready[0]
                  readable.each do |f|
                    fileno = f.fileno

                    begin
                      data = f.read_nonblock(BLOCK_SIZE)

                      case fileno
                      when stderr.fileno
                        err_str << data
                      end
                    rescue EOFError
                      Hydra::Derivatives::Logger.debug "Caught an eof error in ShellBasedProcessor"
                      # No big deal.
                    end
                  end
                end

                stdout.close
                stderr.close
                exit_status = wait_thr.value

                raise "Unable to execute command \"#{command}\". Exit code: #{exit_status}\nError message: #{err_str}" unless exit_status.success?
              end
            end
          end
        end
      end
    end
  end
end