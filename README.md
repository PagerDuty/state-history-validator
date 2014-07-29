# StateValidations

**Current version:** 0.2.0

The StateValidations gem is a collection of two Validators that aid in
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
she wishes through the `:allow` option.

The other validator provided is the StateHistoryEntryValidator. This Validator
examines each state history entry on its own, checking for these issues:

* Zero-length entries: the entry begins and ends at the same time
* Ends before starting: the entry ends before it starts (end < start)

As with the first validator, the user can disable any combination of these
checks.

## Installation

Add this line to your application's Gemfile:

    gem 'state_validations'

And then execute:

    $ bundle

Or install it yourself as:

    $ git clone git://github.com/PagerDuty/state-history-validator.git
    $ rake build
    $ gem install pkg/state_validations-(version).gem

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

The StateHistoryEntryValidator requires that the receiving class validate
for the presence of the `:start` attribute. The `validate_state_history_entry`
construct, which is the recommended way to call this validator, performs this
validation automatically.

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
    * `:active_middle_states` -- Ignore the presence of an active state in the
    middle of a state history. An active state is defined by the state's `:end`
    attribute being `nil`.
    This excludes the final state.
    * `:inactive_end_state` -- Ignore the lack of a final active ending state.
    Using our earlier definition, this means that the last entry does not have
    `nil` as the value of its `:end` attribute.

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


#License and Copyright
Copyright (c) 2014, PagerDuty
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

* Neither the name of [project] nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
