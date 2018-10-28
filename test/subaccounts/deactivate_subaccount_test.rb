require 'test_helper'
require 'util'

class DeactivateSubaccountTest < SeatsioTestClient
  def test_deactivate_subaccount
    subaccount = @seatsio.subaccounts.create name: 'joske'

    @seatsio.subaccounts.deactivate id: subaccount.id

    retrieved_subaccount = @seatsio.subaccounts.retrieve id: subaccount.id
    assert_false(retrieved_subaccount.active)
  end
end
