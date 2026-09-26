import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/vehicle_providers.dart';

enum Notice { batteryLow, service }

const int _serviceSoonKm = 300;

final dismissedNoticesProvider = NotifierProvider<DismissedNoticesNotifier, Set<Notice>>(DismissedNoticesNotifier.new);

final noticeProvider = Provider<Notice?>((ref) {
  final dismissed = ref.watch(dismissedNoticesProvider);
  if (ref.watch(batteryLowProvider) && !dismissed.contains(Notice.batteryLow)) return Notice.batteryLow;
  final serviceKm = ref.watch(serviceRemainingKmProvider);
  return serviceKm != null && serviceKm <= _serviceSoonKm && !dismissed.contains(Notice.service) ? Notice.service : null;
});

class DismissedNoticesNotifier extends Notifier<Set<Notice>> {
  void dismiss(Notice notice) => state = {...state, notice};

  @override
  Set<Notice> build() {
    ref.listen(batteryLowProvider, (_, low) {
      if (!low) state = {...state}..remove(Notice.batteryLow);
    });
    return const {};
  }
}
