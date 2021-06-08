
## Sending events

### Receive batches of events

Base URL:
Host: t.jitsu.com/api/event
We send api_key in the body

Method: POST
Headers:
"Content-Type": "application/json",


#### Multiple events in batch

```
[
{
"src": "jitsu_ios",
"api_key": "VALUE",
"app_build_id": "2.1.1",
"sdk_version": "1.4.1",
"utc_time: "2021-06-08T09:51:02.510000Z",
"local_tz_offset": -180,
"event_id": "gpon6lmpwquappfl0",
"event_type": "user tapped purchase button",
{
"device": "iPhone 12",
"manufacturer": "Apple",
"platform": "iOS",
"os": "iOS",
"os_version": "14.1", 
"screen_resolution": "1440x900"
},
"user": {
"anonymous_id": "sh1ah4rvsasdf",
"email": "foo@bar.com"
"internal_id": "pzrWMXvtZUThJ24JW5iL2bvG9SA2"
},
"user_language": "en-GB",
"location": {
lat: "55.706335",
lon: "37.561748"
},
"custom_param_1": "chips",
"other_custom_param": "crisps",
"another parameter": {
"foo": "bar",
"cat": "cat"
}
},
{
"src": "jitsu_ios",
"app_build_id": "2.1.1",
"sdk_version": "1.4.1",
"utc_time: "2021-06-08T09:51:02.510000Z",
"local_tz_offset": -180,
"event_id": "gpon6lmpwquappfl0",
"event_type": "app entered background",
{
"device": "iPhone 12",
"manufacturer": "Apple",
"platform": "iOS",
"os": "iOS",
"os_version": "14.1", 
"screen_resolution": "1440x900"
},
"user": {
"anonymous_id": "sh1ah4rvqeadfasdf",
"email": "foo@bar.com"
"internal_id": "pzrWMXvtZUThJ24JW5iL2bvG9SA2"
},
"user_language": "en-GB",
"custom_param_2": "34"
}
]
```

#### Multiple events in batch with common template
```
{
"template": {
"api_key": "VALUE",
"src": "jitsu_ios",
"app_build_id": "2.1.1",
"sdk_version": "1.4.1",
{
"device": "iPhone 12",
"manufacturer": "Apple",
"platform": "iOS",
"os": "iOS",
"os_version": "14.1", 
"screen_resolution": "1440x900"
},
"user_language": "en-GB",
"user": {
"anonymous_id": "sh1ah4rvqeadsfd",
"email": "foo@bar.com"
"internal_id": "pzrWMXvtZUThJ24JW5iL2bvG9SA2"
}
},
"events": [
{
"utc_time: "2021-06-08T09:51:02.510000Z",
"local_tz_offset": -180,
"event_id": "gpon6lmpwquappfl0",
"event_type": "user tapped purchase button",
"location": {
lat: "55.706335",
lon: "37.561748"
},
"custom_param_1": "chips",
"other_custom_param": "crisps",
"another parameter": {
"foo": "bar",
"cat": "cat"
}
},
{
"utc_time: "2021-06-08T09:51:02.510000Z",
"local_tz_offset": -180,
"event_id": "gpon6lmpwquappfl0",
"event_type": "app entered background",
"custom_param_2": "34"
}
]
}
```

In this case, each event object should be merged with the template object (event obj has priority) prior to sending
to data pipeline

#### Pass single event
```
{
"src": "jitsu_ios",
"api_key": "VALUE",
"app_build_id": "2.1.1",
"sdk_version": "1.4.1",
"utc_time: "2021-06-08T09:51:02.510000Z",
"local_tz_offset": -180,
"event_id": "gpon6lmpwquappfl0",
"event_type": "user tapped purchase button",
{
"device": "iPhone 12",
"manufacturer": "Apple",
"platform": "iOS",
"os": "iOS",
"os_version": "14.1", 
"screen_resolution": "1440x900"
},
"user": {
"anonymous_id": "sh1ah4rvqedasfd",
"email": "foo@bar.com"
"internal_id": "pzrWMXvtZUThJ24JW5iL2bvG9SA2"
},
"user_language": "en-GB",
"location": {
lat: "55.706335",
lon: "37.561748"
},
"custom_param_1": "chips",
"other_custom_param": "crisps",
"another parameter": {
"foo": "bar",
"cat": "cat"
}
}
```
