# Phase 2 Profile Model

## Overview

The Profile model represents a user's public and private information in the FFT platform. It is separate from the Supabase Auth user identity and stored in a dedicated `profiles` table with Row Level Security (RLS).

## Database Schema

### profiles Table

```sql
CREATE TABLE profiles (
    -- Primary key references auth.users
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Display name (required, 1-50 chars)
    display_name TEXT NOT NULL CHECK (char_length(display_name) BETWEEN 1 AND 50),

    -- Optional username (unique, alphanumeric + underscore, 3-20 chars)
    username TEXT UNIQUE CHECK (username IS NULL OR username ~ '^[a-zA-Z0-9_]{3,20}$'),

    -- Avatar URL (Supabase Storage path or external URL)
    avatar_url TEXT CHECK (avatar_url IS NULL OR char_length(avatar_url) <= 500),

    -- In-game information (Free Fire)
    in_game_name TEXT CHECK (in_game_name IS NULL OR char_length(in_game_name) <= 30),
    in_game_uid TEXT CHECK (in_game_uid IS NULL OR in_game_uid ~ '^\d{8,12}$'),

    -- Privacy settings
    privacy_profile_visibility TEXT NOT NULL DEFAULT 'public'
        CHECK (privacy_profile_visibility IN ('public', 'organizers_only', 'private')),
    privacy_show_in_game_info BOOLEAN NOT NULL DEFAULT false,

    -- Notification preferences (JSONB for flexibility)
    notification_prefs JSONB NOT NULL DEFAULT '{
        "email_tournament_invites": true,
        "email_match_reminders": true,
        "push_tournament_updates": true,
        "push_match_results": true
    }'::jsonb,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_profiles_username ON profiles(username) WHERE username IS NOT NULL;
CREATE INDEX idx_profiles_in_game_uid ON profiles(in_game_uid) WHERE in_game_uid IS NOT NULL;

-- Updated at trigger
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### RLS Policies

```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

-- Public profiles are readable by everyone
CREATE POLICY "Public profiles are readable"
    ON profiles FOR SELECT
    USING (privacy_profile_visibility = 'public');

-- Organizers can read profiles in their tournaments
CREATE POLICY "Organizers can read tournament profiles"
    ON profiles FOR SELECT
    USING (
        privacy_profile_visibility = 'organizers_only' AND
        EXISTS (
            SELECT 1 FROM tournament_organizers
            WHERE tournament_organizers.user_id = auth.uid()
            AND tournament_organizers.tournament_id IN (
                SELECT tournament_id FROM tournament_registrations
                WHERE tournament_registrations.user_id = profiles.id
            )
        )
    );

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Soft delete - users can mark own profile as deleted
CREATE POLICY "Users can soft delete own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id AND deleted_at IS NOT NULL);
```

## Domain Models

### Profile (Freezed)

```dart
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String displayName,
    String? username,
    String? avatarUrl,
    String? inGameName,
    String? inGameUid,
    @Default('public') String privacyProfileVisibility,
    @Default(false) bool privacyShowInGameInfo,
    @Default({}) Map<String, dynamic> notificationPrefs,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
```

### UpdateProfileRequest

```dart
@freezed
class UpdateProfileRequest with _$UpdateProfileRequest {
  const factory UpdateProfileRequest({
    String? displayName,
    String? username,
    String? inGameName,
    String? inGameUid,
    String? privacyProfileVisibility,
    bool? privacyShowInGameInfo,
    Map<String, dynamic>? notificationPrefs,
    String? avatarUrl,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);
}
```

## Field Specifications

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| id | UUID | Yes | PK, FK → auth.users | Supabase Auth user ID |
| displayName | String | Yes | 1-50 chars | Public display name |
| username | String | No | Unique, 3-20 chars, alphanumeric + _ | Unique handle |
| avatarUrl | String | No | URL, ≤500 chars | Profile picture |
| inGameName | String | No | ≤30 chars | Free Fire display name |
| inGameUid | String | No | 8-12 digits | Free Fire numeric ID |
| privacyProfileVisibility | Enum | Yes | public, organizers_only, private | Who can see profile |
| privacyShowInGameInfo | Boolean | Yes | Default: false | Show in-game info |
| notificationPrefs | JSON | Yes | Default object | Notification settings |
| createdAt | DateTime | Yes | Auto | Record creation |
| updatedAt | DateTime | Yes | Auto | Last update |
| deletedAt | DateTime | No | Nullable | Soft delete timestamp |

## Privacy Levels

| Level | Description | Who Can See |
|---|---|---|
| `public` | Visible to everyone | All users |
| `organizers_only` | Visible to tournament organizers | User + organizers of tournaments user is in |
| `private` | Visible only to user | User only |

## Username Rules

- 3-20 characters
- Alphanumeric + underscore only (`^[a-zA-Z0-9_]{3,20}$`)
- Case-insensitive uniqueness (stored lowercase, compared case-insensitive)
- Reserved words blocked: `admin`, `moderator`, `staff`, `fft`, `official`, `support`, `system`, `api`, `www`, `mail`, `email`, `admin`, `root`, `administrator`

## In-Game Info Validation

### inGameName
- Optional
- Max 30 characters
- Free Fire display name (can differ from displayName)

### inGameUid
- Optional
- 8-12 digits only
- Must match Free Fire UID format

## Notification Preferences

Default structure:
```json
{
  "email_tournament_invites": true,
  "email_match_reminders": true,
  "push_tournament_updates": true,
  "push_match_results": true,
  "push_team_invites": true,
  "email_weekly_digest": false
}
```

## API Endpoints

### Get Profile
```
GET /api/v1/profile
Authorization: Bearer <token>
Response: Profile
```

### Update Profile
```
PATCH /api/v1/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "displayName": "New Name",
  "username": "newhandle",
  "inGameName": "FFPlayer123",
  "inGameUid": "12345678",
  "privacyProfileVisibility": "public",
  "privacyShowInGameInfo": true,
  "notificationPrefs": {
    "email_tournament_invites": true,
    "email_match_reminders": false
  }
}
Response: Profile
```

### Update Privacy Settings
```
PATCH /api/v1/profile/privacy
Authorization: Bearer <token>
Content-Type: application/json

