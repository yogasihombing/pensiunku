import 'package:flutter/material.dart';
import 'package:pensiunku/repository/salary_place_repository.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/home_screen.dart';
import 'package:pensiunku/screen/register/register_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class PrepareRegisterScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/register/prepare';

  @override
  _PrepareRegisterScreenState createState() => _PrepareRegisterScreenState();
}

class _PrepareRegisterScreenState extends State<PrepareRegisterScreen> {
  bool _isLoading = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();

    _checkUser();
  }

  Future<void> _checkUser() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token != null) {
      UserRepository().getOne(token).then((result) {
        setState(() {
          _isLoading = false;
        });
        if (result.isSuccess) {
          if (result.data?.isRegistrationComplete() == true) {
            print(1);
            _checkSalaryPlaces();
          } else if (result.data?.username != null) {
            print(2);
            Navigator.of(context).pushReplacementNamed(HomeScreen.ROUTE_NAME);
          } else {
            print(3);
            Navigator.of(context)
                .pushReplacementNamed(RegisterScreen.ROUTE_NAME);
          }
        } else {
          setState(() {
            _isError = true;
          });
        }
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return CircularProgressIndicator();
    if (_isError)
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tidak dapat mengambil data pengguna. Tolong periksa Internet Anda.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _checkUser,
              child: Text('Refresh'),
            ),
          ],
        ),
      );
    return Container();
  }

  void _checkSalaryPlaces() {
    setState(() {
      _isLoading = true;
    });
    SalaryPlaceRepository().getAll().then((result) {
      if (result.isSuccess && result.data?.isNotEmpty == true) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.ROUTE_NAME);
      } else {
        print(1111);
        setState(() {
          _isError = true;
        });
      }
    });
  }
}

// class PrepareRegisterScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/register/prepare';

//   @override
//   _PrepareRegisterScreenState createState() => _PrepareRegisterScreenState();
// }

// class _PrepareRegisterScreenState extends State<PrepareRegisterScreen> {
//   bool _isLoading = false;
//   bool _isError = false;

//   @override
//   void initState() {
//     super.initState();

//     _checkUser();
//   }

//   Future<void> _checkUser() async {
//     setState(() {
//       _isLoading = true;
//       _isError = false;
//     });
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     if (token != null) {
//       UserRepository().getOne(token).then((result) {
//         setState(() {
//           _isLoading = false;
//         });
//         if (result.isSuccess) {
//           if (result.data?.isRegistrationComplete() == true) {
//             print(1);
//             _checkSalaryPlaces();
//           } else if (result.data?.username != null) {
//             print(2);
//             Navigator.of(context).pushReplacementNamed(HomeScreen.ROUTE_NAME);
//           } else {
//             print(3);
//             Navigator.of(context)
//                 .pushReplacementNamed(RegisterScreen.ROUTE_NAME);
//           }
//         } else {
//           setState(() {
//             _isError = true;
//           });
//         }
//       });
//     } else {
//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: _buildBody(),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) return CircularProgressIndicator();
//     if (_isError)
//       return Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Tidak dapat mengambil data pengguna. Tolong periksa Internet Anda.',
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 24.0),
//             ElevatedButton(
//               onPressed: _checkUser,
//               child: Text('Refresh'),
//             ),
//           ],
//         ),
//       );
//     return Container();
//   }

//   void _checkSalaryPlaces() {
//     setState(() {
//       _isLoading = true;
//     });
//     SalaryPlaceRepository().getAll().then((result) {
//       if (result.isSuccess && result.data?.isNotEmpty == true) {
//         Navigator.of(context).pushReplacementNamed(HomeScreen.ROUTE_NAME);
//       } else {
//         print(1111);
//         setState(() {
//           _isError = true;
//         });
//       }
//     });
//   }
// }
