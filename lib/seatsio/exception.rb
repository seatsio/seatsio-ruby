module Seatsio
  module Exception
    class SeatsioException < StandardError
    end

    class NoMorePagesException < StandardError
    end

    class NotFoundException < SeatsioException
    end
  end
end
