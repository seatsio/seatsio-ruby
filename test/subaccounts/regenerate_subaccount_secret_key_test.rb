require 'test_helper'
require 'util'

class RegenerateSubaccountSecretKeyTest < SeatsioTestClient
  def test_regenerate_secret_key
    subaccount = @seatsio.subaccounts.create

    @seatsio.subaccounts.regenerate_secret_key id: subaccount.id

    retrieved_subaccount = @seatsio.subaccounts.retrieve id: subaccount.id
    assert_not_blank(retrieved_subaccount.secret_key)
    assert_not_equal(subaccount.secret_key, retrieved_subaccount.secret_key)
  end
end
