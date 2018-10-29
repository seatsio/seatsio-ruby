require 'test_helper'
require 'util'

class UpdateSubaccountTest < SeatsioTestClient
  def test_update_subaccount
    subaccount = @seatsio.subaccounts.create name: 'joske'
    email = self.random_email
  
    @seatsio.subaccounts.update id: subaccount.id, name: 'jefke', email: email
  
    retrieved_subaccount = @seatsio.subaccounts.retrieve id: subaccount.id
    assert_equal('jefke', retrieved_subaccount.name)
    assert_equal(email, retrieved_subaccount.email)
  end
  
  def test_email_is_optional
    email = self.random_email
    subaccount = @seatsio.subaccounts.create_with_email email: email, name: 'joske'
  
    @seatsio.subaccounts.update id: subaccount.id, name: 'jefke'
  
    retrieved_subaccount = @seatsio.subaccounts.retrieve id: subaccount.id
    assert_equal('jefke', retrieved_subaccount.name)
    assert_equal(email, retrieved_subaccount.email)
  end
  
  def test_name_is_optional
    email = self.random_email
    subaccount = @seatsio.subaccounts.create_with_email email: email, name: 'joske'
  
    @seatsio.subaccounts.update id: subaccount.id, email: email
  
    retrieved_subaccount = @seatsio.subaccounts.retrieve id: subaccount.id
    assert_equal('joske', retrieved_subaccount.name)
    assert_equal(email, retrieved_subaccount.email)
  end
end
