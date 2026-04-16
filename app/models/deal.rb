class Deal < ApplicationRecord
  BAG_WEIGHT_KG = 100

  enum commission_type: { percentage: 0, fixed_per_bag: 1 }
  enum status: { pending: 0, paid: 1 }

  # Associations
  belongs_to :client, class_name: "Party"
  belongs_to :seller, class_name: "Party"
  belongs_to :buyer,  class_name: "Party", optional: true

  # Validations
  validates :deal_date, :quality, :bags, :rate, :commission_type, :commission_value, presence: true
  validates :status, presence: true
  validates :bags, numericality: { greater_than: 0, only_integer: true }
  validates :rate, :commission_value, numericality: { greater_than: 0 }
  validates :commission_value, numericality: {
    less_than_or_equal_to: 100, message: "cannot exceed 100%"
  }, if: :percentage?

  # Auto-calculate bill_amount before every save
  before_validation :calculate_bill_amount

  # Scopes
  scope :by_client,   ->(client_id) { where(client_id: client_id) }
  scope :in_period,   ->(from, to)  { where(deal_date: from..to) }
  scope :recent,      -> { order(deal_date: :desc) }
  scope :this_month,  -> { where(deal_date: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :by_seller,   ->(seller_id) { where(seller_id: seller_id) }
  scope :by_status,   ->(status) { where(status: statuses[status]) if statuses.key?(status) }

  private

  def calculate_bill_amount
    return unless bags.present? && rate.present? && commission_value.present?

    self.bill_amount = CommissionCalculator.calculate(
      bags: bags,
      rate: rate,
      commission_type: commission_type,
      commission_value: commission_value
    )
  end
end
