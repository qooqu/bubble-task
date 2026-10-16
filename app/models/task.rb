class Task < ApplicationRecord
  include Positioned

  belongs_to :user
  belongs_to :worker, optional: true

  validates :name, presence: true
  validates :percent_complete, inclusion: { in: [ 0, 25, 50, 75, 100 ] }
  validate :worker_has_same_user, if: :worker

  # One click on this task's bubble in for_worker's column: assigns an unassigned task to
  # for_worker, steps its progress by 25% per click, and unassigns it after 100%.
  # Bubbles in other workers' columns do nothing while the task is assigned.
  def advance!(for_worker)
    return if worker_id && worker_id != for_worker.id

    if worker_id.nil?
      update!(worker: for_worker, percent_complete: 0)
    elsif percent_complete < 100
      update!(percent_complete: percent_complete + 25)
    else
      update!(worker: nil, percent_complete: 0)
    end
  end

  private
    def worker_has_same_user
      errors.add(:worker, "must belong to the task's user") unless worker.user_id == user_id
    end
end
