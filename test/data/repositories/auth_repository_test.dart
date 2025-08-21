import 'package:app4_receitas/data/repositories/auth_repository.dart';
import 'package:app4_receitas/data/services/auth_service.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/utils/app_error.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_repository_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;
  late AuthRepository authRepository;

  //Configurando o Ambiente de teste antes de todos os testes.
  setUpAll((){
    provideDummy<Either<AppError, AuthResponse>>(Right(AuthResponse()));
    provideDummy<Either<AppError, Map<String, dynamic>?>>(Right(<String, dynamic>{}));
    provideDummy<Either<AppError, void>>(Right(null));

  });

  //Configura o ambiente de testes antes de cada teste
  setUp((){
    mockAuthService = MockAuthService();
  
    // Limpar as DI anteriores
    getIt.reset();

    //Registrar o mock no Getit
    getIt.registerSingleton<AuthService>(mockAuthService);

    authRepository = AuthRepository();
  });

  //Garantindo que o GetIt nao mantenha instancias desnecessárias
  tearDown((){
    if(getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }
  });

  group('AuthRepository', () {

    group('currentUser', () {
      test('deve retornar um UserProfile quando o usuário está logado', () async{
        // Arrange
        final mockUser = User(
        id: 'user-id', 
        appMetadata: {}, 
        userMetadata: {}, 
        aud: 'authenticated', 
        createdAt: DateTime.now().toIso8601String(),
        );

        final mockProfile = {'id': 'user-id', 'username': 'testuser'};

        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockAuthService.fetchUserProfile('user-id'),).thenAnswer((_) async => Right(mockProfile));

        // Act
        final result = await authRepository.currentUser;

        // Assert
        expect(result.isRight, true);
      });
    });

    group('SignInWithPassword', () {});

    group('signUp', () {});

    group('signOut', () {});

  });

}