import 'package:flutter/material.dart';

class IconPicker extends StatefulWidget {
  final String? selectedIcon;
  final Function(String) onIconSelected;
  final String title;

  const IconPicker({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
    this.title = 'Select Icon',
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  String? _selectedIcon;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _allIcons = [
    // Food & Dining
    {'name': 'restaurant', 'icon': Icons.restaurant, 'category': 'Food'},
    {'name': 'restaurant_menu', 'icon': Icons.restaurant_menu, 'category': 'Food'},
    {'name': 'fastfood', 'icon': Icons.fastfood, 'category': 'Food'},
    {'name': 'coffee', 'icon': Icons.coffee, 'category': 'Food'},
    {'name': 'local_cafe', 'icon': Icons.local_cafe, 'category': 'Food'},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart, 'category': 'Food'},
    {'name': 'cake', 'icon': Icons.cake, 'category': 'Food'},
    {'name': 'local_pizza', 'icon': Icons.local_pizza, 'category': 'Food'},
    {'name': 'local_bar', 'icon': Icons.local_bar, 'category': 'Food'},
    {'name': 'wine_bar', 'icon': Icons.wine_bar, 'category': 'Food'},

    // Transportation
    {'name': 'directions_car', 'icon': Icons.directions_car, 'category': 'Transport'},
    {'name': 'directions_bus', 'icon': Icons.directions_bus, 'category': 'Transport'},
    {'name': 'train', 'icon': Icons.train, 'category': 'Transport'},
    {'name': 'subway', 'icon': Icons.subway, 'category': 'Transport'},
    {'name': 'local_taxi', 'icon': Icons.local_taxi, 'category': 'Transport'},
    {'name': 'motorcycle', 'icon': Icons.motorcycle, 'category': 'Transport'},
    {'name': 'pedal_bike', 'icon': Icons.pedal_bike, 'category': 'Transport'},
    {'name': 'directions_walk', 'icon': Icons.directions_walk, 'category': 'Transport'},
    {'name': 'flight', 'icon': Icons.flight, 'category': 'Transport'},
    {'name': 'directions_boat', 'icon': Icons.directions_boat, 'category': 'Transport'},

    // Shopping & Retail
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag, 'category': 'Shopping'},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart, 'category': 'Shopping'},
    {'name': 'checkroom', 'icon': Icons.checkroom, 'category': 'Shopping'},
    {'name': 'diamond', 'icon': Icons.diamond, 'category': 'Shopping'},
    {'name': 'watch', 'icon': Icons.watch, 'category': 'Shopping'},
    {'name': 'phone_iphone', 'icon': Icons.phone_iphone, 'category': 'Shopping'},
    {'name': 'devices', 'icon': Icons.devices, 'category': 'Shopping'},
    {'name': 'computer', 'icon': Icons.computer, 'category': 'Shopping'},
    {'name': 'laptop', 'icon': Icons.laptop, 'category': 'Shopping'},
    {'name': 'tablet', 'icon': Icons.tablet, 'category': 'Shopping'},

    // Entertainment & Leisure
    {'name': 'movie', 'icon': Icons.movie, 'category': 'Entertainment'},
    {'name': 'theater_comedy', 'icon': Icons.theater_comedy, 'category': 'Entertainment'},
    {'name': 'music_note', 'icon': Icons.music_note, 'category': 'Entertainment'},
    {'name': 'games', 'icon': Icons.games, 'category': 'Entertainment'},
    {'name': 'sports_soccer', 'icon': Icons.sports_soccer, 'category': 'Entertainment'},
    {'name': 'fitness_center', 'icon': Icons.fitness_center, 'category': 'Entertainment'},
    {'name': 'pool', 'icon': Icons.pool, 'category': 'Entertainment'},
    {'name': 'terrain', 'icon': Icons.terrain, 'category': 'Entertainment'},
    {'name': 'beach_access', 'icon': Icons.beach_access, 'category': 'Entertainment'},
    {'name': 'casino', 'icon': Icons.casino, 'category': 'Entertainment'},

    // Health & Wellness
    {'name': 'medical_services', 'icon': Icons.medical_services, 'category': 'Health'},
    {'name': 'medication', 'icon': Icons.medication, 'category': 'Health'},
    {'name': 'visibility', 'icon': Icons.visibility, 'category': 'Health'},
    {'name': 'psychology', 'icon': Icons.psychology, 'category': 'Health'},
    {'name': 'favorite', 'icon': Icons.favorite, 'category': 'Health'},
    {'name': 'favorite_border', 'icon': Icons.favorite_border, 'category': 'Health'},
    {'name': 'healing', 'icon': Icons.healing, 'category': 'Health'},
    {'name': 'spa', 'icon': Icons.spa, 'category': 'Health'},
    {'name': 'self_improvement', 'icon': Icons.self_improvement, 'category': 'Health'},
    {'name': 'accessibility', 'icon': Icons.accessibility, 'category': 'Health'},

