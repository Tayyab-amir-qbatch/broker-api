module Api
  module V1
    class BillsController < BaseController
      # POST /api/v1/bills/generate
      # Body: { client_id:, from_date:, to_date: }
      # Returns full commission bill with all deals for the period
      def generate
        bill = BillGenerator.new(
          client_id: params.require(:client_id),
          from_date: params.require(:from_date),
          to_date:   params.require(:to_date)
        ).generate

        render json: bill, status: :ok
      end

      # POST /api/v1/bills/preview
      # Body: { bags:, rate:, commission_type:, commission_value: }
      # Real-time calculation — no DB write, called as user types in deal form
      def preview
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

      # GET /api/v1/bills/monthly?month=2026-04
      def monthly
        month_date = parse_month(params[:month])
        from_date = month_date.beginning_of_month
        to_date = month_date.end_of_month

        monthly_deals = Deal.includes(:seller).in_period(from_date, to_date)
        sellers = monthly_deals.group_by { |deal| deal.seller.name }

        by_seller = sellers.map do |seller_name, deals|
          paid_deals = deals.select(&:paid?)
          pending_deals = deals.select(&:pending?)

          {
            seller: seller_name,
            seller_id: deals.first.seller_id,
            slip_count: deals.length,
            total_bags: deals.sum(&:bags),
            total_commission: deals.sum { |d| d.bill_amount.to_f },
            paid_commission: paid_deals.sum { |d| d.bill_amount.to_f },
            pending_commission: pending_deals.sum { |d| d.bill_amount.to_f },
            pending_count: pending_deals.length
          }
        end.sort_by { |row| -row[:total_commission] }

        render json: {
          month: month_date.strftime("%Y-%m"),
          total_commission: monthly_deals.sum(:bill_amount).to_f.round(2),
          total_slips: monthly_deals.count,
          total_bags: monthly_deals.sum(:bags),
          paid_commission: monthly_deals.paid.sum(:bill_amount).to_f.round(2),
          pending_commission: monthly_deals.pending.sum(:bill_amount).to_f.round(2),
          by_seller: by_seller
        }, status: :ok
      end

      # POST /api/v1/bills/mark_paid_bulk
      # Body: { month: "2026-04", seller_id: 1(optional) }
      def mark_paid_bulk
        month_date = parse_month(params[:month])
        from_date = month_date.beginning_of_month
        to_date = month_date.end_of_month

        scope = Deal.pending.in_period(from_date, to_date)
        scope = scope.by_seller(params[:seller_id]) if params[:seller_id].present?

        updated_count = scope.update_all(status: Deal.statuses[:paid], updated_at: Time.current)
        render json: { updated_count: updated_count }, status: :ok
      end

      private

      def parse_month(raw_month)
        return Date.current if raw_month.blank?

        Date.strptime(raw_month, "%Y-%m")
      rescue ArgumentError
        raise ActionController::BadRequest, "Invalid month format. Use YYYY-MM."
      end
    end
  end
end
