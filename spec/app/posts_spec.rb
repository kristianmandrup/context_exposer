# Run Capybara Spec on Dummy app PostsController

require 'dummy_spec_helper'

feature 'show posts' do
  scenario '2 posts' do
    visit posts_path

    page.should have_content 'Post 1'
    page.should have_content 'Post 2'
  end
end

feature 'show' do
  scenario 'shows first post' do
    visit posts_path

    page.should have_content 'Post 1'
  end
end