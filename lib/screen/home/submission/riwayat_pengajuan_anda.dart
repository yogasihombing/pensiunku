import 'package:flutter/material.dart';
import 'package:pensiunku/model/riwayat_pengajuan_anda_model.dart';
import 'package:pensiunku/repository/riwayat_pengajuan_anda_repository.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/ajukan/pengajuan_anda_screen.dart';
import 'package:pensiunku/screen/home/submission/status_pengajuan_anda.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/dialog_helper.dart';

class RiwayatPengajuanAndaScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/riwayat_pengajuan_anda';
  final void Function(int index) onChangeBottomNavIndex;

  const RiwayatPengajuanAndaScreen({
    Key? key,
    required this.onChangeBottomNavIndex,
  }) : super(key: key);

  @override
  State<RiwayatPengajuanAndaScreen> createState() =>
      _RiwayatPengajuanAndaScreenState();
}

class _RiwayatPengajuanAndaScreenState
    extends State<RiwayatPengajuanAndaScreen> {
  final _repository = RiwayatPengajuanAndaRepository();
  List<RiwayatPengajuanAndaModel> _pengajuanList = [];
  bool _isLoading = true;
  String _telepon = '';

  @override
  void initState() {
    super.initState();
    _getProfileAndData();
  }

  Future<void> _getProfileAndData() async {
    setState(() => _isLoading = true);
    final token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null || token.isEmpty) {
      setState(() => _isLoading = false);
      DialogHelper.showErrorDialog(
        context,
        'Autentikasi Gagal',
        'Token tidak ditemukan. Harap login kembali.',
      );
      return;
    }

    try {
      final result = await UserRepository().getOne(token);
      if (result.error != null) {
        setState(() => _isLoading = false);
        DialogHelper.showErrorDialog(context, 'Error', result.error!);
        return;
      }

      _telepon = result.data?.phone ?? '';
      await _fetchPengajuanData();
    } catch (e) {
      setState(() => _isLoading = false);
      DialogHelper.showErrorDialog(
        context,
        'Error',
        'Gagal memuat profil: ${e.toString()}',
      );
    }
  }

  Future<void> _fetchPengajuanData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repository.getRiwayatPengajuanAnda(_telepon);
      setState(() {
        _pengajuanList = data;
        _isLoading = false;
      });

      if (data.isEmpty) {
        await showDialog(
          context: context,
          builder: (_) => DialogHelper(
            title: 'Informasi',
            description:
                'Tidak ada riwayat pengajuan Anda.\nAjukan permohonan sekarang.',
            buttonText: 'Ajukan Sekarang',
            dialogType: DialogType.success,
            onButtonPress: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PengajuanAndaScreen(),
                ),
              );
            },
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      await showDialog(
        context: context,
        builder: (_) => DialogHelper(
          title: 'Error Memuat Data',
          description:
              'Terjadi kesalahan saat memuat riwayat pengajuan Anda: ${e.toString()}',
          buttonText: 'Coba Lagi',
          dialogType: DialogType.error,
          onButtonPress: () {
            Navigator.of(context).pop();
            _fetchPengajuanData();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF017964)),
          onPressed: () {
            if (Navigator.canPop(context))
              Navigator.pop(context);
            else
              widget.onChangeBottomNavIndex(0);
          },
        ),
        title: const Text(
          'Riwayat Pengajuan',
          style: TextStyle(
            color: Color(0xFF017964),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFDCE293)],
            stops: [0.6, 1.0],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () => _fetchPengajuanData(),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pengajuanList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _pengajuanList.length,
                      itemBuilder: (_, index) {
                        final item = _pengajuanList[index];
                        return PengajuanCard(
                          pengajuan: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StatusPengajuanAndaScreen(
                                  pengajuanAnda: item,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const Center(
              child: Text(
                'AJUKAN PINJAMAN SEKARANG!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

class PengajuanCard extends StatelessWidget {
  final RiwayatPengajuanAndaModel pengajuan;
  final VoidCallback onTap;

  const PengajuanCard({
    Key? key,
    required this.pengajuan,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pengajuan.nama,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF017964),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          size: 20,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pengajuan ${pengajuan.tiket}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 12),
                        Text(pengajuan.tanggal),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Status: ${pengajuan.statusPengajuan}',
                      style: TextStyle(
                        color: _getStatusColor(pengajuan.statusPengajuan),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF017964),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
