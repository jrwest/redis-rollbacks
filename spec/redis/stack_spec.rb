require 'spec_helper'

describe Redis::Stack do
  before(:each) do
    @db = Redis.new
  end
  after(:each) do
    @db.delete 'my_stack'
  end
  subject { Redis::Stack.new(:db => Redis.new, :key => 'my_stack') }
  describe "#push" do
    it "adds a member to the top of the stack" do
      subject.push('some_str')
      @db.lrange('my_stack', 0, 0).should == ['some_str']
      subject.push('another_str')
      @db.lrange('my_stack', 0, 0).should == ['another_str']
    end
    it "pushes each member to the top of the stack in order given" do
      vals = %w[some_str another_str yet_another_str]
      subject.push(*vals)
      @db.lrange('my_stack', 0, -1).should == vals.reverse
    end 
  end
  context "with elements on the stack" do
    before(:each) do
      subject.push 1, 2, 3 
    end
    describe "#pop" do
      it "returns the last element pushed to the stack" do
        subject.pop.should == '3'
      end
      it "takes the top element off the stack" do
        subject.pop
        @db.lrange('my_stack', 0, -1).should == %w[2 1]
      end
    end
    describe "#peek" do
      it "returns the last element pushed to the stack" do
        subject.peek.should == '3'
      end
      it "does not take the top element off the stack" do
        subject.peek
        @db.lrange('my_stack', 0, -1).should == %w[3 2 1]
      end
    end
    describe "#size" do
      it "returns the number of elements in the stack" do
        subject.size.should == 3
      end
    end
  end
  describe "#empty?" do
    it "returns true if has no members" do
      subject.should be_empty
    end
    it "returns false if has members" do
      subject.push '1'
      subject.should_not be_empty
    end
  end
end
