require 'test_helper'

class HelperMethodsTest < ActiveSupport::TestCase
  context "The helper methods on a perfectly valid state history" do
    setup do
      now = DateTime.new(2011, 2, 3, 5, 8, 13)
      @starts = [now, now + 2.months, now + 3.months, now + 5.months]
      @ends   = [now + 2.months, now + 3.months, now + 5.months, nil]
    end

    should "simply work" do
      record_entries = []
      @starts.each_with_index do |start, i|
        _end = @ends[i]
        id = i
        entry = RecordEntry.new(start, _end, id)

        assert entry.valid?

        record_entries << entry
      end

      record_entries.stubs(:order).with("start ASC, ISNULL(end) ASC, end ASC").returns(record_entries)
      record_entries.stubs(:all).returns(record_entries)

      record = Record.new(record_entries)

      assert record.valid?
    end
  end

end

class Record < Struct.new(:record_entries)
  include ActiveModel::Validations

  validate_state_history :record_entries,
    :self_transition_match => [:id]
end

class RecordEntry < Struct.new(:start, :end, :id)
  include ActiveModel::Validations

  validate_state_history_entry
end
