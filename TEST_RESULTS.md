# Hwork SSO Plugin - Test Results & Issues

**Test Date:** 2026-02-17 14:45  
**Token Expiry:** 2026-02-17 16:35:30 +0800  
**Status:** ✅ Core functionality working

## Test Results Summary

| Test | Status | Notes |
|------|--------|-------|
| Plugin Loading | ✅ | Plugin enabled and loaded correctly |
| SSO Endpoint (no token) | ✅ | Correctly returns error |
| SSO Endpoint (with token) | ✅ | Returns HTML with localStorage script |
| Hwork API Authentication | ✅ | Successfully authenticates and retrieves user info |
| User Creation/Update | ✅ | User created/updated with correct data |
| Route Configuration | ✅ | Route `/hwork-sso` configured correctly |
| API Token Header Auth | ⚠️ | Requires server restart |

## Successful Authentication

```
User ID: 1
Username: 20015536
Name: 王斌
Email: wangbin.psi@haier.com
Active: true
Approved: true
Trust Level: 1
```

## Issues Found & Fixed

### Issue 1: Username Format ✅ FIXED
**Problem:** Username was prefixed with "user_" (e.g., "user_20015536")  
**Fix:** Changed to use user_id directly (e.g., "20015536")  
**File:** `lib/hwork_token_authenticator.rb`

```ruby
# Before
username = "user_#{user_info[:user_id]}"

# After
username = user_info[:user_id]
```

### Issue 2: Name Not Updated on Existing Users ✅ FIXED
**Problem:** When user already exists, name wasn't updated from Hwork API  
**Fix:** Update name when finding existing user  
**File:** `lib/hwork_token_authenticator.rb`

```ruby
# Added name update for existing users
user = User.find_by(username: username)
if user
  user.update(name: user_info[:user_name]) if user_info[:user_name].present?
  return user
end
```

### Issue 3: API Token Authentication Not Active ⚠️ NEEDS SERVER RESTART
**Problem:** X-System-Token header not authenticating API requests  
**Cause:** Server needs restart to load CurrentUserProvider changes  
**Solution:** Restart Rails server

```bash
# Stop server
lsof -ti:3000 | xargs kill -9

# Start server
cd /Users/robin/Study/bbs/discourse
bin/rails s -p 3000
```

## Testing the Complete Flow

### Method 1: Using Test Page
1. Visit: http://localhost:4200/plugins/discourse-robin-sso/test.html
2. Paste JWT token:
   ```
   eyJ0eXAiOiJqd3QiLCJhbGciOiJSUzI1NiIsImtpZCI6InprMk5kSCJ9...
   ```
3. Click "测试 SSO 登录"
4. Should redirect to homepage with user logged in

### Method 2: Direct URL
Visit:
```
http://localhost:4200/hwork-sso?token=eyJ0eXAiOiJqd3QiLCJhbGciOiJSUzI1NiIsImtpZCI6InprMk5kSCJ9...
```

### Method 3: API Request
```bash
TOKEN="eyJ0eXAiOiJqd3QiLCJhbGciOiJSUzI1NiIsImtpZCI6InprMk5kSCJ9..."
curl -H "X-System-Token: $TOKEN" http://localhost:3000/site.json | jq '.current_user'
```

## JWT Token Details

```json
{
  "sub": "20015536",
  "aud": "login",
  "iss": "hwork-pre",
  "USER": "20015536",
  "USER-ROLE": "open_op_developer",
  "USER-ROLE-NAME": "平台开发者",
  "iat": 1771310130,
  "exp": 1771317330
}
```

**Expiry:** 2026-02-17 16:35:30 +0800 (valid for ~2 hours from issue time)

## Plugin Architecture

### Flow Diagram
```
1. User visits /hwork-sso?token=XXX
   ↓
2. HworkSsoController#login
   - Validates token presence
   - Returns HTML with localStorage script
   ↓
3. Browser executes script
   - Stores token in localStorage
   - Redirects to homepage
   ↓
4. Frontend initializer (hwork-sso.js)
   - Intercepts all AJAX requests
   - Adds X-System-Token header
   ↓
5. Backend CurrentUserProvider
   - Reads X-System-Token header
   - Calls HworkTokenAuthenticator.authenticate
   ↓
6. HworkTokenAuthenticator
   - Calls Hwork API to verify token
   - Caches result for 5 minutes
   - Finds or creates user
   ↓
7. User authenticated
```

### Key Files

1. **plugin.rb** - Plugin definition and initialization
2. **app/controllers/hwork_sso_controller.rb** - SSO endpoint
3. **lib/hwork_token_authenticator.rb** - Token validation and user management
4. **assets/javascripts/discourse/initializers/hwork-sso.js** - Frontend token injection
5. **public/test.html** - Test page

## Performance Considerations

### Token Caching
- Cache duration: 5 minutes
- Cache key: SHA256 hash of token
- Reduces API calls to Hwork

### API Timeout
- Connection timeout: 5 seconds
- Read timeout: 5 seconds
- Prevents hanging requests

## Security Features

1. **Token Validation:** Every request validates token with Hwork API
2. **HTTPS:** Hwork API uses HTTPS
3. **Error Handling:** All exceptions caught and logged
4. **Strong Passwords:** Generated with SecureRandom.hex(32)
5. **CSRF Protection:** Disabled only for login endpoint

## Monitoring

### Check Logs
```bash
# Real-time monitoring
tail -f log/development.log | grep -i "hwork\|error"

# Check recent errors
tail -100 log/development.log | grep -i error
```

### Key Metrics to Monitor
- SSO login success rate
- Hwork API response time
- Token cache hit rate
- User creation failures

## Next Steps

1. ✅ Fix username format
2. ✅ Fix name update for existing users
3. ⏳ Restart server to enable API token auth
4. ⏳ Test complete flow in browser
5. ⏳ Verify frontend token injection
6. ⏳ Test API requests with token
7. ⏳ Write automated tests

## Known Limitations

1. **Token Expiry:** Tokens expire after ~2 hours, no automatic refresh
2. **No Logout:** No mechanism to invalidate tokens on logout
3. **Cache Invalidation:** Token cache persists for 5 minutes even if revoked
4. **Single Sign-Out:** No SSO logout support

## Recommendations

### For Production
1. Add token refresh mechanism
2. Implement SSO logout
3. Add monitoring and alerting
4. Set up error tracking (e.g., Sentry)
5. Add rate limiting for SSO endpoint
6. Consider shorter cache duration for production

### For Testing
1. Create automated test suite (RSpec)
2. Add integration tests for full flow
3. Test token expiry handling
4. Test error scenarios (API down, invalid token, etc.)

## Support

For issues or questions:
- Check logs: `tail -f log/development.log`
- Run test script: `./test_plugin.sh`
- Review documentation in plugin directory

## Changelog

### 2026-02-17
- ✅ Fixed username format (removed "user_" prefix)
- ✅ Added name update for existing users
- ✅ Verified Hwork API integration
- ✅ Confirmed token validation working
- ✅ Created comprehensive test script
