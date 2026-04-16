module Api
  module V1
    class DashboardController < BaseController
      # GET /api/v1/dashboard
      def index
        pending_scope = Deal.pending

        render json: {
          this_month: {
            deal_count:  Deal.this_month.count,
            total_bags:  Deal.this_month.sum(:bags),
            total_bill:  Deal.this_month.sum(:bill_amount).to_f.round(2)
          },
          pending: {
            deal_count: pending_scope.count,
            total_bill: pending_scope.sum(:bill_amount).to_f.round(2)
          },
          all_time: {
            deal_count:  Deal.count,
            total_bill:  Deal.sum(:bill_amount).to_f.round(2),
            party_count: Party.count
          },
          recent_deals: DealBlueprint.render_as_hash(
            Deal.recent.includes(:client, :seller, :buyer).limit(10)
          )
        }
      end
    end
  end
end
