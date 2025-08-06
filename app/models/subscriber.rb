class Subscriber < ApplicationRecord
  include Mailkick::Model

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 255 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  before_validation :set_defaults

  def full_info
    "#{name} <#{email}>"
  end

  private

  def set_defaults
    self.active = true if active.nil?
  end
end
