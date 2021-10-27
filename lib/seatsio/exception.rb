module Seatsio
  module Exception
    class SeatsioException < StandardError
    end

    class RateLimitExceededException < SeatsioException
    end

    class NoMorePagesException < SeatsioException
    end

    class NotFoundException < SeatsioException
    end
  end
end
