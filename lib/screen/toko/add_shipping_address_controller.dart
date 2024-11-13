class AddShippingAddressController {
  bool isAllInputValid(
    String inputAddress,
    String inputProvince,
    String inputKabupaten,
    String inputKecamatan,
    String inputKelurahan,
    String inputPhone,
  ) {
    return getInputAddressError(inputAddress) != null ||
        getInputPhoneError(inputPhone) != null ||
        getInputProvinceError(inputProvince) != null ||
        getInputKabupatenError(inputKabupaten) != null ||
        getInputKecamatanError(inputKecamatan) != null ||
        getInputKelurahanError(inputKelurahan) != null;
  }

  String? getInputAddressError(String inputAddress) {
    if (inputAddress.isEmpty) {
      return "Alamat harus diisi";
    }
    return null;
  }

  String? getInputPhoneError(String inputPhone) {
    if (inputPhone.isEmpty) {
      return "No. Handphone harus diisi";
    } else if (!inputPhone.trim().startsWith('0')) {
      return "Nomor telepon harus mulai dari angka 0";
    } else if (inputPhone.trim().length < 8) {
      return "No. Handphone harus terdiri dari min. 8 karakter";
    }
    return null;
  }

  String? getInputProvinceError(String inputProvince) {
    if (inputProvince.isEmpty) {
      return "Provinsi harus diisi";
    }
    return null;
  }

  String? getInputKabupatenError(String inputKabupaten) {
    if (inputKabupaten.isEmpty) {
      return "Kabupaten/Kota harus diisi";
    }
    return null;
  }

  String? getInputKecamatanError(String inputKecamatan) {
    if (inputKecamatan.isEmpty) {
      return "Kecamatan harus diisi";
    }
    return null;
  }

  String? getInputKelurahanError(String inputDesa) {
    if (inputDesa.isEmpty) {
      return "Desa/Kelurahan harus diisi";
    }
    return null;
  }
}
