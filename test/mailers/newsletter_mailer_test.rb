require "test_helper"

class NewsletterMailerTest < ActionMailer::TestCase
  def setup
    @newsletter = newsletters(:one)
    @subscriber = subscribers(:one)
  end

  test "weekly_newsletter" do
    mail = NewsletterMailer.weekly_newsletter(@newsletter, @subscriber)

    assert_equal @newsletter.title, mail.subject
    assert_equal [ @subscriber.email ], mail.to
    assert_equal [ "newsletter@example.com" ], mail.from
    assert_match @newsletter.title, mail.body.encoded
  end

  test "weekly_newsletter includes rendered markdown" do
    @newsletter.content = "# Test Header\n\n**Bold text**"
    mail = NewsletterMailer.weekly_newsletter(@newsletter, @subscriber)

    # HTML version should contain rendered HTML from Marksmith
    assert_match "Test Header", mail.html_part.body.to_s
    assert_match "Bold text", mail.html_part.body.to_s

    # Text version should contain plain markdown
    assert_match "# Test Header", mail.text_part.body.to_s
    assert_match "**Bold text**", mail.text_part.body.to_s
  end

  test "weekly_newsletter includes unsubscribe link" do
    mail = NewsletterMailer.weekly_newsletter(@newsletter, @subscriber)

    assert_match "unsubscribe", mail.html_part.body.to_s
    assert_match "unsubscribe", mail.text_part.body.to_s
  end

  test "bulk_newsletter sends to multiple recipients via TO" do
    emails = [ "test1@example.com", "test2@example.com", "test3@example.com" ]
    mail = NewsletterMailer.bulk_newsletter(@newsletter, emails)

    assert_equal @newsletter.title, mail.subject
    assert_equal emails, mail.to
    assert_equal [ "newsletter@example.com" ], mail.from
  end

  test "send_to_subscribers sends bulk emails with fewer messages" do
    # Create additional subscribers for bulk testing
    subscriber2 = Subscriber.create!(name: "Test User 2", email: "test2@example.com", active: true)
    subscriber3 = Subscriber.create!(name: "Test User 3", email: "test3@example.com", active: true)

    subscribers = Subscriber.where(id: [ @subscriber.id, subscriber2.id, subscriber3.id ])

    # Should send only 1 email (bulk) instead of 3 individual emails
    assert_emails 1 do
      result = NewsletterMailer.send_to_subscribers(@newsletter, subscribers)
      assert_equal 3, result[:successful]
      assert_equal 0, result[:failed]
    end
  end

  test "send_to_subscribers handles empty subscriber list" do
    subscribers = Subscriber.none

    assert_emails 0 do
      result = NewsletterMailer.send_to_subscribers(@newsletter, subscribers)
      assert_equal 0, result[:successful]
      assert_equal 0, result[:failed]
    end
  end

  test "send_to_subscribers processes subscribers correctly" do
    # Test with normal subscriber - should send successfully
    subscribers = Subscriber.where(id: @subscriber.id)

    assert_emails 1 do
      result = NewsletterMailer.send_to_subscribers(@newsletter, subscribers)
      assert_equal 1, result[:successful]
      assert_equal 0, result[:failed]
    end
  end
end
