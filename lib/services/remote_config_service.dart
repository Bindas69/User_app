import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:nb_utils/nb_utils.dart';

class RemoteConfigService {
  static RemoteConfigService? _instance;
  static RemoteConfigService get instance => _instance ??= RemoteConfigService._();
  RemoteConfigService._();

  late FirebaseRemoteConfig _remoteConfig;

  // Feature flags keys
  static const String ECOMMERCE_ENABLED = 'ecommerce_enabled';
  static const String ECOMMERCE_BETA_USERS = 'ecommerce_beta_users';
  static const String MAINTENANCE_MODE = 'maintenance_mode';

  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 0),  // allow immediate refetch
        ),
      );

      // Set default values (fallback if Firebase is unavailable)
      await _remoteConfig.setDefaults({
        ECOMMERCE_ENABLED: false,
        ECOMMERCE_BETA_USERS: false,
        MAINTENANCE_MODE: false,
      });

      // Fetch and activate
      bool updated = await _remoteConfig.fetchAndActivate();

      // Debug prints
      print('Remote Config fetched and activated: $updated');
      bool flag = _remoteConfig.getBool(ECOMMERCE_ENABLED);
      print('ecommerce_enabled flag = $flag');

      print('Remote Config initialized successfully');
    } catch (e) {
      print('Error initializing Remote Config: $e');
    }
  }

  // Check if e-commerce is enabled
  bool get isEcommerceEnabled => _remoteConfig.getBool(ECOMMERCE_ENABLED);

  // Check if e-commerce is enabled for beta users
  bool get isEcommerceBetaEnabled => _remoteConfig.getBool(ECOMMERCE_BETA_USERS);

  // Check if app is in maintenance mode
  bool get isMaintenanceMode => _remoteConfig.getBool(MAINTENANCE_MODE);

  // Fetch latest values from server
  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Error fetching Remote Config: $e');
    }
  }

  // Listen to real-time updates
  void listenToUpdates() {
    _remoteConfig.onConfigUpdated.listen((event) async {
      await _remoteConfig.activate();
      print('Remote Config updated');
    });
  }
}
