# Run Capybara Spec on Dummy app PostsController

require 'dummy_spec_helper'

feature 'show list of items' do
  let(:names) { ['Item 1', 'Item 2'] }
  let(:name)  { names.first }


  before :each do
    names.each{|n| Item.new n }

    visit items_path
  end

  context '2 items' do
    scenario 'display item 1 and 2' do
      page.should have_content names.first
      page.should have_content names.last
    end
  end
end

feature 'show item' do
  let(:name)  { 'Item 1' }

  before do
    Item.new name
  end

  scenario 'display one item' do
    visit item_path(1)

    page.should have_content "A very nice #{name}"
  end
end
