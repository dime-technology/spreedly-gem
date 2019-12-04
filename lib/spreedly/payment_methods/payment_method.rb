# frozen_string_literal: true

require 'time'

module Spreedly
  class PaymentMethod < Model
    include ErrorsParser

    field :email, :storage_state, :data, :payment_method_type
    attr_reader :errors

    def initialize(xml_doc)
      super
      @errors = errors_from(xml_doc)
    end

    def self.new_from(xml_doc)
      case xml_doc.at_xpath('.//payment_method_type').inner_text
      when 'credit_card'
        CreditCard.new(xml_doc)
      when 'paypal'
        Paypal.new(xml_doc)
      when 'sprel'
        Sprel.new(xml_doc)
      when 'bank_account'
        Spreedly::BankAccount.new(xml_doc)
      when 'third_party_token'
        ThirdPartyToken.new(xml_doc)
      end
    end

    def self.new_list_from(xml_doc)
      payment_methods = xml_doc.xpath('.//payment_methods/payment_method')
      payment_methods.map do |each|
        new_from(each)
      end
    end

    def valid?
      @errors.empty?
    end
  end
end
