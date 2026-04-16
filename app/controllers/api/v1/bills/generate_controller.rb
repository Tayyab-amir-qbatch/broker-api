module Api
  module V1
    module Bills
      class GenerateController < BaseController
        # POST /api/v1/bills/generate
        # Body: { client_id:, from_date:, to_date: }
        def create
          bill = BillGenerator.new(
            client_id: params.require(:client_id),
            from_date: params.require(:from_date),
            to_date:   params.require(:to_date)
          ).generate

          render json: bill, status: :ok
        end
      end
    end
  end
end
