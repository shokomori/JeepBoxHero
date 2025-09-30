class GameConstants {
  // Colors
  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color secondaryColor = Color(0xFF3498DB);
  static const Color accentColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color backgroundColor = Color(0xFFFFF8E7);
  
  // Timing
  static const double dialogueCharDelay = 0.03;
  static const double customerSpawnDelay = 3.0;
  static const double notificationDuration = 2.0;
  
  // Layout
  static const double recordWidth = 120.0;
  static const double recordHeight = 180.0;
  static const int recordsPerRow = 4;
  
  // Prices (for random generation if needed)
  static const double minPrice = 350.0;
  static const double maxPrice = 650.0;
  
  // Game progression
  static const int customersPerDay = 5;
  static const int daysToComplete = 7;
}

// ============================================
// Example: Adding more OPM albums to database
// ============================================
/*
Add these to AlbumDatabase.albums list:

AlbumData(
  id: 'apo_hiking_society_greatest',
  title: 'Greatest Hits',
  artist: 'APO Hiking Society',
  coverAsset: 'assets/albums/apo_greatest.png',
  genre: 'OPM Pop',
  price: 480.00,
  description: 'Timeless classics from the legendary trio.',
  artistBio: 'APO Hiking Society is one of the most beloved Filipino musical groups.',
  releaseYear: 1991,
  trackList: [
    'Panalangin',
    'Batang-Bata Ka Pa',
    'Ewan',
    'Pumapatak ang Ulan',
  ],
  reviews: [
    Review(
      reviewer: 'Nostalgia FM',
      text: 'These songs defined Filipino childhoods. Essential listening.',
      rating: 5,
    ),
  ],
),

AlbumData(
  id: 'bamboo_light_peace_love',
  title: 'Light Peace Love',
  artist: 'Bamboo',
  coverAsset: 'assets/albums/bamboo_lpl.png',
  genre: 'Pinoy Rock',
  price: 420.00,
  description: 'Powerful rock anthems from Bamboo Mañalac.',
  artistBio: 'Bamboo brought raw energy to OPM rock in the 2000s.',
  releaseYear: 2005,
  trackList: [
    'Noypi',
    'Hallelujah',
    'Much Has Been Said',
  ],
  reviews: [
    Review(
      reviewer: 'Rock Republika',
      text: 'Noypi is THE Filipino pride anthem. Goosebumps every time.',
      rating: 5,
    ),
  ],
),