class UnboardingContent {
  String image;
  String title;
  String description;
  UnboardingContent(
    {required this.description, required this.image, required this.title});
}

List<UnboardingContent> contents = [
  UnboardingContent(
    description: 'Discover an exciting way to cast your\n    vote and celebrate your favorites!',
    image: "images/screen1.jpg",
    title: 'Welcome to UCSTT 2024-2025\n         King & Queen Voting!',
  ),
  UnboardingContent(
    description:'  Browse through the nominees and\nsupport the ones you believe deserve\n       the crown. Every vote counts!',
    image: "images/screen2.jpg",
    title: 'Choose Your Favourite!',
  ),
  UnboardingContent(
    description: '    Enjoy a smooth and secure voting \nexperience and view real-time results.',
    image: "images/screen3.jpg",
    title: 'Safe & Simple Voting Process\n                 Live Result',
  ),
];