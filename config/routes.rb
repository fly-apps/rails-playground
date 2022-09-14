Rails.application.routes.draw do
  resources :sandwiches

  sitepress_pages
  sitepress_root
end
