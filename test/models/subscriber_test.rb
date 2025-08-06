require "test_helper"

class SubscriberTest < ActiveSupport::TestCase
  def setup
    @subscriber = Subscriber.new(
      name: "Test User",
      email: "testuser@example.com"
    )
  end

  test "should be valid with valid attributes" do
    assert @subscriber.valid?
  end

  test "should require name" do
    @subscriber.name = nil
    assert_not @subscriber.valid?
    assert_includes @subscriber.errors[:name], "can't be blank"
  end

  test "should require email" do
    @subscriber.email = nil
    assert_not @subscriber.valid?
    assert_includes @subscriber.errors[:email], "can't be blank"
  end

  test "should validate email format" do
    invalid_emails = [ "plainaddress", "@missingdomain.com", "missing@.com", "missing.domain@.com" ]

    invalid_emails.each do |email|
      @subscriber.email = email
      assert_not @subscriber.valid?, "#{email} should be invalid"
      assert_includes @subscriber.errors[:email], "is invalid"
    end
  end

  test "should accept valid email formats" do
    valid_emails = [ "test@example.com", "user.name@domain.co.uk", "user+tag@example.org" ]

    valid_emails.each do |email|
      @subscriber.email = email
      assert @subscriber.valid?, "#{email} should be valid"
    end
  end

  test "should require unique email" do
    @subscriber.save!

    duplicate = Subscriber.new(name: "Jane Doe", email: "testuser@example.com")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "should be active by default" do
    subscriber = Subscriber.create!(name: "Test User", email: "test@example.com")
    assert subscriber.active?
  end

  test "active scope returns only active subscribers" do
    active = Subscriber.create!(name: "Active", email: "active@example.com", active: true)
    inactive = Subscriber.create!(name: "Inactive", email: "inactive@example.com", active: false)

    active_subscribers = Subscriber.active
    assert_includes active_subscribers, active
    assert_not_includes active_subscribers, inactive
  end

  test "inactive scope returns only inactive subscribers" do
    active = Subscriber.create!(name: "Active", email: "active@example.com", active: true)
    inactive = Subscriber.create!(name: "Inactive", email: "inactive@example.com", active: false)

    inactive_subscribers = Subscriber.inactive
    assert_includes inactive_subscribers, inactive
    assert_not_includes inactive_subscribers, active
  end

  test "full_info returns formatted name and email" do
    expected = "Test User <testuser@example.com>"
    assert_equal expected, @subscriber.full_info
  end

  test "name length validation" do
    @subscriber.name = "a" * 256
    assert_not @subscriber.valid?
    assert_includes @subscriber.errors[:name], "is too long (maximum is 255 characters)"
  end
end
