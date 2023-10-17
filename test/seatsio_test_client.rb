require "securerandom"

class SeatsioTestClient < Minitest::Test

  def setup
    company = create_test_user
    @user = company['admin']
    @workspace = Seatsio::Workspace.new(company['workspace'])
    @seatsio = test_client(@user['secretKey'], nil)
  end

  def random_email
    "#{SecureRandom.hex 20}@mailinator.com"
  end

  def wait_for_status_changes(event, num_status_changes)
    start = Time.now
    while true do
      status_changes = @seatsio.events.list_status_changes(event.key).to_a
      if status_changes.length != num_status_changes
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

  def demo_company_secret_key
    ENV["DEMO_COMPANY_SECRET_KEY"]
  end

  def assert_demo_company_secret_key_set
    if demo_company_secret_key.nil?
      skip "DEMO_COMPANY_SECRET_KEY environment variable not set, skipping test"
    end
  end
end
