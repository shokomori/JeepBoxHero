enum CustomerPersonality {
  nostalgic,
  enthusiastic,
  mysterious,
  scholarly,
  shy,
  demanding,
}

class CustomerData {
  final String id;
  final String name;
  final String spriteAsset;
  final CustomerPersonality personality;
  final String intro;
  final String requestDialogue;
  final String requestedAlbumId;
  final String afterPurchaseDialogue;
  final String backstory;

  const CustomerData({
    required this.id,
    required this.name,
    required this.spriteAsset,
    required this.personality,
    required this.intro,
    required this.requestDialogue,
    required this.requestedAlbumId,
    required this.afterPurchaseDialogue,
    required this.backstory,
  });
}

// Sample customers
class CustomerDatabase {
  static final List<CustomerData> customers = [
    const CustomerData(
      id: 'aling_fe',
      name: 'Aling Fe',
      spriteAsset: 'assets/customers/aling_fe.png',
      personality: CustomerPersonality.nostalgic,
      intro: 'Magandang hapon! Ay, ang tagal ko nang hindi nakapasok dito...',
      requestDialogue:
          'May hinahanap ako... yung Circus ng Eraserheads. Pampaalala sa kabataan ko.',
      requestedAlbumId: 'eraserheads_circus',
      afterPurchaseDialogue:
          'Salamat, anak. Maririnig ko na ulit ang "Alapaap" sa bahay.',
      backstory:
          'A retired teacher who grew up during martial law. Music was her escape.',
    ),
    const CustomerData(
      id: 'mc_luwalhati',
      name: 'MC Luwalhati',
      spriteAsset: 'assets/customers/mc_luwalhati.png',
      personality: CustomerPersonality.enthusiastic,
      intro: 'Yo! Fresh beats lang ang hanap ko dito, boss.',
      requestDialogue:
          'May Rivermaya ba kayong Trip? Classic yan, pre. Inspiration ko yan sa mga lyrics.',
      requestedAlbumId: 'rivermaya_trip',
      afterPurchaseDialogue:
          'Solid! Salamat, idol. Sige, may susulatin pa akong bars.',
      backstory:
          'An underground rapper from Quezon City. Fuses OPM rock with hip-hop.',
    ),
    const CustomerData(
      id: 'noir_delubyo',
      name: 'Noir Delubyo',
      spriteAsset: 'assets/customers/noir.png',
      personality: CustomerPersonality.mysterious,
      intro: '...Hi. Do you have anything melancholic?',
      requestDialogue: 'I need something... emotional. Eraserheads, maybe?',
      requestedAlbumId: 'eraserheads_circus',
      afterPurchaseDialogue: '*nods silently and leaves*',
      backstory: 'A goth artist who paints to OPM. Prefers rainy day albums.',
    ),
  ];

  static CustomerData? getById(String id) {
    try {
      return customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  static CustomerData getRandomCustomer() {
    customers.shuffle();
    return customers.first;
  }
}
