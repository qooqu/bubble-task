class Worker < ApplicationRecord
  include Positioned

  belongs_to :user
  has_many :tasks

  validates :name, presence: true

  # Tasks assigned to a deleted worker go back to unassigned, with their progress reset.
  before_destroy { tasks.update_all(worker_id: nil, percent_complete: 0) }
end
