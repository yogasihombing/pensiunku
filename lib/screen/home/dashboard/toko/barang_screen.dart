import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/model/toko/toko_model.dart';
import 'package:pensiunku/repository/toko/toko_repository.dart';
import 'package:pensiunku/screen/home/dashboard/toko/history_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/keranjang_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:pensiunku/widget/toko/product_card.dart';

class BarangScreenArguments {
  final int barangId;
  final Product barang; // Product barang yang dilewatkan harus non-nullable

  BarangScreenArguments({required this.barangId, required this.barang});
}

class BarangScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/toko-item';
  final int barangId;
  final Product barang; // Product barang yang dilewatkan harus non-nullable

  const BarangScreen({Key? key, required this.barangId, required this.barang})
      : super(key: key);

  @override
  State<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends State<BarangScreen> {
  final TextEditingController editingController = TextEditingController();
  late Future<ResultModel<List<Cart>>> _futureDataCarts;
  late Future<ResultModel<List<Product>>> _futureBarang;
  late int totalCart;
  late List<Cart>
      carts; // PENTING: Inisialisasi carts di initState karena ini non-nullable
  late List<Product> relatedItem;
  late Product barang; // Ini sekarang adalah properti state, bukan widget

  final CarouselController _carouselController = CarouselController();
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    print('BarangScreen: initState dipanggil.');
    totalCart = 0;
    relatedItem = [];
    carts = []; // Perbaikan: Inisialisasi carts di sini
    barang = widget.barang; // Inisialisasi barang dari widget
    _currentCarouselIndex = 0;
    _refreshData();
  }

  @override
  void dispose() {
    print('BarangScreen: dispose() dipanggil.');
    editingController.dispose();
    _carouselController.stopAutoPlay();
    super.dispose();
  }

  _refreshData() {
    print('BarangScreen: _refreshData dipanggil.');
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null) {
      print('BarangScreen: Token null, tidak dapat memuat data.');
      if (mounted) {
        setState(() {
          _futureBarang = Future.value(
              ResultModel(isSuccess: false, error: 'Token tidak tersedia.'));
          _futureDataCarts = Future.value(
              ResultModel(isSuccess: false, error: 'Token tidak tersedia.'));
          totalCart = 0;
          relatedItem = [];
        });
      }
      return;
    }

    _loadCarts();

    // Pastikan barang.idKategori tidak null sebelum dilewatkan
    int idKategori =
        barang.idKategori; // Gunakan barang dari state, bukan widget
    print('BarangScreen: Memuat produk terkait untuk kategori: $idKategori');
    _futureBarang = TokoRepository()
        .getRelatedProductById(
            token, idKategori) // Gunakan idKategori yang dipastikan
        .then((value) {
      print(
          'BarangScreen: Related product data fetched. Error: ${value.error}, Data Length: ${value.data?.length}');
      if (!value.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value.error.toString(),
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            relatedItem = value.data ?? []; // Pastikan relatedItem tidak null
          });
        }
      }
      return value;
    }).catchError((e) {
      print('BarangScreen: Error fetching related products: $e');
      if (mounted) {
        setState(() {
          _futureBarang = Future.value(ResultModel(
              isSuccess: false, error: 'Gagal memuat produk terkait: $e'));
          relatedItem = [];
        });
      }
      return ResultModel(
          isSuccess: false, error: 'Gagal memuat produk terkait: $e');
    });
  }

  _loadCarts() {
    print('BarangScreen: _loadCarts dipanggil.');
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null) {
      print('BarangScreen: Token null, tidak dapat memuat keranjang.');
      if (mounted) {
        setState(() {
          _futureDataCarts = Future.value(
              ResultModel(isSuccess: false, error: 'Token tidak tersedia.'));
          totalCart = 0;
        });
      }
      return;
    }

    _futureDataCarts = TokoRepository().getShoppingCart(token).then((value) {
      print(
          'BarangScreen: Cart data fetched. Error: ${value.error}, Data Length: ${value.data?.length}');
      if (value.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value.error.toString(),
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            carts = value.data ?? []; // Pastikan carts tidak null
            totalCart = 0;
            carts.forEach((element) {
              totalCart = totalCart +
                  (element.jumlahBarang
                      as int); // Perbaikan: Pastikan jumlahBarang adalah int
            });
            print('BarangScreen: Total keranjang: $totalCart');
          });
        }
      }
      return value;
    }).catchError((e) {
      print('BarangScreen: Error fetching carts: $e');
      if (mounted) {
        setState(() {
          _futureDataCarts = Future.value(ResultModel(
              isSuccess: false, error: 'Gagal memuat keranjang: $e'));
          totalCart = 0;
        });
      }
      return ResultModel(isSuccess: false, error: 'Gagal memuat keranjang: $e');
    });
  }

  _postToShoppingCart(int idBarang, int amount) {
    print(
        'BarangScreen: _postToShoppingCart dipanggil. ID Barang: $idBarang, Jumlah: $amount');
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null) {
      print('BarangScreen: Token null, tidak dapat menambahkan ke keranjang.');
      return;
    }

    // Cari apakah produk sudah ada di keranjang
    bool isExist = false;
    int currentJumlahBarang = 0;
    Cart? existingCartItem;

    for (var cart in carts) {
      // carts sudah dipastikan non-nullable
      if (idBarang == cart.idBarang) {
        isExist = true;
        currentJumlahBarang = cart.jumlahBarang;
        existingCartItem = cart;
        break;
      }
      // Perbaikan: tambahkan print() untuk melihat idBarang dan idBarang di cart
      print(
          'BarangScreen: Membandingkan idBarang: $idBarang dengan cart.idBarang: ${cart.idBarang}');
    }
    print('BarangScreen: Produk id $idBarang sudah ada di keranjang: $isExist');

    if (isExist) {
      print('BarangScreen: Produk sudah ada di keranjang. Melakukan update.');
      int newJumlah = currentJumlahBarang + amount;
      if (newJumlah <= 0 && existingCartItem != null) {
        // Jika jumlah menjadi 0 atau kurang, hapus item
        TokoRepository()
            .deleteShoppingCart(token, existingCartItem.id)
            .then((value) {
          if (mounted) {
            if (value.isSuccess) {
              print('BarangScreen: Item keranjang berhasil dihapus.');
              _refreshData();
            } else {
              print(
                  'BarangScreen: Gagal menghapus item keranjang: ${value.error}');
            }
          }
        });
        return; // Hentikan fungsi
      }

      TokoRepository()
          .putToShoppingCart(
              token, PushToShoppingCart(id: idBarang, stok: newJumlah))
          .then((value) {
        print(
            'BarangScreen: putToShoppingCart result: ${value.isSuccess ? "Success" : "Failed"}. Error: ${value.error}');
        if (!value.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value.error.toString(),
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          if (mounted) {
            setState(() {
              _refreshData();
            });
          }
        }
      }).catchError((e) {
        print('BarangScreen: Error putToShoppingCart: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui keranjang: $e',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    } else {
      print(
          'BarangScreen: Produk belum ada di keranjang. Melakukan penambahan baru.');
      TokoRepository()
          .postToShoppingCart(
              token, PushToShoppingCart(id: idBarang, stok: amount))
          .then((value) {
        print(
            'BarangScreen: postToShoppingCart result: ${value.isSuccess ? "Success" : "Failed"}. Error: ${value.error}');
        if (!value.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value.error.toString(),
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          if (mounted) {
            setState(() {
              _refreshData();
            });
          }
        }
      }).catchError((e) {
        print('BarangScreen: Error postToShoppingCart: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambahkan ke keranjang: $e',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    // Dimensi responsif
    final double carouselHeight = screenSize.height * 0.4;
    final double paddingHorizontal = 12.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Colors.transparent,
          child: SafeArea(
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: GestureDetector(
                onTap: () {
                  print('BarangScreen: AppBar kembali ditekan.');
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Color(0xFF017964),
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    visualDensity:
                        VisualDensity(horizontal: -4.0, vertical: -4.0),
                    tooltip: 'Keranjang',
                    onPressed: () {
                      print('BarangScreen: Tombol keranjang ditekan.');
                      Navigator.of(context)
                          .pushNamed(
                        KeranjangScreen.ROUTE_NAME,
                      )
                          .then((value) {
                        print(
                            'BarangScreen: Kembali dari KeranjangScreen. Memuat ulang data.');
                        _loadCarts(); // Load carts saja
                      });
                    },
                    icon: SizedBox(
                      height: 30.0,
                      child: totalCart == 0
                          ? Image.asset('assets/toko/keranjang.png')
                          : Badge(
                              badgeContent: Text(
                                '$totalCart',
                                style: theme.textTheme.bodyText1?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              position: BadgePosition.topEnd(
                                top: -4,
                                end: -4,
                              ),
                              child: Image.asset('assets/toko/keranjang.png')),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    visualDensity:
                        VisualDensity(horizontal: -4.0, vertical: -4.0),
                    tooltip: 'History',
                    onPressed: () {
                      print('BarangScreen: Tombol history ditekan.');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryScreen(),
                        ),
                      ).then((_) {
                        print(
                            'BarangScreen: Kembali dari HistoryScreen. Memuat ulang data.');
                        _loadCarts(); // Load carts saja
                      });
                    },
                    icon: SizedBox(
                      height: 30.0,
                      child: Image.asset('assets/toko/history.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Color(0xFFDCE293),
            ],
            stops: [0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            print('BarangScreen: RefreshIndicator dipicu.');
            await _refreshData();
          },
          child: SingleChildScrollView(
            // Menggunakan SingleChildScrollView
            physics: AlwaysScrollableScrollPhysics(), // Selalu bisa di-scroll
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    height:
                        30), // Padding atas untuk konten di bawah AppBar transparan
                // Carousel Gambar Produk
                Container(
                  height: carouselHeight,
                  width: double.infinity,
                  child: CarouselSlider(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      height: carouselHeight,
                      aspectRatio: 1,
                      enlargeCenterPage: false,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      autoPlay: false,
                      onPageChanged: (index, reason) {
                        if (mounted) {
                          setState(() {
                            _currentCarouselIndex = index;
                            print(
                                'BarangScreen: Carousel index berubah menjadi $_currentCarouselIndex.');
                          });
                        }
                      },
                    ),
                    items: barang.gallery.map<Widget>((e) {
                      String imageUrl =
                          e.path ?? ''; // Pastikan path tidak null
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(0.0),
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) {
                                // Tambahkan errorWidget
                                print(
                                    'BarangScreen: CachedNetworkImage ERROR: $error for URL: $url');
                                return Icon(Icons.error); // Placeholder error
                              },
                              imageUrl: imageUrl,
                              fit: BoxFit.fitHeight,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang.nama,
                        style: theme.textTheme.subtitle1
                            ?.copyWith(color: Colors.black),
                      ),
                      Text(
                        barang.getTotalPriceFormatted(),
                        style: theme.textTheme.subtitle1?.copyWith(
                            color: Color.fromRGBO(76, 167, 157, 1.0)),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          if (barang.averageRating !=
                              null) // Pastikan averageRating tidak null
                            RatingBar.builder(
                              initialRating: barang.averageRating!,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 12.0,
                              ignoreGestures: true,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.black,
                              ),
                              unratedColor: Colors.grey.withAlpha(50),
                              onRatingUpdate: (rating) {
                                print('BarangScreen: Rating updated: $rating');
                              },
                            ),
                          SizedBox(width: 8.0),
                          Text(barang.terjual ??
                              '0'), // Gunakan ?? '0' untuk default
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('Deskripsi'),
                      SizedBox(height: 2),
                      Text(barang.deskripsi),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                // Ulasan Produk
                if (barang.review != null &&
                    barang.review!
                        .isNotEmpty) // Perbaikan: Cek review tidak null/kosong
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                          thickness: 8.0,
                          color: Color.fromRGBO(236, 236, 236, 1.0)),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: paddingHorizontal, vertical: 5.0),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Text('Ulasan Produk'),
                            Spacer(),
                            Icon(Icons.navigate_next,
                                color: Color.fromRGBO(149, 149, 149, 1.0)),
                          ],
                        ),
                      ),
                      Divider(
                          thickness: 4.0,
                          color: Color.fromRGBO(236, 236, 236, 1.0)),
                      ...barang.review!.map((review) {
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            Color.fromRGBO(241, 176, 86, 1.0),
                                        radius: 20,
                                        child: Icon(
                                          Icons.person,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10.0),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review.userName?.toString() ??
                                                'Anonim', // Gunakan ?.toString() ?? 'Anonim'
                                          ),
                                          SizedBox(height: 3),
                                          RatingBar.builder(
                                            initialRating: review.star
                                                .toDouble(), // Langsung ke double
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: false,
                                            itemCount: 5,
                                            itemSize: 12.0,
                                            ignoreGestures: true,
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Color(0xFFFFC950),
                                            ),
                                            unratedColor:
                                                Colors.grey.withAlpha(50),
                                            onRatingUpdate: (rating) {
                                              print(
                                                  'BarangScreen: Review rating updated: $rating');
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.0),
                                  Text(review.ulasan),
                                  SizedBox(height: 8.0),
                                  Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(review.createdAt)
                                        .toString(),
                                    style:
                                        TextStyle(color: Colors.grey.shade400),
                                  )
                                ],
                              ),
                            ),
                            Divider(
                                thickness: 4.0,
                                color: Color.fromRGBO(236, 236, 236, 1.0)),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                // Bagian "Produk Serupa"
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: paddingHorizontal, vertical: 5.0),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text('Produk Serupa'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: FutureBuilder<ResultModel<List<Product>>>(
                    // Pastikan FutureBuilder di sini
                    future: _futureBarang, // Gunakan _futureBarang
                    builder: (context, snapshot) {
                      print(
                          'BarangScreen: FutureBuilder (produk serupa) - ConnectionState: ${snapshot.connectionState}');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 200, // Placeholder
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError ||
                          (snapshot.hasData && !snapshot.data!.isSuccess)) {
                        print(
                            'BarangScreen: FutureBuilder (produk serupa) - Ada error: ${snapshot.error ?? snapshot.data?.error}');
                        return SizedBox(
                          height: 200,
                          child: ErrorCard(
                              title: 'Gagal Memuat Produk Serupa',
                              subtitle: snapshot.error?.toString() ??
                                  snapshot.data?.error ??
                                  'Terjadi kesalahan.',
                              iconData: Icons.error_outline),
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data!.data!.isNotEmpty) {
                        print(
                            'BarangScreen: FutureBuilder (produk serupa) - Data berhasil dimuat. Jumlah: ${relatedItem.length}');
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: relatedItem.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.70,
                          ),
                          itemBuilder: (context, position) {
                            // Perbaikan: Menggunakan ProductCard yang baru
                            return ProductCard(
                              product: relatedItem[position],
                              onTap: (product) {
                                print(
                                    'BarangScreen: Related ProductCard diklik untuk produk ID: ${product.id}');
                                // Navigasi ke BarangScreen baru untuk produk terkait
                                Navigator.of(context)
                                    .pushReplacementNamed(
                                        // Gunakan pushReplacementNamed untuk menghindari tumpukan halaman yang tak terbatas
                                        BarangScreen.ROUTE_NAME,
                                        arguments: BarangScreenArguments(
                                            barangId: product.id,
                                            barang: product))
                                    .then((value) {
                                  print(
                                      'BarangScreen: Kembali dari Produk Serupa. Memuat ulang data.');
                                  if (mounted) {
                                    _refreshData();
                                  } // Refresh data halaman saat ini
                                });
                              },
                            );
                          },
                        );
                      } else {
                        print(
                            'BarangScreen: FutureBuilder (produk serupa) - Tidak ada produk serupa.');
                        return SizedBox(
                          height: 100,
                          child:
                              Center(child: Text('Tidak ada produk serupa.')),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 55.0,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                splashRadius: 100.0,
                splashColor: Color(0xFF017964),
                tooltip: 'Add Cart',
                
                icon: Icon(Icons.add_shopping_cart),
                color: Color(0xFF017964),
                iconSize: 30.0,
                onPressed: () {
                  print(
                      'BarangScreen: Tombol Add to Cart di bottom bar ditekan.');
                  _postToShoppingCart(
                      barang.id, 1); // Panggil dengan ID barang dari state
                },
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  // Mengubah menjadi async
                  print(
                      'BarangScreen: Tombol "Beli Sekarang" di bottom bar ditekan.');
                  await _postToShoppingCart(
                      barang.id, 1); // Tunggu sampai selesai

                  // Berikan sedikit jeda sebelum navigasi untuk memastikan state keranjang terupdate
                  await Future.delayed(Duration(milliseconds: 500));

                  Navigator.of(context)
                      .pushNamed(
                    KeranjangScreen.ROUTE_NAME,
                  )
                      .then((value) {
                    print(
                        'BarangScreen: Kembali dari KeranjangScreen. Memuat ulang data.');
                    _loadCarts(); // Load carts saja
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Color(0xFFFFC950)),
                  child: Text(
                    'Beli Sekarang',
                    style: theme.textTheme.subtitle1
                        ?.copyWith(color: Colors.black),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
