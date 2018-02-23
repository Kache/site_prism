# frozen_string_literal: true

require 'spec_helper'

describe SitePrism::Page do
  it 'should respond to elements' do
    expect(SitePrism::Page).to respond_to :elements
  end

  it 'should be able to check for elements existence' do
    class PageWithElements < SitePrism::Page
      elements :bobs, 'a.b c.d'
    end
    page = PageWithElements.new
    expect { page.has?(:bobs) }.not_to raise_error
  end

  it 'elements method should generate method to return the elements' do
    class PageWithElements < SitePrism::Page
      elements :bobs, 'a.b c.d'
    end
    page = PageWithElements.new
    expect(page).to respond_to :bobs
  end
end
