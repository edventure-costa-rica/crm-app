ActionController::Routing::Routes.draw do |map|
  map.resources :people, :except => [:new, :create, :destroy]

  map.resources :regions, 
    :only => [ :index, :create, :update, :destroy ] \
  do |region|
    region.resources :companies, :only => :index
  end

  # clients have trips and reservations, sort of
  map.resources :clients do |client|
      client.resources :reservations, :only => [ :show, :index ]

      # trips have reservations, really
      client.resources :trips do |trip|
        trip.resources :reservations, 
          :collection => { :vouchers => :get, :pays => :get },
          :member     => { :voucher  => :get, :pay  => :get }
      end
  end

  # ajax needs the id parameter sent in the query string
  map.ajax_company '/companies/show',
    :controller => 'companies', :action => 'show', :format => 'js'

  # companies also have reservations
  map.resources :companies do |company|
    company.resources :reservations, :only => [ :index ]
  end

  # show trips on their own, plus a list of upcoming trips
  map.resources :trips, :only => [ :show, :index ],
                        :collection => { :upcoming => :get },
                        :member     => { :proposal     => :get,
                                         :confirmation => :get }

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  map.root :controller => :home
end
