import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/services/save_service.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';
import 'package:time_factory/presentation/ui/dialogs/offline_dialog.dart';
import 'package:time_factory/domain/entities/offline_earnings.dart';
import 'package:time_factory/presentation/ui/pages/factory_screen.dart';
import 'package:time_factory/domain/usecases/calculate_offline_earnings_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      systemNavigationBarColor: Colors.black,
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: TimeFactoryApp()));
}

/// Global save service instance
final saveServiceProvider = Provider<SaveService>((ref) => SaveService());

class TimeFactoryApp extends ConsumerWidget {
  const TimeFactoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Time Factory: Paradox Industries',
      debugShowCheckedModeBanner: false,
      theme: TimeFactoryColors.darkTheme.copyWith(
        textTheme: TimeFactoryColors.darkTheme.textTheme.apply(
          fontFamily: theme.typography.fontFamily,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('pt')],
      home: const _AppLoader(),
    );
  }
}

/// Loads saved game data before showing main screen
class _AppLoader extends ConsumerStatefulWidget {
  const _AppLoader();

  @override
  ConsumerState<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends ConsumerState<_AppLoader> {
  bool _isLoading = true;
  OfflineEarnings? _pendingOfflineEarnings;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    final saveService = ref.read(saveServiceProvider);
    await saveService.init();

    // Try to load saved game
    final savedState = await saveService.load();

    if (savedState != null) {
      // Calculate offline earnings BEFORE loading state
      // Use Domain UseCase for accurate calculation including Tech bonuses
      final offlineUseCase = CalculateOfflineEarningsUseCase();
      final offlineEarnings = offlineUseCase.execute(savedState);

      // Load saved state
      ref.read(gameStateProvider.notifier).loadState(savedState);

      // Store offline earnings to show dialog after load
      if (offlineEarnings != null && offlineEarnings.ceEarned > BigInt.zero) {
        _pendingOfflineEarnings = offlineEarnings;
      }
    }

    setState(() => _isLoading = false);
  }

  void _collectOfflineEarnings() {
    if (_pendingOfflineEarnings != null) {
      ref
          .read(gameStateProvider.notifier)
          .addChronoEnergy(_pendingOfflineEarnings!.ceEarned);
      _pendingOfflineEarnings = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: TimeFactoryColors.electricCyan,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.loadingTimeline,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show offline earnings dialog if needed
    if (_pendingOfflineEarnings != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        OfflineEarningsDialog.show(
          context,
          _pendingOfflineEarnings!,
          _collectOfflineEarnings,
        );
        // Clear so dialog only shows once
        _pendingOfflineEarnings = null;
      });
    }

    return const FactoryScreen();
  }
}
