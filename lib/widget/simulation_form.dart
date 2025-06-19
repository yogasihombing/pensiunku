import 'package:flutter/material.dart';
import 'package:pensiunku/model/simulation_form_model.dart';

import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:pensiunku/widget/simulation_form_type/pegawai_aktif_form.dart';
import 'package:pensiunku/widget/simulation_form_type/pensiun_form.dart';
import 'package:pensiunku/widget/simulation_form_type/platinum_form.dart';
import 'package:pensiunku/widget/simulation_form_type/pra_pensiun_form.dart';

class SimulationForm extends StatefulWidget {
  final bool isLoading;
  final bool showError;

  final Color inputColor;
  final SimulationFormType? simulationFormType;
  final SimulationFormModel? simulationFormModel;

  const SimulationForm({
    Key? key,
    required this.isLoading,
    required this.showError,
    this.inputColor = Colors.white,
    this.simulationFormType,
    this.simulationFormModel,
  }) : super(key: key);

  @override
  _SimulationFormState createState() => _SimulationFormState();
}

class _SimulationFormState extends State<SimulationForm> {
  late Future<ResultModel<UserModel>> _futureData;

  @override
  void initState() {
    super.initState();

    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return FutureBuilder(
      future: _futureData,
      builder: (BuildContext context,
          AsyncSnapshot<ResultModel<UserModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data?.data != null) {
            UserModel data = snapshot.data!.data!;
            SimulationFormType? formType;
            if (widget.simulationFormType != null) {
              formType = widget.simulationFormType;
            } else {
              formType = data.getSimulationFormType();
            }
            switch (formType) {

              default:
                return Container();
            }
          } else {
            String errorTitle = 'Tidak dapat menampilkan form simulasi';
            String? errorSubtitle = snapshot.data?.error;
            return Column(
              children: [
                SizedBox(height: 16),
                ErrorCard(
                  title: errorTitle,
                  subtitle: errorSubtitle,
                  iconData: Icons.warning_rounded,
                ),
              ],
            );
          }
        } else {
          return Column(
            children: [
              SizedBox(height: 16),
              Center(
                child: CircularProgressIndicator(
                  color: theme.primaryColor,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    return _futureData = UserRepository().getOneDb(token!);
  }
}
// cek juga di simulation_result_screen dan simulation_form_scree//