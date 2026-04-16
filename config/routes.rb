Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Parties — clients, sellers, buyers
      resources :parties, only: %i[index show create update destroy] do
        get :deals, on: :member   # GET /api/v1/parties/:id/deals
      end

      # Deals — core transactions
      resources :deals, only: %i[index show create update destroy] do
        patch :mark_paid, on: :member # PATCH /api/v1/deals/:id/mark_paid
      end

      # Bills — generate commission bill for a client + period
      post "bills/generate", to: "bills#generate"   # POST /api/v1/bills/generate
      post "bills/preview",  to: "bills#preview"    # POST /api/v1/bills/preview (real-time calc)
      get "bills/monthly",   to: "bills#monthly"    # GET /api/v1/bills/monthly?month=YYYY-MM
      post "bills/mark_paid_bulk", to: "bills#mark_paid_bulk" # POST /api/v1/bills/mark_paid_bulk

      # Dashboard summary stats
      get :dashboard, to: "dashboard#index"
    end
  end
end
