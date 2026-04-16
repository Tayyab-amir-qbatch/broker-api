module Api
  module V1
    class PartiesController < BaseController
      before_action :set_party, only: %i[show update destroy deals]

      # GET /api/v1/parties?role=client
      def index
        parties = Party.by_name
        parties = parties.where("? = ANY(roles)", params[:role]) if params[:role].present?
        paged_parties = paginate(parties)

        render json: PartyBlueprint.render(
          paged_parties,
          root: :data,
          meta: pagination_meta(paged_parties)
        )
      end

      # GET /api/v1/parties/:id
      def show
        render json: PartyBlueprint.render(@party)
      end

      # POST /api/v1/parties
      def create
        party = Party.create!(party_params)
        render json: PartyBlueprint.render(party), status: :created
      end

      # PATCH /api/v1/parties/:id
      def update
        @party.update!(party_params)
        render json: PartyBlueprint.render(@party)
      end

      # DELETE /api/v1/parties/:id
      def destroy
        @party.destroy!
        head :no_content
      end

      # GET /api/v1/parties/:id/deals?from=2024-08-01&to=2025-07-31
      def deals
        deals = @party.client_deals.recent.includes(:seller, :buyer)
        deals = deals.in_period(params[:from], params[:to]) if params[:from] && params[:to]
        paged_deals = paginate(deals)

        render json: DealBlueprint.render(
          paged_deals,
          root: :data,
          meta: pagination_meta(paged_deals)
        )
      end

      private

      def set_party
        @party = Party.find(params[:id])
      end

      def party_params
        params.require(:party).permit(:name, :phone, :address, roles: [])
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
