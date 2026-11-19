import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/datasources/blood_request_datasource.dart';
import '../../data/datasources/hospital_datasource.dart';
import '../../data/datasources/mock/mock_auth_datasource.dart';
import '../../data/datasources/mock/mock_blood_request_datasource.dart';
import '../../data/datasources/mock/mock_hospital_datasource.dart';
import '../../data/datasources/remote/address_remote_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/blood_request_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/blood_request_repository_impl.dart';
import '../../data/repositories/hospital_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/blood_request_repository.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/pledge_blood_donation_usecase.dart';
import '../../presentation/cubits/auth/auth_cubit.dart';
import '../../presentation/cubits/create_request/create_request_cubit.dart';
import '../../presentation/cubits/donor_card/donor_card_cubit.dart';
import '../../presentation/cubits/feed/case_feed_cubit.dart';
import '../../presentation/cubits/hospitals/hospital_directory_cubit.dart';
import '../../presentation/cubits/profile/profile_cubit.dart';
import '../../presentation/cubits/request_details/request_details_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // 1. Storage & Network Client
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<DioClient>(() => DioClient(tokenStorage: sl()));

  // 2. Data Sources (Dual-Mode: Mock First or Production REST API)
  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSource(dioClient: sl()),
  );

  if (AppConfig.useMockData) {
    sl.registerLazySingleton<AuthDataSource>(() => MockAuthDataSource());
    sl.registerLazySingleton<BloodRequestDataSource>(() => MockBloodRequestDataSource());
    sl.registerLazySingleton<HospitalDataSource>(() => MockHospitalDataSource());
  } else {
    sl.registerLazySingleton<AuthDataSource>(
      () => AuthRemoteDataSource(dioClient: sl(), tokenStorage: sl()),
    );
    sl.registerLazySingleton<BloodRequestDataSource>(
      () => BloodRequestRemoteDataSource(dioClient: sl()),
    );
    sl.registerLazySingleton<HospitalDataSource>(() => MockHospitalDataSource());
  }

  // 3. Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<BloodRequestRepository>(() => BloodRequestRepositoryImpl(sl()));
  sl.registerLazySingleton<HospitalRepository>(() => HospitalRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(authDataSource: sl(), addressDataSource: sl()),
  );

  // 4. Use Cases
  sl.registerLazySingleton<PledgeBloodDonationUseCase>(() => PledgeBloodDonationUseCase(sl()));

  // 5. Cubits (Factory registration for fresh state instances)
  sl.registerFactory<AuthCubit>(() => AuthCubit(repository: sl()));
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(profileRepository: sl()));
  sl.registerFactory<CaseFeedCubit>(() => CaseFeedCubit(requestRepository: sl(), authRepository: sl()));
  sl.registerFactory<RequestDetailsCubit>(() => RequestDetailsCubit(
        requestRepository: sl(),
        authRepository: sl(),
        pledgeUseCase: sl(),
      ));
  sl.registerFactory<CreateRequestCubit>(() => CreateRequestCubit(repository: sl()));
  sl.registerFactory<HospitalDirectoryCubit>(() => HospitalDirectoryCubit(repository: sl()));
  sl.registerFactory<DonorCardCubit>(() => DonorCardCubit(authRepository: sl(), requestRepository: sl()));
}