    // Home & Utilities
    {'name': 'home', 'icon': Icons.home, 'category': 'Home'},
    {'name': 'home_work', 'icon': Icons.home_work, 'category': 'Home'},
    {'name': 'electric_bolt', 'icon': Icons.electric_bolt, 'category': 'Home'},
    {'name': 'water_drop', 'icon': Icons.water_drop, 'category': 'Home'},
    {'name': 'local_fire_department', 'icon': Icons.local_fire_department, 'category': 'Home'},
    {'name': 'wifi', 'icon': Icons.wifi, 'category': 'Home'},
    {'name': 'phone', 'icon': Icons.phone, 'category': 'Home'},
    {'name': 'build', 'icon': Icons.build, 'category': 'Home'},
    {'name': 'cleaning_services', 'icon': Icons.cleaning_services, 'category': 'Home'},
    {'name': 'chair', 'icon': Icons.chair, 'category': 'Home'},

    // Business & Professional
    {'name': 'business', 'icon': Icons.business, 'category': 'Business'},
    {'name': 'work', 'icon': Icons.work, 'category': 'Business'},
    {'name': 'trending_up', 'icon': Icons.trending_up, 'category': 'Business'},
    {'name': 'account_balance', 'icon': Icons.account_balance, 'category': 'Business'},
    {'name': 'account_balance_wallet', 'icon': Icons.account_balance_wallet, 'category': 'Business'},
    {'name': 'credit_card', 'icon': Icons.credit_card, 'category': 'Business'},
    {'name': 'savings', 'icon': Icons.savings, 'category': 'Business'},
    {'name': 'security', 'icon': Icons.security, 'category': 'Business'},
    {'name': 'receipt_long', 'icon': Icons.receipt_long, 'category': 'Business'},
    {'name': 'payment', 'icon': Icons.payment, 'category': 'Business'},

    // Education & Learning
    {'name': 'school', 'icon': Icons.school, 'category': 'Education'},
    {'name': 'book', 'icon': Icons.book, 'category': 'Education'},
    {'name': 'library_books', 'icon': Icons.library_books, 'category': 'Education'},
    {'name': 'article', 'icon': Icons.article, 'category': 'Education'},
    {'name': 'quiz', 'icon': Icons.quiz, 'category': 'Education'},
    {'name': 'science', 'icon': Icons.science, 'category': 'Education'},
    {'name': 'psychology', 'icon': Icons.psychology, 'category': 'Education'},
    {'name': 'calculate', 'icon': Icons.calculate, 'category': 'Education'},
    {'name': 'code', 'icon': Icons.code, 'category': 'Education'},
    {'name': 'language', 'icon': Icons.language, 'category': 'Education'},

    // Social & Relationships
    {'name': 'people', 'icon': Icons.people, 'category': 'Social'},
    {'name': 'person', 'icon': Icons.person, 'category': 'Social'},
    {'name': 'group', 'icon': Icons.group, 'category': 'Social'},
    {'name': 'event', 'icon': Icons.event, 'category': 'Social'},
    {'name': 'celebration', 'icon': Icons.celebration, 'category': 'Social'},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard, 'category': 'Social'},
    {'name': 'volunteer_activism', 'icon': Icons.volunteer_activism, 'category': 'Social'},
    {'name': 'church', 'icon': Icons.church, 'category': 'Social'},
    {'name': 'local_hospital', 'icon': Icons.local_hospital, 'category': 'Social'},
    {'name': 'local_police', 'icon': Icons.local_police, 'category': 'Social'},

    // Technology & Digital
    {'name': 'computer', 'icon': Icons.computer, 'category': 'Technology'},
    {'name': 'phone_android', 'icon': Icons.phone_android, 'category': 'Technology'},
    {'name': 'cloud', 'icon': Icons.cloud, 'category': 'Technology'},
    {'name': 'storage', 'icon': Icons.storage, 'category': 'Technology'},
    {'name': 'memory', 'icon': Icons.memory, 'category': 'Technology'},
    {'name': 'router', 'icon': Icons.router, 'category': 'Technology'},
    {'name': 'bluetooth', 'icon': Icons.bluetooth, 'category': 'Technology'},
    {'name': 'wifi', 'icon': Icons.wifi, 'category': 'Technology'},
    {'name': 'nfc', 'icon': Icons.nfc, 'category': 'Technology'},
    {'name': 'qr_code', 'icon': Icons.qr_code, 'category': 'Technology'},

    // Miscellaneous
    {'name': 'category', 'icon': Icons.category, 'category': 'Other'},
    {'name': 'circle', 'icon': Icons.circle, 'category': 'Other'},
    {'name': 'star', 'icon': Icons.star, 'category': 'Other'},
    {'name': 'favorite', 'icon': Icons.favorite, 'category': 'Other'},
    {'name': 'thumb_up', 'icon': Icons.thumb_up, 'category': 'Other'},
    {'name': 'help', 'icon': Icons.help, 'category': 'Other'},
    {'name': 'info', 'icon': Icons.info, 'category': 'Other'},
    {'name': 'warning', 'icon': Icons.warning, 'category': 'Other'},
    {'name': 'error', 'icon': Icons.error, 'category': 'Other'},
    {'name': 'check_circle', 'icon': Icons.check_circle, 'category': 'Other'},
  ];

  List<Map<String, dynamic>> get _filteredIcons {
    if (_searchQuery.isEmpty) {
      return _allIcons;
    }
    return _allIcons.where((icon) {
      return icon['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             icon['category'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search icons...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _filteredIcons.length,
                itemBuilder: (context, index) {
                  final iconData = _filteredIcons[index];
                  final isSelected = _selectedIcon == iconData['name'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconData['name'];
                      });
                      widget.onIconSelected(iconData['name']);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            iconData['icon'],
                            color: isSelected 
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            iconData['name'],
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected 
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
