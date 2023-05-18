class RateLimiter
  attr_reader :limit, :remaining

  def initialize
    @remaining = 1
    @enqueued = 0
    @mutex = Mutex.new
  end

  def perform(&block)
    @mutex.synchronize do
      # Wait for the API rate limit to reset
      sleep_until_reset

      # Let's go!
      @enqueued += 1
    end

    response = block.call

    @mutex.synchronize do
      update_rate_limit(response)
      @enqueued -= 1
    end

    response
  end

  private

  def sleep_until_reset
    return unless @reset
    return if @reset < Time.now.to_i
    return if @remaining - @enqueued > 0

    # We wait one more seconds because the clock might be slightly off
    sleep_seconds = @reset - Time.now.to_i + 1
    puts "Rate limit reached. Waiting for reset: #{sleep_seconds} seconds"
    sleep(sleep_seconds)
  end

  def update_rate_limit(response)
    remaining = response['X-RateLimit-Remaining']&.to_i || return
    reset = response['X-RateLimit-Reset']&.to_i || return

    if reset > @reset.to_i || remaining < @remaining
      @remaining = remaining
      @reset = reset
    end
  end
end
