class AntiFraudController < ApplicationController
  def check_transaction
    transaction_data = params[:transaction]

    # Verifique se o usuário tentou muitas transações em sequência
    if too_many_transactions_in_row?(transaction_data[:user_id])
      render json: { transaction_id: transaction_data[:transaction_id], recommendation: "deny" }
      return
    end

    # Verifique se a transação está acima de um determinado valor em um dado período
    if transaction_amount_exceeds_limit?(transaction_data[:user_id], transaction_data[:transaction_amount])
      render json: { transaction_id: transaction_data[:transaction_id], recommendation: "deny" }
      return
    end

    # Verifique se o usuário teve um chargeback anteriormente
    if user_has_chargeback?(transaction_data[:user_id])
      render json: { transaction_id: transaction_data[:transaction_id], recommendation: "deny" }
      return
    end

    render json: { transaction_id: transaction_data[:transaction_id], recommendation: "approve" }
  end

  private

  def too_many_transactions_in_row?(user_id)
    transactions = Transaction.where(user_id: user_id).order(created_at: :desc).limit(3)
    transactions.count >= 3 && transactions.first.transaction_date - transactions.last.transaction_date <= 1.hour
  end

  def transaction_amount_exceeds_limit?(user_id, amount)
    recent_transactions = Transaction.where(user_id: user_id, transaction_date: 1.day.ago..Time.now)
    total_amount = recent_transactions.sum(:transaction_amount)
    total_amount + amount.to_d > 1000 # Limite hipotético
  end

  def user_has_chargeback?(user_id)
    Transaction.where(user_id: user_id, has_cbk: true).exists?
  end
end
