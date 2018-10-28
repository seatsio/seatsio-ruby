require 'test_helper'
require 'util'

class ActivateSubaccountTest < SeatsioTestClient
  def test_activate_subaccount
    subaccount = @seatsio.subaccounts.create name: 'joske'

    @seatsio.subaccounts.deactivate id: subaccount.id
    @seatsio.subaccounts.activate id: subaccount.id

    retrieved_subaccount = @seatsio.subaccounts.retrieve id: subaccount.id
    assert_true(retrieved_subaccount.active)
  end
end
