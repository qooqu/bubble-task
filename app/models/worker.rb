class Worker < ApplicationRecord
  include Positioned

  belongs_to :user
  has_many :tasks

  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, length: { maximum: 50 }

  # Tasks assigned to a deleted worker go back to unassigned, with their progress reset.
  before_destroy { tasks.update_all(worker_id: nil, percent_complete: 0, updated_at: Time.current) }
end
