class DealDiscount < ActiveRecord::Base
  belongs_to :deal

  def self.deal_current_discount(deal_id, no_of_customers)
    query = %Q{ select discount from deal_discounts where deal_id = #{deal_id} and #{no_of_customers} between customers and max_customers }
    dd = find_by_sql(query)[0]
    return (dd.blank?)? "0" : dd.discount
  end

  def self.deal_current_discount_details(deal_id, no_of_customers)
    dds = Deal.find(deal_id).deal_discounts
    dealdis = nil
    for dd in dds
      min_cust = dd.customers
      max_cust = dd.max_customers
      if max_cust.blank? && (no_of_customers.to_i >= min_cust)
        dealdis = dd
        break
      elsif (no_of_customers.to_i >= min_cust) && (no_of_customers.to_i <= max_cust)
        dealdis = dd
        break
      end
    end
    return dealdis
  end

  def self.current_deal_discount_for_deal(deal_id)
    dds = Deal.find(deal_id).deal_discounts
    discount = 0
    no_of_customers = find_by_sql(%Q{ select sum(case when cd.quantity is null then 0 else cd.quantity end) no_of_customers from deals d left outer join customer_deals cd on cd.deal_id = d.id where d.id = #{deal_id}})[0].no_of_customers
    for dd in dds
      min_cust = dd.customers
      max_cust = dd.max_customers
      if max_cust.blank? && (no_of_customers.to_i >= min_cust)
        discount = dd.discount
        buy_value = dd.buy_value
        break
      elsif (no_of_customers.to_i >= min_cust) && (no_of_customers.to_i <= max_cust)
        discount = dd.discount
        buy_value = dd.buy_value
        break
      end
    end
    return discount, buy_value
  end
  
end
