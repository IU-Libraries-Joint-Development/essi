# Job classes based on ApplicationJob will wait to enqueue any nested jobs until
# the current job has finished.
class ApplicationJob < ActiveJob::Base
  prepend SequentialJob
end
