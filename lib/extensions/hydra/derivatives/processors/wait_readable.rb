module Extensions
  module Hydra
    module Derivatives
      module Processors
        module WaitReadable
          def self.prepended(base)
            base.class_eval do

              # Modified execute_without_timeout from hydra-derivatives
              # Retries IO::WaitReadable errors
              # Remove when updated to hydra-derivatives >= 3.8.0
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
                      data = f.read_nonblock(::Hydra::Derivatives::Processors::ShellBasedProcessor::BLOCK_SIZE)

                      case fileno
                      when stderr.fileno
                        err_str << data
                      end
                    rescue IO::WaitReadable
                      ::Hydra::Derivatives::Logger.warn "Caught an IO::WaitReadable error in ShellBasedProcessor. Retrying..."
                      IO.select([f], nil, nil, 60)
                      retry
                    rescue EOFError
                      ::Hydra::Derivatives::Logger.debug "Caught an eof error in ShellBasedProcessor"
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