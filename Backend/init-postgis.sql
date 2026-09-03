-- Enable PostGIS spatial extensions
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. Landslide Hazard Reports (B1)
CREATE TABLE IF NOT EXISTS landslide_reports (
    id VARCHAR(64) PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    altitude DOUBLE PRECISION,
    location_description TEXT NOT NULL,
    severity VARCHAR(32) NOT NULL,
    detected_features JSONB NOT NULL DEFAULT '[]'::jsonb,
    estimated_slope_angle DOUBLE PRECISION NOT NULL,
    plain_language_explanation TEXT NOT NULL,
    recommended_safety_actions JSONB NOT NULL DEFAULT '[]'::jsonb,
    local_photo_path TEXT,
    reporter_id VARCHAR(64) NOT NULL,
    sync_status VARCHAR(32) NOT NULL DEFAULT 'syncedToCloud',
    relay_hops INTEGER NOT NULL DEFAULT 0,
    last_relay_peer VARCHAR(64),
    location GEOGRAPHY(Point, 4326) GENERATED ALWAYS AS (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography) STORED
);

-- 2. Road Condition & Blockage Reports (B6)
CREATE TABLE IF NOT EXISTS road_reports (
    id VARCHAR(64) PRIMARY KEY,
    road_identifier VARCHAR(64) NOT NULL,
    section_name VARCHAR(128) NOT NULL,
    status VARCHAR(32) NOT NULL,
    obstacle_type VARCHAR(64) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    estimated_clearance_time VARCHAR(128),
    passable_by_two_wheeler BOOLEAN NOT NULL DEFAULT FALSE,
    passable_by_4x4 BOOLEAN NOT NULL DEFAULT FALSE,
    description TEXT NOT NULL,
    reporter_id VARCHAR(64) NOT NULL,
    sync_status VARCHAR(32) NOT NULL DEFAULT 'syncedToCloud',
    relay_hops INTEGER NOT NULL DEFAULT 0,
    last_relay_peer VARCHAR(64),
    location GEOGRAPHY(Point, 4326) GENERATED ALWAYS AS (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography) STORED
);

-- 3. Mesh Packet Relay Logs
CREATE TABLE IF NOT EXISTS mesh_packet_logs (
    id SERIAL PRIMARY KEY,
    packet_id VARCHAR(64) UNIQUE NOT NULL,
    type VARCHAR(32) NOT NULL,
    payload JSONB NOT NULL,
    original_sender_id VARCHAR(64) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    max_ttl INTEGER NOT NULL DEFAULT 5,
    current_hop INTEGER NOT NULL DEFAULT 0,
    relay_path JSONB NOT NULL DEFAULT '[]'::jsonb,
    priority INTEGER NOT NULL DEFAULT 2
);

-- Spatial GIST Indices for sub-millisecond radius and route queries
CREATE INDEX IF NOT EXISTS idx_landslide_location ON landslide_reports USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_road_location ON road_reports USING GIST (location);

-- Seed Initial Himalayan Corridor Reports
INSERT INTO landslide_reports (
    id, timestamp, latitude, longitude, altitude, location_description, severity,
    detected_features, estimated_slope_angle, plain_language_explanation,
    recommended_safety_actions, reporter_id, relay_hops, last_relay_peer
) VALUES (
    'ls-db-001', NOW() - INTERVAL '1 hour', 26.9048, 88.3375, 1450.0,
    'NH-55 Tindharia Hillside Cut', 'high',
    '["tensionCrack", "waterSeepage", "debrisFall"]'::jsonb, 48.5,
    'Tension cracks extending over 14 meters with active mud seepage identified on steep cut slope.',
    '["Evacuate downslope residences within 100 meters.", "Halt heavy vehicular traffic."]'::jsonb,
    'volunteer-phone-b', 1, 'rescue-van-04'
) ON CONFLICT (id) DO NOTHING;

