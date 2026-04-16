module Api
  module V1
    class DealsController < BaseController
      before_action :set_deal, only: %i[show update destroy mark_paid]

      # GET /api/v1/deals?client_id=1&from=2024-08-01&to=2025-07-31
      def index
        deals = Deal.recent.includes(:client, :seller, :buyer)
        deals = deals.by_client(params[:client_id]) if params[:client_id].present?
        deals = deals.by_seller(params[:seller_id]) if params[:seller_id].present?
        deals = deals.by_status(params[:status]) if params[:status].present?
        deals = deals.in_period(params[:from], params[:to]) if params[:from] && params[:to]
        paged_deals = paginate(deals)

        render json: DealBlueprint.render(
          paged_deals,
          root: :data,
          meta: pagination_meta(paged_deals)
        )
      end

      # GET /api/v1/deals/:id
      def show
        render json: DealBlueprint.render(@deal, view: :extended)
      end

      # POST /api/v1/deals
      def create
        deal = Deal.create!(deal_params)
        render json: DealBlueprint.render(deal, view: :extended), status: :created
      end

      # PATCH /api/v1/deals/:id
      def update
        @deal.update!(deal_params)
        render json: DealBlueprint.render(@deal, view: :extended)
      end

      # DELETE /api/v1/deals/:id
      def destroy
        @deal.destroy!
        head :no_content
      end

      # PATCH /api/v1/deals/:id/mark_paid
      def mark_paid
        @deal.update!(status: :paid)
        render json: DealBlueprint.render(@deal, view: :extended)
      end

      private

      def set_deal
        @deal = Deal.includes(:client, :seller, :buyer).find(params[:id])
      end

      def deal_params
        params.require(:deal).permit(
          :deal_date, :client_id, :seller_id, :buyer_id,
          :quality, :bags, :rate,
          :commission_type, :commission_value,
          :notes, :status
        )
      end

      def pagination_meta(scope)
        {
          current_page: scope.current_page,
          total_pages:  scope.total_pages,
          total_count:  scope.total_count
        }
      end
    end
  end
end
