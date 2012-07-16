require 'test_helper'

class ErrorHandlerControllerTest < ActionController::TestCase
  test "should get conflict" do
    get :conflict
    assert_response :success
  end

  test "should get validation" do
    get :validation
    assert_response :success
  end

  test "should get others" do
    get :others
    assert_response :success
  end

end
