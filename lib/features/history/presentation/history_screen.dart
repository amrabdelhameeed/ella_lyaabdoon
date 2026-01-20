import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late CalendarController _calendarController;

  // Showcase Keys
  final GlobalKey _calendarKey = GlobalKey();

  // Constants
  static const String _showcaseKey = 'history_showcase_shown12';

  // Track if showcase key has been used
  bool _showcaseKeyUsed = false;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();

    // Start showcase after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startShowcase();
    });
  }

  void _startShowcase() async {
    if (!CacheHelper.getBool(_showcaseKey) && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        try {
          // ShowCaseWidget.of(context).startShowCase([_calendarKey]);
          CacheHelper.setBool(_showcaseKey, true);
        } catch (e) {
          debugPrint('Showcase error: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      autoPlayDelay: const Duration(seconds: 3),
      disableBarrierInteraction: false,
      autoPlay: true,
      builder: (context) => Scaffold(
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 20),
                  width: double.infinity,
                  // height: 200,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('showcase_appointment_title'.tr()),
                        Divider(),
                        Text('showcase_appointment_desc'.tr()),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: const Icon(Icons.info_outline),
        ),
        appBar: AppBar(title: Text('history'.tr()), centerTitle: true),
        body: FutureBuilder<_CalendarDataSource>(
          future: _loadDataSource(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorWidget(context);
            }

            // Reset the flag when rebuilding
            _showcaseKeyUsed = false;

            return _buildCalendar(context, snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text('history_error'.tr(), style: theme.textTheme.bodyLarge),
    );
  }

  Widget _buildCalendar(BuildContext context, _CalendarDataSource dataSource) {
    return SfCalendar(
      appointmentTextStyle: TextStyle(color: Colors.transparent),

      maxDate: DateTime.now(),
      initialSelectedDate: DateTime.now(),
      initialDisplayDate: DateTime.now(),
      controller: _calendarController,
      view: CalendarView.month,
      dataSource: dataSource,
      firstDayOfWeek: 6,
      showDatePickerButton: true,

      headerStyle: const CalendarHeaderStyle(
        backgroundColor: Colors.transparent,
      ),
      monthViewSettings: const MonthViewSettings(
        agendaStyle: AgendaStyle(
          placeholderTextStyle: TextStyle(color: Colors.transparent),
        ),
        showAgenda: true,

        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
      ),
      appointmentBuilder: (context, details) =>
          _buildAppointment(context, details),
      onTap: (details) => _handleCalendarTap(context, details),
      onLongPress: (details) => _handleCalendarLongPress(context, details),
    );
  }

  Widget _buildAppointment(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final theme = Theme.of(context);
    final appointment = details.appointments.first as Appointment;

    final appointmentWidget = Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        appointment.subject,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    // Only wrap the first appointment with Showcase
    if (!_showcaseKeyUsed) {
      _showcaseKeyUsed = true;
      return Showcase(
        key: _calendarKey,
        title: 'showcase_calendar_title'.tr(),
        description: 'showcase_calendar_desc'.tr(),
        tooltipPosition: TooltipPosition.bottom,
        targetPadding: const EdgeInsets.all(8),
        showArrow: true,
        disableMovingAnimation: true,
        disableScaleAnimation: true,
        // tooltipAlignment: Alignment.bottomCenter,
        // tooltipMargin: const EdgeInsets.only(top: 16),
        child: appointmentWidget,
      );
    }

    return appointmentWidget;
  }

  void _handleCalendarTap(BuildContext context, CalendarTapDetails details) {
    if (details.targetElement != CalendarElement.appointment) return;
    if (details.appointments == null || details.appointments!.isEmpty) return;

    final appointment = details.appointments!.first as Appointment;
    final zikrId = appointment.notes;

    if (zikrId == null) return;

    _showZikrDetailsDialog(context, appointment, zikrId);
  }

  void _showZikrDetailsDialog(
    BuildContext context,
    Appointment appointment,
    String zikrId,
  ) {
    final count = HistoryDBProvider.getChecks(zikrId).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment.subject),
        content: Text('${'zikr_done_count'.tr()} : $count'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );

    debugPrint('Pressed zikr: ${appointment.subject}');
  }

  void _handleCalendarLongPress(
    BuildContext context,
    CalendarLongPressDetails details,
  ) {
    if (details.appointments == null || details.appointments!.isEmpty) return;

    final appointment = details.appointments!.first as Appointment;
    final zikrId = appointment.notes;

    if (zikrId == null) return;

    _showDeleteDialog(
      context,
      appointment.subject,
      appointment.startTime,
      zikrId,
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String title,
    DateTime date,
    String zikrId,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_zikr'.tr()),
        content: Text('delete_zikr_confirm'.tr(namedArgs: {'zikr': title})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => _deleteZikr(context, zikrId, date),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteZikr(
    BuildContext context,
    String zikrId,
    DateTime date,
  ) async {
    await HistoryDBProvider.removeCheck(zikrId, date);
    if (mounted) {
      Navigator.pop(context);
      setState(() {});
    }
  }

  Future<_CalendarDataSource> _loadDataSource(BuildContext context) async {
    final appointments = <Appointment>[];
    final theme = Theme.of(context);

    final allRewards = AppLists.timelineItems
        .expand((item) => item.rewards)
        .toList();

    for (var reward in allRewards) {
      final checks = HistoryDBProvider.getChecks(reward.id);

      for (var date in checks) {
        appointments.add(
          Appointment(
            startTime: date,
            endTime: date.add(const Duration(minutes: 1)),
            subject: reward.title,
            notes: reward.id,
            isAllDay: true,
            color: theme.colorScheme.primary,
          ),
        );
      }
    }

    return _CalendarDataSource(appointments);
  }
}

class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(List<Appointment> source) {
    appointments = source;
  }
}
