import 'package:adhan_dart/adhan_dart.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';

class AzanHelper {
  final double latitude;
  final double longitude;

  late final PrayerTimes prayerTimes;

  AzanHelper({required this.latitude, required this.longitude}) {
    final coordinates = Coordinates(latitude, longitude);

    final methodStr = AppServicesDBprovider.getCalculationMethod();
    final madhabStr = AppServicesDBprovider.getMadhab();

    final params = _getParams(methodStr)
      ..madhab = (madhabStr == 'hanafi' ? Madhab.hanafi : Madhab.shafi);

    prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: DateTime.now(),
      calculationParameters: params,
      precision: true,
    );
  }
  CalculationParameters _getParams(String method) {
    switch (method) {
      case 'karachi':
        return CalculationMethodParameters.karachi();

      case 'isna':
      case 'north_america':
        return CalculationMethodParameters.northAmerica();

      case 'muslim_world_league':
        return CalculationMethodParameters.muslimWorldLeague();

      case 'umm_al_qura':
        return CalculationMethodParameters.ummAlQura();

      case 'dubai':
        return CalculationMethodParameters.dubai();

      case 'kuwait':
        return CalculationMethodParameters.kuwait();

      case 'qatar':
        return CalculationMethodParameters.qatar();

      case 'singapore':
        return CalculationMethodParameters.singapore();

      case 'tehran':
        return CalculationMethodParameters.tehran();

      case 'egyptian':
        return CalculationMethodParameters.egyptian();

      case 'turkiye':
        return CalculationMethodParameters.turkiye();

      case 'morocco':
        return CalculationMethodParameters.morocco();

      case 'moonsighting_committee':
        return CalculationMethodParameters.moonsightingCommittee();

      case 'other':
        return CalculationMethodParameters.other();

      default:
        return CalculationMethodParameters.egyptian();
    }
  }

  DateTime get fajr => prayerTimes.fajr.toLocal();
  DateTime get sunrise => prayerTimes.sunrise.toLocal();
  DateTime get dhuhr => prayerTimes.dhuhr.toLocal();
  DateTime get asr => prayerTimes.asr.toLocal();
  DateTime get maghrib => prayerTimes.maghrib.toLocal();
  DateTime get isha => prayerTimes.isha.toLocal();

  AzanDayPeriod getCurrentPeriod() {
    final now = DateTime.now();
    if (now.isAfter(fajr) && now.isBefore(sunrise)) return AzanDayPeriod.fajr;
    if (now.isAfter(sunrise) && now.isBefore(dhuhr)) {
      return AzanDayPeriod.shorouq;
    }
    if (now.isAfter(dhuhr) && now.isBefore(asr)) return AzanDayPeriod.duhr;
    if (now.isAfter(asr) && now.isBefore(maghrib)) return AzanDayPeriod.asr;
    if (now.isAfter(maghrib) && now.isBefore(isha)) {
      return AzanDayPeriod.maghrib;
    }
    if (now.isAfter(isha)) return AzanDayPeriod.isha;
    return AzanDayPeriod.night;
  }

  DateTime getNextPrayerTime(DateTime now) {
    if (now.isBefore(fajr)) return fajr;
    if (now.isBefore(sunrise)) return sunrise;
    if (now.isBefore(dhuhr)) return dhuhr;
    if (now.isBefore(asr)) return asr;
    if (now.isBefore(maghrib)) return maghrib;
    if (now.isBefore(isha)) return isha;

    // If after isha, next is Fajr tomorrow
    // Ideally we should calculate for tomorrow, but for now roughly add 24h to current Fajr or just use current Fajr + 1 day
    return fajr.add(const Duration(days: 1));
  }
}
