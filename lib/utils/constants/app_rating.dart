// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:rate_my_app/rate_my_app.dart';

// class AppRating {
//   static final _rate = RateMyApp(
//     minDays: 3,
//     minLaunches: 10,
//     remindDays: 10,
//     remindLaunches: 10,
//     preferencesPrefix: 'arab_',
//     googlePlayIdentifier: 'af.secuirties.mobile_new',
//     appStoreIdentifier: 'af.secuirties.mobile_new',
//   );
//   static void rating(BuildContext context) async {
//     await _rate.init().then((value) async {
//       if (_rate.shouldOpenDialog) {
//         _rate
//             .showStarRateDialog(context,
//                 onDismissed: () =>
//                     _rate.callEvent(RateMyAppEventType.laterButtonPressed),
//                 actionsBuilder: (context, stars) {
//                   return [
//                     TextButton(
//                         onPressed: () async {
//                           _rate
//                               .callEvent(RateMyAppEventType.laterButtonPressed);
//                           Navigator.pop(context);
//                         },
//                         child: Text("cancel".tr())),
//                     TextButton(
//                         onPressed: () async {
//                           if (stars != null && stars >= 3) {
//                             await _rate.callEvent(
//                                 RateMyAppEventType.rateButtonPressed);
//                             Navigator.pop<RateMyAppDialogButton>(
//                                 context, RateMyAppDialogButton.rate);
//                             _rate.launchStore();
//                           } else {
//                             Navigator.pop(context);
//                             showDialog(
//                               context: context,
//                               builder: (context) {
//                                 final _controller = TextEditingController();
//                                 final _formKey = GlobalKey<FormState>();
//                                 return Form(
//                                     key: _formKey,
//                                     child: AlertDialog(
//                                       content: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           TextFormField(
//                                             decoration: InputDecoration(
//                                                 hintText:
//                                                     "enter your feedback".tr(),
//                                                 border: OutlineInputBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10))),
//                                             controller: _controller,
//                                             validator: (value) {
//                                               if (value == null ||
//                                                   value.isEmpty) {
//                                                 return "please_enter_valid_value"
//                                                     .tr();
//                                               }
//                                               return null;
//                                             },
//                                             maxLines: 3,
//                                           )
//                                         ],
//                                       ),
//                                       actions: [
//                                         TextButton(
//                                             onPressed: () {
//                                               if (_formKey.currentState!
//                                                   .validate()) {
//                                                 //connect@gurow.io
//                                                 sendEmail(
//                                                     '#Review from ${FirebaseAuth.instance.currentUser!.email} , ${stars != null ? (stars.toInt()) : ""}${stars != null ? " stars" : ""} \n \"${_controller.text}\"',
//                                                     emails: [
//                                                       "connect@gurow.io"
//                                                     ]).then((value) {
//                                                   if (value.isEmpty) {
//                                                     ScaffoldMessenger.of(
//                                                             context)
//                                                         .showSnackBar(SnackBar(
//                                                             content: Text(
//                                                                     'Sent Success')
//                                                                 .tr()));
//                                                   }
//                                                   Navigator.pop(context);
//                                                 });
//                                               }
//                                             },
//                                             child: Text('send feedback'.tr()))
//                                       ],
//                                     ));
//                               },
//                             );
//                           }
//                         },
//                         child: Text("ok".tr())),
//                   ];
//                 },
//                 title: "Enjoy our app ?".tr(),
//                 message: "Please leave a rating!".tr(),
//                 starRatingOptions: StarRatingOptions())
//             .then((value) {});
//       }
//       if (kDebugMode) {
//         _rate.conditions.forEach((element) {
//           if (element is DebuggableCondition) {
//             print(element.debugMap);
//             // if (element.isMet) {
//             //   final shared = SharedPreferences.getInstance().then((value) {
//             //     element.saveToPreferences(value, 'arabfinance_');
//             //   });
//             // }
//           }
//         });
//       }
//     });
//   }
// }
