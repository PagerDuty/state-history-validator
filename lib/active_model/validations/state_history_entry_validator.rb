require 'active_model/validations'

module ActiveModel
  module Validations

    class StateHistoryEntryValidator < ActiveModel::Validator
      def initialize(options = {})
        super

        @start = options[:start] || :start
        @end   = options[:end]   || :end
        @allow = options[:allow] || []
      end

      def validate(record)
        non_zero?(record)         unless @allow.include? :zero_duration
        start_before_end?(record) unless @allow.include? :end_before_start

        return
      end

      private

      def non_zero?(record)
        start = record[@start]
        _end  = record[@end]
        if start == _end
          record.errors[:base] << "Start time (#{start}) is equal to end (#{_end})"
        end
      end

      def start_before_end?(record)
        start = record[@start]
        _end  = record[@end]
        if !_end.blank? && start > _end
          record.errors[:base] << "Start time (#{start}) is later than end time (#{_end})"
        end
      end
    end

    module HelperMethods
      def validate_state_history_entry(options = {})
        start_attr = options[:start] || :start
        validates start_attr, :presence => true

        validates_with StateHistoryEntryValidator, options
      end
    end

  end
end
