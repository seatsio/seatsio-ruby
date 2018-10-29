require 'test_helper'
require 'util'

class RegenerateDesignerKeyTest < SeatsioTestClient
  def test_regenerate_designer_key
    subaccount = @seatsio.subaccounts.create
  
    @seatsio.subaccounts.regenerate_designer_key id: subaccount.id
  
    retrieved_subaccount = @seatsio.subaccounts.retrieve id: subaccount.id

    assert_not_blank(retrieved_subaccount.designer_key)
    assert_not_equal(subaccount.designer_key, retrieved_subaccount.designer_key)
  end
end
