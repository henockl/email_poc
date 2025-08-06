class SendNewsletterJob < ApplicationJob
  queue_as :default

  def perform(date = Date.current)
    # Find newsletters that are published, not sent, and scheduled for today
    newsletters = Newsletter.ready_to_send(date)

    newsletters.each do |newsletter|
      # Get active subscribers
      active_subscribers = Subscriber.active

      Rails.logger.info "Sending newsletter '#{newsletter.title}' to #{active_subscribers.count} subscribers"

      if active_subscribers.any?
        # Use bulk sending for better performance
        result = NewsletterMailer.send_to_subscribers(newsletter, active_subscribers)
        Rails.logger.info "Bulk send results - Successful: #{result[:successful]}, Failed: #{result[:failed]}"
      else
        Rails.logger.info "No active subscribers found for newsletter '#{newsletter.title}'"
      end

      # Mark newsletter as sent (even if no active subscribers)
      newsletter.mark_as_sent!
      Rails.logger.info "Newsletter '#{newsletter.title}' marked as sent"
    end
  end
end
