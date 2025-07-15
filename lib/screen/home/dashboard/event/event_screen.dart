import 'package:flutter/material.dart';
import 'package:pensiunku/model/event_model.dart';
import 'package:pensiunku/repository/event_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/screen/home/dashboard/event/event_item_screen.dart';
import 'package:pensiunku/screen/home/dashboard/event/latest_event_screen.dart';
import 'package:pensiunku/screen/home/dashboard/event/no_event_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class EventScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/event';
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late Future<ResultModel<List<EventModel>>> _futureData;
  // late Future<ResultModel<List<EventModel>>> _futureDataWithoutSearchString; // --- PERUBAHAN: Dihapus karena tidak digunakan ---
  int _filterIndex = 0;
  String? _searchText;
  final TextEditingController editingController = TextEditingController();
  // --- PERUBAHAN: Inisialisasi list di sini, akan diisi di _refreshData ---
  List<String> images = [];
  List<int> idArticles = [];
  // --- AKHIR PERUBAHAN ---

  @override
  void initState() {
    super.initState();
    _filterIndex = 0;
    _searchText = null;
    _refreshData();
  }

  Future<void> _refreshData() async { // Mengubah return type menjadi Future<void>
    final token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    // --- PERUBAHAN: Penanganan token null lebih awal ---
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi berakhir. Mohon login kembali.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
        // Opsional: Redirect ke halaman login
        // Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.ROUTE_NAME, (route) => false);
      }
      // Menginisialisasi _futureData dengan Future.error agar FutureBuilder bisa menangani error
      setState(() {
        _futureData = Future.error('Token tidak tersedia.');
      });
      return;
    }
    // --- AKHIR PERUBAHAN ---

    // --- PERUBAHAN: Inisialisasi _futureData dan mengisi images/idArticles di sini ---
    setState(() {
      _futureData = EventRepository().getEvents(token, _filterIndex, _searchText).then((value) {
        if (value.error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value.error.toString(), style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else if (value.data != null) {
          // Hanya isi images dan idArticles jika data berhasil diambil dan tidak ada error
          images = value.data!.take(3).map((e) => e.foto).toList();
          idArticles = value.data!.take(3).map((e) => e.id).toList();
        }
        return value; // Mengembalikan value agar FutureBuilder tetap dapat mengaksesnya
      });
      // _futureDataWithoutSearchString = EventRepository().getEvents(token, _filterIndex, ''); // --- PERUBAHAN: Dihapus ---
    });
    // --- AKHIR PERUBAHAN ---
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF017964)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Event',
          style: theme.textTheme.headline6?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF017964),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Color.fromARGB(255, 220, 226, 147),
            ],
            stops: [0.25, 0.5, 0.75, 1],
          ),
        ),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: editingController,
                  onSubmitted: (v) {
                    _searchText = v;
                    _refreshData();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFE4E4E4),
                    suffixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(36)),
                    ),
                  ),
                ),
              ),
            ),

            // Carousel
            FutureBuilder<ResultModel<List<EventModel>>>(
              future: _futureData,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                // --- PERUBAHAN: Menggunakan list yang sudah diisi di _refreshData ---
                if (images.isNotEmpty) {
                  return LatestEvent(images: images, idArticles: idArticles);
                }
                // --- AKHIR PERUBAHAN ---
                return const SizedBox.shrink();
              },
            ),

            // Filter tabs
            filter(context),

            // Daftar event: dibungkus Expanded agar scroll hanya pada bagian ini
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _refreshData(),
                child: FutureBuilder<ResultModel<List<EventModel>>>(
                  future: _futureData,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snap.data?.data;
                    if (data == null || data.isEmpty) {
                      return const NoEvent();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: data.length,
                      itemBuilder: (c, i) {
                        return EventItemScreen(
                          event: data[i],
                          status: _filterIndex,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filter(BuildContext context) {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 45, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC3C3C3)),
        borderRadius: const BorderRadius.all(Radius.circular(36)),
      ),
      child: Row(
        children: [
          // Akan Berlangsung
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _filterIndex = 0;
                  _refreshData();
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _filterIndex == 0
                      ? const Color(0xFF01A99F)
                      : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    bottomLeft: Radius.circular(36),
                  ),
                ),
                child: Text(
                  'Akan Berlangsung',
                  style: TextStyle(
                    color: _filterIndex == 0
                        ? Colors.white
                        : const Color(0xFF959595),
                  ),
                ),
              ),
            ),
          ),

          // Telah Berlangsung
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _filterIndex = 1;
                  _refreshData();
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _filterIndex == 1
                      ? const Color(0xFF01A99F)
                      : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: Text(
                  'Telah Berlangsung',
                  style: TextStyle(
                    color: _filterIndex == 1
                        ? Colors.white
                        : const Color(0xFF959595),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}