# Software Engineer Test - Cloudwalk

## API

CloudWalk anti-fraud system API.

## Technologies Used

- Ruby 2.7.1
- Rails 6.0.6
- PostgreSQL
- Smarter CSV

## Creating the Database and Running Migrations:

```
rails db:drop db:create db:migrate
```

## Load the Data from the Provided CSV File to Populate the Development Database:

```
rake import_csv:transactions
```

## Starting the API Project:

```
rails s
```

## API Endpoint Documentation:
[Postman Documentation](https://documenter.getpostman.com/view/4148278/2sA3e2hA3G)

## 3. Tasks

## 3.1 - Understand the Industry

### 1. Explain the money flow and the information flow in the acquirer market and the role of the main players.

The acquirer market consists of various players who perform specific roles in processing payments. The main players are: the merchant, the acquirer, the card network, the card issuer, and the consumer. Let's detail the money and information flows among these players:

#### Information Flow:

1. The **consumer** makes a purchase using a credit or debit card.
2. The **merchant** sends the transaction details to their **acquirer** (the company that processes payments on behalf of the merchant).
3. The **acquirer** forwards the transaction to the **card network** (Visa, Mastercard, etc.).
4. The **card network** sends the transaction to the **card issuer** (the bank or financial institution that issued the card).
5. The **card issuer** verifies the availability of funds and the authenticity of the transaction, approving or declining it.
6. The response (approval or decline) is sent back to the **merchant** through the same path: issuer → card network → acquirer → merchant.

#### Money Flow:

1. After the transaction is approved, the **card issuer** debits the amount from the **consumer**'s account.
2. The **card issuer** transfers the funds (minus fees) to the **card network**.
3. The **card network** passes the funds to the **acquirer**.
4. The **acquirer** deposits the funds into the **merchant**'s account, deducting processing fees.

### 2. Explain the difference between acquirer, sub-acquirer, and payment gateway and how the flow explained in question 1 changes for these players.

#### Acquirer:
- **Role**: A company that processes payment transactions on behalf of merchants. They have a direct connection with the card networks.
- **Examples**: Cielo, Rede, Stone.
- **Information Flow**: The acquirer receives the transaction details from the merchant and forwards them directly to the card network.

#### Sub-acquirer:
- **Role**: A company that acts as an intermediary between the merchant and the acquirer. They do not have a direct connection with the card networks.
- **Examples**: PagSeguro, MercadoPago.
- **Information Flow**: The sub-acquirer receives the transaction details from the merchant and forwards them to an acquirer, who then sends them to the card network.

#### Payment Gateway:
- **Role**: A service provider that facilitates communication between the merchant and financial entities (acquirers, sub-acquirers). They provide the technical infrastructure for processing payments but do not participate in the money flow.
- **Examples**: Stripe, PayPal.
- **Information Flow**: The payment gateway receives the transaction details from the merchant and forwards them to the acquirer or sub-acquirer, who then sends them to the card network.

#### Changes in the Flow:
- For a sub-acquirer, there is an additional step in the information and money flows as transactions pass through the sub-acquirer before reaching the acquirer.
- For a payment gateway, they only facilitate communication and do not directly participate in the money flow, but they help route the information correctly.

### 3. Explain what chargebacks are, how they differ from cancellations, and what their connection is with fraud in the acquiring world.

#### Chargebacks:
- **Definition**: A chargeback is a reversal of a transaction made by a card issuer at the cardholder's request. This occurs when the consumer disputes a transaction due to fraud, non-receipt of goods, defective products, among other reasons.
- **Process**: When a consumer disputes a transaction, the card issuer investigates the claim. If the claim is deemed valid, the issuer reverses the transaction and debits the merchant's account.

#### Cancellations:
- **Definition**: A cancellation is the annulment of a transaction by the merchant before it is fully processed. This can occur due to merchant error, consumer request, or issues with the order.
- **Process**: The merchant initiates the annulment of the transaction, and the amount is refunded to the consumer without the card issuer's intervention.

#### Connection with Fraud:
- **Chargebacks** are often associated with fraud, as one of the most common reasons for disputing a transaction is that the cardholder does not recognize or did not authorize it.
- In the acquiring world, a high volume of chargebacks can indicate security issues and fraud within the merchant's system, leading to fines and additional fees for the merchant.
- **Fraud Prevention**: Acquirers and sub-acquirers implement various security measures to prevent fraud, such as fraud detection systems, 3D Secure authentication, and real-time transaction monitoring.

Understanding the industry and the associated concepts is fundamental for the development and implementation of effective solutions for technical challenges in the payments sector.


## 3.2 - Get Your Hands Dirty

Using [this CSV](https://gist.github.com/cloudwalk-tests/76993838e65d7e0f988f40f1b1909c97#file-transactional-sample-csv) with hypothetical transactional data, imagine you are trying to understand if there is any kind of suspicious behavior.

1. **Analyze the provided data and present your conclusions (consider that all transactions are made using a mobile device).**

   Analyzing the transactional data provided in the CSV file, we can observe the following points:

   - **Transactions with Chargeback (has_cbk = TRUE):**
     - Transaction ID 21320399: Amount of $734.87.
     - Transaction ID 21320401: Amount of $2556.13.
     - Transaction ID 21320405: Amount of $188.68.
     - Transaction ID 21320406: Amount of $352.77.
     - Transaction ID 21320407: Amount of $345.68.

   - **Multiple Attempts by the Same User (user_id):**
     - User ID 81152 made three transactions (IDs 21320405, 21320406, 21320407) in a short period of time, all with chargebacks, suggesting suspicious behavior.

   - **High-Value Transactions:**
     - Transaction ID 21320401: $2556.13.

   Conclusions:
   - Transactions with chargebacks indicate potentially fraudulent behavior.
   - Users with multiple transaction attempts in a short period should be closely monitored.
   - High-value transactions should be scrutinized to ensure authenticity.

2. **In addition to the spreadsheet data, what other data would you look at to try to find patterns of possible fraud?**

   To identify patterns of possible fraud, in addition to the data provided in the spreadsheet, it would be useful to consider:

   - **User Transaction History:** Frequency of transactions, past behavior, purchase patterns.
   - **Geographical Location:** Check if transactions are being made from unusual locations or multiple transactions from different locations in a short period.
   - **Device Used:** Identify if the same device is being used for multiple accounts or if there is a sudden change in the device used.
   - **Browsing Behavior:** Time spent on the site, pages visited before the transaction.
   - **Authentication Data:** Additional verification like 3D Secure.
   - **Fraud Reports:** Consult known fraud databases for similar behavior patterns.


### 3.3 - Solve the problem

*Stop credit card fraud: Implement the concept of a simple anti-fraud.*

An Anti-fraud works by receiving information about a transaction and inferring whether it is a fraudulent transaction or not before authorizing it.
We work mostly with Ruby and Python, but you can use any programming language that you want.

Please use the data provided on challenge 2 to test your solution. Consider that transactions with the flag ```has_cbk = true``` are transactions with fraud chargebacks.

Your Anti-fraud must have at least:
1 endpoint that receives transaction data and returns a recommendation to “approve/deny” the transaction.

Example payload:
```json
{
  "transaction_id" : 2342357,
  "merchant_id" : 29744,
  "user_id" : 97051,
  "card_number" : "434505******9116",
  "transaction_date" : "2019-11-31T23:16:32.812632",
  "transaction_amount" : 373,
  "device_id" : 285475
}
```
Example response:
```json
{
  "transaction_id" : 2342357,
  "recommendation" : "approve"
}
```

You are free to determine the methods to approve/deny the transactions, but a few ways to do it are:

- rule-based  - you define which cases get approved/denied based on predefined rules;
- score-base  - you create a method/model (you could use machine learning models here if you want)  to determine the risk-- score of a transaction and make your decision based on it;
- a combination of both;

Things to watch for:
- Latency
- Security
- Architecture
- Coding style

#### Antifraud Requirements

- Reject transaction if user is trying too many transactions in a row;
- Reject transactions above a certain amount in a given period;
- Reject transaction if a user had a chargeback before (note that this information does not comes on the payload. The chargeback data is received **days after the transaction was approved**)
