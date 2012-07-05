require 'active_model'
require File.join(File.dirname(__FILE__), 'active_model', 'validations', 'helper_methods')
:wa

class StateHistoryValidator < ActiveModel::Validator
  def initialize(options = {})
    super

    @association = options[:association]

    @start = options[:start] || :start
    @end   = options[:end]   || :end
    @match = options[:match] || []
    @order = options[:order] || "#{@start.to_s} ASC, ISNULL(#{@end}) ASC, #{@end} ASC"
    @allow = options[:allow] || []
  end

  def validate(record)
    entries = record.send(@association)
    sorted_history = entries.order(@order).all

    return if sorted_history.blank?

    if !@allow.include? :last_end_not_nil
      valid = last_end_nil?(sorted_history, record.errors)
      return unless valid
    end

    no_self_trans = no_gaps = no_overlaps = no_nils = true
    sorted_history.each_cons(2) do |a|
      this_entry = a[0]
      next_entry = a[1]

      if !@allow.include? :self_transitions
        no_self_trans = no_self_transitions?(this_entry, next_entry, record.errors)
      end

      if !@allow.include? :gaps
        no_gaps = no_gaps?(this_entry, next_entry, record.errors)
      end

      if !@allow.include? :overlaps
        no_overlaps = no_overlaps?(this_entry, next_entry, record.errors)
      end

      if !@allow.include? :nil_end_in_middle
        no_nils = no_intervening_nils?(this_entry, record.errors)
      end

      return unless no_self_trans && no_gaps && no_overlaps && no_nils
    end

    return
  end

  private

  def last_end_nil?(history, errors)
    last = history.last

    if last[@end] != nil
      errors[:base] << "no nil ending"
      return false
    end

    true
  end

  def no_self_transitions?(this_entry, next_entry, errors)
    if matches?(this_entry, next_entry) && this_entry[@end] == next_entry[@start]
      errors[:base] << "self-transition found"
      return false
    end

    true
  end

  def no_gaps?(this_entry, next_entry, errors)
    if !this_entry[@end].nil? && next_entry[@start] > this_entry[@end]
      errors[:base] << "Gap found"
      return false
    end

    true
  end

  def no_overlaps?(this_entry, next_entry, errors)
    if !this_entry[@end].nil? && next_entry[@start] < this_entry[@end]
      errors[:base] << "Overlap found"
      return false
    end

    true
  end

  # This doesn't get invoked on the very last entry, so we should be safe
  def no_intervening_nils?(this_entry, errors)
    if this_entry[@end].blank?
      errors[:base] << "Found nil end in middle of state history"
      return false
    end

    true
  end

  # Match two entries based on the specified attributes in @match
  def matches?(entry1, entry2)
    return false if @match.size == 0

    @match.each do |attr|
      return false if entry1[attr] != entry2[attr]
    end

    true
  end

end
