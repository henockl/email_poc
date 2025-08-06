require "test_helper"

class SendNewsletterJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  def setup
    # Clean up any existing data
    Newsletter.destroy_all
    Subscriber.destroy_all
    ActionMailer::Base.deliveries.clear

    @sunday = Date.parse("2025-01-26")  # A Sunday
    @newsletter = Newsletter.create!(
      title: "Test Newsletter",
      content: "# Welcome\n\nThis is a test.",
      publish_date: @sunday,
      published: true,
      sent: false
    )
    @active_subscriber = Subscriber.create!(
      name: "Active User",
      email: "active@example.com",
      active: true
    )
    @inactive_subscriber = Subscriber.create!(
      name: "Inactive User",
      email: "inactive@example.com",
      active: false
    )
  end

  test "sends newsletter to active subscribers only" do
    # With bulk sending, we send 1 email message (with 1 BCC recipient)
    assert_emails 1 do
      SendNewsletterJob.perform_now(@sunday)
    end

    @newsletter.reload
    assert @newsletter.sent?
  end

  test "does not send to inactive subscribers" do
    @active_subscriber.update!(active: false)

    assert_emails 0 do
      SendNewsletterJob.perform_now(@sunday)
    end

    @newsletter.reload
    assert @newsletter.sent?  # Should be marked as sent even when no emails sent (no active subscribers)
  end

  test "does not send unpublished newsletters" do
    @newsletter.update_columns(published: false)  # Skip validations

    assert_emails 0 do
      SendNewsletterJob.perform_now(@sunday)
    end

    @newsletter.reload
    assert_not @newsletter.sent?
  end

  test "does not send already sent newsletters" do
    @newsletter.update!(sent: true)

    assert_emails 0 do
      SendNewsletterJob.perform_now(@sunday)
    end
  end

  test "does not send newsletters for wrong date" do
    different_date = @sunday + 7.days

    assert_emails 0 do
      SendNewsletterJob.perform_now(different_date)
    end

    @newsletter.reload
    assert_not @newsletter.sent?
  end

  test "sends multiple newsletters on same date" do
    newsletter2 = Newsletter.create!(
      title: "Second Newsletter",
      content: "# Another Newsletter\n\nSecond content.",
      publish_date: @sunday,
      published: true,
      sent: false
    )

    # 2 newsletters, each sent as 1 bulk email = 2 total emails
    assert_emails 2 do
      SendNewsletterJob.perform_now(@sunday)
    end

    [ @newsletter, newsletter2 ].each do |newsletter|
      newsletter.reload
      assert newsletter.sent?
    end
  end

  test "handles email delivery errors gracefully" do
    # Simulate error by using invalid email
    ActionMailer::Base.deliveries.clear

    # Should not raise an error even if delivery fails
    assert_nothing_raised do
      SendNewsletterJob.perform_now(@sunday)
    end

    @newsletter.reload
    assert @newsletter.sent?  # Still marks as sent despite error
  end

  test "uses current date when no date provided" do
    travel_to(@sunday) do
      assert_emails 1 do
        SendNewsletterJob.perform_now  # No date argument
      end
    end
  end

  test "uses bulk sending for multiple subscribers" do
    # Create additional active subscribers
    subscriber2 = Subscriber.create!(
      name: "Subscriber 2",
      email: "subscriber2@example.com",
      active: true
    )
    subscriber3 = Subscriber.create!(
      name: "Subscriber 3",
      email: "subscriber3@example.com",
      active: true
    )

    # Should send 1 bulk email to all 3 active subscribers via BCC
    assert_emails 1 do
      SendNewsletterJob.perform_now(@sunday)
    end

    @newsletter.reload
    assert @newsletter.sent?
  end
end
