import 'package:flutter/material.dart';
import '../../widgets/section_title.dart';
import '../../widgets/collection_card.dart';
import '../../widgets/watch_tile.dart';
import '../../widgets/app_header.dart';
import '../../widgets/nav_drawer.dart';
import '../../widgets/carousel_widget.dart';
import '../../widgets/infinite_brands_scroller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavDrawer(),
      appBar: const AppHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              CarouselWidget(
                items: [
                  CarouselItem(
                    imageUrl:
                        'https://images.unsplash.com/photo-1589988599196-6bacb4f694b0?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    title: 'Luxury at its Finest',
                  ),
                  CarouselItem(
                    imageUrl:
                        'https://images.unsplash.com/photo-1684297476376-8badc0335c63?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    title: 'Timeless Elegance',
                  ),
                  CarouselItem(
                    imageUrl:
                        'https://images.unsplash.com/photo-1589988599196-6bacb4f694b0?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    title: 'Timeless Elegance',
                  ),
                ],
              ),

              const SizedBox(height: 32),

              InfiniteBrandsScroller(
                brandImageUrls: [
                  'https://images.unsplash.com/photo-1684297476376-8badc0335c63?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  'https://images.unsplash.com/photo-1574607304075-f7f22632aa64?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                ],
              ),

              const SizedBox(height: 32),

              SectionTitle(
                title: 'Prime Collection',
                action: 'See all',
                onActionTap: () {},
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 300,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    CollectionCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1589988599196-6bacb4f694b0?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      model: 'GMT-MASTER II',
                      description: 'The Cosmopolitan Watch',
                      price: '2,995',
                    ),
                    SizedBox(width: 16),
                    CollectionCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1684297476376-8badc0335c63?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      model: 'SUBMARINER',
                      description: 'Iconic Diver’s Watch',
                      price: '4,250',
                    ),
                    SizedBox(width: 16),
                    CollectionCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1606736739929-b369d6faabdb?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      model: 'OYSTER PERPETUAL',
                      description: 'Bold & Elegant',
                      price: '5,800',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const SectionTitle(title: 'New Arrivals'),
              const SizedBox(height: 12),

              const WatchTile(
                imageUrl:
                    'https://images.unsplash.com/photo-1582150264904-e0bea5ef0ad1?fm=jpg&q=60&w=200&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8d3Jpc3R3YXRjaHxlbnwwfHwwfHx8MA%3D%3D',
                title: 'YACHT MASTER 42',
                description: 'Glowing with new brilliance',
                price: '101,999',
              ),
              const SizedBox(height: 32),
              const WatchTile(
                imageUrl:
                    'https://images.unsplash.com/photo-1697119858836-fc3a742b68e0?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                title: 'SEA-DWELLER',
                description: 'Adventure Ready',
                price: '75,000',
              ),
              const SizedBox(height: 32),
              const WatchTile(
                imageUrl:
                    'https://images.unsplash.com/photo-1629581515634-0b0980b5b79b?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                title: 'EXPLORER II',
                description: 'Ready to conquer extremes',
                price: '67,500',
              ),
              const SizedBox(height: 32),
              const WatchTile(
                imageUrl:
                    'https://images.unsplash.com/photo-1574607304075-f7f22632aa64?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                title: 'COSMOGRAPH DAYTONA',
                description: 'Precision and legacy',
                price: '89,999',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
