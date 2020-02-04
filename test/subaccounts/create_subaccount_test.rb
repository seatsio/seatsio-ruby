require 'test_helper'
require 'util'

class CreateSubaccountTest < SeatsioTestClient
  def test_create_subaccount
    subaccount = @seatsio.subaccounts.create name: 'joske'

    assert_not_blank(subaccount.secret_key)
    assert_not_blank(subaccount.designer_key)
    assert_equal('joske', subaccount.name)
    assert_true(subaccount.active)
  end

  def test_name_is_optional
    subaccount = @seatsio.subaccounts.create
    assert_not_nil(subaccount.name)
  end
end
