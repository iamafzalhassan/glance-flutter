import 'package:glance_protocol/glance_protocol.dart';

final class LinkStats {
  static const LinkStats empty = LinkStats(delayMs: 0, framesPerSecond: 0, outOfOrderFrames: 0, spikeFrames: 0, rejectedFrames: {});

  final int delayMs;
  final int framesPerSecond;
  final int outOfOrderFrames;
  final int spikeFrames;

  final Map<FrameRejection, int> rejectedFrames;

  const LinkStats({required this.delayMs, required this.framesPerSecond, required this.outOfOrderFrames, required this.spikeFrames, required this.rejectedFrames});

  int get discardedFrames => outOfOrderFrames + spikeFrames + rejectedFrames.values.fold(0, (sum, count) => sum + count);

  int rejectedFor(FrameRejection reason) => rejectedFrames[reason] ?? 0;
}
