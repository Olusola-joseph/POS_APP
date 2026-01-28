-- PosMap Database Schema

-- Users table (Field Agents and Supervisors)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    whatsapp_number VARCHAR(15),
    name VARCHAR(255) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('field_agent', 'supervisor', 'admin')) NOT NULL,
    assigned_ward_id UUID,
    assigned_town_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- LGAs (Local Government Areas)
CREATE TABLE lgas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    state VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Towns
CREATE TABLE towns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lga_id UUID REFERENCES lgas(id),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Wards
CREATE TABLE wards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    town_id UUID REFERENCES towns(id),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Streets/Locations
CREATE TABLE streets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ward_id UUID REFERENCES wards(id),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- POS Operators (The main entities we're registering)
CREATE TABLE pos_operators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id), -- Field agent who registered
    shop_name VARCHAR(255) NOT NULL,
    operator_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    whatsapp_number VARCHAR(15),
    email VARCHAR(255),
    street_id UUID REFERENCES streets(id),
    landmark TEXT,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    space_size VARCHAR(50) CHECK (space_size IN ('single_table', 'kiosk', 'shop', 'store')),
    pos_terminals_count INTEGER DEFAULT 1,
    banks_serviced TEXT[], -- Array of bank names
    tier VARCHAR(10) CHECK (tier IN ('tier_1', 'tier_2', 'tier_3')) DEFAULT 'tier_3',
    bvn VARCHAR(11), -- Unique identifier
    nin VARCHAR(11), -- National ID Number
    voters_id VARCHAR(16), -- Voter's card number
    referral_code VARCHAR(10) UNIQUE,
    referred_by UUID REFERENCES pos_operators(id), -- Who referred this operator
    photo_url TEXT, -- Selfie URL
    business_signage_url TEXT, -- Business sign photo URL
    id_photo_url TEXT, -- NIN/BVN/Voters ID photo URL
    verification_slip_url TEXT, -- Generated verification slip PDF
    digital_id_card_url TEXT, -- Generated digital ID card with QR
    requires_cash BOOLEAN DEFAULT FALSE,
    requires_paper_rolls BOOLEAN DEFAULT FALSE,
    inventory_needs TEXT[], -- Other inventory needs
    status VARCHAR(20) CHECK (status IN ('pending', 'verified', 'active', 'inactive', 'fraud')) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_synced TIMESTAMP,
    is_offline BOOLEAN DEFAULT TRUE
);

-- Registrations (Each registration attempt/wizard session)
CREATE TABLE registrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pos_operator_id UUID REFERENCES pos_operators(id),
    user_id UUID REFERENCES users(id), -- Field agent
    step_completed INTEGER DEFAULT 0, -- Current step in the registration wizard (0-5)
    step1_gps_enabled BOOLEAN DEFAULT FALSE,
    step1_lat DECIMAL(10, 8),
    step1_lng DECIMAL(11, 8),
    step1_ward_auto_filled VARCHAR(255),
    step2_photo_uploaded BOOLEAN DEFAULT FALSE,
    step2_business_signage_uploaded BOOLEAN DEFAULT FALSE,
    step2_nin_scanned VARCHAR(11),
    step2_bvn_scanned VARCHAR(11),
    step2_voters_id_scanned VARCHAR(16),
    step2_duplicate_check_performed BOOLEAN DEFAULT FALSE,
    step2_duplicate_found BOOLEAN DEFAULT FALSE,
    step3_shop_name VARCHAR(255),
    step3_landmark TEXT,
    step3_space_size VARCHAR(50),
    step3_pos_terminals_count INTEGER,
    step3_banks_serviced TEXT[],
    step4_operator_name VARCHAR(255),
    step4_phone_number VARCHAR(15),
    step4_whatsapp_number VARCHAR(15),
    step4_tier_assigned VARCHAR(10),
    step5_operator_signature_url TEXT,
    step5_field_agent_signature_url TEXT,
    verification_slip_generated BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Referral tracking
CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_id UUID REFERENCES pos_operators(id), -- The person who referred
    referee_id UUID REFERENCES pos_operators(id), -- The person being referred
    reward_amount DECIMAL(10,2) DEFAULT 500.00, -- Naira amount
    reward_status VARCHAR(20) CHECK (reward_status IN ('pending', 'awarded', 'claimed')) DEFAULT 'pending',
    claimed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Agent performance tracking
CREATE TABLE agent_performance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id), -- Field agent
    date DATE NOT NULL,
    registrations_completed INTEGER DEFAULT 0,
    total_distance_traveled DECIMAL(10,2), -- in kilometers
    average_rating DECIMAL(3,2), -- from 1-5 stars
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Offline sync queue
CREATE TABLE offline_sync_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL, -- 'pos_operator', 'registration', etc.
    entity_id UUID NOT NULL,
    operation_type VARCHAR(10) CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')) NOT NULL,
    data JSONB NOT NULL, -- Serialized entity data
    synced BOOLEAN DEFAULT FALSE,
    sync_error TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    synced_at TIMESTAMP
);