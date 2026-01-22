import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/repo/service_provider_details_repo.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_state.dart';

class ServiceProviderDetailsCubit extends Cubit<ServiceProviderDetailsState> {
  final ServiceProviderDetailsRepo _serviceProviderDetailsRepo;

  ServiceProviderDetailsCubit(this._serviceProviderDetailsRepo) : super(InitialState());



  static ServiceProviderDetailsCubit get(context) => BlocProvider.of(context);
}