{
  "profileVisibility": "organizers_only",
  "showInGameInfo": false
}
Response: Profile
```

### Upload Avatar
```
POST /api/v1/profile/avatar
Authorization: Bearer <token>
Content-Type: multipart/form-data

file: <image>
Response: { "avatarUrl": "https://storage.supabase.co/..." }
```

### Delete Avatar
```
DELETE /api/v1/profile/avatar
Authorization: Bearer <token>
Response: Profile
```

## Supabase Storage

### Avatars Bucket

```sql
-- Create avatars bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']);

-- RLS Policies
CREATE POLICY "Users can upload own avatar"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update own avatar"
    ON storage.objects FOR UPDATE
    USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete own avatar"
    ON storage.objects FOR DELETE
    USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Public avatars are readable"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars');
```

### File Naming
```
avatars/{user_id}/{timestamp}_{random}.{ext}
Example: avatars/abc123/20260115_143022_x7k9.jpg
```

## Repository Interface

```dart
abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile();
  Future<Either<Failure, Profile>> updateDisplayName({required String displayName});
  Future<Either<Failure, Profile>> updateUsername({required String username});
  Future<Either<Failure, Profile>> updateInGameInfo({String? inGameName, String? inGameUid});
  Future<Either<Failure, Profile>> updatePrivacySettings({required String profileVisibility, required bool showInGameInfo});
  Future<Either<Failure, Profile>> updateNotificationPreferences({required Map<String, dynamic> prefs});
  Future<Either<Failure, Profile>> updateAvatar({required String avatarUrl});
}
```

## Use Cases

| Use Case | Description |
|---|---|
| GetProfileUseCase | Fetch current user's profile |
| UpdateProfileUseCase | Update multiple profile fields |
| UpdatePrivacySettingsUseCase | Update privacy settings |
| UpdateNotificationPreferencesUseCase | Update notification preferences |
| UpdateAvatarUseCase | Upload new avatar |
| DeleteAvatarUseCase | Remove avatar |

## Validation Rules

### Display Name
- Required
- 1-50 characters
- Trim whitespace
- No leading/trailing spaces
- Not empty after trim

### Username
- Optional
- If provided: 3-20 chars, alphanumeric + underscore
- Lowercase normalization
- Uniqueness check (case-insensitive)
- Reserved word check

### In-Game Name
- Optional
- Max 30 characters
- Trim whitespace

### In-Game UID
- Optional
- 8-12 digits only (`^\d{8,12}$`)
- Trim whitespace

### Privacy Settings
- Profile visibility: must be one of `public`, `organizers_only`, `private`
- Show in-game info: boolean

### Avatar
- Max 5MB
- JPEG, PNG, WebP
- Auto-resize to 512x512 max
- Convert to WebP for storage

## Error Codes

| Code | HTTP | Description |
|---|---|---|
| `PROFILE_NOT_FOUND` | 404 | Profile doesn't exist |
| `USERNAME_TAKEN` | 409 | Username already in use |
| `INVALID_USERNAME` | 400 | Username format invalid |
| `INVALID_IN_GAME_UID` | 400 | UID format invalid (8-12 digits) |
| `AVATAR_TOO_LARGE` | 413 | File exceeds 5MB |
| `AVATAR_INVALID_TYPE` | 400 | Must be JPEG, PNG, or WebP |
| `PRIVACY_INVALID` | 400 | Invalid privacy value |
| `NOT_AUTHORIZED` | 403 | Cannot modify other's profile |

## Testing

### Unit Tests
- Validation logic
- Privacy level comparisons
- Username normalization
- In-game UID validation

### Integration Tests
- Profile CRUD
- RLS enforcement
- Avatar upload/download
- Username uniqueness (race condition)
- Soft delete behavior

### Database Tests
- RLS policies
- Triggers (updated_at)
- Constraints (unique, check)
- Soft delete (deleted_at)

## Future Enhancements

- [ ] Profile badges / achievements
- [ ] Social links (Discord, Twitter, YouTube)
- [ ] Team history
- [ ] Tournament statistics
- [ ] Preferred roles (Attacker, Support, etc.)
- [ ] Language preference
- [ ] Timezone
- [ ] Two-factor auth status display
- [ ] Login history
- [ ] Connected accounts (Google, Apple)