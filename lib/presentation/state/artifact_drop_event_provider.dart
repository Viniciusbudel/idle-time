import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';

class ArtifactDropEventNotifier extends StateNotifier<WorkerArtifact?> {
  ArtifactDropEventNotifier() : super(null);

  void notifyDrop(WorkerArtifact artifact) {
    // Generate a fresh state to ensure listeners trigger even if same artifact ID
    state = null; // Reset first
    Future.microtask(() {
      if (mounted) state = artifact;
    });
  }
}

final artifactDropEventProvider =
    StateNotifierProvider<ArtifactDropEventNotifier, WorkerArtifact?>((ref) {
      return ArtifactDropEventNotifier();
    });
