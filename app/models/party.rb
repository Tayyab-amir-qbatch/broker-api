class Party < ApplicationRecord
  ROLES = %w[client seller buyer].freeze

  # Associations
  has_many :client_deals,  class_name: "Deal", foreign_key: :seller_id,  dependent: :restrict_with_error
  # has_many :seller_deals,  class_name: "Deal", foreign_key: :seller_id,  dependent: :restrict_with_error
  has_many :buyer_deals,   class_name: "Deal", foreign_key: :buyer_id,   dependent: :nullify

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :roles, presence: true
  validate  :roles_must_be_valid

  # Scopes — filter by role using PostgreSQL array operator
  scope :clients,  -> { where("'client' = ANY(roles)") }
  scope :sellers,  -> { where("'seller' = ANY(roles)") }
  scope :buyers,   -> { where("'buyer' = ANY(roles)") }
  scope :by_name,  -> { order(:name) }

  def client?  = roles.include?("client")
  def seller?  = roles.include?("seller")
  def buyer?   = roles.include?("buyer")

  private

  def roles_must_be_valid
    invalid = roles - ROLES
    errors.add(:roles, "contains invalid values: #{invalid.join(', ')}") if invalid.any?
  end
end
