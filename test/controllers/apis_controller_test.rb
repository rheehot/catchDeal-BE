require 'test_helper'

class ApisControllerTest < ActionDispatch::IntegrationTest
  test "should get test" do
    get apis_test_url
    assert_response :success
  end

  test "should get book_mark" do
    get apis_book_mark_url
    assert_response :success
  end

end
