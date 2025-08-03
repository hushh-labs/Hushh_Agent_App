class AppRoutes {
  // Authentication routes
  static const String mainAuth = '/main-auth';
  static const String emailVerification = '/email-verification';

  // Auth Flow routes (for profile creation)
  static const String authName = '/auth-name';
  static const String authEmail = '/auth-email';
  static const String authCategories = '/auth-categories';
  static const String authBrands = '/auth-brands';
  static const String authCardCreated = '/auth-card-created';

  // App routes
  static const String splash = '/splash';
  static const String home = '/home';

  // Agent Profile Flow routes (keeping for backward compatibility)
  static const String agentProfileEmail = '/agent-profile-email';
  static const String agentProfileName = '/agent-profile-name';
  static const String agentProfileCategories = '/agent-profile-categories';
  static const String agentProfileBrands = '/agent-profile-brands';
  static const String agentCardCreated = '/agent-card-created';

  // Lookbooks & Products routes
  static const String agentLookbook = '/agent-lookbook';
  static const String createLookbook = '/create-lookbook';
  static const String agentProducts = '/agent-products';

  // Profile & Settings routes
  static const String permissions = '/permissions';

  // Notification Bidding routes
  static const String notificationBidding = '/notification-bidding';
}
