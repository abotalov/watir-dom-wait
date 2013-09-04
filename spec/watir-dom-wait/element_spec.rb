require 'spec_helper'

describe Watir::Element do
  describe "#when_dom_changed" do
    context "when DOM is changed" do
      context "when block is not given" do
        it "waits using event handler" do
          @browser.button(:id => "quick").click
          @browser.div.when_dom_changed.should have(20).spans
        end

        it "may be run more than one time" do
          3.times do |i|
            @browser.button(:id => "quick").click
            @browser.div.when_dom_changed.should have(20 * (i + 1)).spans
          end
        end

        it "waits using custom interval" do
          @browser.button(:id => "long").click
          @browser.div.when_dom_changed(:interval => 1.1).should have(5).spans
        end

        it "raises timeout error" do
          @browser.button(:id => "quick").click
          lambda { @browser.div.when_dom_changed(:timeout => 2).spans }.should raise_error(Watir::Wait::TimeoutError)
        end
      end

      context "when block given" do
        it "waits using event handler" do
          @browser.button(:id => "quick").click
          @browser.div.when_dom_changed do |div|
            div.should have(20).spans
          end
        end

        it "waits using custom interval" do
          @browser.button(:id => "long").click
          @browser.div.when_dom_changed(:interval => 1.1) do |div|
            div.should have(5).spans
          end
        end

        it "raises timeout error" do
          @browser.button(:id => "quick").click
          lambda do
            @browser.div.when_dom_changed(:timeout => 2) { |div| div.spans }
          end.should raise_error(Watir::Wait::TimeoutError)
        end

        it "returns block evaluation" do
          @browser.button(:id => "quick").click
          @browser.div.when_dom_changed do |div|
            div.spans.size
          end.should == 20
        end
      end
    end

    context "when DOM is not changed" do
      it "doesn't raise any exception" do
        @browser.div.when_dom_changed.should have(0).spans
      end
    end

    context "when element goes stale" do
      before(:all) do
        Watir.always_locate = false
      end

      after(:all) do
        Watir.always_locate = true
      end

      it "relocates element" do
        div = @browser.div(:id => 'container2')
        div.exists?
        @browser.refresh
        lambda do
          div.when_dom_changed.text
        end.should_not raise_error(Selenium::WebDriver::Error::StaleElementReferenceError)
      end
    end
  end

  describe "#wait_until_dom_changed" do
    it "calls #when_dom_changed" do
      div = @browser.div
      opts = { timeout: 1, interval: 2, delay: 3 }
      div.should_receive(:when_dom_changed).with(opts)
      div.wait_until_dom_changed(opts)
    end

    it "returns nil" do
      @browser.div.wait_until_dom_changed.should == nil
    end
  end
end