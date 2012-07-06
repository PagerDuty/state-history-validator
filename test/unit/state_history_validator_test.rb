require 'test_helper'

module ActiveModel
  module Validations

    class StateHistoryValidatorTest < ActiveSupport::TestCase
      context "A perfectly valid state history" do
        setup do
          now = DateTime.new(2011, 2, 3, 5, 8, 13)
          @starts = [now, now + 2.months, now + 3.months, now + 5.months]
          @ends   = [now + 2.months, now + 3.months, now + 5.months, nil]
        end

        should "simply be valid with the default options" do
          state_history = mock_state_history(@starts, @ends) do |entry, i|
            entry[:other_id] = i + 1
          end

          record = Validatable.new(state_history)
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id, :other_id]
          )
          validator.validate(record)

          assert !record.errors.any?
        end

        should "be valid if we only set a different start and end name" do
          MockEntry = Struct.new(:begin, :finish, :id, :other_id)
          state_history = mock_state_history(@starts, @ends, nil,
                                             {:entry_class => MockEntry,
                                              :start => :begin,
                                              :end => :finish}) do |entry, i|
            entry[:other_id] = i + 1
          end

          record = Validatable.new(state_history)
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :start => :begin,
            :end   => :finish,
            :self_transition_match => [:id, :other_id]
          )
          validator.validate(record)

          assert !record.errors.any?
        end

      end

      context "A \"perfect\" state history with a self-transition" do
        setup do
          now = DateTime.new(2011, 2, 3, 5, 8, 13)
          starts = [now, now + 2.months, now + 3.months, now + 5.months]
          ends   = [now + 2.months, now + 3.months, now + 5.months, nil]
          ids = [0, 1, 1, 2]
          other_id = [1, 1, 1, 2]

          state_history = mock_state_history(starts, ends, ids) do |entry, i|
            entry[:other_id] = other_id[i]
          end

          @record = Validatable.new(state_history)
        end

        should "be invalid with nothing allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id, :other_id]
          )
          validator.validate(@record)

          assert @record.errors.any?
        end

        should "be valid with :self_transitions allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id, :other_id],
            :allow => [:self_transitions]
          )
          validator.validate(@record)

          assert !@record.errors.any?
        end

        should "be valid if no :self_transition_match is specified and nothing is allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries
          )
          validator.validate(@record)

          assert !@record.errors.any?
        end
      end

      context "A \"perfect\" state history with a non-nil end" do
        setup do
          now = DateTime.new(2011, 2, 3, 5, 8, 13)
          starts = [now, now + 2.months, now + 3.months, now + 5.months]
          ends   = [now + 2.months, now + 3.months, now + 5.months, now + 8.months]

          @state_history = mock_state_history(starts, ends, nil) {}

          @record = Validatable.new(@state_history)
        end

        should "not be valid with nothing allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id]
          )
          validator.validate(@record)

          assert @record.errors.any?
        end

        should "be valid with :last_end_not_nil allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id],
            :allow => [:last_end_not_nil]
          )
          validator.validate(@record)

          assert !@record.errors.any?
        end
      end

      context "A state history with overlaps" do
        setup do
          now = DateTime.new(2011, 2, 3, 5, 8, 13)
          starts = [now, now + 2.months, now + 3.months, now + 5.months]
          ends   = [now + 2.months, now + 3.months, now + 6.months, nil]

          @state_history = mock_state_history(starts, ends) {}

          @record = Validatable.new(@state_history)
        end

        should "not be valid with nothing allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id]
          )
          validator.validate(@record)

          assert @record.errors.any?
        end

        should "be valid with :overlaps allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id],
            :allow => [:overlaps]
          )
          validator.validate(@record)

          assert !@record.errors.any?
        end
      end

      context "A state history with gaps" do
        setup do
          now = DateTime.new(2011, 2, 3, 5, 8, 13)
          starts = [now, now + 2.months, now + 3.months, now + 5.months]
          ends   = [now + 2.months, now + 3.months, now + 4.months, nil]

          state_history = mock_state_history(starts, ends) {}
          @record = Validatable.new(state_history)
        end

        should "not be valid with nothing allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id]
          )
          validator.validate(@record)

          assert @record.errors.any?
        end

        should "be valid with :gaps allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id],
            :allow => [:gaps]
          )
          validator.validate(@record)

          assert !@record.errors.any?
        end
      end

      context "A state history with nil `:ends` in the middle" do
        setup do
          now = DateTime.new(2011, 2, 3, 5, 8, 13)
          @starts = [now, now + 2.months, now + 3.months, now + 5.months]
          @ends   = [now + 2.months, nil, now + 5.months, nil]

          state_history = mock_state_history(@starts, @ends) {}
          @record = Validatable.new(state_history)
        end

        should "not be valid with nothing allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id]
          )
          validator.validate(@record)

          assert @record.errors.any?
        end

        should "be valid with :nil_end_in_middle allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id],
            :allow => [:nil_end_in_middle]
          )
          validator.validate(@record)

          assert !@record.errors.any?
        end
      end

      context "A state history with two consecutive equivalent states separated by a gap" do
        setup do
          now = DateTime.new(2011, 2, 3, 5, 8, 13)
          @starts = [now, now + 2.months]
          @ends   = [now + 1.months, nil]
          @id     = [0, 0]

          state_history = mock_state_history(@starts, @ends, @id) {}

          @record = Validatable.new(state_history)
        end

        should "not be valid with nothing allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id]
          )
          validator.validate(@record)

          assert @record.errors.any?
        end

        should "be valid with :gaps allowed" do
          validator = StateHistoryValidator.new(
            :association => :state_history_entries,
            :self_transition_match => [:id],
            :allow => [:gaps]
          )
          validator.validate(@record)

          assert !@record.errors.any?
        end
      end

      private

      class Validatable < Struct.new(:state_history_entries)
        include ActiveModel::Validations
      end

      class ValidatableEntry < Struct.new(:start, :end, :id, :other_id)
      end

      # fake the entries.order(@order).all call
      def state_history_stub(state_history, options = {})
        start_attr = options[:start] || :start
        end_attr = options[:end] || :end
        sort_dir = options[:sort_dir] || "ASC"

        order_by = options[:order] || 
          "#{start_attr} #{sort_dir}, ISNULL(#{end_attr}) #{sort_dir}, #{end_attr} #{sort_dir}"

        state_history.stubs(:order).with(order_by).returns(state_history)
        state_history.stubs(:all).returns(state_history)
      end

      # Set up a state_history with fake objects and then yield to allow further customization
      def mock_state_history(starts, ends, ids = nil, options = {})
        stub_history = (options[:stub_history].nil?) ? true : options[:stub_history]
        entry_class = (options[:entry_class].nil?) ? ValidatableEntry : options[:entry_class]

        state_history = []
        starts.each_with_index do |start, i|
          _end = ends[i]
          id = (ids.nil?) ? i : ids[i]
          entry = entry_class.new(start, _end, id)

          yield entry, i

          state_history << entry
        end

        state_history_stub(state_history, options) if stub_history

        state_history
      end

    end

  end
end
