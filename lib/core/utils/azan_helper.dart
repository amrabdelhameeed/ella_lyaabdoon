import 'package:adhan_dart/adhan_dart.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';

class AzanHelper {
  final double latitude;
  final double longitude;

  late final PrayerTimes prayerTimes;

  AzanHelper({required this.latitude, required this.longitude}) {
    final coordinates = Coordinates(latitude, longitude);

    final params = CalculationMethodParameters.egyptian()
      ..madhab = Madhab.shafi;

    prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: DateTime.now(),
      calculationParameters: params,
      precision: true,
    );
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
