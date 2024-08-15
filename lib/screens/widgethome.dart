import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_log.dart'; // Import the AppLog model

class WidgetHome extends StatelessWidget {
  const WidgetHome({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;
    final double availableHeight = screenHeight - appBarHeight;

    final double carouselHeight = availableHeight * 0.178; // 20% of available height for carousel
    final double cardHeight = (availableHeight - carouselHeight) / 5; // Remaining height divided by 4 rows

    // Calculate card width to match the carousel width
    final double cardWidth = screenWidth * 0.45; // 45% of the screen width for cards

    // Build carousel items with latest date
    return FutureBuilder<String>(
      future: fetchLatestDate(), // Fetch the latest date
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error fetching date')),
          );
        }

        final latestDate = snapshot.data ?? 'No Data';

        final List<Widget> carouselItems = [
          _buildCarouselItem(latestDate, Colors.blue),
          _buildCarouselItem('Overview 2', Colors.green),
          _buildCarouselItem('Overview 3', Colors.orange),
        ];

        return Scaffold(
          body: Column(
            children: [
              // Carousel Slider
              Container(
                height: carouselHeight,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: carouselHeight,
                    viewportFraction: 0.95,
                    enlargeCenterPage: true,
                    autoPlay: false, // Disable automatic scrolling
                    enableInfiniteScroll: false, // Optional: Disable infinite scroll
                  ),
                  items: carouselItems,
                ),
              ),
              const SizedBox(height: 5),
              // GridView of Dashboard Cards
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: cardWidth / cardHeight, // Adjust aspect ratio based on card dimensions
                  ),
                  itemCount: 8, // Updated to reflect 8 cards
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: cardWidth, // Set the width of the card
                      height: cardHeight,
                      child: DashboardCard(index: index),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<String> fetchLatestDate() async {
    final box = await Hive.openBox<AppLog>('app_log_box');
    final latestEntry = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date in descending order
    if (latestEntry.isNotEmpty) {
      final latestDate = latestEntry.first.date;
      return '${latestDate.year}-${latestDate.month.toString().padLeft(2, '0')}-${latestDate.day.toString().padLeft(2, '0')}';
    }
    return 'No Data'; // Return a placeholder if no data is found
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    // Gradient colors for the cards
    final gradients = [
      LinearGradient(
        colors: [Colors.blue.shade700, Colors.blue.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.green.shade700, Colors.green.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.orange.shade700, Colors.orange.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.red.shade700, Colors.red.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.purple.shade700, Colors.purple.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.teal.shade700, Colors.teal.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // Adding two new gradients
      LinearGradient(
        colors: [Colors.cyan.shade700, Colors.cyan.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.indigo.shade700, Colors.indigo.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];

    final titles = [
      'Profit Status',
      'Loss Status',
      'Revenue',
      'Expenses',
      'Investments',
      'Savings',
      'Growth',
      'Targets',
    ];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradients[index],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.bar_chart,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                titles[index],
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Details here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
