import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/toko/ongkir_model.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/toko/ongkir_repository.dart';
import 'package:pensiunku/widget/error_card.dart';

class ExpeditionScreenArguments {
  final String destination;
  final String origin;
  final int weight;

  ExpeditionScreenArguments(this.destination, this.origin, this.weight);
}

class ExpeditionScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/expedition';
  final String destination;
  final String origin;
  final int weight;

  const ExpeditionScreen(
      {Key? key,
      required this.destination,
      required this.origin,
      required this.weight})
      : super(key: key);

  @override
  State<ExpeditionScreen> createState() => _ExpeditionScreenState();
}

class _ExpeditionScreenState extends State<ExpeditionScreen> {
  late Future<ResultModel<List<ExpedisiModel>>> _futureExpedisiData;
  ExpedisiModel? _selectedExpedition;

  @override
  void initState() {
    super.initState();

    _refreshData();
  }

  _refreshData() {
    List<String> couriers = ["tiki", "jne", "pos"];
    return _futureExpedisiData = OngkirRepository()
        .getCost(widget.origin, widget.destination, widget.weight, couriers)
        .then((value) {
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(value.error.toString(),
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
      } else {
        return value;
      }
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    Color dividerColor = Color.fromRGBO(236, 236, 236, 1.0);
    Color iconColor = Color.fromARGB(76, 167, 157, 1);
    Color fontColor = Color.fromRGBO(0, 186, 175, 1.0);
    double carouselWidth = screenSize.width * 0.9;
    double cardWidth = carouselWidth - 16.0;
    double promoCardHeight = cardWidth * (746 / 1697) + 24.0;
    double promoCarouselHeight = promoCardHeight + 16.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: Icon(Icons.arrow_back),
            color: Color(0xFF017964),
          ),
          title: Text(
            "Opsi Pengiriman",
            style: theme.textTheme.headline6?.copyWith(
              fontWeight: FontWeight.w600,
              color: Color(0xFF017964),
            ),
          )),
      bottomNavigationBar: Container(
        height: 55.0,
        child: Row(
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.pop(context, _selectedExpedition);
                },
                child: Container(
                  width: screenSize.width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Color(0xFF017964)),
                  child: Text(
                    'Pilih Pengiriman',
                    style: theme.textTheme.subtitle1
                        ?.copyWith(color: Colors.white),
                  ),
                )),
          ],
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
          onRefresh: () {
            return _refreshData();
          },
          child: ListView(
            children: [
              ListTile(
                title: Text("Pilih salah satu"),
              ),
              Divider(
                height: 1,
              ),
              FutureBuilder(
                future: _futureExpedisiData,
                builder: (BuildContext context,
                    AsyncSnapshot<ResultModel<List<ExpedisiModel>>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data?.data?.isNotEmpty == true) {
                      List<ExpedisiModel> expeditionModel =
                          snapshot.data!.data!;
                      return Column(
                        children: [
                          ...expeditionModel.map((e) => singleDeliveryItem(e)),
                          SizedBox(
                            height: 50,
                          )
                        ],
                      );
                    } else {
                      String errorTitle = 'Tidak ada pilihan expedisi';
                      String? errorSubtitle = snapshot.data?.error;
                      return Container(
                        child: ErrorCard(
                          title: errorTitle,
                          subtitle: errorSubtitle,
                          iconData: Icons.info_outline,
                        ),
                      );
                    }
                  } else {
                    return Container(
                      height: promoCarouselHeight + 36 + 16.0,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.primaryColor,
                        ),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget singleDeliveryItem(ExpedisiModel expedisiModel) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: [
        RadioListTile<ExpedisiModel>(
          onChanged: (value) {
            setState(() {
              _selectedExpedition = value;
            });
          },
          groupValue: _selectedExpedition,
          value: expedisiModel,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${expedisiModel.name}'),
            ],
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jenis: ${expedisiModel.service}'),
              Text('Deskripsi: ${expedisiModel.description}'),
              Text('Estimasi: ${expedisiModel.estimationDate} hari'),
              Text('Biaya: ' +
                  CurrencyTextInputFormatter(
                    locale: 'id',
                    decimalDigits: 0,
                    symbol: 'Rp. ',
                  ).format(expedisiModel.cost.toString())),
            ],
          ),
        ),
        Divider(
          height: 35,
        ),
      ],
    );
  }
}
