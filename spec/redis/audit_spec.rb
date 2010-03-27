require 'spec_helper'

describe Redis, "Audit" do
  let (:example_commands) do 
    [
     ['set', 'abc', 'aval'],
     ['get', 'abc'],
     ['lpush', 'def', 'aval'],
     ['lrange', 'def', '0', '-1']
    ]
  end
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
        subject.serialize_command(['set', 'mykey', 'myvalue']).should == 'set mykey myvalue'
        subject.serialize_command(['set', 'anotherkey', 'anothervalue']).should == 'set anotherkey anothervalue'
        subject.serialize_command(['lpush', 'alist', 1]).should == 'lpush alist 1'
      end
    end
  end
  describe "last command, no audit" do  
    it "returns the last command array" do
      example_commands.each do |command|
        subject.call_command command
        subject.last_command.should == command
      end
    end
  end
  describe "last command effect" do
    it "is :none if GET command access a key" do
      subject.set 'key', 'abc'
      subject.get 'key'
      subject.last_effect.should == :none
    end
    it "is :none if RANDOMKEY command is called" do
      subject.randomkey
      subject.last_effect.should == :none
    end
    it "is :create if SET command creates a key" do
      subject.delete 'key'
      subject.call_command ['set', 'key', 'abc']
      subject.last_effect.should == :create
    end
    it "is :update if SET command updates a key" do
      subject.set 'key', 'def'
      subject.set 'key', 'def'
      subject.last_effect.should == :update
    end
    it "is :destroy if DELETE command is called on a key" do
      subject.set 'key', 'def'
      subject.delete 'key'
      subject.last_effect.should == :destroy
    end
  end
  describe "previous state" do
    context "when updating a value" do
      it "returns the value before a SET" do
        subject.delete 'key'
        subject.set 'key', 'a'
        subject.last_value('key').should be_nil
        subject.set 'key', 'b'
        subject.last_value('key').should == 'a'
        subject.get('key').should == 'b'
      end
    end
    context "when deleting a value" do
      it "returns a string if the deleted key had a string value" do
        subject.set 'key', 'abc'
        subject.delete 'key'
        subject.last_value('key').should == 'abc'
      end
      it "returns an array if the delete key had a list value" do
        subject.delete 'key'
        subject.lpush 'key', 1
        subject.lpush 'key', 2
        subject.delete 'key'
        subject.last_value('key').should == %w[2 1]
      end
    end
  end
  describe "in audit" do
    before(:each) do
      subject.start_audit
      example_commands.each do |command|
        subject.call_command command
      end
    end
    after(:each) do
      subject.stop_audit
      subject.delete subject.audit_key
    end
    it "returns true if asked if auditing"
    it "pushes each serialized command onto a stack" do
      example_commands.map do |command|
        subject.serialize_command(command)
      end.reverse.should == subject.audit_stack.to_a
    end
    describe "last command" do
      it "returns the last command array given no arguments" do
        subject.set 'abc', '123'
        subject.last_command.should == ['set', 'abc', '123']
      end
      it "returns the last command array given the argument 1" do
        subject.set 'abc', '123'
        subject.last_command(1).should == ['set', 'abc', '123']
      end
      it "returns an array of last command arrays with the last 3 commands given the argument 3" do
        subject.last_command(3).should == example_commands.reverse[0...3]
      end
      it "returns the entire array of last commands when the argument is greater than the number of commands in the audit" do
        subject.last_command(10).should == example_commands.reverse
      end
    end
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
