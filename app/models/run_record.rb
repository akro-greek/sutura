class RunRecord < ApplicationRecord
  self.abstract_class = true

  enum :status, { pending: "pending", running: "running", completed: "completed", failed: "failed" }, default: :pending, validate: true
end
