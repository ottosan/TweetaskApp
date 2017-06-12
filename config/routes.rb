Rails.application.routes.draw do
	root 'home#index'
	get 'home/index'
	get 'home/new' => 'home#new'
	post 'home/create' => 'home#create'
	get 'home/edit/:id' => 'home#edit'
	patch 'home/update/:id' => 'home#update'
	delete 'home/:id' => 'home#destroy'
	patch 'home/done/:id' => 'home#done'
	# twitter login/logout
	get '/auth/:provider/callback', :to => 'sessions#callback'
	post '/auth/:provider/callback', :to => 'sessions#callback'
	get '/logout' => 'sessions#destroy', :as => :logout
	# twitter bot
	get 'bot' => 'bot#start'
end
