module Venice
  InvalidData = Class.new(StandardError)
  InvalidSignature = Class.new(StandardError)

  class << self
    def read_container(binary)
      OpenSSL::PKCS7.new(binary)
    rescue => e
      fail InvalidData, "Could not parse PKCS7 (#{e})"
    end

    def cert_store
      @cert_store ||= OpenSSL::X509::Store.new.tap do |s|
        root_certs.each { |c| s.add_cert(c) }
      end
    end

    private

    def root_certs
      @root_certs ||= ['apple_inc_root.pem'].map { |filename| read_cert(filename) }
    end

    def read_cert(filename)
      cert_data = File.read(resource_path(filename))
      OpenSSL::X509::Certificate.new(cert_data)
    end

    def resource_path(filename)
      File.join(gem_root, 'resources', filename)
    end

    def gem_root
      File.expand_path('..', File.dirname(__FILE__))
    end
  end
end

require 'venice/version'
require 'venice/client'
require 'venice/in_app_receipt'
require 'venice/receipt'
require 'venice/pending_renewal_info'
require 'venice/asn_model'
require 'venice/asn_in_app_purchase'
require 'venice/asn_receipt'
