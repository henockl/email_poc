require "test_helper"

class NewsletterTest < ActiveSupport::TestCase
  def setup
    @newsletter = Newsletter.new(
      title: "Test Newsletter",
      content: "# Welcome\n\nThis is a test newsletter.",
      publish_date: next_sunday
    )
  end

  test "should be valid with valid attributes" do
    assert @newsletter.valid?
  end

  test "should require title" do
    @newsletter.title = nil
    assert_not @newsletter.valid?
    assert_includes @newsletter.errors[:title], "can't be blank"
  end

  test "should require content" do
    @newsletter.content = nil
    assert_not @newsletter.valid?
    assert_includes @newsletter.errors[:content], "can't be blank"
  end

  test "should require publish_date" do
    @newsletter.publish_date = nil
    assert_not @newsletter.valid?
    assert_includes @newsletter.errors[:publish_date], "can't be blank"
  end

  test "publish_date must be a Sunday" do
    @newsletter.publish_date = Date.current.beginning_of_week # Monday
    assert_not @newsletter.valid?
    assert_includes @newsletter.errors[:publish_date], "must be a Sunday (end of week)"
  end

  test "should be valid when publish_date is Sunday" do
    @newsletter.publish_date = next_sunday
    assert @newsletter.valid?
  end

  test "cannot edit when published" do
    @newsletter.save!
    @newsletter.update!(published: true)

    @newsletter.title = "New Title"
    assert_not @newsletter.valid?
    assert_includes @newsletter.errors[:base], "Cannot edit a published newsletter"
  end

  test "cannot unpublish newsletter" do
    @newsletter.save!
    @newsletter.update!(published: true)

    @newsletter.published = false
    assert_not @newsletter.valid?
    assert_includes @newsletter.errors[:base], "Cannot unpublish a newsletter"
  end

  test "can_edit? returns false when published" do
    @newsletter.published = true
    assert_not @newsletter.can_edit?
  end

  test "can_edit? returns true when not published" do
    @newsletter.published = false
    assert @newsletter.can_edit?
  end

  test "mark_as_sent! updates sent status" do
    @newsletter.save!
    assert_not @newsletter.sent?

    @newsletter.mark_as_sent!
    assert @newsletter.sent?
  end

  test "ready_to_send scope returns correct newsletters" do
    # Create published newsletter for today
    published_today = Newsletter.create!(
      title: "Today",
      content: "Content",
      publish_date: next_sunday,
      published: true
    )

    # Create published newsletter for different date
    published_other_date = Newsletter.create!(
      title: "Other Date",
      content: "Content",
      publish_date: next_sunday + 7.days,
      published: true
    )

    # Create unpublished newsletter for today
    unpublished_today = Newsletter.create!(
      title: "Unpublished",
      content: "Content",
      publish_date: next_sunday,
      published: false
    )

    results = Newsletter.ready_to_send(next_sunday)
    assert_includes results, published_today
    assert_not_includes results, published_other_date
    assert_not_includes results, unpublished_today
  end

  private

  def next_sunday
    today = Date.current
    days_until_sunday = (7 - today.wday) % 7
    days_until_sunday = 7 if days_until_sunday == 0
    today + days_until_sunday.days
  end
end
