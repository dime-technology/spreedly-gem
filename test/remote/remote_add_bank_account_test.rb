# frozen_string_literal: true

require 'test_helper'

class RemoteAddBankAccountTest < Test::Unit::TestCase
  def setup
    @environment = Spreedly::Environment.new(remote_test_environment_key, remote_test_access_secret)
  end

  def test_invalid_login
    assert_invalid_login do |environment|
      environment.add_bank_account(account_deets)
    end
  end

  def test_failed_with_validation_errors
    error = assert_raises(Spreedly::TransactionCreationError) do
      @environment.add_bank_account(account_deets(last_name: '', first_name: ''))
    end

    expected_errors = [
      { attribute: 'full_name', key: 'errors.blank', message: "Full name can't be blank" }
    ]

    assert_equal expected_errors, error.errors
    assert_equal "Full name can't be blank", error.message
  end

  def test_payment_required
    assert_raise_with_message(Spreedly::PaymentRequiredError, "Your environment (#{remote_test_environment_key}) has not been activated for real transactions with real payment methods. If you're using a Test Gateway you can *ONLY* use Test payment methods - ( https://docs.spreedly.com/test-data). All other credit card numbers are considered real credit cards; real credit cards are not allowed when using a Test Gateway.") do
      @environment.add_bank_account(account_deets(bank_routing_number: '123'))
    end
  end

  def test_successful_add_bank_account
    t = @environment.add_bank_account(account_deets)

    assert t.succeeded?
    assert_equal 'Stein', t.payment_method.last_name
    assert !t.retained
    assert_equal 'cached', t.payment_method.storage_state
  end

  def test_successfully_retain_on_create
    t = @environment.add_bank_account(account_deets(retained: true))

    assert t.succeeded?
    assert t.retained
    assert_equal 'retained', t.payment_method.storage_state
  end

  private

  def account_deets(options = {})
    {
      bank_routing_number: '021000021', bank_account_number: '9876543210',
      bank_account_type: 'checking', bank_account_holder_type: 'personal',
      last_name: 'Stein', first_name: 'Alessandro'
    }.merge(options)
  end
end
