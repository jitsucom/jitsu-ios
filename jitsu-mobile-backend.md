API for backend - specification


# Auth
With OAuth? 
get-token
We get token, and use it in further requests


# Receive batches of events

Base url: `https://jitsu/app=APP_ID/send`

Receives batch of events. 

Headers:
```
"Content-Type": "application/json",
"x-api-key": TOKEN
```

Body:
```
"anonymousUserId": "foo", 
"userId": "bar",
"events": [
    {
        "timestamp": 2021-08-09T18:31:42,
        "name": "user tapped purchase button"
        "params": {
            "screen": "checkout screen",
            "product_id": "dslkfjlsda32",
            "product_name": "chips"
            "device": "iPhone 12",
            "os": "14.1",
            "location": "55.706335, 37.561748"
        }
    },
    {
        "timestamp": 2021-08-09T18:31:43,
        "name": "app entered background"
        "params": {
            "device": "iPhone 12",
            "os": "14.1",
            "location": "55.706335, 37.561748"
        }
    }, 
    ...
]
```
