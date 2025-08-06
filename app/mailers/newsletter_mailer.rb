class NewsletterMailer < ApplicationMailer
  include AhoyEmail::Mailer

  # Send newsletter to individual subscriber (kept for backwards compatibility)
  def weekly_newsletter(newsletter, subscriber)
    @newsletter = newsletter
    @subscriber = subscriber
    @html_content = sanitize_html(Marksmith::Renderer.new(body: @newsletter.content).render)
    @unsubscribe_url = "https://example.com/unsubscribe"

    mail(
      to: subscriber.email,
      subject: @newsletter.title,
      from: "newsletter@example.com"
    )

    track subject: @newsletter.title if respond_to?(:track)
  end

  # True bulk send newsletter using BCC to multiple subscribers
  def bulk_newsletter(newsletter, subscriber_emails)
    @newsletter = newsletter
    @html_content = sanitize_html(Marksmith::Renderer.new(body: @newsletter.content).render)
    @unsubscribe_url = "https://example.com/unsubscribe"

    mail(
      to: subscriber_emails,
      subject: @newsletter.title,
      from: "newsletter@example.com"
    ) do |format|
      format.html { render "weekly_newsletter" }
      format.text { render "weekly_newsletter" }
    end

    track subject: @newsletter.title if respond_to?(:track)
  end

  # Batch processing wrapper for bulk sending
  def self.send_to_subscribers(newsletter, subscribers)
    batch_size = 50  # Email servers often have BCC limits
    successful_batches = 0
    failed_batches = 0
    total_sent = 0

    # Filter out opted-out subscribers upfront
    active_subscribers = subscribers.reject do |subscriber|
      subscriber.respond_to?(:opted_out?) && subscriber.opted_out?
    end

    if active_subscribers.empty?
      Rails.logger.info "No active subscribers to send newsletter '#{newsletter.title}' to"
      return { successful: 0, failed: 0 }
    end

    Rails.logger.info "Sending newsletter '#{newsletter.title}' to #{active_subscribers.size} subscribers in batches of #{batch_size}"

    # Process in batches to respect email server BCC limits
    active_subscribers.each_slice(batch_size).with_index do |batch, index|
      begin
        Rails.logger.info "Processing batch #{index + 1} of #{batch.size} subscribers"

        # Extract email addresses for this batch
        batch_emails = batch.map(&:email)

        # Send single email to entire batch via BCC
        bulk_newsletter(newsletter, batch_emails).deliver_now

        successful_batches += 1
        total_sent += batch.size
        Rails.logger.info "Batch #{index + 1} sent successfully to #{batch.size} recipients"

        # Small delay between batches to be respectful to email servers
        sleep(0.1) unless batch.size < batch_size

      rescue StandardError => e
        failed_batches += 1
        Rails.logger.error "Failed to send batch #{index + 1}: #{e.message}"
        Rails.logger.error "Failed batch contained emails: #{batch.map(&:email).join(', ')}"
      end
    end

    Rails.logger.info "Bulk sending complete. Batches sent: #{successful_batches}, Failed: #{failed_batches}, Total recipients: #{total_sent}"
    { successful: total_sent, failed: (active_subscribers.size - total_sent) }
  end

  private

  # Sanitize HTML content for email safety
  def sanitize_html(html)
    return '' if html.blank?
    
    # Allow common newsletter HTML tags but sanitize for safety
    allowed_tags = %w[
      h1 h2 h3 h4 h5 h6 p br strong b em i u 
      ul ol li blockquote a img table thead tbody tr td th
      div span hr
    ]
    
    allowed_attributes = %w[
      href src alt title class id style width height
      border cellpadding cellspacing
    ]
    
    ActionController::Base.helpers.sanitize(
      html, 
      tags: allowed_tags,
      attributes: allowed_attributes
    )
  end
end
