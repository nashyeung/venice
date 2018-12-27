module Venice
  class ASN1InAppPurchase < ASN1Model
    IAP_ATTRIBUTES = {
      1701 => :quantity,
      1702 => :product_id,
      1703 => :transaction_id,
      1704 => :purchase_date,
      1705 => :original_transaction_id,
      1706 => :original_purchase_date,
      1708 => :expires_date,
      1711 => :web_order_line_item_id,
      1712 => :cancellation_date,
      1719 => :is_in_intro_offer_period,
    }
    DATE_ATTRIBUTES = [1704, 1706, 1708, 1712]

    def to_json
      result = {}
      IAP_ATTRIBUTES.values.each do |attr|
        result[attr.to_s] = send(attr) if instance_methods(false).include?(attr)
      end
      result
    end

    protected

    def attribute_name_for_type_id(type_id)
      IAP_ATTRIBUTES[type_id]
    end
  end
end
