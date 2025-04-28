import 'package:flutter/material.dart';

class FranchiseScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/Franchise';
  const FranchiseScreen({Key? key}) : super(key: key);

  @override
  State<FranchiseScreen> createState() => _FranchiseScreenState();
}

class _FranchiseScreenState extends State<FranchiseScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _allFranchises;
  late List<String> _filteredFranchises;

  @override
  void initState() {
    super.initState();
    _allFranchises = [
      'Geprek Mas Ajul',
      'Cimol Bojot AA',
      'Franchise 3',
      'Franchise 4',
      'Franchise 5',
      'Franchise 6',
    ];
    _filteredFranchises = List.from(_allFranchises);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFranchises = List.from(_allFranchises);
      } else {
        _filteredFranchises = _allFranchises
            .where((f) => f.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final backIconSize = screenHeight * 0.03;

    final categoryItems = [
      {'label': 'Makanan', 'icon': 'assets/franchise/makanan.png'},
      {'label': 'Minuman', 'icon': 'assets/franchise/minuman.png'},
      {'label': 'Bengkel',  'icon': 'assets/franchise/bengkel.png'},
      {'label': 'Lainnya', 'icon': 'assets/franchise/lainnya.png'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: const Color(0xFF017964),
          size: backIconSize,
        ),
        title: const Text(
          'Info Franchise',
          style: TextStyle(color: Color(0xFF017964)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            SizedBox(
              height: screenHeight * 0.06,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Disini...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF017964)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF017964)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Banner Image
            SizedBox(
              height: screenHeight * 0.22,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/franchise/franchise_banner.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.025),

            // Kategori Franchise (statik 4 item)
            const Text(
              'Kategori Franchise',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: screenHeight * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    // TODO: Navigate to Makanan page
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        categoryItems[0]['icon']!,
                        height: screenHeight * 0.1,
                        width: screenHeight * 0.1,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(categoryItems[0]['label']!),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    // TODO: Navigate to Minuman page
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        categoryItems[1]['icon']!,
                        height: screenHeight * 0.1,
                        width: screenHeight * 0.1,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(categoryItems[1]['label']!),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    // TODO: Navigate to Bengkel page
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        categoryItems[2]['icon']!,
                        height: screenHeight * 0.1,
                        width: screenHeight * 0.1,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(categoryItems[2]['label']!),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    // TODO: Navigate to Lainnya page
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        categoryItems[3]['icon']!,
                        height: screenHeight * 0.1,
                        width: screenHeight * 0.1,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(categoryItems[3]['label']!),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),

            // Top Franchise (onclick per item)
            const Text(
              'Top Franchise',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: screenHeight * 0.015),
            SizedBox(
              height: screenHeight * 0.28,
              child: _filteredFranchises.isEmpty
                  ? Center(child: Text('Tidak ada franchise ditemukan'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filteredFranchises.length,
                      itemBuilder: (context, index) {
                        final title = _filteredFranchises[index];
                        return InkWell(
                          onTap: () {
                            switch (title) {
                              case 'Geprek Mas Ajul':
                                // TODO: Navigate to Geprek Mas Ajul detail
                                break;
                              case 'Cimol Bojot AA':
                                // TODO: Navigate to Cimol Bojot AA detail
                                break;
                              case 'Franchise 3':
                                // TODO: Navigate to Franchise 3 detail
                                break;
                              case 'Franchise 4':
                                // TODO: Navigate to Franchise 4 detail
                                break;
                              case 'Franchise 5':
                                // TODO: Navigate to Franchise 5 detail
                                break;
                              case 'Franchise 6':
                                // TODO: Navigate to Franchise 6 detail
                                break;
                              default:
                                break;
                            }
                          },
                          child: Container(
                            width: screenHeight * 0.28,
                            height: screenHeight * 0.28,
                            margin: EdgeInsets.only(
                                right: index == _filteredFranchises.length - 1
                                    ? 0
                                    : screenWidth * 0.04),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
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