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

  def wait_for_status_changes(event)
    start = Time.now
    while true do
      status_changes = @seatsio.events.list_status_changes(event.key).to_a
      if status_changes.empty?
        if Time.now - start > 10
          raise "No status changes for event #{event.key}"
        else
          sleep(1)
        end
      else
        return true
      end
    end
  end
end
