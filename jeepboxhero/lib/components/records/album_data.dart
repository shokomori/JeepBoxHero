class AlbumData {
  final String id;
  final String title;
  final String artist;
  final String coverAsset;
  final String genre;
  final double price;
  final String description;
  final String artistBio;
  final List<String> trackList;
  final List<Review> reviews;
  final int releaseYear;

  const AlbumData({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverAsset,
    required this.genre,
    required this.price,
    required this.description,
    required this.artistBio,
    required this.trackList,
    required this.reviews,
    required this.releaseYear,
  });
}

class Review {
  final String reviewer;
  final String text;
  final int rating; // out of 5

  const Review({
    required this.reviewer,
    required this.text,
    required this.rating,
  });
}

// Sample OPM albums (you'll expand this with your data)
class AlbumDatabase {
  static final List<AlbumData> albums = [
    AlbumData(
      id: 'eraserheads_circus',
      title: 'Circus',
      artist: 'Eraserheads',
      coverAsset: 'assets/albums/circus.png',
      genre: 'Pinoy Rock',
      price: 450.00,
      description:
          'The sophomore album that cemented the Eraserheads as OPM legends.',
      artistBio:
          'Eraserheads is a Filipino rock band formed in 1989. Often called "The Beatles of the Philippines".',
      releaseYear: 1994,
      trackList: [
        'Circus',
        'Kailan',
        'Magasin',
        'Ligaya',
        'Sembreak',
        'Alapaap',
        'Kaliwete',
        'Troopa',
        'Harana',
        'Sirena',
      ],
      reviews: [
        Review(
          reviewer: 'Manila Sound Archives',
          text:
              'A masterpiece that defined 90s Filipino youth culture. Every track is a gem.',
          rating: 5,
        ),
        Review(
          reviewer: 'Kabataang Pinoy Zine',
          text: 'Alapaap alone makes this album worth it. Timeless.',
          rating: 5,
        ),
      ],
    ),
    AlbumData(
      id: 'rivermaya_trip',
      title: 'Trip',
      artist: 'Rivermaya',
      coverAsset: 'assets/albums/trip.png',
      genre: 'Pinoy Rock',
      price: 420.00,
      description:
          'Raw, energetic debut from one of the most influential Filipino bands.',
      artistBio:
          'Rivermaya formed in 1994 and became one of the biggest rock acts in the Philippines.',
      releaseYear: 1996,
      trackList: ['Ulan', 'Kisapmata', 'Awit ng Kabataan', '214', 'Himala'],
      reviews: [
        Review(
          reviewer: 'Rock Pilipinas',
          text: 'Kisapmata is an eternal anthem. This album never gets old.',
          rating: 5,
        ),
      ],
    ),
  ];

  static AlbumData? getById(String id) {
    try {
      return albums.firstWhere((album) => album.id == id);
    } catch (e) {
      return null;
    }
  }
}
