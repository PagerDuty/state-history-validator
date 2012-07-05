module ActiveModel
  module Validations
    module HelperMethods

      def validate_state_history(association, options = {})
        params = { :association => association }
        params.merge!(options)
        validates_with StateHistoryValidator, params
      end

      def validate_state_history_entry(options = {})
        validates_with StateHistoryEntryValidator, options
      end

    end
  end
end
