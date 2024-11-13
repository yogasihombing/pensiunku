class PengajuanFormError {
  final String? errorUsia;
  final String? errorDomisili;
  final String? errorInstansi;
  final String? errorNIP;
  final String? errorKTP;
  final String? errorNPWP;

  PengajuanFormError({
    this.errorUsia,
    this.errorDomisili,
    this.errorInstansi,
    this.errorNIP,
    this.errorKTP,
    this.errorNPWP,
  });

  bool get isValid {
    return errorUsia == null &&
        errorDomisili == null &&
        errorInstansi == null &&
        errorNIP == null &&
        errorKTP == null &&
        errorNPWP == null;
  }
}
