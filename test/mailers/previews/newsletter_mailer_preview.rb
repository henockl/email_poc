# Preview all emails at http://localhost:3000/rails/mailers/newsletter_mailer
class NewsletterMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/newsletter_mailer/weekly_newsletter
  def weekly_newsletter
    NewsletterMailer.weekly_newsletter
  end
end
