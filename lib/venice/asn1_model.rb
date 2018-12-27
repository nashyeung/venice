module Venice
  class ASN1Model
    class Segment
      attr_reader :type, :version, :value

      def initialize(seq)
        @type    = seq.value[0].value.to_i
        @version = seq.value[1].value.to_i
        @value   = OpenSSL::ASN1.decode(seq.value[2].value)
      end
    end

    def initialize(asn_set)
      asn_set = OpenSSL::ASN1.decode(asn_set) if asn_set.is_a?(String)
      asn_set.each do |element|
        # Some segments have Apple "Private" binary data in them.
        # If this is the case then we don't care about it, move on to the next one.
        segment = Segment.new(element) rescue next
        handle_segment(segment)
      end
    end

    def native_value(segment)
      asn1_obj = segment.value

      case asn1_obj
      when OpenSSL::ASN1::Integer
        asn1_obj.value.to_i
      else
        asn1_obj.value.to_s
      end
    end

    def handle_segment(segment)
      method_name = attribute_name_for_type_id(segment.type)
      return unless method_name

      define_singleton_method(method_name) { native_value(segment) }
    end
  end
end
