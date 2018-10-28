require 'test_helper'
require 'util'

class CreateSubaccountTest < SeatsioTestClient
  def test_create_subaccount
    subaccount = @seatsio.subaccounts.create name: 'joske'

    assert_not_blank(subaccount.secret_key)
    assert_not_blank(subaccount.designer_key)
    assert_not_blank(subaccount.public_key)
    assert_equal('joske', subaccount.name)
    assert_true(subaccount.active)
  end
  
  def test_name_is_optional
    subaccount = @seatsio.subaccounts.create
    assert_nil(subaccount.name)
  end
  
  def test_with_email
    email = self.random_email
    subaccount = @seatsio.subaccounts.create_with_email email: email
    assert_not_blank(subaccount.secret_key)
    assert_not_blank(subaccount.designer_key)
    assert_not_blank(subaccount.public_key)
    assert_nil(subaccount.name)
    assert_true(subaccount.active)
    assert_equal(email, subaccount.email)
  end
  
  def test_with_email_and_name
    email = self.random_email
    subaccount = @seatsio.subaccounts.create_with_email email: email, name: 'jeff'
    assert_not_blank(subaccount.secret_key)
    assert_not_blank(subaccount.designer_key)
    assert_not_blank(subaccount.public_key)
    assert_equal('jeff', subaccount.name)
    assert_true(subaccount.active)
    assert_equal(email, subaccount.email)
  end
end
