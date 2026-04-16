class DealBlueprint < Blueprinter::Base
  identifier :id

  fields :deal_date, :quality, :bags, :commission_type, :notes, :created_at, :status

  field :rate         do |deal| deal.rate.to_f          end
  field :commission_value do |deal| deal.commission_value.to_f end
  field :bill_amount  do |deal| deal.bill_amount.to_f    end

  # Nested party references (default view — just id + name)
  association :client, blueprint: PartyBlueprint
  association :seller, blueprint: PartyBlueprint

  # Extended view includes buyer and full party details
  view :extended do
    association :buyer, blueprint: PartyBlueprint
  end
end
