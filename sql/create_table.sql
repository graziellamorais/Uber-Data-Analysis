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

-- Copy data from CSV
-- \copy fact_rides FROM 'path' DELIMITER ',' CSV HEADER;

-- Verify import
SELECT COUNT(*) FROM fact_rides;
SELECT * FROM fact_rides LIMIT 5;

-- Create foreign key relationships
-- ALTER TABLE fact_rides
-- ADD COLUMN vehicle_id INT,
-- ADD COLUMN location_id INT;
-- UPDATE fact_rides
-- SET vehicle_id = dv.vehicle_id
-- FROM dim_vehicle dv
-- WHERE fact_rides.vehicle_type = dv.vehicle_type;
-- UPDATE fact_rides
-- SET location_id = dl.location_id
-- FROM dim_location dl
-- WHERE fact_rides.pickup_location = dl.pickup_location
--    AND fact_rides.drop_location = dl.drop_location;
-- ALTER TABLE fact_rides
-- ADD FOREIGN KEY (vehicle_id) REFERENCES dim_vehicle(vehicle_id),
-- ADD FOREIGN KEY (location_id) REFERENCES dim_location(location_id);