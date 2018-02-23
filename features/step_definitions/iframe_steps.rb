# frozen_string_literal: true

Then(/^I can locate the iframe by id$/) do
  @test_site.home.wait_for(:my_iframe)

  expect(@test_site.home.has?(:my_iframe)).to be true
end

Then(/^I can locate the iframe by index$/) do
  @test_site.home.wait_for(:index_iframe)

  expect(@test_site.home.has?(:index_iframe)).to be true
end

Then(/^I can see elements in an iframe$/) do
  @test_site.home.my_iframe do |f|
    expect(f.some_text.text).to eq('Some text in an iframe')
  end
end

Then(/^I can see elements in an iframe with capybara query options$/) do
  @test_site.home.my_iframe do |f|
    expect(f.has?(:some_text, text: 'Some text in an iframe')).to be true
  end
end
