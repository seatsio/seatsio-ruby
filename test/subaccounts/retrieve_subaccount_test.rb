require 'test_helper'
require 'util'

class RetrieveSubaccountTest < SeatsioTestClient
  def test_retrieve_subaccount
    subaccount = @seatsio.subaccounts.create name: 'joske'

    retrieved_subaccount = @seatsio.subaccounts.retrieve id: subaccount.id

    assert_equal(subaccount.id, retrieved_subaccount.id)
    assert_not_blank(retrieved_subaccount.secret_key)
    assert_not_blank(retrieved_subaccount.designer_key)
    assert_not_blank(retrieved_subaccount.public_key)
    assert_equal('joske', retrieved_subaccount.name)
    assert_true(retrieved_subaccount.active)
  end
end
