require 'test_helper'

module ActiveModel
  module Validations

    class StateHistoryEntryValidatorTest < ActiveSupport::TestCase
      context "An \"perfect\" account state history entry" do
        setup do
          @now = DateTime.new(2011, 2, 3, 5, 8, 13)
        end

        should "be valid by default with no checks disabled" do
          entry = ValidatableEntry.new(@now, @now + 1.days)

          validator = StateHistoryEntryValidator.new
          validator.validate(entry)

          assert !entry.errors.any?
        end

        should "be valid if :start and :end are changed" do
          MockEntry = Struct.new(:begin, :finish)
          MockEntry.class_eval do
            include ActiveModel::Validations
          end
          entry = MockEntry.new(@now, @now + 1.days)

          validator = StateHistoryEntryValidator.new(
            :start => :begin,
            :end => :finish
          )
          validator.validate(entry)

          assert !entry.errors.any?
        end

        should "be valid even if the end is nil" do
          entry = ValidatableEntry.new(@now, nil)

          validator = StateHistoryEntryValidator.new
          validator.validate(entry)

          assert !entry.errors.any?
        end
      end

      context "An account state history entry where start == end" do
        setup do
          @now = DateTime.new(2011, 2, 3, 5, 8, 13)
          @entry = ValidatableEntry.new(@now, @now)
        end

        should "not be valid with no checks disabled" do
          validator = StateHistoryEntryValidator.new
          validator.validate(@entry)

          assert @entry.errors.any?
        end

        should "be valid with :zero_duration allowed" do
          validator = StateHistoryEntryValidator.new(
            :allow => [:zero_duration]
          )
          validator.validate(@entry)

          assert !@entry.errors.any?
        end
      end

      context "An account state history entry where start > end" do
        setup do
          @now = DateTime.new(2011, 2, 3, 5, 8, 13)
          @entry = ValidatableEntry.new(@now + 1.days, @now)
        end

        should "not be valid with no checks disabled" do
          validator = StateHistoryEntryValidator.new
          validator.validate(@entry)

          assert @entry.errors.any?
        end

        should "be valid with :end_before_start allowed" do
          validator = StateHistoryEntryValidator.new(
            :allow => [:end_before_start]
          )
          validator.validate(@entry)

          assert !@entry.errors.any?
        end
      end

      private

      class ValidatableEntry < Struct.new(:start, :end)
        include ActiveModel::Validations
      end
    end

  end
end
