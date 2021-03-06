require 'rails_helper'

RSpec.describe 'Shainmasters', type: :request do
  describe 'GET /shainmasters' do
    before do
      user = FactoryBot.create :user, password: 'abc123', admin: true
      post login_path, params: { session: { 担当者コード: user.id, password: 'abc123' } }
    end
    it 'index' do
      get shainmasters_path
      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
    it 'index with json type' do
      get shainmasters_path, headers: { 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('application/json')
      expect(response).to render_template(:index)
    end
  end
end
