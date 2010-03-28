require 'spec_helper'

describe Redis, "Rollbacks" do
  context "single commands" do
    context "with effect" do
      before(:each) do
        subject.delete 'key'
      end
      it "deletes a key created by the SET command" do
        subject.set 'key', 'abc'
        subject.rollback_last 
        subject.get('key').should be_nil
      end
      it "restores the previous value of a key updated by SET command" do
        subject.set 'key', 'abc'
        subject.set 'key', 'def'
        subject.rollback_last
        subject.get('key').should == 'abc'
      end
      it "restores the previous string value of a key destroyed by DELETE command" do
        subject.set 'key', 'abc'
        subject.delete 'key'
        subject.rollback_last
        subject.get('key').should == 'abc'
      end
      it "restores previous list members of key destroyed by DELETE command" do
        subject.lpush 'key', 1
        subject.lpush 'key', 2
        subject.delete 'key'
        subject.rollback_last
        subject.lrange('key', 0, -1).should == %w[2 1] 
      end
      pending "takes a pushed member off a list operated on by LPUSH" do

      end
      it "takes a pushed member off a list operated on by RPUSH"
      it "pushes a popped member off a list operated on by LPOP"
      it "pushes a popped member off a list operated on by RPOP"
      context "in audit" do
        
      end
    end
  end

end
