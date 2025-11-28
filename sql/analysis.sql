-- =====================================================
-- 1. EXECUTIVE DASHBOARD - KEY METRICS
-- =====================================================

-- Overall Business Health Snapshot
SELECT 
    COUNT(*) AS total_bookings,
    COUNT(CASE WHEN is_completed THEN 1 END) AS completed_rides, -- completed rides
    COUNT(CASE WHEN is_cancelled THEN 1 END) AS cancelled_rides, -- cancelled rides
    COUNT(CASE WHEN is_incomplete THEN 1 END) AS incomplete_rides, -- incomplete rides
    COUNT(CASE WHEN no_driver_found THEN 1 END) AS no_driver_found, -- no driver found cases
    
    ROUND(COUNT(CASE WHEN is_completed THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) AS completion_rate_pct, -- completion rate
    ROUND(COUNT(CASE WHEN is_cancelled THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) AS cancellation_rate_pct, -- cancellation rate
    ROUND(COUNT(CASE WHEN is_incomplete THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) AS incompletion_rate_pct, -- incompletion rate
    ROUND(COUNT(CASE WHEN no_driver_found THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) AS no_driver_found_rate_pct, -- no driver found rate

    ROUND(SUM(booking_value), 2) AS total_revenue, -- total revenue
    ROUND(AVG(booking_value), 2) AS avg_booking_value, -- average booking value 
    ROUND(SUM(ride_distance), 2) AS total_distance_km, -- total distance covered
    ROUND(AVG(ride_distance), 2) AS avg_distance_km, -- average distance per ride
    
    ROUND(AVG(driver_ratings), 2) AS avg_driver_rating, -- average driver rating
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating, -- average customer rating
    ROUND(AVG(rating_difference), 2) AS avg_rating_gap, -- average rating gap
    
    ROUND(AVG(avg_vtat), 2) AS avg_vehicle_arrival_time_min, -- vehicle arrival time
    ROUND(AVG(total_tat), 2) AS avg_total_trip_time_min -- total trip time
FROM fact_rides;


-- =====================================================
-- 2. REVENUE OPTIMIZATION ANALYSIS
-- =====================================================

-- Vehycle Type Performance & Revenue Contribution
SELECT 
    vehicle_type,
    COUNT(*) AS total_bookings,
    ROUND(SUM(booking_value), 2) AS total_revenue,
    ROUND(AVG(booking_value), 2) AS avg_booking_value,
    ROUND(AVG(ride_distance), 2) AS avg_distance_km,
    ROUND(AVG(revenue_per_km), 2) AS avg_revenue_per_km
FROM fact_rides
WHERE is_completed = TRUE
GROUP BY vehicle_type
ORDER BY total_revenue DESC;


-- Payment Method Analysis - Which channels drive revenue?

-- Bucket booking values to see distribution
SELECT
    width_bucket(booking_value, 0, 1000, 10) AS bucket, -- 10 buckets from 0 to 1000
    COUNT(*) AS rides,
    MIN(booking_value),
    MAX(booking_value)
FROM fact_rides
WHERE is_completed = TRUE
GROUP BY bucket
ORDER BY bucket;

-- Payment Method Performance & Revenue Contribution
SELECT 
    payment_method,
    COUNT(*) AS transactions,
    ROUND(SUM(booking_value), 2) AS total_revenue,
    ROUND(AVG(booking_value), 2) AS avg_transaction_value,
    ROUND(SUM(booking_value) / (SELECT SUM(booking_value) FROM fact_rides WHERE is_completed) * 100, 2) AS revenue_share_pct,
    ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM fact_rides WHERE is_completed) * 100, 2) AS transaction_share_pct
FROM fact_rides
WHERE is_completed = TRUE AND payment_method IS NOT NULL
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- High-Value Rides Analysis (Premium opportunities)
SELECT 
    value_category,
    COUNT(*) AS ride_count,
    ROUND(AVG(booking_value), 2) AS avg_fare,
    ROUND(SUM(booking_value), 2) AS total_revenue,
    ROUND(AVG(ride_distance), 2) AS avg_distance,
    ROUND(AVG(revenue_per_km), 2) AS avg_revenue_per_km,
    ROUND(AVG(customer_rating), 2) AS avg_customer_satisfaction,
    ROUND(AVG(driver_ratings), 2) AS avg_driver_satisfaction,
    STRING_AGG(DISTINCT vehicle_type, ', ' ORDER BY vehicle_type) AS vehicle_types_used
FROM fact_rides
WHERE is_completed = TRUE AND value_category IS NOT NULL
GROUP BY value_category
ORDER BY 
    CASE value_category
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
        ELSE 4
    END;


-- =====================================================
-- 3. CANCELLATION DEEP DIVE - Root Cause Analysis
-- =====================================================

-- Overall Cancellation Breakdown
SELECT 
    CASE 
        WHEN cancelled_by_customer = 1 THEN 'Customer'
        WHEN cancelled_by_driver = 1 THEN 'Driver'
        ELSE 'Unknown'
    END AS cancelled_by,
    COUNT(*) AS cancellation_count,
    ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM fact_rides WHERE is_cancelled) * 100, 2) AS pct_of_total_cancellations,
    COUNT(DISTINCT vehicle_type) AS vehicle_types_affected
FROM fact_rides
WHERE is_cancelled = TRUE
GROUP BY 
    CASE 
        WHEN cancelled_by_customer = 1 THEN 'Customer'
        WHEN cancelled_by_driver = 1 THEN 'Driver'
        ELSE 'Unknown'
    END
ORDER BY cancellation_count DESC;

-- Customer Cancellation Reasons - Prioritized
SELECT 
    customer_cancel_reason AS reason_for_cancelling_by_customer,
    COUNT(*) AS frequency,
    ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM fact_rides WHERE cancelled_by_customer = 1) * 100, 2) AS pct_of_customer_cancellations,
    STRING_AGG(DISTINCT vehicle_type, ', ') AS affected_vehicle_types,
    ROUND(AVG(avg_vtat), 2) AS avg_wait_time_before_cancel
FROM fact_rides
WHERE cancelled_by_customer = 1 AND customer_cancel_reason IS NOT NULL
GROUP BY customer_cancel_reason
ORDER BY frequency DESC;

-- Driver Cancellation Reasons - Action Items
SELECT 
    driver_cancel_reason AS reason_for_cancelling_by_driver,
    COUNT(*) AS frequency,
    ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM uber_rides WHERE cancelled_rides_by_driver = 1) * 100, 2) AS pct_of_driver_cancellations,
    STRING_AGG(DISTINCT vehicle_type, ', ') AS affected_vehicle_types,
    STRING_AGG(DISTINCT time_of_day, ', ') AS common_times
FROM uber_rides
WHERE cancelled_rides_by_driver = 1 AND driver_cancellation_reason IS NOT NULL
GROUP BY driver_cancellation_reason
ORDER BY frequency DESC;