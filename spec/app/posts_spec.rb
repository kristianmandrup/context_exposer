# Run Capybara Spec on Dummy app PostsController

require 'dummy_spec_helper'

describe 'Dummy app' do
  describe 'PostsController' do
    describe 'index' do
      it 'shows posts' do
        visit posts_path

        page.should have_content 'Post 1'
        page.should have_content 'Post 2'
      end
    end

    describe 'show' do
      it 'shows first post' do
        visit posts_path

        page.should have_content 'Post 1'
        page.should_not have_content 'Post 2'
      end
    end
  end
end