# frozen_string_literal: true

require 'spec_helper'

describe SitePrism::Page do
  it 'should respond to element' do
    expect(SitePrism::Page).to respond_to :element
  end

  it 'should be able to check for element existence' do
    class PageWithElement < SitePrism::Page
      element :bob, 'a.b c.d'
    end
    page = PageWithElement.new
    expect { page.has?(:bob) }.not_to raise_error
  end

  it 'element method should generate method to return the element' do
    class PageWithElement < SitePrism::Page
      element :bob, 'a.b c.d'
    end
    page = PageWithElement.new
    expect(page).to respond_to :bob
  end

  it 'should be able to check for css element nonexistence' do
    class PageWithElement < SitePrism::Page
      element :thing, 'input#nonexistent'
    end
    page = PageWithElement.new
    expect { page.no?(:thing) }.not_to raise_error
  end

  it 'should be able to wait for an element' do
    class PageWithElement < SitePrism::Page
      element :some_slow_element, 'a.slow'
    end
    page = PageWithElement.new
    expect { page.wait_for(:some_slow_element) }.not_to raise_error
  end

  it 'should know if all mapped elements are on the page' do
    class PageWithAFewElements < SitePrism::Page
      element :bob, 'a.b c.d'
    end
    page = PageWithAFewElements.new
    expect(page).to respond_to :all_there?
  end

  it 'should be able to check for xpath element nonexistence' do
    class PageWithElement < SitePrism::Page
      element :bob, :xpath, '//a[@class="b"]//c[@class="d"]'
    end
    page = PageWithElement.new
    expect { page.has?(:bob) }.not_to raise_error
  end

  it 'element method with xpath should generate method to return the element' do
    class PageWithElement < SitePrism::Page
      element :bob, :xpath, '//a[@class="b"]//c[@class="d"]'
    end
    page = PageWithElement.new
    expect(page).to respond_to :bob
  end

  it 'should be able to wait for an element defined with xpath selector' do
    class PageWithElement < SitePrism::Page
      element :some_slow_element, :xpath, '//a[@class="slow"]'
    end
    page = PageWithElement.new
    expect { page.wait_for(:some_slow_element) }.not_to raise_error
  end

  it 'should know if all mapped elements defined by xpath selector are on the page' do
    class PageWithAFewElements < SitePrism::Page
      element :bob, :xpath, '//a[@class="b"]//c[@class="d"]'
    end
    page = PageWithAFewElements.new
    expect(page).to respond_to :all_there?
  end
end
