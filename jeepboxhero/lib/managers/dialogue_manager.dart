class DialogueManager {
  static final List<String> randomGreetings = [
    'Kumusta! Welcome to Jeep Box Records.',
    'Magandang araw! Looking for something special?',
    'Hey there! First time sa shop?',
    'Welcome! We have the best OPM selection in Cubao.',
  ];

  static final List<String> randomFarewells = [
    'Salamat! Come back soon!',
    'Thank you for your patronage!',
    'Sige, ingat! See you next time.',
    'Enjoy the music! Balik ka ha?',
  ];

  static String getRandomGreeting() {
    randomGreetings.shuffle();
    return randomGreetings.first;
  }

  static String getRandomFarewell() {
    randomFarewells.shuffle();
    return randomFarewells.first;
  }

  static String getHelpText(String topic) {
    switch (topic.toLowerCase()) {
      case 'navigation':
        return 'Click on any album to view details. Use the cart button to see your selections!';
      case 'checkout':
        return 'When ready, open your cart and click checkout. You\'ll write the receipt by hand!';
      case 'customers':
        return 'Each customer has a story. Take time to read their dialogues!';
      default:
        return 'Need help? Just explore and click around!';
    }
  }
}
