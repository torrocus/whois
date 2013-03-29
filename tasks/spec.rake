require 'fileutils'

namespace :spec do

  ROOT_DIR      = File.expand_path("../../", __FILE__)
  TARGET_DIR    = File.join(ROOT_DIR, %w( spec whois record parser responses ))

  SOURCE_DIR    = File.join(ROOT_DIR, %w( spec fixtures responses ))
  SOURCE_PARTS  = SOURCE_DIR.split("/")


  TPL_DESCRIBE = <<-RUBY.chomp!
# encoding: utf-8

# This file is autogenerated. Do not edit it manually.
# If you want change the content of this file, edit
#
#   %{sfile}
#
# and regenerate the tests with the following rake task
#
#   $ rake spec:generate
#

require 'spec_helper'
require 'whois/record/parser/%{khost}.rb'

describe %{described_class}, "%{descr}" do

  subject do
    file = fixture("responses", "%{fixture}")
    part = Whois::Record::Part.new(:body => File.read(file))
    described_class.new(part)
  end

%{contexts}
end
  RUBY

  TPL_CONTEXT  = <<-RUBY.chomp!
  describe "#%{descr}" do
    it do
%{examples}
    end
  end
  RUBY

  TPL_MATCH = <<-RUBY.chomp!
      subject.%{attribute}.%{should} %{match}
  RUBY

  TPL_MATCH_RAISE = <<-RUBY.chomp!
      lambda { subject.%{attribute} }.%{should} %{match}
  RUBY

  def relativize(path)
    path.gsub(ROOT_DIR, "")
  end


  task :generate => :generate_parsers

  task :generate_parsers do
    Dir["#{SOURCE_DIR}/**/*.expected"].each do |source_path|

      # Generate the filename and described_class name from the test file.
      parts = (source_path.split("/") - SOURCE_PARTS)
      khost = parts.first
      kfile = parts.last
      described_class = Whois::Record::Parser.parser_described_class(khost)

      target_path = File.join(TARGET_DIR, *parts).gsub(".expected", "_spec.rb")

      # Extract the tests from the test file
      # and generates a Hash.
      #
      #   {
      #     "domain" => [
      #       ["%s", "should", "== \"google.biz\""]
      #     ],
      #     "created_on" => [
      #       ["%s", "should", "be_a(Time)"],
      #       ["%s", "should", "== Time.parse(\"2002-03-27 00:01:00 UTC\")"]
      #     ]
      #   }
      #
      tests = {}
      match = nil
      lines = File.open(source_path)
      lines.each do |line|
        line.chomp!
        case line
        when ""
          # skip empty line
        when /^\s*\/\//
          # skip comment line
        when /^#([^\s]+)/
          tests[match = $1] = []
        when /^\s+(.+?): (.+?) (.+)/
          tests[match] << _parse_assertion($2, $1, $3)
        else
          raise "Invalid Line `#{line}' in `#{source_path}'"
        end
      end

      # Generate the RSpec content and
      # write one file for every test.
      contexts = tests.map do |attr, specs|
        matches = specs.map do |method, should, condition|
          attribute = method % attr
          if condition.index("raise_")
            TPL_MATCH_RAISE % { :attribute => attribute, :should => should, :match => condition }
          else
            TPL_MATCH % { :attribute => attribute, :should => should, :match => condition }
          end
        end.join("\n")
        TPL_CONTEXT % { :descr => attr, :examples => matches }
      end.join("\n")

      describe = <<-RUBY
#{TPL_DESCRIBE % {
  :described_class    => described_class,
  :khost    => khost,
  :descr    => kfile,
  :sfile    => relativize(source_path),
  :fixture  => parts.join("/").gsub(".expected", ".txt"),
  :contexts => contexts
}}
      RUBY

      print "Generating #{relativize(target_path)}... "
      File.dirname(target_path).tap { |d| File.exists?(d) || FileUtils.mkdir_p(d) }
      File.open(target_path, "w+") { |f| f.write(describe) }
      print "done!\n"
    end

  end


  def _parse_assertion(method, should, condition)
    m = method
    s = should
    c = condition

    case condition

    # should: %s CLASS(time)
    # ->
    # should: %s be_a(time)
    when /^CLASS\((.+)\)$/
      c = "be_a(#{_build_condition_typeof($1)})"

    # should: %s SIZE(3)
    # ->
    # should: %s have(3).items
    when /^SIZE\((.+)\)$/
      c = "have(#{$1}).items"
    end

    [m, s, c]
  end

  def _build_condition_typeof(described_class)
    case described_class
    when "array"      then "Array"
    when "time"       then "Time"
    when "contact"    then "Whois::Record::Contact"
    when "registrar"  then "Whois::Record::Registrar"
    when "nameserver" then "Whois::Record::Nameserver"
    else
      raise "Unknown class `#{described_class}'"
    end
  end

  def _build_condition_typecast(described_class, value)
    case described_class
    when "time"       then %Q{Time.parse("#{value}")}
    else
      raise "Unknown class `#{described_class}'"
    end
  end

end
