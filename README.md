# StateHistoryValidator

**Current version:** 0.0.1

The StateHistoryValidator gem is a collection of two Validators that aid in
verifying the integrity of a state history association. As defined here, a
state history is a collection of entries, each with start and end time
attributes.

One validator provided is the aptly-named StateHistoryValidator. This Validator
examines a state history holistically checking for a variety of issues. These 
issues include:

* Overlaps: the time ranges of two consecutive entries overlap
* Gaps: the time ranges of two consecutive entries are not continuous
* Self-transitions: two continuous consecutive entries are equivalent in state
* Simultaneous states: an entry that is not the last entry has not ended (i.e.
the entry's end time is `nil`)
* Ended state histories: the last entry has ended (i.e. last entry's end time
is `nil`)

The user of this validator can disable any combination of these checks as he or
she wishes.

The other validator provided is the StateHistoryEntryValidator. This Validator
examines each state history entry on its own, checking for these issues:

* Zero-length entries: the entry begins and ends at the same time
* Ends before starting: the entry ends before it starts (end < start)

As with the first validator, the user can disable any combination of these
checks.

## Installation

Add this line to your application's Gemfile:

    gem 'state_history_validator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install state_history_validator

## Usage

### Examples

#### StateHistoryValidator
Let's say that we want to check the integrity of `:state_history_entries`.
This is how we might call the validator:

    validate_state_history :state_history_entries,
      :self_transition_match => [:state_id],
      :allow => [:gaps]

Here, our validator will allow for gaps in the state history entries. It
will look for self-transitions depending on whether the `:state_id`
attribute of two consecutive entries match.

#### StateHistoryEntryValidator
Let's say we want to validate an entry, but we don't particularly care
about zero-entries. In addition, our entry uses the attribute `:begin` to
indicate its start time attribute. This is how we might use the validator:

    validate_state_history_entry
      :start => :begin
      :allow => [:zero_duration]

Note that we omitted the comma after `validate_state_history_entry`.

### Interface
With these examples in mind, here is the full documentation on every option
that can be toggled.

#### StateHistoryValidator
* `:start` -- (default = `:start`) Specifies the attribute referring to the
starting time of each entry
* `:end` -- (default = `:end`) Specifies the attribute referring to the
ending time of each entry
* `:order` -- (default = `#{start} ASC, ISNULL(#{end}) ASC, #{end} ASC`)
Specifies the SQL order by which the validator will sort all entries in the
state history. This is essential in ensuring that the validator obtains the
correct chronological order of entries so that it can properly check for
issues. By default, the validator sorts in ascending order of starting 
time. If the start times for two entries are equal, it will then sort by
end times (pushing `nil` ends to the bottom).
* `:self_transition_match` -- (default = `[]`) Specifies the attributes to
check two states for equality. This is used when checking for self-transitions.
If self-transitions are allowed, this option has no effect. If this option
is left to its default value of an empty array, the validator will not check
for self-transitions.
* `:allow` -- (default = `[]`) Specifies issues to be ignored by the validator.
This is specified as a list of issues. By default, all checks are performed.
The issues that can be specified are:
    * `:gaps` -- Ignore gaps
    * `:overlaps` -- Ignore overlaps
    * `:self_transitions` -- Ignore two consecutive equal states. As a side
    note, two equal states separated by a gap are not considered to be in
    self-transition.
    * `:simultaneous` -- Ignore entries whose end attributes are `nil`, which
    indicates that the entry has not ended yet. This excludes the final state.
    * `:last_end_not_nil` -- Ignore the last entry not ending with a `nil`

#### StateHistoryEntryValidator
* `:start` -- (default = `:start`) Specifies the attribute referring to the
starting time of this entry
* `:end` -- (default = `:end`) Specifies the attribute referring to the ending
time of this entry
* `:allow` -- (default = `[]`) Specifies issues to be ignored by the validator.
    * `:zero_duration` -- Ignore start time equal to end time
    * `:end_before_start` -- Ignore end time less than start time
      

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
