require "test_helper"

class SubscribersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @subscriber = subscribers(:one)
  end

  test "should get index" do
    get subscribers_url
    assert_response :success
  end

  test "should get new" do
    get new_subscriber_url
    assert_response :success
  end

  test "should create subscriber" do
    assert_difference("Subscriber.count") do
      post subscribers_url, params: { subscriber: {
        name: "Test User",
        email: "test@example.com",
        active: true
      } }
    end

    assert_redirected_to subscriber_url(Subscriber.last)
  end

  test "should not create subscriber with invalid data" do
    assert_no_difference("Subscriber.count") do
      post subscribers_url, params: { subscriber: {
        name: "",
        email: "invalid-email"
      } }
    end

    assert_response :unprocessable_entity
  end

  test "should show subscriber" do
    get subscriber_url(@subscriber)
    assert_response :success
  end

  test "should get edit" do
    get edit_subscriber_url(@subscriber)
    assert_response :success
  end

  test "should update subscriber" do
    patch subscriber_url(@subscriber), params: { subscriber: { name: "Updated Name" } }
    assert_redirected_to subscriber_url(@subscriber)
    @subscriber.reload
    assert_equal "Updated Name", @subscriber.name
  end

  test "should not update subscriber with invalid data" do
    patch subscriber_url(@subscriber), params: { subscriber: { email: "invalid-email" } }
    assert_response :unprocessable_entity
  end

  test "should destroy subscriber" do
    assert_difference("Subscriber.count", -1) do
      delete subscriber_url(@subscriber)
    end

    assert_redirected_to subscribers_url
  end
end
