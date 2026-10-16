class Task < ApplicationRecord
  include Positioned

  belongs_to :user
  belongs_to :worker, optional: true

  validates :name, presence: true
  validates :percent_complete, inclusion: { in: [ 0, 25, 50, 75, 100 ] }

  # One click on this task's bubble in worker's column: assigns an unassigned task to
  # worker, steps its progress by 25% per click, and unassigns it after 100%.
  # Bubbles in other workers' columns do nothing while the task is assigned.
  def advance!(worker)
    return if self.worker && self.worker != worker

    if self.worker.nil?
      update!(worker:, percent_complete: 0)
    elsif percent_complete < 100
      update!(percent_complete: percent_complete + 25)
    else
      update!(worker: nil, percent_complete: 0)
    end
  end
end
