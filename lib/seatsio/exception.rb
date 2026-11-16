module Seatsio
  module Exception
    class SeatsioException < StandardError
      attr_accessor :idempotency_key
    end

    class RateLimitExceededException < SeatsioException
    end

    class BestAvailableObjectsNotFoundException < SeatsioException
    end

    class NoMorePagesException < SeatsioException
    end

    class NotFoundException < SeatsioException
    end
  end
end
