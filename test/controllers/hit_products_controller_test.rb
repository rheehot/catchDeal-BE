require 'test_helper'

class HitProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get hit_products_index_url
    assert_response :success
  end

end
