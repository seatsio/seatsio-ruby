require "securerandom"

class SeatsioTestClient < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = test_client(@user['secretKey'], nil)
  end

  def random_email
    "#{SecureRandom.hex 20}@mailinator.com"
  end
end
