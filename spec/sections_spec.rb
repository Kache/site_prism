# frozen_string_literal: true

require 'spec_helper'

describe SitePrism::Page do
  it 'should respond to sections' do
    expect(SitePrism::Page).to respond_to :sections
  end

  it 'should be able to check for sections existence' do
    class SomePageWithSectionsThatNeedsTestingForExistence < SitePrism::Section
    end

    class YetAnotherPageWithSections < SitePrism::Page
      # in order to test method name collisions with rspec, we'll include its matchers
      include RSpec::Matchers

      section  :some_things,  SomePageWithSectionsThatNeedsTestingForExistence, '.bob'
      sections :other_things, SomePageWithSectionsThatNeedsTestingForExistence, '.tim'
    end

    page = YetAnotherPageWithSections.new
    expect { page.has?(:some_things) }.not_to raise_error
    expect { page.has?(:other_things) }.not_to raise_error
    # will throw a NoMethodError if methods overwritten by rspec matchers are called
    expect { page.other_things }.not_to raise_error
  end
end
