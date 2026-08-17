class CandidateMatchPolicy < ApplicationPolicy
  def index? = user.present?
  def show? = user.present?
  def review? = user.present?

  class Scope < ApplicationPolicy::Scope
  end
end
