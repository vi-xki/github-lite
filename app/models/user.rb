class User < ApplicationRecord
  has_secure_password
  has_one_attached :profile_image

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :mobile, presence: true, format: { with: /\A[0-9]{10}\z/, message: "must be 10 digits" }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validate :acceptable_profile_image

  has_many :items, dependent: :destroy

  def as_json(options = {})
    super(options.merge(
      except: [:password_digest],
      methods: [:profile_image_url]
    ))
  end

  def profile_image_url
    Rails.application.routes.url_helpers.url_for(profile_image) if profile_image.attached?
  end

  private

  def acceptable_profile_image
    return unless profile_image.attached?

    unless profile_image.blob.byte_size <= 5.megabytes
      errors.add(:profile_image, "is too big (maximum is 5MB)")
    end

    acceptable_types = ["image/png", "image/jpeg", "image/jpg"]
    unless acceptable_types.include?(profile_image.blob.content_type)
      errors.add(:profile_image, "must be a PNG or JPEG")
    end
  end
end 