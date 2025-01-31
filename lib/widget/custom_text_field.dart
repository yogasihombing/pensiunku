import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool useLabel;
  // final bool readOnly;
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  // final String initialValue;
  final Color fillColor;
  final Widget? prefix;
  final Widget? suffix;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final TextAlign textAlign;
  final double borderRadius;
  final double fontSize;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.keyboardType,
    // required this.readOnly,
    this.onChanged,
    this.enabled = true,
    this.useLabel = true,
    this.hintText,
    this.minLines,
    this.maxLines,
    // this.initialValue = '',
    this.fillColor = const Color.fromARGB(255, 226, 226, 226),
    this.prefix,
    this.suffix,
    this.errorText,
    this.helperText,
    this.controller,
    this.inputFormatters,
    this.contentPadding,
    this.textAlign = TextAlign.start,
    this.borderRadius = 8.0,
    this.fontSize = 12.0, // Default ukuran font 16
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            textAlign: widget.textAlign,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(
                fontSize: widget.fontSize), // Gunakan ukuran font yang diatur
            decoration: InputDecoration(
              prefix: widget.prefix,
              suffix: widget.suffix,
              filled: true,
              labelText: widget.hintText,
              // labelText: showLabelText ? widget.hintText : '',
              errorText: widget.errorText,
              hintText: widget.hintText,
              helperText: widget.helperText,
              fillColor: widget.fillColor,
              focusedBorder: OutlineInputBorder(
                gapPadding: 0.0,
                borderSide: BorderSide(
                  color: theme.primaryColor,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              focusedErrorBorder: OutlineInputBorder(
                gapPadding: 0.0,
                borderSide: BorderSide(color: theme.errorColor),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.errorColor),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              contentPadding: widget.contentPadding,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


// class CustomTextField extends StatefulWidget {
//   final String labelText;
//   final TextInputType? keyboardType;
//   final void Function(String)? onChanged;
//   final bool enabled;
//   final bool useLabel;
//   // final bool readOnly;
//   final String? hintText;
//   final int? minLines;
//   final int? maxLines;
//   // final String initialValue;
//   final Color fillColor;
//   final Widget? prefix;
//   final Widget? suffix;
//   final String? errorText;
//   final String? helperText;
//   final TextEditingController? controller;
//   final List<TextInputFormatter>? inputFormatters;
//   final EdgeInsetsGeometry? contentPadding;
//   final TextAlign textAlign;
//   final double borderRadius;

//   const CustomTextField({
//     Key? key,
//     required this.labelText,
//     this.keyboardType,
//     // required this.readOnly,
//     this.onChanged,
//     this.enabled = true,
//     this.useLabel = true,
//     this.hintText,
//     this.minLines,
//     this.maxLines,
//     // this.initialValue = '',
//     this.fillColor = const Color.fromARGB(255, 226, 226, 226),
//     this.prefix,
//     this.suffix,
//     this.errorText,
//     this.helperText,
//     this.controller,
//     this.inputFormatters,
//     this.contentPadding,
//     this.textAlign = TextAlign.start,
//     this.borderRadius = 8.0,
//   }) : super(key: key);

//   @override
//   _CustomTextFieldState createState() => _CustomTextFieldState();
// }

// class _CustomTextFieldState extends State<CustomTextField> {
//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);

//     return Stack(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 8.0),
//           child: TextFormField(
//             controller: widget.controller,
//             enabled: widget.enabled,
//             keyboardType: widget.keyboardType,
//             onChanged: widget.onChanged,
//             minLines: widget.minLines,
//             maxLines: widget.maxLines,
//             textAlign: widget.textAlign,
//             inputFormatters: widget.inputFormatters,
//             decoration: InputDecoration(
//               prefix: widget.prefix,
//               suffix: widget.suffix,
//               filled: true,
//               labelText: widget.hintText,
//               // labelText: showLabelText ? widget.hintText : '',
//               errorText: widget.errorText,
//               hintText: widget.hintText,
//               helperText: widget.helperText,
//               fillColor: widget.fillColor,
//               focusedBorder: OutlineInputBorder(
//                 gapPadding: 0.0,
//                 borderSide: BorderSide(
//                   color: theme.primaryColor,
//                 ),
//                 borderRadius: BorderRadius.circular(widget.borderRadius),
//               ),
//               focusedErrorBorder: OutlineInputBorder(
//                 gapPadding: 0.0,
//                 borderSide: BorderSide(color: theme.errorColor),
//                 borderRadius: BorderRadius.circular(widget.borderRadius),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: theme.errorColor),
//                 borderRadius: BorderRadius.circular(widget.borderRadius),
//               ),
//               contentPadding: widget.contentPadding,
//               border: OutlineInputBorder(
//                 borderSide: BorderSide.none,
//                 borderRadius: BorderRadius.circular(widget.borderRadius),
//               ),
//             ),
//           ),
//         ),
//         // if (showLabelText && widget.hintText != null)
//         //   Positioned(
//         //     top: 8.0,
//         //     left: 16.0,
//         //     child: Container(
//         //       decoration: BoxDecoration(
//         //         color: Colors.white,
//         //         borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0)),
//         //       ),
//         //       child: Padding(
//         //         padding: const EdgeInsets.symmetric(horizontal: 4.0),
//         //         child: Text(
//         //           widget.hintText!,
//         //           style: theme.textTheme.bodyText1?.copyWith(
//         //             color: Colors.white,
//         //           ),
//         //         ),
//         //       ),
//         //     ),
//         //   ),
//         // if (showLabelText && widget.hintText != null)
//         //   Positioned(
//         //     top: 0.0,
//         //     left: 16.0,
//         //     child: Container(
//         //       child: Padding(
//         //         padding: const EdgeInsets.symmetric(horizontal: 4.0),
//         //         child: Text(widget.hintText!),
//         //       ),
//         //     ),
//         //   ),
//       ],
//     );
//   }
// }
