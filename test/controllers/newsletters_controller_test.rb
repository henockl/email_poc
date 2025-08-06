require "test_helper"

class NewslettersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @newsletter = newsletters(:one)
  end

  test "should get index" do
    get newsletters_url
    assert_response :success
  end

  test "should get new" do
    get new_newsletter_url
    assert_response :success
  end

  test "should create newsletter" do
    assert_difference("Newsletter.count") do
      post newsletters_url, params: { newsletter: {
        title: "Test Newsletter",
        content: "# Test Content",
        publish_date: next_sunday
      } }
    end

    assert_redirected_to newsletter_url(Newsletter.last)
  end

  test "should show newsletter" do
    get newsletter_url(@newsletter)
    assert_response :success
  end

  test "should get edit for unpublished newsletter" do
    get edit_newsletter_url(@newsletter)
    assert_response :success
  end

  test "should redirect when trying to edit published newsletter" do
    @newsletter.update!(published: true)
    get edit_newsletter_url(@newsletter)
    assert_redirected_to newsletter_url(@newsletter)
    assert_match(/cannot edit/i, flash[:alert])
  end

  test "should update unpublished newsletter" do
    patch newsletter_url(@newsletter), params: { newsletter: { title: "Updated Title" } }
    assert_redirected_to newsletter_url(@newsletter)
    @newsletter.reload
    assert_equal "Updated Title", @newsletter.title
  end

  test "should not update published newsletter" do
    @newsletter.update!(published: true)
    patch newsletter_url(@newsletter), params: { newsletter: { title: "Updated Title" } }
    assert_redirected_to newsletter_url(@newsletter)
    assert_match(/cannot edit/i, flash[:alert])
  end

  test "should destroy unpublished newsletter" do
    assert_difference("Newsletter.count", -1) do
      delete newsletter_url(@newsletter)
    end

    assert_redirected_to newsletters_url
  end

  test "should not destroy published newsletter" do
    @newsletter.update!(published: true)
    assert_no_difference("Newsletter.count") do
      delete newsletter_url(@newsletter)
    end

    assert_redirected_to newsletters_url
    assert_match(/cannot delete/i, flash[:alert])
  end

  private

  def next_sunday
    today = Date.current
    days_until_sunday = (7 - today.wday) % 7
    days_until_sunday = 7 if days_until_sunday == 0
    today + days_until_sunday.days
  end
end
