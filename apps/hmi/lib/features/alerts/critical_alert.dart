import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_protocol/glance_protocol.dart';

import '../../core/providers/telemetry_providers.dart';

enum CriticalAlert { engineWarning, lowFuel }

final alertFlagsProvider = Provider<AlertFlags>((ref) => ref.watch(telemetryProvider.select((snapshot) => AlertFlags(engineWarning: snapshot.has(TelemetryFlag.fiWarning), lowFuel: snapshot.has(TelemetryFlag.lowFuel)))));

final dismissedAlertsProvider = NotifierProvider<DismissedAlertsNotifier, Set<CriticalAlert>>(DismissedAlertsNotifier.new);

final criticalAlertProvider = Provider<CriticalAlert?>((ref) {
  final flags = ref.watch(alertFlagsProvider);
  final dismissed = ref.watch(dismissedAlertsProvider);
  for (final alert in CriticalAlert.values) {
    if (flags.isActive(alert) && !dismissed.contains(alert)) return alert;
  }
  return null;
});

final class AlertFlags {
  final bool engineWarning;
  final bool lowFuel;

  const AlertFlags({required this.engineWarning, required this.lowFuel});

  bool isActive(CriticalAlert alert) => switch (alert) {
    CriticalAlert.engineWarning => engineWarning,
    CriticalAlert.lowFuel => lowFuel,
  };

  @override
  bool operator ==(Object other) => other is AlertFlags && other.engineWarning == engineWarning && other.lowFuel == lowFuel;

  @override
  int get hashCode => Object.hash(engineWarning, lowFuel);
}

class DismissedAlertsNotifier extends Notifier<Set<CriticalAlert>> {
  void dismiss(CriticalAlert alert) => state = {...state, alert};

  @override
  Set<CriticalAlert> build() {
    ref.listen(
      alertFlagsProvider,
      (_, flags) => state = {
        for (final alert in state)
          if (flags.isActive(alert)) alert,
      },
    );
    return const {};
  }
}
