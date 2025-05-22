import 'package:flutter/material.dart';
import 'package:mcc_frontend/pages/item_page.dart';
import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  final String username;
  final int userID;
  const HomePage({Key? key, required this.username, required this.userID})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDarkTheme = true;
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final PageController _bottomPageController =
      PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  int _bottomCurrentPage = 0;

  final List<String> _carouselImages = [
    'caro-pizza1.jpeg',
    'caro-pizza2.jpeg',
    'caro-pizza3.jpeg',
    'caro-pizza4.jpeg',
  ];

  final List<String> _bottomCarouselImages = [
    'baro-pizza1.jpeg',
    'baro-pizza2.jpeg',
    'baro-pizza3.jpeg',
    'baro-pizza4.jpeg',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _bottomPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isDarkTheme ? Colors.black : Colors.white;
    final appBarColor = _isDarkTheme ? Colors.black : Colors.white;
    final containerColor =
        _isDarkTheme ? const Color(0xFF242424) : Colors.grey.shade200;
    final buttonColor =
        _isDarkTheme ? const Color(0xFF131313) : Colors.grey.shade300;
    final textColor = _isDarkTheme ? Colors.white : Colors.black87;
    final secondaryTextColor = _isDarkTheme ? Colors.grey[300] : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: PopupMenuButton<String>(
          onSelected: (String value) {
            setState(() {
              if (value == 'logout') {
                Navigator.of(context).pushReplacementNamed('/login');
              } else if (value == 'toggle_theme') {
                _isDarkTheme = !_isDarkTheme;
              } else if (value == 'view_pizza') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AllProductsPage(
                      username: widget.username,
                      isDarkTheme: _isDarkTheme,
                      userID: widget.userID,
                    ),
                  ),
                );
              }
            });
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: 'toggle_theme',
                child: Text(_isDarkTheme ? 'Light Theme' : 'Dark Theme'),
              ),
              PopupMenuItem(
                value: 'view_pizza',
                child: Text('View All Products'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ];
          },
        ),
        backgroundColor: Color.fromARGB(255, 39, 39, 39),
        elevation: 0,
      ),
      
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Text('Hello, ${widget.username}',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _carouselImages.length,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = _pageController.page! - index;
                              value =
                                  (1 - (value.abs() * 0.25)).clamp(0.8, 1.0);
                            }
                            return Center(
                              child: Transform.scale(
                                scale: Curves.easeOut.transform(value),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(15.0),
                              image: DecorationImage(
                                image: AssetImage(_carouselImages[index]),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _carouselImages.map((url) {
                      int index = _carouselImages.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? textColor
                              : textColor.withOpacity(0.3),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'About DJ Pizza',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('background1.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Card(
                      color: Colors
                          .transparent, // Make card background transparent
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DJ Pizza is a company that provides pizza ordering services with various choices of toppings and sizes',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Offering fresh pizza made with local ingredients. Fast delivery service and easy-to-use online ordering system make it the top choice for customers',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Our New Event',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _bottomPageController,
                      onPageChanged: (int index) {
                        setState(() {
                          _bottomCurrentPage = index;
                        });
                      },
                      itemCount: _bottomCarouselImages.length,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _bottomPageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_bottomPageController.position.haveDimensions) {
                              value = _bottomPageController.page! - index;
                              value =
                                  (1 - (value.abs() * 0.25)).clamp(0.8, 1.0);
                            }
                            return Center(
                              child: Transform.scale(
                                scale: Curves.easeOut.transform(value),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(15.0),
                              image: DecorationImage(
                                image: AssetImage(_bottomCarouselImages[index]),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _bottomCarouselImages.map((url) {
                      int index = _bottomCarouselImages.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _bottomCurrentPage == index
                              ? textColor
                              : textColor.withOpacity(0.3),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
