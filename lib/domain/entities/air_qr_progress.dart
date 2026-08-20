import 'package:flutter/foundation.dart';

enum AirQrStatus { idle, receiving, completed, error }

/// Represents real-time progress state for receiving an optical AirQR stream.
@immutable
class AirQrProgress {
  final String? streamId;
  final int totalBlocks;
  final int receivedBlockCount;
  final Set<int> capturedIndices;
  final double fps;
  final AirQrStatus status;
  final String? reassembledContent;
  final String? errorMessage;

  const AirQrProgress({
    this.streamId,
    this.totalBlocks = 0,
    this.receivedBlockCount = 0,
    this.capturedIndices = const <int>{},
    this.fps = 0.0,
    this.status = AirQrStatus.idle,
    this.reassembledContent,
    this.errorMessage,
  });

  double get progressRatio => totalBlocks > 0
      ? (receivedBlockCount / totalBlocks).clamp(0.0, 1.0)
      : 0.0;

  int get progressPercent => (progressRatio * 100).round();

  AirQrProgress copyWith({
    String? streamId,
    int? totalBlocks,
    int? receivedBlockCount,
    Set<int>? capturedIndices,
    double? fps,
    AirQrStatus? status,
    String? reassembledContent,
    String? errorMessage,
  }) {
    return AirQrProgress(
      streamId: streamId ?? this.streamId,
      totalBlocks: totalBlocks ?? this.totalBlocks,
      receivedBlockCount: receivedBlockCount ?? this.receivedBlockCount,
      capturedIndices: capturedIndices ?? this.capturedIndices,
      fps: fps ?? this.fps,
      status: status ?? this.status,
      reassembledContent: reassembledContent ?? this.reassembledContent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
