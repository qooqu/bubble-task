# Records kept in a user-defined order, like the board's workers and tasks.
module Positioned
  extend ActiveSupport::Concern

  included do
    before_create :append_to_end
  end

  class_methods do
    # Sets positions to match the order of ids. Call it through an association
    # (e.g. Current.user.tasks.reposition(ids)) so ids from other users are ignored.
    def reposition(ids)
      transaction do
        ids.each.with_index { |id, position| where(id:).update_all(position:) }
      end
    end
  end

  private
    def append_to_end
      self.position = (self.class.where(user_id:).maximum(:position) || -1) + 1
    end
end
