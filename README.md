# TTML Ruby

Simple Timed Text Markup Language (TTML) parsing. Builds upon [TTML](https://github.com/loop23/ttml) by [Luca S.G. de Marinis](https://github.com/loop23) and [SRT](https://github.com/cpetersen/srt) by [Christopher Petersen](https://github.com/cpetersen).

## Installation

Add this line to your application's Gemfile:

    gem 'ttml-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ttml-ruby

## Usage

Parse an entire TTML file in Ruby:

    require 'ttml'
    doc = TTML::Document.parse("test/sample.xml")
    doc.lines.each do |line|
      puts line.sequence
      puts line.start_time
      puts line.end_time
      puts line.text.join(" ")
      puts line.cleaned_text.join(" ")
    end

Command line example for converting TTML to SRT:

    $ ttml2srt test/sample.xml > sample.srt

## Test

Run all tests:

    bundle exec rake

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
