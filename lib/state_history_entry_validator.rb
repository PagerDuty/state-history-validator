require 'active_model'

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
      return false
    end

    true
  end

  def start_before_end?(record)
    start = record[@start]
    _end  = record[@end]
    if !_end.blank? && start > _end
      record.errors[:base] << "Start time (#{start}) is later than end time (#{_end})"
      return false
    end

    true
  end
end
