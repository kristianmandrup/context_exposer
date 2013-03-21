# Run Capybara Spec on Dummy app PostsController

require 'dummy_spec_helper'

feature 'show list of animals' do
  let(:names) { ['Cow', 'Sheep'] }
  let(:name)  { names.first }


  before :each do
    names.each{|n| Animal.new n }

    visit animals_path
  end

  context '2 items' do
    scenario 'display animal 1 and 2' do
      page.should have_content names.first
      page.should have_content names.last
    end
  end
end

feature 'show animal' do
  let(:name)  { 'Cow' }

  before do
    Animal.new name
  end

  scenario 'display one item' do
    visit animal_path(1)

    page.should have_content "A very fancy #{name}"
  end
end
