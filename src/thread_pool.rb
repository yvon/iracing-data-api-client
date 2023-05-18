class ThreadPool
  def initialize(max_threads)
    @max_threads = max_threads
    @queue = Queue.new
  end

  def perform(&block)
    @queue.push(block)
  end

  def start
    # Array to hold the threads
    threads = Array.new(@max_threads) do
      Thread.new do
        loop do
          # Exit loop if no job available
          break if @queue.empty?

          # Process the job and store the result
          job = @queue.pop
          job.call
        end
      end
    end

    # Wait for all threads to finish
    threads.each(&:join)
  end
end
