class Newsletter < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true
  validates :publish_date, presence: true
  # validate :publish_date_must_be_end_of_week
  validate :cannot_edit_if_published

  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :unsent, -> { where(sent: false) }
  scope :ready_to_send, ->(date) { published.unsent.where(publish_date: date) }

  before_validation :set_defaults

  def can_edit?
    !published?
  end

  def mark_as_sent!
    update!(sent: true)
  end

  private

  def set_defaults
    self.published ||= false
    self.sent ||= false
  end

  def publish_date_must_be_end_of_week
    return unless publish_date

    # Sunday is end of week (wday 0)
    unless publish_date.wday == 0
      errors.add(:publish_date, "must be a Sunday (end of week)")
    end
  end

  def cannot_edit_if_published
    # Prevent unpublishing
    if published_changed? && published_changed?(from: true, to: false)
      errors.add(:base, "Cannot unpublish a newsletter")
    end

    # Prevent editing title/content when published
    if persisted? && published? && (title_changed? || content_changed?)
      errors.add(:base, "Cannot edit a published newsletter")
    end
  end
end
