# Transactions bot

Whatsapp Bot for managing offline payment transactions built using [Whatsapp APIs by Twilio](https://www.twilio.com/whatsapp) and [Wit.ai](https://wit.ai/)

## Purpose
>Large working population in India is in unorganized sector often receiving payments daily or weekly. 
<br>There was lack of maintaining records for such payment at my farm so I created this simple bot which anyone can operate and keep track of payments made to labour and farm workers.
<br> Also I wanted to develop PoC based on Twilio APIs and Wit AI

## Features and Demo

> Supports messages like
```
{amount} to {name}
to register an outgoing transaction.

{amount} from {name}
to register an incoming transaction.

daily report
to get daily incoming and outgoing summary.

weekly report
to get weekly incoming and outgoing summary.

help
to get this description.
```

> You can add contact to the chat and it will be saved as member

> Adding transactions

> Checking daily reports

## Dependencies
- Ruby 2.6.6
- Rails 5.2.1
- MongoDB 4.2.6

## Build Instructions
```
export wbot_twilio_account_sid='xxxx'
export wbot_twilio_auth_token='xxxx'
export wbot_wit_access_token='xxxx'
```

```
bundle install
rails s
```
## Tests
- WIP

