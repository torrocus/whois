# encoding: utf-8

# This file is autogenerated. Do not edit it manually.
# If you want change the content of this file, edit
#
#   /spec/whois/answer/parser/responses/whois.ripn.net/su/status_registered_spec.rb
#
# and regenerate the tests with the following rake task
#
#   $ rake genspec:parsers
#

require 'spec_helper'
require 'whois/answer/parser/whois.ripn.net'

describe Whois::Answer::Parser::WhoisRipnNet, "status_registered.expected" do

  before(:each) do
    file = fixture("responses", "whois.ripn.net/su/status_registered.txt")
    part = Whois::Answer::Part.new(:body => File.read(file))
    @parser = klass.new(part)
  end

  context "#registrar" do
    it do
      @parser.registrar.should be_a(_registrar)
    end
    it do
      @parser.registrar.id.should           == "RUCENTER-REG-FID"
    end
    it do
      @parser.registrar.name.should         == nil
    end
    it do
      @parser.registrar.organization.should == nil
    end
  end
  context "#registrant_contacts" do
    it do
      lambda { @parser.registrant_contacts }.should raise_error(Whois::PropertyNotSupported)
    end
  end
  context "#admin_contacts" do
    it do
      @parser.admin_contacts.should be_a(Array)
    end
    it do
      @parser.admin_contacts.should have(1).items
    end
    it do
      @parser.admin_contacts[0].should be_a(_contact)
    end
    it do
      @parser.admin_contacts[0].type.should         == Whois::Answer::Contact::TYPE_ADMIN
    end
    it do
      @parser.admin_contacts[0].id.should           == nil
    end
    it do
      @parser.admin_contacts[0].name.should         == "Private Person"
    end
    it do
      @parser.admin_contacts[0].phone.should        == "+7 495 9681807"
    end
    it do
      @parser.admin_contacts[0].fax.should          == "+7 495 9681807"
    end
    it do
      @parser.admin_contacts[0].email.should        == "cis@cis.su"
    end
  end
  context "#technical_contacts" do
    it do
      lambda { @parser.technical_contacts }.should raise_error(Whois::PropertyNotSupported)
    end
  end
end
