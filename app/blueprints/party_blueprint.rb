class PartyBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :phone, :address, :roles, :created_at, :updated_at

  view :with_stats do
    field :total_commission do |party|
      party.client_deals.sum(:bill_amount).to_f.round(2)
    end

    field :deal_count do |party|
      party.client_deals.count
    end
  end
end
