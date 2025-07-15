import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/event_model.dart';
import 'package:pensiunku/screen/home/dashboard/event/event_detail_screen.dart';

class EventItemScreen extends StatelessWidget {
  final EventModel event;
  final int status;

  const EventItemScreen({
    Key? key,
    required this.event,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(EventDetailScreen.ROUTE_NAME,
            arguments: EventDetailScreenArguments(eventId: event.id));
      },
      child: Container(
        // --- PERUBAHAN: Menghapus width yang fixed agar responsif terhadap padding Card ---
        // width: screenSize.width - 16.0,
        // --- AKHIR PERUBAHAN ---
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              // --- PERUBAHAN: Mengatur crossAxisAlignment ke start agar konten Column rata kiri atas ---
              crossAxisAlignment: CrossAxisAlignment.start,
              // --- AKHIR PERUBAHAN ---
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Color.fromRGBO(1, 169, 159, 1.0),
                      image: DecorationImage(
                        image: NetworkImage(
                          event.foto.toString(),
                          // --- PERUBAHAN: Tambahkan errorBuilder untuk gambar ---
                          // onError: (exception, stackTrace) { // Named parameter 'onError' is not defined for NetworkImage
                          //   print('Error loading event item image: ${event.foto} - $exception');
                          // }
                          // --- AKHIR PERUBAHAN ---
                        ),
                        fit: BoxFit
                            .cover, // Menggunakan BoxFit.cover untuk mengisi ruang
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    // --- PERUBAHAN: Mengatur mainAxisAlignment ke start dan crossAxisAlignment ke start ---
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // --- AKHIR PERUBAHAN ---
                    children: [
                      Text(
                        event.nama.toString(),
                        style: theme.textTheme
                            .titleMedium // Menggunakan titleMedium untuk ukuran yang lebih sesuai
                            ?.copyWith(fontWeight: FontWeight.w700),
                        // --- PERUBAHAN: Batasi jumlah baris dan tambahkan ellipsis ---
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        // --- AKHIR PERUBAHAN ---
                      ),
                      Text(
                        event.tempat,
                        style:
                            theme.textTheme.bodySmall // Menggunakan bodySmall
                                ?.copyWith(color: Colors.grey),
                        // --- PERUBAHAN: Batasi jumlah baris dan tambahkan ellipsis ---
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // --- AKHIR PERUBAHAN ---
                      ),
                      // --- PERUBAHAN: Menampilkan tanggal event ---
                      Text(
                        DateFormat("dd MMMM yyyy")
                            .format(DateTime.parse(event.tanggal)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // --- AKHIR PERUBAHAN ---
                    ],
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  flex: 1,
                  child: status == 0
                      ? Container(
                          // --- PERUBAHAN: Hapus width dan height yang fixed di dalam Expanded ---
                          // width: 72.0,
                          // height: 36.0,
                          // --- AKHIR PERUBAHAN ---
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              color: Color.fromRGBO(232, 232, 232, 1.0)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                // --- PERUBAHAN: Menggunakan event.tanggal (String) untuk parsing tanggal ---
                                DateFormat("dd")
                                    .format(DateTime.parse(event.tanggal)),
                                // --- AKHIR PERUBAHAN ---
                                style: theme.textTheme.headlineSmall?.copyWith(
                                    // Menggunakan headlineSmall
                                    color: Color.fromRGBO(112, 112, 112, 1.0),
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                // --- PERUBAHAN: Menggunakan event.tanggal (String) untuk parsing bulan ---
                                DateFormat("MMM")
                                    .format(DateTime.parse(event.tanggal)),
                                // --- AKHIR PERUBAHAN ---
                                style: theme.textTheme.bodySmall?.copyWith(
                                    // Menggunakan bodySmall
                                    color: Color.fromRGBO(112, 112, 112, 1.0),
                                    fontSize: 11.0),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          // --- PERUBAHAN: Hapus width dan height yang fixed di dalam Expanded ---
                          // width: 72.0,
                          // height: 36.0,
                          // --- AKHIR PERUBAHAN ---
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
