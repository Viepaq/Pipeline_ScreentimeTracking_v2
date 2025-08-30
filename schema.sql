-- Schema for ScreenTime Accountability App
-- This schema defines the database structure for the Supabase backend

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create groups table
CREATE TABLE IF NOT EXISTS groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    admin_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create memberships table (for group members)
CREATE TABLE IF NOT EXISTS memberships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'active', 'declined', 'removed')),
    invited_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    joined_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, group_id)
);

-- Create screen_time_limits table
CREATE TABLE IF NOT EXISTS screen_time_limits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    app_id TEXT NOT NULL,
    app_name TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    daily_limit_minutes INTEGER NOT NULL CHECK (daily_limit_minutes > 0),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, app_id)
);

-- Create screen_time_usage table
CREATE TABLE IF NOT EXISTS screen_time_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    app_id TEXT NOT NULL,
    app_name TEXT NOT NULL,
    minutes_used INTEGER NOT NULL DEFAULT 0 CHECK (minutes_used >= 0),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, app_id, date)
);

-- Create extension_requests table
CREATE TABLE IF NOT EXISTS extension_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    app_id TEXT NOT NULL,
    app_name TEXT NOT NULL,
    requested_minutes INTEGER NOT NULL CHECK (requested_minutes > 0 AND requested_minutes <= 420),
    reason TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'denied')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create extension_responses table
CREATE TABLE IF NOT EXISTS extension_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES extension_requests(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    approved BOOLEAN NOT NULL,
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(request_id, user_id)
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('extensionRequest', 'extensionApproved', 'extensionDenied', 'groupInvite', 'groupJoined', 'dailySummary')),
    related_id UUID,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create device_tokens table for push notifications
CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    device_type TEXT NOT NULL DEFAULT 'ios',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, token)
);

-- Create trigger to update updated_at columns
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to all tables with updated_at
CREATE TRIGGER update_profiles_modtime
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_groups_modtime
    BEFORE UPDATE ON groups
    FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_screen_time_limits_modtime
    BEFORE UPDATE ON screen_time_limits
    FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_screen_time_usage_modtime
    BEFORE UPDATE ON screen_time_usage
    FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_extension_requests_modtime
    BEFORE UPDATE ON extension_requests
    FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_device_tokens_modtime
    BEFORE UPDATE ON device_tokens
    FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- Create trigger to automatically insert into profiles after auth.users insert
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, username, email)
    VALUES (NEW.id, NEW.raw_user_meta_data->>'username', NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Create function to check extension request approval threshold
CREATE OR REPLACE FUNCTION check_extension_approval_threshold()
RETURNS TRIGGER AS $$
DECLARE
    total_active_members INTEGER;
    approval_threshold INTEGER;
    approval_count INTEGER;
    denial_count INTEGER;
BEGIN
    -- Count active members in the group (excluding requester)
    SELECT COUNT(*) INTO total_active_members
    FROM memberships m
    JOIN extension_requests er ON m.group_id = er.group_id
    WHERE m.group_id = (SELECT group_id FROM extension_requests WHERE id = NEW.request_id)
    AND m.status = 'active'
    AND m.user_id != (SELECT user_id FROM extension_requests WHERE id = NEW.request_id);
    
    -- Calculate threshold based on group size
    IF total_active_members <= 2 THEN
        approval_threshold := 1;
    ELSIF total_active_members <= 3 THEN
        approval_threshold := 1;
    ELSE
        approval_threshold := 2;
    END IF;
    
    -- Count approvals and denials
    SELECT 
        COUNT(*) FILTER (WHERE approved = TRUE),
        COUNT(*) FILTER (WHERE approved = FALSE)
    INTO approval_count, denial_count
    FROM extension_responses
    WHERE request_id = NEW.request_id;
    
    -- Update request status if threshold is met
    IF approval_count >= approval_threshold THEN
        UPDATE extension_requests
        SET status = 'approved', updated_at = now()
        WHERE id = NEW.request_id AND status = 'pending';
    ELSIF denial_count >= approval_threshold THEN
        UPDATE extension_requests
        SET status = 'denied', updated_at = now()
        WHERE id = NEW.request_id AND status = 'pending';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER check_extension_approval
    AFTER INSERT OR UPDATE ON extension_responses
    FOR EACH ROW EXECUTE PROCEDURE check_extension_approval_threshold();

-- Create function to handle daily reset (to be called by cron job)
CREATE OR REPLACE FUNCTION daily_reset()
RETURNS void AS $$
BEGIN
    -- Archive yesterday's usage data if needed
    
    -- Reset usage for today
    UPDATE screen_time_usage
    SET minutes_used = 0, updated_at = now()
    WHERE date = CURRENT_DATE;
    
    -- Create summary notifications
    INSERT INTO notifications (title, body, type, user_id)
    SELECT 
        'Daily Reset',
        'Your screen time limits have been reset for today.',
        'dailySummary',
        user_id
    FROM profiles;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
