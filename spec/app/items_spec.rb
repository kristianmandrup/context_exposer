# Run Capybara Spec on Dummy app PostsController

require 'dummy_spec_helper'

feature 'show list of items' do
  before do
    Item.new 'Item 1'
    Item.new 'Item 2'
  end

  scenario '2 items' do
    visit items_path

    page.should have_content 'Item 1'
    page.should have_content 'Item 2'
  end
end

feature 'show item' do
  before do
    Item.new 'Item 1'
  end

  scenario 'one item' do
    visit item_path(1)

    page.should have_content 'Item 1'
  end
end