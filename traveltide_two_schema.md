# TravelTide II

TravelTide is an online booking platform for travel, specializing in discount airplane tickets and hotel accommodations.

![TravelTide's Entity Relationship Diagram](traveltide_two_schema.png)

## Connection String

postgresql://Test:bQNxVzJL4g6u@ep-noisy-flower-846766.us-east-2.aws.neon.tech/TravelTide?sslmode=require

## Data Dictionary

- ***users***: users' demographic information
    - *user.id*: unique user ID (key, int)
    - *birthdate*: user date of birth (date)
    - *gender*: user gender (text)
    - *married*: user marriage status (bool)
    - *has_children*: whether or not the user has children (bool)
    - *home_country*: user’s resident country (text)
    - *home_city*: user’s resident city (text)
    - *home_airport*: user’s preferred hometown airport (text)
    - *home_airport_lat*: geographical north-south position of home airport (numeric)
    - *home_airport_lon*: geographical east-west position of home airport (numeric)
    - *sign_up_date*: date of TravelTide account creation (date)

- ***sessions***: information about individual browsing sessions (note: only sessions with at least 2 clicks are included)
    - *session_id*: unique browsing session ID (key, text)
    - *user_id*: the user ID (foreign key, int)
    - *trip_id*: ID mapped to flight and hotel bookings (foreign key, text)
    - *session_start*: time of browsing session start (timestamp)
    - *session_end*: time of browsing session end (timestamp)
    - *flight_discount*: whether or not flight discount was offered (bool)
    - *hotel_discount*: whether or not hotel discount was offered (bool)
    - *flight_discount_amount*: percentage off base fare (numeric)
    - *hotel_discount_amount*: percentage off base night rate (numeric)
    - *flight_booked*: whether or not flight was booked (bool)
    - *hotel_booked*: whether or not hotel was booked (bool)
    - *page_clicks*: number of page clicks during browsing session (int)
    - *cancellation*: whether or not the purpose of the session was to cancel a trip (bool)

- ***flights***: information about purchased flights
    - *trip_id*: unique trip ID (key, text)
    - *origin_airport*: user’s home airport (text)
    - *destination*: destination city (text)
    - *destination_airport*: airport in destination city (text)
    - *seats*: number of seats booked (int)
    - *return_flight_booked*: whether or not a return flight was booked (bool)
    - *departure_time*: time of departure from origin airport (timestamp)
    - *return_time*: time of return to origin airport (timestamp)
    - *checked_bags*: number of checked bags (int)
    - *trip_airline*: airline taking user from origin to destination (text)
    - *destination_airport_lat*: geographical north-south position of destination airport (numeric)
    - *destination_airport_lon*: geographical east-west position of destination airport (numeric)
    - *base_fare_usd*: pre-discount price of airfare (numeric)

- ***hotels***: information about purchased hotel stays
    - *trip_id*: unique trip ID (key, text)
    - *hotel_name*: hotel brand name (text)
    - *rooms*: number of rooms booked with hotel (int)
    - *check_in_time*: time user hotel stay begins (timestamp)
    - *check_out_time*: time user hotel stay ends (timestamp)
    - *hotel_per_room_usd*: pre discount price of hotel stay (numeric)