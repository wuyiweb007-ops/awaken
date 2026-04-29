/// 隐私政策在 App Store Connect 中填写的**公开 URL** 应与之一致。
/// 在构建时可传入，例如：
/// `flutter build ipa --dart-define=PRIVACY_POLICY_URL=https://example.com/privacy`
const String kPrivacyPolicyUrl = String.fromEnvironment(
  'PRIVACY_POLICY_URL',
  defaultValue: '',
);
