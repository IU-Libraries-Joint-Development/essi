module ESSI
  module OrderedMembersNilValues
    extend ActiveSupport::Concern

    def ordered_members
      result = super
      Rails.logger.error("Nil values present in ordered_members of #{self.class.to_s} #{self.id}") if result.to_a.any?(&:nil?)
      result
    end
  end
end
