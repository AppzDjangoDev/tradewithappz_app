import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart'; // For debugging purposes
import 'package:slide_action/slide_action.dart';
import 'package:slider_button/slider_button.dart';

class OptionChainView extends StatelessWidget {
  const OptionChainView({
    super.key,
    required this.cardInfos,
    required this.carouselHeight,
    required this.listTileHeight,
    required this.carouselWidth,
  });

  final List<CardInfo> cardInfos;
  final double carouselHeight;
  final double listTileHeight;
  final double carouselWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1618123069754-cd64c230a169?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmxhY2slMjB0ZXh0dXJlfGVufDB8fDB8fHww'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          Column(
            children: <Widget>[
              // Add padding to the top of the carousel
              const SizedBox(height:125),
              CarouselExample(
                  cardInfos: cardInfos,
                  height: carouselHeight,
                ),
          
              SizedBox(height: 10), // Adjust height as needed
              Expanded(
                child: SpacedItemsList(
                  listTileHeight: listTileHeight,
                  carouselWidth: carouselWidth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CarouselExample extends StatelessWidget {
  const CarouselExample({
    super.key,
    required this.cardInfos,
    required this.height,
  });

  final List<CardInfo> cardInfos;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: height, // Use the dynamic height
        viewportFraction: 0.95,
        enlargeCenterPage: true,
      ),
      items: cardInfos.map((CardInfo info) {
        return Builder(
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: HeroLayoutCard(cardInfo: info),
            );
          },
        );
      }).toList(),
    );
  }
}

class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({
    super.key,
    required this.cardInfo,
  });

  final CardInfo cardInfo;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.95,
      color: Color.fromARGB(243, 9, 9, 9), // Define the color for consistency
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              cardInfo.title,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 3),
            Text(
              cardInfo.subtitle,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class SpacedItemsList extends StatelessWidget {
  const SpacedItemsList({
    super.key,
    required this.listTileHeight,
    required this.carouselWidth,
  });

  final double listTileHeight;
  final double carouselWidth;

  @override
  Widget build(BuildContext context) {
    const items = 8;

    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          items,
          (index) => Container(
            width: carouselWidth,
            margin: const EdgeInsets.symmetric(vertical: 0.1),
            child: ItemWidget(
              text: 'Strike ${index + 1}',
              height: listTileHeight,
            ),
          ),
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.text,
    required this.height,
  });

  final String text;
  final double height;

  @override
  Widget build(BuildContext context) {
    final AudioPlayer _player = AudioPlayer();

    void _playTapSound() async {
      try {
        await _player.setAudioSource(AudioSource.uri(
          Uri.parse('https://example.com/tap_sound.mp3'), // Replace with your audio URL
        ));
        _player.play();
      } catch (e) {
        if (kDebugMode) {
          print('Error loading audio source: $e');
        }
      }
    }

    final double buttonHeight = height * 0.8; // Adjust fraction as needed
    final double buttonWidth = 130; // Adjust width for buttons

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Color.fromARGB(243, 9, 9, 9), // Define the color for consistency
        elevation: 0, // Remove shadow
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.9), // Semi-transparent green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _playTapSound();
                    // Add Buy button action here
                  },
                  child: const Text(
                    'Buy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9), // Semi-transparent blue
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.9), // Semi-transparent red
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _playTapSound();
                    // Add Sell button action here
                  },
                  child: const Text(
                    'Sell',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum CardInfo {
  dashBoard(' Dashboard', 'Dashboard Overview status'),
  midcpnifty(' MIDCPNIFTY', 'Running : 42000'),
  finnifty(' FINNIFTY', 'Running : 34000'),
  bankNifty(' BANK NIFTY', 'Running : 52000'),
  nifty(' NIFTY', 'Running : 16000'),
  portfolio('Portfolio : 25000', 'order Qty : 10');

  const CardInfo(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

const dashBoardCardInfo = [
  CardInfo.dashBoard,
  CardInfo.portfolio,
];

const midcpNiftyCardInfo = [
  CardInfo.midcpnifty,
  CardInfo.portfolio,
];

const finniftyCardInfo = [
  CardInfo.finnifty,
  CardInfo.portfolio,
];

const bankNiftyCardInfo = [
  CardInfo.bankNifty,
  CardInfo.portfolio,
];

const niftyCardInfo = [
  CardInfo.nifty,
  CardInfo.portfolio,
];

const controlsCardInfo = [
  CardInfo.portfolio,
];
