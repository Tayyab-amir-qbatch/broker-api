class CommissionCalculator
  # Standard yarn bag weight in KG
  BAG_WEIGHT_KG = 100

  # Returns commission bill amount as BigDecimal, rounded to 2 decimal places.
  #
  # Percentage:   bill = bags * rate_per_kg * bag_weight_kg * (commission_value / 100)
  # Fixed per bag: bill = bags * commission_value
  #
  def self.calculate(bags:, rate:, commission_type:, commission_value:)
    bags  = bags.to_d
    rate  = rate.to_d
    value = commission_value.to_d

    amount = case commission_type.to_s
             when "percentage"
               bags * rate * BAG_WEIGHT_KG * (value / 100)
             when "fixed_per_bag"
               bags * value
             else
               raise ArgumentError, "Unknown commission_type: #{commission_type}"
             end

    amount.round(2)
  end

  # Preview calculation without a Deal instance — used by the API for real-time UI updates
  def self.preview(bags:, rate:, commission_type:, commission_value:)
    {
      bill_amount:      calculate(bags: bags, rate: rate, commission_type: commission_type, commission_value: commission_value),
      total_sale_value: (bags.to_d * rate.to_d * BAG_WEIGHT_KG).round(2),
      commission_type:  commission_type,
      commission_value: commission_value
    }
  end
end
