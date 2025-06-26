import 'package:flutter/material.dart';
import 'package:watch_hub_ep/widgets/testimonial_widget.dart';
import '../../widgets/section_title.dart';
import '../../widgets/collection_card.dart';
import '../../widgets/watch_tile.dart';
import '../../widgets/app_header.dart';
import '../../widgets/nav_drawer.dart';
import '../../widgets/single_video_banner.dart';
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

              const SingleVideoBanner(
                videoUrl:
                    'https://media.rolex.com/video/upload/c_limit,w_2880/f_auto:video/q_auto:eco/v1/rolexcom/new-watches/2025/hub/videos/autoplay/cover/rolex-watches-new-watches-2025-cover-autoplay',
              ),
              const SizedBox(height: 32),

              SectionTitle(
                title: 'Collection 1',
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
                      imageUrl: 'https://i.ibb.co/rGjKLnc2/watch-4.png',
                      model: 'GMT-MASTER II',
                      description: 'The Cosmopolitan Watch',
                      price: '2,995',
                    ),
                    SizedBox(width: 16),
                    CollectionCard(
                      imageUrl: 'https://i.ibb.co/5gW477z2/watch-3.png',
                      model: 'SUBMARINER',
                      description: 'Iconic Diver’s Watch',
                      price: '4,250',
                    ),
                    SizedBox(width: 16),
                    CollectionCard(
                      imageUrl: 'https://i.ibb.co/kVZrPm5J/watch-1.png',
                      model: 'OYSTER PERPETUAL',
                      description: 'Bold & Elegant',
                      price: '5,800',
                    ),
                    SizedBox(width: 16),
                    CollectionCard(
                      imageUrl: 'https://i.ibb.co/pjt3TJnw/watch-2.png',
                      model: 'OYSTER PERPETUAL',
                      description: 'Bold & Elegant',
                      price: '5,800',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const SectionTitle(title: 'List Collection'),
              const SizedBox(height: 12),

              WatchTile(
                imageUrl: 'https://i.ibb.co/rGjKLnc2/watch-4.png',
                title: 'Rolex Submariner',
                description: 'Classic diving watch with timeless style.',
                originalPrice: 2999.99,
                discountPercentage: 20,
              ),
              WatchTile(
                imageUrl: 'https://i.ibb.co/kVZrPm5J/watch-1.png',
                title: 'Rolex Submariner',
                description: 'Classic diving watch with timeless style.',
                originalPrice: 2999.99,
                discountPercentage: 10,
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
                title: 'Collection 2',
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
                          const SizedBox(height: 32),
TestimonialCarousel(
  testimonials: [
    Testimonial(
      imageUrl: 'https://images.unsplash.com/photo-1606736739929-b369d6faabdb?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      testimonial: 'WatchHub has the most elegant collection I\'ve seen. The luxury is unmatched!',
      name: 'Ayaan Malik',
      occupation: 'Fashion Blogger',
    ),
    Testimonial(
      imageUrl: 'https://images.unsplash.com/photo-1606736739929-b369d6faabdb?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      testimonial: 'A perfect platform to explore timeless watches. I loved the whole experience!',
      name: 'Sarah Khan',
      occupation: 'Entrepreneur',
    ),
    Testimonial(
      imageUrl: 'https://images.unsplash.com/photo-1606736739929-b369d6faabdb?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      testimonial: 'Premium service and unmatched quality! Highly recommended.',
      name: 'Usman Tariq',
      occupation: 'Luxury Consultant',
    ),
  ],
),
const SizedBox(height: 32),

            ],
          ),
        ),
      ),
    );
  }
}
