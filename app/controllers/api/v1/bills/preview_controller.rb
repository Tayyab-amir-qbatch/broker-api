module Api
  module V1
    module Bills
      # Real-time commission preview — no DB write, just calculation.
      # Called by mobile app as user types in the deal form.
      class PreviewController < BaseController
        # POST /api/v1/bills/preview
        # Body: { bags:, rate:, commission_type:, commission_value: }
        def create
          result = CommissionCalculator.preview(
            bags:             params.require(:bags),
            rate:             params.require(:rate),
            commission_type:  params.require(:commission_type),
            commission_value: params.require(:commission_value)
          )

          render json: result, status: :ok
        rescue ArgumentError => e
          render json: { error: e.message }, status: :bad_request
        end
      end
    end
  end
end