INSERT INTO road_reports (
    id, road_identifier, section_name, status, obstacle_type,
    latitude, longitude, timestamp, estimated_clearance_time,
    passable_by_two_wheeler, passable_by_4x4, description, reporter_id, relay_hops
) VALUES (
    'rd-db-001', 'NH-55', 'Pagla Jhora Chasm', 'blocked', 'landslideDebris',
    26.9215, 88.3142, NOW() - INTERVAL '40 minutes', '4 to 6 Hours (PWD JCB deployed)',
    FALSE, FALSE, 'Heavy sludge and 3-meter boulders covering both lanes after cloudburst.',
    'pwd-patrol-07', 2
) ON CONFLICT (id) DO NOTHING;

-- 4. Safe Havens, Hospitals & Disaster Evacuation Camps (AMBITIOUS)
CREATE TABLE IF NOT EXISTS safe_havens (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    type VARCHAR(64) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    altitude_meters DOUBLE PRECISION NOT NULL DEFAULT 1000,
    locality VARCHAR(128) NOT NULL,
    capacity INTEGER NOT NULL DEFAULT 100,
    medical_capabilities JSONB NOT NULL DEFAULT '[]'::jsonb,
    emergency_radio_freq VARCHAR(128) NOT NULL,
    road_access_notes TEXT NOT NULL,
    location GEOGRAPHY(Point, 4326) GENERATED ALWAYS AS (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography) STORED
);

CREATE INDEX IF NOT EXISTS idx_safe_haven_location ON safe_havens USING GIST (location);

INSERT INTO safe_havens (
    id, name, type, latitude, longitude, altitude_meters, locality, capacity,
    medical_capabilities, emergency_radio_freq, road_access_notes
) VALUES 
(
    'haven-001', 'Kurseong Sub-Divisional Hospital', 'subDivisionalHospital',
    26.8845, 88.2812, 1480, 'Kurseong Town Centre', 120,
    '["Trauma Surgery", "High-Pressure Oxygen Supply", "Hypothermia Rewarming Ward", "Blood Bank", "24x7 Emergency Doctors"]'::jsonb,
    'VHF 154.600 MHz (Hospital Channel 1)', 'Approachable via Rohini Road even when NH-55 Pagla Jhora is blocked.'
),
(
    'haven-002', 'Tindharia Railway Community Shelter & PHC', 'primaryHealthCentre',
    26.8560, 88.3390, 856, 'Tindharia Mid-Slopes', 85,
    '["First-Aid Triage", "Burn & Fracture Splinting", "IV Fluids & Dehydration Packs", "Oxygen Concentrator"]'::jsonb,
    'VHF 154.250 MHz', 'Situated on stable rock spur above the Tindharia railway workshop.'
),
(
    'haven-003', 'Makaibari Community Relief Safe Haven', 'disasterReliefShelter',
    26.8520, 88.2710, 1250, 'Makaibari Lower Valley', 250,
    '["Emergency Thermal Blankets", "Potable Water Filtration Unit", "Dry Food Stock (7 Days)", "Basic Trauma Dressing"]'::jsonb,
    'PMR446 Channel 7 / 446.08125 MHz', 'Direct access via Pankhabari Heritage Cut. Zero subsidence risk.'
),
(
    'haven-004', 'Sukna Army Base Hospital & Relief Staging', 'subDivisionalHospital',
    26.7920, 88.3620, 165, 'Sukna Plains Foothills', 350,
    '["Air-Evacuation Helipad", "ICU & Ventilators", "Orthopedic Reconstruction", "NDRF Staging Battalion"]'::jsonb,
    'VHF 155.100 MHz (Military Disaster Net)', 'All-weather plains access. Serves as primary casualty evacuation point.'
),
(
    'haven-005', 'Teesta Low Dam Safe Refuge & SDRF Outpost', 'emergencyRescuePost',
    26.9280, 88.4620, 210, 'Kalijhora Canyon Floor', 90,
    '["River Rescue Boats (Zodiacs)", "Spinal Immobilization Boards", "Crush Injury Medication", "Satellite Phone Uplink"]'::jsonb,
    'VHF 152.850 MHz (SDRF River Net)', 'Located 40m above river high-water line on engineered concrete abutment.'
) ON CONFLICT (id) DO NOTHING;

