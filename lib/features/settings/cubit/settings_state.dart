import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kasir_rakyat/features/settings/models/printer_settings.dart';
import 'package:kasir_rakyat/features/settings/models/store_profile.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = _Initial;
  const factory SettingsState.loading() = _Loading;
  const factory SettingsState.loaded({
    required StoreProfile profile,
    @Default(false) bool notifLowStock,
    @Default(true) bool printReceiptAuto,
    @Default('1.0.0') String appVersion,
    PrinterSettings? defaultPrinter,
  }) = _Loaded;
  const factory SettingsState.error(String message) = _Error;
}
