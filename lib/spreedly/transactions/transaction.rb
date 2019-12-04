# frozen_string_literal: true

module Spreedly
  class Transaction < Model
    field :state, :message
    field :succeeded, type: :boolean

    def self.new_from(xml_doc)
      case xml_doc.at_xpath('.//transaction_type').inner_text
      when 'AddPaymentMethod'
        Spreedly::AddPaymentMethod.new(xml_doc)
      when 'Purchase'
        Purchase.new(xml_doc)
      when 'OffsitePurchase'
        OffsitePurchase.new(xml_doc)
      when 'Authorization'
        Authorization.new(xml_doc)
      when 'Capture'
        Capture.new(xml_doc)
      when 'Credit'
        Refund.new(xml_doc)
      when 'Void'
        Void.new(xml_doc)
      when 'Verification'
        Verification.new(xml_doc)
      when 'RetainPaymentMethod'
        RetainPaymentMethod.new(xml_doc)
      when 'RedactPaymentMethod'
        RedactPaymentMethod.new(xml_doc)
      when 'RedactGateway'
        RedactGateway.new(xml_doc)
      when 'RecacheSensitiveData'
        RecacheSensitiveData.new(xml_doc)
      when 'DeliverPaymentMethod'
        DeliverPaymentMethod.new(xml_doc)
      when 'Store'
        Store.new(xml_doc)
      else
        Transaction.new(xml_doc)
      end
    end

    def self.new_list_from(xml_doc)
      transactions = xml_doc.xpath('.//transactions/transaction')
      transactions.map do |each|
        new_from(each)
      end
    end
  end
end
