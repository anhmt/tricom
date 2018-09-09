require 'rails_helper'

RSpec.describe EkisController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/ekis').to route_to('ekis#index')
    end

    it 'routes to #create' do
      expect(post: '/ekis').to route_to('ekis#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/ekis/1').to route_to('ekis#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/ekis/1').to route_to('ekis#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/ekis/1').to route_to('ekis#destroy', id: '1')
    end
  end
end
