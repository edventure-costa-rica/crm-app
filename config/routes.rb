ActionController::Routing::Routes.draw do |map|
  map.resources :regions, only: [:index, :create, :update, :destroy] do |region|
    region.resources :companies, :only => :index
  end

  map.resources :clients,
                member: {remove: :get},
                collection: {search: :get} do |client|
    client.resources :trips, only: :index
  end

  map.resources :companies do |company|
    company.resources :reservations, only: :index
  end

  map.resources :trips,
                collection: {upcoming: :get},
                member: {pending: :get, confirmed: :get} do |trip|
    trip.resource :reservations, only: [:index, :create]
  end

  map.resources :reservations,
                except: [:new, :create, :show, :edit],
                collection: %i(pending unpaid paid),
                member: {email: :get, confirm: :post}

  map.resources :calendar, only: [],
                collection: %i(day week month year)

  map.home 'home', controller: :home, action: :index

  map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.root :controller => :home, action: :redirect
end
