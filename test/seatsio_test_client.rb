require "securerandom"

class SeatsioTestClient < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], nil, 'https://api-staging.seatsio.net')
  end

  def random_email
    "#{SecureRandom.hex 20}@mailinator.com"
  end
end
