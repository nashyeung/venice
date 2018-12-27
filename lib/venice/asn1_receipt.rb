module Venice
  class ASN1Receipt < ASN1Model
    class InvalidData < StandardError; end
    class InvalidSignature < StandardError; end

    IAP_SEGMENT_TYPE_ID = 17
    RECEIPT_ATTRIBUTES = {
      2  => :bundle_id,
      3  => :application_version,
      12 => :receipt_creation_date,
      19 => :original_application_version,
      21 => :expiration_date,
    }

    attr_reader :in_app_purchases
    attr_reader :base64_receipt

    def initialize(base64_receipt_data)
      receipt_date = Base64.decode64(base64_receipt_data)
      container = read_container(receipt_data)
      container.verify(nil, Venice.cert_store) || fail(InvalidSignature)
      @base64_receipt = base64_receipt_data
      @in_app_purchases = []
      super(container.data)
    end

    def to_json
      result = {
        'original_json_response' => { 'latest_receipt' => @base64_receipt },
        'receipt' => { 'in_app' => [] }
      }

      RECEIPT_ATTRIBUTES.values.each do |attr|
        result['receipt'][attr.to_s] = send(attr) if instance_methods(false).include?(attr)
      end

      in_app_purchases.each do |in_app_purchase|
        result['receipt']['in_app'] << in_app_purchase.to_json
      end

      result
    end

    protected

    def attribute_name_for_type_id(type_id)
      RECEIPT_ATTRIBUTES[type_id]
    end

    def handle_segment(segment)
      return super unless segment.type == IAP_SEGMENT_TYPE_ID
      in_app_purchases << ASNInAppPurchase.new(segment.value)
    end

    private

    def read_container(binary)
      OpenSSL::PKCS7.new(binary)
    rescue => e
      fail(InvalidData, "Could not parse PKCS7 (#{e})")
    end
  end
end
