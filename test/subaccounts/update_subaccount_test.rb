require 'test_helper'
require 'util'

class UpdateSubaccountTest < SeatsioTestClient
  def test_update_subaccount
    subaccount = @seatsio.subaccounts.create name: 'joske'

    @seatsio.subaccounts.update id: subaccount.id, name: 'jefke'

    retrieved_subaccount = @seatsio.subaccounts.retrieve id: subaccount.id
    assert_equal('jefke', retrieved_subaccount.name)
  end

  def test_name_is_optional
    subaccount = @seatsio.subaccounts.create name: 'joske'

    @seatsio.subaccounts.update id: subaccount.id

    retrieved_subaccount = @seatsio.subaccounts.retrieve id: subaccount.id
    assert_equal('joske', retrieved_subaccount.name)
  end
end
