import 'package:flutter/material.dart';
import '../../widgets/section_title.dart';
import '../../widgets/collection_card.dart';
import '../../widgets/watch_tile.dart';
import '../../widgets/app_header.dart';
import '../../widgets/nav_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavDrawer(), // <-- Drawer for screen navigation
      appBar: const AppHeader(), // <-- Reusable themed header
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              SectionTitle(
                title: 'Prime Collection',
                action: 'See all',
                onActionTap: () {
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    CollectionCard(
                      imageUrl: 'https://images.unsplash.com/photo-1589988599196-6bacb4f694b0?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      model: 'GMT-MASTER II',
                      description: 'The Cosmopolitan Watch',
                      price: '2,995',
                    ),
                    SizedBox(width: 16),
                    CollectionCard(
                      imageUrl: 'https://images.unsplash.com/photo-1684297476376-8badc0335c63?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      model: 'GMT-MASTER II',
                      description: 'The Cosmopolitan Watch',
                      price: '2,995',
                    ),
                    SizedBox(width: 16),
                    CollectionCard(
                      imageUrl: 'https://images.unsplash.com/photo-1606736739929-b369d6faabdb?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      model: 'GMT-MASTER II',
                      description: 'The Cosmopolitan Watch',
                      price: '2,995',
                    ),
                    SizedBox(width: 16),
                    CollectionCard(
                      imageUrl: 'https://images.unsplash.com/photo-1602479152858-12238c0d691c?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      model: 'GMT-MASTER II',
                      description: 'The Cosmopolitan Watch',
                      price: '2,995',
                    ),
                    SizedBox(width: 16),
                    CollectionCard(
                      imageUrl: 'https://images.unsplash.com/photo-1568661403059-8e4374bc9e04?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      model: 'GMT-MASTER II',
                      description: 'The Cosmopolitan Watch',
                      price: '2,995',
                    ),
                    SizedBox(width: 16),
                    CollectionCard(
                      imageUrl: 'https://images.unsplash.com/photo-1726258895076-b217276b2539?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      model: 'GMT-MASTER II',
                      description: 'The Cosmopolitan Watch',
                      price: '2,995',
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
                title: 'YACHT MASTER 42',
                description: 'Glowing with new brilliance',
                price: '101,999',
              ),
              const SizedBox(height: 32),
              const WatchTile(
                imageUrl:
                    'https://images.unsplash.com/photo-1629581515634-0b0980b5b79b?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                title: 'YACHT MASTER 42',
                description: 'Glowing with new brilliance',
                price: '101,999',
              ),
              const SizedBox(height: 32),
              const WatchTile(
                imageUrl:
                    'https://images.unsplash.com/photo-1574607304075-f7f22632aa64?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                title: 'YACHT MASTER 42',
                description: 'Glowing with new brilliance',
                price: '101,999',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
