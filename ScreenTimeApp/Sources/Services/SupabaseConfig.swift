import Foundation

struct SupabaseConfig {
    // Replace these with your actual Supabase project URL and anon key
    static let supabaseURL = URL(string: "https://your-project-id.supabase.co")!
    static let supabaseAnonKey = "your-supabase-anon-key"
    
    // Realtime channels
    static let extensionRequestsChannel = "extension_requests"
    static let extensionResponsesChannel = "extension_responses"
    
    // Tables
    static let profilesTable = "profiles"
    static let groupsTable = "groups"
    static let membershipsTable = "memberships"
    static let screenTimeLimitsTable = "screen_time_limits"
    static let screenTimeUsageTable = "screen_time_usage"
    static let extensionRequestsTable = "extension_requests"
    static let extensionResponsesTable = "extension_responses"
    static let notificationsTable = "notifications"
    static let deviceTokensTable = "device_tokens"
}
