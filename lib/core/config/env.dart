// ============================================================
// PASTE YOUR OWN GOOGLE OAUTH "ANDROID" CLIENT ID BELOW.
//
// Get it from: Google Cloud Console > APIs & Services > Credentials
//   1. Create OAuth client ID > Application type = Android
//   2. Package name = com.example.tube_flow (must match applicationId in
//      android/app/build.gradle.kts)
//   3. SHA-1 signing certificate fingerprint, e.g. for the debug keystore:
//      keytool -list -v -keystore ~/.android/debug.keystore \
//        -alias androiddebugkey -storepass android -keypass android
//
// This client type never has (or needs) a client secret — do not paste one
// here, and never commit one anywhere in this repo.
//
// Also make sure the OAuth consent screen's "Publishing status" is set to
// "In production" (not "Testing"). Testing-status apps get refresh tokens
// that silently expire after 7 days for restricted scopes such as
// `https://www.googleapis.com/auth/youtube`.
// ============================================================
const String kGoogleOAuthClientId =
    '45915931754-oggc6tn5ip85teautmh0g7v00s7frbds.apps.googleusercontent.com';

/// Must exactly match the `appAuthRedirectScheme` manifest placeholder set in
/// android/app/build.gradle.kts, and the applicationId if that ever changes.
const String kOAuthRedirectScheme = 'com.example.tube_flow';

const String kOAuthRedirectUri = '$kOAuthRedirectScheme:/oauth2redirect';
