class Item < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :description, presence: true

  def as_json(options = {})
    super(options.merge(
      include: {
        user: {
          only: [:id, :name, :email]
        }
      }
    ))
  end
end 