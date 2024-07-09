class AntiFraudController < ApplicationController
  def check_transaction
    transaction_data = params[:transaction]

    # Verifica se o usuário tentou muitas transações em sequência
    if too_many_transactions_in_sequence?(transaction_data[:user_id])
      render_response(transaction_data[:transaction_id], "deny")
    # Verifica se a transação está acima de um determinado valor em um dado período
    elsif transaction_amount_exceeds_limit?(transaction_data[:user_id], transaction_data[:transaction_amount])
      render_response(transaction_data[:transaction_id], "deny")
    # Verifica se o usuário teve um chargeback anteriormente
    elsif user_has_chargeback?(transaction_data[:user_id])
      render_response(transaction_data[:transaction_id], "deny")
    else
      render_response(transaction_data[:transaction_id], "approve")
    end
  end

  private

  def too_many_transactions_in_sequence?(user_id)
    transactions = Transaction.where(user_id: user_id).order(created_at: :desc).limit(3)
    transactions.count >= 3 && transactions.first.transaction_date - transactions.last.transaction_date <= 1.hour
  end


  def transaction_amount_exceeds_limit?(user_id, amount)
    recent_transactions = Transaction.where(user_id: user_id, transaction_date: 1.day.ago..Time.now)
    total_amount = recent_transactions.sum(:transaction_amount)
    total_amount + amount.to_d > 1000
  end

  def user_has_chargeback?(user_id)
    Transaction.exists?(user_id: user_id, has_cbk: true)
  end

  def render_response(transaction_id, recommendation)
    render json: { transaction_id: transaction_id, recommendation: recommendation }
  end
end
