require 'spec_helper'

describe Redis, "Audit" do
  describe "serializing commands" do
    context "with a single argument" do
      it "returns a string with the command and argument separated by a space" do
        subject.serialize_command(['get', 'mykey']).should == 'get mykey'
        subject.serialize_command(['get', 'another_key']).should == 'get another_key'
        subject.serialize_command(['del', 'key']).should == 'del key'
      end
    end
    context "with multiple arguments" do
      it "returns a string with the command and each argument separated by a space" do

      end
    end
    context "when command is invalid" do

    end
  end
  describe "single commands" do
    
  end
  describe "in audit" do
    it "returns true if asked if auditing" 
  end
  describe "after audit" do

  end
  describe "logging" do
    context "when logger exists" do
      pending "it logs the start of the audit"
      pending "it logs the end of the audit"
    end
    context "when logger does not exist" do

    end
  end
end
