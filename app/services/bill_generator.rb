class BillGenerator
  attr_reader :client, :from_date, :to_date

  def initialize(client_id:, from_date:, to_date:)
    @client    = Party.find(client_id)
    @from_date = from_date.to_date
    @to_date   = to_date.to_date
  end

  def generate
    deals = client.client_deals
                  .in_period(from_date, to_date)
                  .recent
                  .includes(:seller, :buyer)

    {
      client:      { id: client.id, name: client.name, phone: client.phone },
      from_date:   from_date,
      to_date:     to_date,
      deals:       serialize_deals(deals),
      total_bags:  deals.sum(:bags),
      total_bill:  deals.sum(:bill_amount).to_f.round(2),
      deal_count:  deals.count
    }
  end

  private

  def serialize_deals(deals)
    deals.map do |deal|
      {
        id:               deal.id,
        deal_date:        deal.deal_date,
        seller:           deal.seller.name,
        buyer:            deal.buyer&.name,
        quality:          deal.quality,
        bags:             deal.bags,
        rate:             deal.rate.to_f,
        commission_type:  deal.commission_type,
        commission_value: deal.commission_value.to_f,
        bill_amount:      deal.bill_amount.to_f
      }
    end
  end
end
