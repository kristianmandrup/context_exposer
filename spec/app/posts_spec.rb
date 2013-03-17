# Run Capybara Spec on Dummy app PostsController

require 'dummy_spec_helper'

feature 'show list of posts' do
  before do
    Post.new 'Post 1'
    Post.new 'Post 2'
  end

  scenario '2 posts' do
    visit posts_path

    page.should have_content 'Post 1'
    page.should have_content 'Post 2'
  end
end

feature 'show post' do
  before do
    Post.new 'Post 1'
  end

  scenario 'one post' do
    visit post_path(1)

    page.should have_content 'Post 1'
  end
end