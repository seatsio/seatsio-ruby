require 'test_helper'
require 'util'

class RetrieveMyAccountTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_retrieve_my_account
    account = @seatsio.accounts.retrieve_my_account
    assert_operator(account.secret_key, :!=, nil)
    assert_operator(account.designer_key, :!=, nil)
    assert_operator(account.public_key, :!=, nil)
    assert_operator(account.email, :!=, nil)
    assert_equal(true, account.settings.draft_chart_drawings_enabled)
    assert_equal('ERROR', account.settings.chart_validation.validate_duplicate_labels)
    assert_equal('ERROR', account.settings.chart_validation.validate_objects_without_categories)
    assert_equal('ERROR', account.settings.chart_validation.validate_unlabeled_objects)
  end
end
