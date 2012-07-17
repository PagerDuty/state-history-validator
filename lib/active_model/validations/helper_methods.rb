require 'active_model/validations'

module ActiveModel
  module Validations

    module HelperMethods
      def validate_state_history_entry(options = {})
        start_attr = options[:start] || :start
        validates start_attr, :presence => true

        validates_with StateHistoryEntryValidator, options
      end


      def validate_state_history(association, options = {})
        params = { :association => association }
        params.merge!(options)
        validates_with StateHistoryValidator, params
      end
    end

  end
end

