class Constants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
  
  // Local Storage Keys
  static const String userBox = 'user_box';
  static const String userDataKey = 'user_data';
  static const String offlineQueueKey = 'offline_queue';
  
  // API Endpoints
  static const String baseUrl = 'https://api.posmap.com';
  
  // Tier Definitions
  static const List<String> tiers = ['Tier 1', 'Tier 2', 'Tier 3'];
  
  // POS Terminal Options
  static const List<int> terminalCount = [1, 2, 3];
  
  // Nigerian Banks
  static const List<String> banks = [
    'GT Bank',
    'Access Bank',
    'UBA',
    'First Bank',
    'Zenith Bank',
    'Ecobank',
    'Fidelity Bank',
    'Sterling Bank',
    'Keystone Bank',
    'Polaris Bank',
    'Heritage Bank',
    'Union Bank',
    'Standard Chartered',
    'First City Monument Bank',
    'ProvidusBank',
    'Parallex Bank',
    'SunTrust Bank',
    'Titan Trust Bank',
    'Opay',
    'Palmpay',
    'Kuda Bank',
    'Jaiz Bank',
    'Mint Finex',
    'Sparkle Bank',
    'VFD Microfinance Bank'
  ];
  
  // Nigerian LGAs (sample list)
  static const List<String> lgas = [
    'Lagos Mainland',
    'Lagos Island',
    'Surulere',
    'Ikoyi',
    'Eti Osa',
    'Alimosho',
    'Badagry',
    'Apapa',
    'Amuwo Odofin',
    'Oshodi Isolo',
    'Kosofe',
    'Mushin',
    'Agege',
    'Ifako-Ijaiye',
    'Ikeja',
    'Somolu',
    'Ikorodu',
    'Epe',
    'Ibeju-Lekki',
    'Shomolu'
  ];
}