import 'package:bloc/bloc.dart';
import 'package:ella_lyaabdoon/core/constants/app_routes.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:equatable/equatable.dart';

part 'intro_state.dart';

class IntroCubit extends Cubit<IntroState> {
  IntroCubit() : super(const IntroState(index: 0));

  void pageChanged(int index) {
    emit(state.copyWith(index: index));
  }

  Future<void> completeIntro(Function(String route) navigate) async {
    await AppServicesDBprovider.setFirstOpen();
    navigate(AppRoutes.home);
  }
}
