import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/model/simulation_form_model.dart';
import 'package:pensiunku/util/api_util.dart';

class SimulationApi extends BaseApi {
  dynamic preparePengajuanForm(PengajuanFormModel formModel) {
    return {
      'produk': 'pengajuan',
      'usia': formModel.usia,
      'domisili': formModel.domisili,
      'instansi': formModel.instansi,
      'nip': formModel.nip,
      'ktp': formModel.ktp,
      'npwp': formModel.npwp,
    };
  }
  // harusnya ini sudah beres //

  // dynamic preparePensiunForm(PensiunFormModel formModel) {
  //   return {
  //     'produk': 'pensiun',
  //     'name': formModel.name,
  //     'phone': formModel.phone,
  //     'status_pensiun': formModel.statusPensiun.text,
  //     'tanggal_lahir': DateFormat('yyyy-MM-dd').format(formModel.birthDate),
  //     'gaji': formModel.salary,
  //     'tenorbulan': formModel.tenor,
  //     'plafond': formModel.plafond,
  //     'bank': formModel.salaryPlace.text,
  //     'sisa_hutang': formModel.sisaHutang,
  //     'bank_hutang': formModel.bankHutang.text,
  //   };
  // }

  // dynamic preparePraPensiunForm(PraPensiunFormModel formModel) {
  //   return {
  //     'produk': 'prapensiun',
  //     'name': formModel.name,
  //     'phone': formModel.phone,
  //     'tanggal_lahir': DateFormat('yyyy-MM-dd').format(formModel.birthDate),
  //     'gaji': formModel.salary,
  //     'tenorbulan': formModel.tenor,
  //     'plafond': formModel.plafond,
  //     'bank': formModel.salaryPlace.text,
  //     'pensiun': formModel.age,
  //     'bup': formModel.bup,
  //     'sisa_hutang': formModel.sisaHutang,
  //     'bank_hutang': formModel.bankHutang.text,
  //   };
  // }

  // dynamic preparePlatinumForm(PlatinumFormModel formModel) {
  //   return {
  //     'produk': 'platinum',
  //     'name': formModel.name,
  //     'phone': formModel.phone,
  //     'tanggal_lahir': DateFormat('yyyy-MM-dd').format(formModel.birthDate),
  //     'gaji': formModel.salary,
  //     'tenorbulan': '${formModel.tenor.id}',
  //     'provinsi': '${formModel.province.text}',
  //     'angsuran': formModel.angsuran,
  //     'bank': formModel.salaryPlace.text,
  //   };
  // }

  Future<Response> simulatePengajuanForm(
    String token,
    PengajuanFormModel formModel,
  ) {
    var data = preparePengajuanForm(formModel);
    log(data.toString());
    return httpPost(
      '/simulation',
      data: data,
      options: ApiUtil.getTokenOptions(token),
    );
  }
  // harusnya ini sudah beres //
}
