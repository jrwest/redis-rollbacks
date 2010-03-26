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
        subject.serialize_command(['set', 'mykey', 'myvalue']).should == 'set mykey myvalue'
        subject.serialize_command(['set', 'anotherkey', 'anothervalue']).should == 'set anotherkey anothervalue'
        subject.serialize_command(['lpush', 'alist', 1]).should == 'lpush alist 1'
      end
    end
  end
  describe "last command" do
    let (:example_commands) do 
      [
       ['set', 'abc', 'aval'],
       ['get', 'abc'],
       ['lpush', 'def', 'aval'],
       ['lrange', 'def', '0', '-1']
      ]
    end
    it "returns the last command array" do
      example_commands.each do |command|
        subject.call_command command
        subject.last_command.should == command
      end
    end
  end
  describe "last command effect" do
    it "is :none if GET command access a key" do
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
