-- CREATE DATABASE ride_hailing_analytics;

-- Connect to database
-- \c ride_hailing_analytics;

-- Create main table for ride data
CREATE TABLE fact_rides (
    ride_date DATE,
    ride_time TIME,
    booking_id TEXT PRIMARY KEY,
    booking_status TEXT,
    customer_id TEXT,
    vehicle_type TEXT,
    pickup_location TEXT,
    drop_location TEXT,
    avg_vtat NUMERIC,
    avg_ctat NUMERIC,
    cancelled_by_customer NUMERIC,
    customer_cancel_reason TEXT,
    cancelled_by_driver NUMERIC,
    driver_cancel_reason TEXT,
    incomplete_rides NUMERIC,
    incomplete_rides_reason TEXT,
    booking_value NUMERIC,
    ride_distance NUMERIC,
    driver_ratings NUMERIC,
    customer_rating NUMERIC,
    payment_method TEXT,
    booking_datetime TEXT,
    year INT,
    month INT,
    month_name TEXT,
    day INT,
    day_of_week TEXT,
    hour INT,
    time_of_day TEXT,
    has_missing_values BOOLEAN,
    is_completed BOOLEAN,
    is_cancelled BOOLEAN,
    is_incomplete BOOLEAN,
    no_driver_found BOOLEAN,
    revenue_per_km NUMERIC,
    total_tat NUMERIC,
    rating_difference NUMERIC,
    distance_category TEXT,
    value_category TEXT
);

-- DROP TABLE IF EXISTS fact_rides;
TRUNCATE TABLE fact_rides RESTART IDENTITY;

-- Copy data from CSV
-- \copy fact_rides FROM 'path' DELIMITER ',' CSV HEADER;

-- Verify import
SELECT COUNT(*) FROM fact_rides;
SELECT * FROM fact_rides LIMIT 5;