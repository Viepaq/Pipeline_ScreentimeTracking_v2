-- Row-Level Security (RLS) Policies for ScreenTime Accountability App
-- These policies control access to the database tables based on user roles and relationships

-- Enable Row Level Security on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE screen_time_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE screen_time_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE extension_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE extension_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- Profiles policies
-- Users can read their own profile
CREATE POLICY profiles_select_own ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY profiles_update_own ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Groups policies
-- Users can read groups they're members of
CREATE POLICY groups_select_member ON groups
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM memberships
            WHERE memberships.group_id = groups.id
            AND memberships.user_id = auth.uid()
            AND memberships.status = 'active'
        )
    );

-- Only group admin can update group details
CREATE POLICY groups_update_admin ON groups
    FOR UPDATE USING (auth.uid() = admin_user_id);

-- Any authenticated user can create a group
CREATE POLICY groups_insert_auth ON groups
    FOR INSERT WITH CHECK (auth.uid() = admin_user_id);

-- Only group admin can delete a group
CREATE POLICY groups_delete_admin ON groups
    FOR DELETE USING (auth.uid() = admin_user_id);

-- Memberships policies
-- Users can read memberships for groups they're members of
CREATE POLICY memberships_select_group_member ON memberships
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM memberships m
            WHERE m.group_id = memberships.group_id
            AND m.user_id = auth.uid()
            AND m.status = 'active'
        )
    );

-- Users can read their own memberships
CREATE POLICY memberships_select_own ON memberships
    FOR SELECT USING (auth.uid() = user_id);

-- Group admins can insert new memberships (invitations)
CREATE POLICY memberships_insert_admin ON memberships
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM groups
            WHERE groups.id = memberships.group_id
            AND groups.admin_user_id = auth.uid()
        )
    );

-- Users can update their own membership status (accept/decline invitations)
CREATE POLICY memberships_update_own ON memberships
    FOR UPDATE USING (auth.uid() = user_id);

-- Group admins can update any membership in their group
CREATE POLICY memberships_update_admin ON memberships
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM groups
            WHERE groups.id = memberships.group_id
            AND groups.admin_user_id = auth.uid()
        )
    );

-- Screen time limits policies
-- Users can read their own screen time limits
CREATE POLICY screen_time_limits_select_own ON screen_time_limits
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own screen time limits
CREATE POLICY screen_time_limits_insert_own ON screen_time_limits
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own screen time limits
CREATE POLICY screen_time_limits_update_own ON screen_time_limits
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own screen time limits
CREATE POLICY screen_time_limits_delete_own ON screen_time_limits
    FOR DELETE USING (auth.uid() = user_id);

-- Screen time usage policies
-- Users can read their own screen time usage
CREATE POLICY screen_time_usage_select_own ON screen_time_usage
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own screen time usage
CREATE POLICY screen_time_usage_insert_own ON screen_time_usage
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own screen time usage
CREATE POLICY screen_time_usage_update_own ON screen_time_usage
    FOR UPDATE USING (auth.uid() = user_id);

-- Extension requests policies
-- Users can read extension requests for groups they're members of
CREATE POLICY extension_requests_select_group_member ON extension_requests
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM memberships
            WHERE memberships.group_id = extension_requests.group_id
            AND memberships.user_id = auth.uid()
            AND memberships.status = 'active'
        )
    );

-- Users can insert their own extension requests
CREATE POLICY extension_requests_insert_own ON extension_requests
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own extension requests
CREATE POLICY extension_requests_update_own ON extension_requests
    FOR UPDATE USING (auth.uid() = user_id);

-- Extension responses policies
-- Users can read extension responses for requests in their group
CREATE POLICY extension_responses_select_group_member ON extension_responses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM extension_requests er
            JOIN memberships m ON er.group_id = m.group_id
            WHERE er.id = extension_responses.request_id
            AND m.user_id = auth.uid()
            AND m.status = 'active'
        )
    );

-- Users can insert their own extension responses
CREATE POLICY extension_responses_insert_own ON extension_responses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own extension responses
CREATE POLICY extension_responses_update_own ON extension_responses
    FOR UPDATE USING (auth.uid() = user_id);

-- Notifications policies
-- Users can read their own notifications
CREATE POLICY notifications_select_own ON notifications
    FOR SELECT USING (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
CREATE POLICY notifications_update_own ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- Device tokens policies
-- Users can read their own device tokens
CREATE POLICY device_tokens_select_own ON device_tokens
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own device tokens
CREATE POLICY device_tokens_insert_own ON device_tokens
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own device tokens
CREATE POLICY device_tokens_update_own ON device_tokens
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own device tokens
CREATE POLICY device_tokens_delete_own ON device_tokens
    FOR DELETE USING (auth.uid() = user_id);
