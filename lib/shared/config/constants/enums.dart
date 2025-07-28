/// Login methods enum
enum LoginMode {
  google,
  apple,
  phone,
  email,
}

/// Entity types enum  
enum Entity {
  agent,
  customer,
  business,
}

/// Payment methods enum
enum PaymentMethods {
  card,
  upi,
  wallet,
  cash,
}

/// Next action after splash enum
enum NextAction {
  showOnboarding,
  showAuth, 
  showHome,
  showAgentDashboard,
  showBusinessSetup,
  showVerification,
}

/// Theme mode enum
enum ThemeMode {
  light,
  dark,
  system,
} 