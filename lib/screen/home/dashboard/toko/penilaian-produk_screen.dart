import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pensiunku/model/toko/toko-order_model.dart';
import 'package:pensiunku/repository/toko/toko-order_repository.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';


class PenilaianProduk extends StatefulWidget {
  final ProductModel product;
  final int orderId;
  const PenilaianProduk({
    Key? key,
    required this.product,
    required this.orderId,
  }) : super(key: key);

  @override
  State<PenilaianProduk> createState() => _PenilaianProdukState();
}

class _PenilaianProdukState extends State<PenilaianProduk> {
  final TextEditingController _ulasanController = TextEditingController();
  final RegExp regExp = RegExp(r"[\w-._]+");

  double productRating = 5;
  bool isMaximumWord = false;

  Future<bool> addProductsRatingandReview({
    required String ulasan,
    double rating = 0,
    required ProductModel product,
  }) async {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    var data = {
      'id_barang': product.id,
      'star': productRating,
      'ulasan': ulasan,
    };

    bool success = await TokoOrderRepository()
        .addProductsRatingandReview(
      token!,
      data,
      widget.orderId,
    )
        .then((value) {
      return value.data!;
    });
    print('review : ' + success.toString());
    return success;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color greenColor = Color.fromRGBO(1, 169, 159, 1.0);
    TextStyle whiteTextStyle = TextStyle(color: Colors.white);
    Widget produk() {
      return Container(
        color: Colors.grey.shade300,
        margin: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 16),
                padding: EdgeInsets.all(8),
                child: CachedNetworkImage(
                  imageUrl: widget.product.gallery![0].path!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.product.nama!,
              ),
            ),
          ],
        ),
      );
    }

    Widget rating() {
      return RatingBar.builder(
        direction: Axis.horizontal,
        initialRating: productRating,
        allowHalfRating: true,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          setState(() {
            productRating = rating;
          });
        },
      );
    }

    Widget ulasan() {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: TextFormField(
          keyboardType: TextInputType.multiline,
          controller: _ulasanController,
          maxLines: 8,
          maxLength: 200,
          buildCounter: (context,
                  {required currentLength, required isFocused, maxLength}) =>
              Text('${_ulasanController.text.length} / 200'),
          style: TextStyle(fontSize: 20),
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: 'Tulis ulasan',
            hintStyle: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      );
    }

    Widget buttonSubmit() {
      return InkWell(
        onTap: () async {
          if (productRating > 0) {
            if (await addProductsRatingandReview(
              ulasan: _ulasanController.text,
              product: widget.product,
              rating: productRating,
            )) {
              Navigator.of(context).pop();
            }
          }
        },
        child: Container(
          color: greenColor,
          height: 56,
          width: double.infinity,
          child: Center(
            child: Text(
              'Submit',
              style: whiteTextStyle.copyWith(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
        ),
        title: Text(
          "Penilaian Produk",
          style: theme.textTheme.headline6?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      bottomNavigationBar: buttonSubmit(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          child: Column(
            children: [
              produk(),
              rating(),
              ulasan(),
            ],
          ),
        ),
      ),
    );
  }
}
