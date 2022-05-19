require "securerandom"

class SeatsioTestClient < Minitest::Test

  def setup
    company = create_test_user
    @user = company['admin']
    @subaccount = company['subaccount']
    @seatsio = test_client(@user['secretKey'], nil)
  end

  def random_email
    "#{SecureRandom.hex 20}@mailinator.com"
  end
end
