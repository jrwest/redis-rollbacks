require 'spec_helper'

describe Redis, "Rollbacks" do
  context "single commands" do
    context "with effect" do
      it "deletes a key created by the SET command" do
        subject.delete 'key'
        subject.call_command ['set', 'key', 'abc']
        subject.rollback_last 
        subject.get('key').should be_nil
      end
      it "restores the previous value of a key updated by set" 
    end
  end
end
