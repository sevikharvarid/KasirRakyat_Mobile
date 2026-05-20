import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/features/settings/models/printer_settings.dart';
import 'package:kasir_rakyat/features/settings/models/store_profile.dart';
import 'package:kasir_rakyat/features/settings/repository/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(const SettingsState.initial());

  Future<void> loadSettings() async {
    emit(const SettingsState.loading());
    try {
      final profile = await _repository.getProfile();
      final notifLowStock = await _repository.getNotifLowStock();
      final printReceiptAuto = await _repository.getPrintReceiptAuto();
      final defaultPrinter = await _repository.getPrinterSettings();
      emit(SettingsState.loaded(
        profile: profile,
        notifLowStock: notifLowStock,
        printReceiptAuto: printReceiptAuto,
          defaultPrinter: defaultPrinter,
      ));
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> saveProfile(StoreProfile profile) async {
    try {
      await _repository.saveProfile(profile);
      state.maybeWhen(
        loaded: (p, notif, print_, ver, printer) => emit(
          SettingsState.loaded(
          profile: profile,
          notifLowStock: notif,
          printReceiptAuto: print_,
            defaultPrinter: printer,
        )),
        orElse: () {},
      );
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> toggleNotifLowStock(bool value) async {
    try {
      await _repository.setNotifLowStock(value);
      state.maybeWhen(
        loaded: (profile, _, print_, ver, printer) => emit(
          SettingsState.loaded(
          profile: profile,
          notifLowStock: value,
          printReceiptAuto: print_,
            defaultPrinter: printer,
        )),
        orElse: () {},
      );
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> togglePrintReceiptAuto(bool value) async {
    try {
      await _repository.setPrintReceiptAuto(value);
      state.maybeWhen(
        loaded: (profile, notif, _, ver, printer) => emit(
          SettingsState.loaded(
          profile: profile,
          notifLowStock: notif,
          printReceiptAuto: value,
            defaultPrinter: printer,
          ),
        ),
        orElse: () {},
      );
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> savePrinterSettings(PrinterSettings settings) async {
    try {
      await _repository.savePrinterSettings(settings);
      state.maybeWhen(
        loaded: (profile, notif, print_, ver, _) => emit(
          SettingsState.loaded(
            profile: profile,
            notifLowStock: notif,
            printReceiptAuto: print_,
            defaultPrinter: settings,
          ),
        ),
        orElse: () {},
      );
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> clearPrinterSettings() async {
    try {
      await _repository.clearPrinterSettings();
      state.maybeWhen(
        loaded: (profile, notif, print_, ver, _) => emit(
          SettingsState.loaded(
            profile: profile,
            notifLowStock: notif,
            printReceiptAuto: print_,
            defaultPrinter: null,
        )),
        orElse: () {},
      );
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }
}
