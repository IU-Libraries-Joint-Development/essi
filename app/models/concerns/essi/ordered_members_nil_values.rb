module ESSI
  module OrderedMembersNilValues
    extend ActiveSupport::Concern

    # modified from hyrax 2.9.6 to remove any persisted nil values
    # (which aren't supposed to be possible, and so break things when they do happen
    # @return [ActiveFedora::Orders::TargetProxy, Array] original TargetProxy if unmodified; Array if modified successfully; original TargetProxy if errors modifying
    def ordered_members
      result = super
      member_array = result.to_a
      if member_array.any?(&:nil?)
        remove_nil_ordered_members(member_array) || result
      else
        result
      end
    end

    # removes nil values from member_array and notifies work depositor via email, Hyrax notifications
    # @param member_array [Array] an ordered_members Array containing nil values 
    # @return [Array, FalseClass, NilClass] fixed ordered_members Array when successful, false when failed, nil when no action
    def remove_nil_ordered_members(member_array)
      return unless member_array.any?(&:nil?)
      nil_indexes = member_array.each_index.select { |i| member_array[i].nil? }
      Rails.logger.error("Nil values present in ordered_members of #{self.class.to_s} #{self.id} at indexes: #{nil_indexes.join(', ')}")
      begin
        revised_members = member_array.reject(&:nil?)
        self.ordered_members = revised_members
        if self.save(validate: false)
          Rails.logger.info("Nil values successfully removed from ordered_members of #{self.class.to_s} #{self.id} at indexes: #{nil_indexes.join(', ')}")
          notify_user_of_nil_values(true, nil_indexes)
          CleanListSourceByIdJob.perform_later(self.id)
          revised_members
        else
          Rails.logger.error("Save failure updating resource to remove nil values from ordered_members of #{self.class.to_s} #{self.id} at indexes: #{nil_indexes.join(', ')}")
          Rails.logger.error(self.errors.full_messages.join("\n"))
          notify_user_of_nil_values(false, nil_indexes)
          false
        end
      rescue => e
        Rails.logger.error("Error attempting to remove nil values from ordered_members of #{self.class.to_s} #{self.id} at indexes: #{nil_indexes.join(', ')}")
        Rails.logger.error(e.inspect)
        notify_user_of_nil_values(false, nil_indexes)
        false
      end
    end

    # emails depositor, additionally sends Hyrax notification if user account found
    def notify_user_of_nil_values(result, nil_indexes)
      message = "#{result ? 'Success' : 'Failure' } removing nil values found in ordered_members of #{self.class.to_s} #{self.id} at position(s): #{nil_indexes.map { |i| i + 1 }.join(', ')}"
      subject = "Nil values in #{self.id}"
      email = self.depositor
      return unless email
      headers = { mime_version: "1.0", charset: "UTF-8", content_type: "text/plain", parts_order: ["text/plain", "text/enriched", "text/html"],
                  subject: subject, body: message, to: email, from: Hyrax.config.contact_email }
      ActionMailer::Base.new.mail(headers).deliver
      # notify hyrax dashboard 
      user = User.find_by_email(email)
      Hyrax::MessengerService.deliver(user, user, message, subject) if user
    end
  end
end
