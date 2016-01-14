ActionController::Routing::Routes.draw do |map|
  map.resources :regions, only: [:index, :create, :update, :destroy] do |region|
    region.resources :companies, :only => :index
  end

  map.resources :clients,
                member: {remove: :get},
                collection: %i(search export) do |client|
    client.resources :trips, only: %i(index new create)
  end

  map.resources :companies, collection: [:export] do |company|
    company.resources :reservations, only: :index
  end

  map.resources :trips,
                except: %i(new create edit show),
                collection: %i(upcoming) do |trip|
    trip.resource :reservations, only: :create,
                  collection: %i(pending confirmed vouchers export)
  end

  map.resources :reservations,
                except: [:new, :create, :show, :edit],
                collection: %i(unconfirmed unpaid),
                member: {email: :get, confirm: :post, voucher: :get}

  map.resources :calendar, only: [],
                collection: %i(day week month)

  map.home 'home', controller: :home, action: :index

  map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.root :controller => :home, action: :redirect
end
