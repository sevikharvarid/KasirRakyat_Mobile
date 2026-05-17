import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/features/reports/models/reports_models.dart';
import 'package:kasir_rakyat/features/reports/repository/reports_repository.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository _repository;

  ReportsCubit(this._repository) : super(const ReportsState.initial());

  Future<void> loadReport(ReportsPeriod period) async {
    emit(const ReportsState.loading());
    try {
      final summary = await _repository.getSummary(period);
      final dailyRevenues = await _repository.getDailyRevenues(period);
      final topProducts = await _repository.getTopProducts(period);
      emit(ReportsState.loaded(
        period: period,
        summary: summary,
        dailyRevenues: dailyRevenues,
        topProducts: topProducts,
      ));
    } catch (e) {
      emit(ReportsState.error(e.toString()));
    }
  }

  void changePeriod(ReportsPeriod period) => loadReport(period);
}
