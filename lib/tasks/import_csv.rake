namespace :import_csv do
  desc "Import transaction data from CSV"
  task transactions: :environment do
    require 'smarter_csv'

    file_path = '/Users/thiagomagalhaes/Documents/Projetos/Cloudwalk/transactional-sample.csv'
    options = { key_mapping: { transaction_id: :transaction_id, merchant_id: :merchant_id, user_id: :user_id, card_number: :card_number, transaction_date: :transaction_date, transaction_amount: :transaction_amount, device_id: :device_id, has_cbk: :has_cbk } }

    SmarterCSV.process(file_path, options) do |chunk|
      chunk.each do |data|
        Transaction.create(data)
      end
    end
  end
end
