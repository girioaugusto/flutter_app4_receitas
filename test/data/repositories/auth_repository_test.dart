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
    
      test('deve retornar um erro quando o fetchUserProfile falha', () async{
        // Arrange
        final mockUser = User(
        id: 'user-id', 
        appMetadata: {}, 
        userMetadata: {}, 
        aud: 'authenticated', 
        createdAt: DateTime.now().toIso8601String(),
        );
      });
    });

    group('SignInWithPassword', () {

      test('deve retornar UserProfile quando login é bem sucedido', () async {
        // Arrange
        final mockUser = User(
        id: 'user-id', 
        appMetadata: {}, 
        userMetadata: {}, 
        aud: 'authenticated', 
        createdAt: DateTime.now().toIso8601String(),
        );
        final mockAuthResponse = AuthResponse(user: mockUser);
        final mockProfile = {'id': 'user-id', 'username': 'testuser'};

        when(mockAuthService.signInWithPassword(
            email: 'test@email.com', 
            password: 'password123'
          )
        ).thenAnswer((_) async => Right(mockAuthResponse));

        when (mockAuthService.fetchUserProfile('user-id'),
        ).thenAnswer((_) async => Right(mockProfile));

        // Act
        final result = await authRepository.signInWithPassword(
          email: 'test@email.com', 
          password: 'password123'
        );

        // Assert
        expect(result.isRight, true);
        expect(result.right.username, equals('testuser'));

      });

      test('deve retornar erro quando as credenciais são inválidas', () async {
        //Arrange
        when(mockAuthService.signInWithPassword(
            email: 'test@email.com', 
            password: 'wrongpassword123',
          )
        ).thenAnswer((_) async => 
          Left(AppError('usuário não cadastrado ou credenciais inválidas'))
        );

        //Act
        final result = await authRepository.signInWithPassword(
          email: 'test@email.com', 
          password: 'wrongpassword123',
        );

        //Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('usuário não cadastrado ou credenciais inválidas'));
      });
      test('deve retornar erro quando o E-mail não foi confirmado', () async {
        //Arrange
        when(mockAuthService.signInWithPassword(
            email: 'test@email.com', 
            password: 'password123',
          )
        ).thenAnswer((_) async => 
          Left(AppError('E-mail não confirmado'))
        );

        //Act
        final result = await authRepository.signInWithPassword(
          email: 'test@email.com', 
          password: 'password123',
        );

        //Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('E-mail não confirmado'));
      });

      test('deve retornar erro quando UserProfile falha após login bem sucedido', () async {
        // Arrange
        final mockUser = User(
        id: 'user-id', 
        appMetadata: {}, 
        userMetadata: {}, 
        aud: 'authenticated', 
        createdAt: DateTime.now().toIso8601String(),
        );
        final mockAuthResponse = AuthResponse(user: mockUser);

        when(mockAuthService.signInWithPassword(
            email: 'test@email.com', 
            password: 'password123'
          )
        ).thenAnswer((_) async => Right(mockAuthResponse));

        when (mockAuthService.fetchUserProfile('user-id'),
        ).thenAnswer((_) async => Left(AppError('Erro ao carregar profile')));

        // Act
        final result = await authRepository.signInWithPassword(
          email: 'test@email.com', 
          password: 'password123'
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Erro ao carregar profile'));
        verify(mockAuthService.fetchUserProfile('user-id')).called(1);
      });
      test('deve retornar erro quando há problema no login', () async {
        //Arrange
        when(mockAuthService.signInWithPassword(
            email: 'test@email.com', 
            password: 'password123',
          )
        ).thenAnswer((_) async => 
          Left(AppError('Erro ao fazer login'))
        );

        //Act
        final result = await authRepository.signInWithPassword(
          email: 'test@email.com', 
          password: 'password123',
        );

        //Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Erro ao fazer login'));
      });

    });

    group('signUp', () {
      test(
        'deve retornar UserProfile quando cadastro é bem-sucedido',
        () async {
          // Arrange
          final mockUser = User(
            id: 'user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          );
          final mockAuthResponse = AuthResponse(user: mockUser);

          when(
            mockAuthService.signUp(
              email: 'test@email.com',
              password: 'password123',
              username: 'testuser',
              avatarUrl: 'avatar.jpg',
            ),
          ).thenAnswer((_) async => Right(mockAuthResponse));

          final mockProfile = {
            'email': 'test@email.com',
            'password': 'password123',
            'username': 'testuser',
            'avatarUrl': 'avatar.jpg',
          };
          when(
            mockAuthService.fetchUserProfile('user-id'),
          ).thenAnswer((_) async => Right(mockProfile));

          // Act
          final result = await authRepository.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'avatar.jpg',
          );

          // Assert
          expect(result.isRight, true);
          expect(result.right.username, equals('testuser'));
          verify(
            mockAuthService.signUp(
              email: 'test@email.com',
              password: 'password123',
              username: 'testuser',
              avatarUrl: 'avatar.jpg',
            ),
          ).called(1);
          verify(mockAuthService.fetchUserProfile('user-id')).called(1);
        },
      );

      test('deve retornar erro quando e-mail já existe', () async {
        // Arrange
        when(
          mockAuthService.signUp(
            email: 'existing@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'avatar.jpg',
          ),
        ).thenAnswer((_) async => Left(AppError('E-mail já cadastrado')));

        // Act
        final result = await authRepository.signUp(
          email: 'existing@email.com',
          password: 'password123',
          username: 'testuser',
          avatarUrl: 'avatar.jpg',
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('E-mail já cadastrado'));
      });

      test('deve retornar erro quando username já existe', () async {
        // Arrange
        when(
          mockAuthService.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'existinguser',
            avatarUrl: 'avatar.jpg',
          ),
        ).thenAnswer((_) async => Left(AppError('Username já existe')));

        // Act
        final result = await authRepository.signUp(
          email: 'test@email.com',
          password: 'password123',
          username: 'existinguser',
          avatarUrl: 'avatar.jpg',
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Username já existe'));
      });

      test(
        'deve retornar erro quando fetchUserProfile falha após signUp',
        () async {
          // Arrange
          final mockUser = User(
            id: 'user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          );
          final mockAuthResponse = AuthResponse(user: mockUser);

          when(
            mockAuthService.signUp(
              email: 'test@email.com',
              password: 'password123',
              username: 'testuser',
              avatarUrl: 'avatar.jpg',
            ),
          ).thenAnswer((_) async => Right(mockAuthResponse));

          when(
            mockAuthService.fetchUserProfile('user-id'),
          ).thenAnswer((_) async => Left(AppError('Erro ao carregar profile')));

          // Act
          final result = await authRepository.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'avatar.jpg',
          );

          // Assert
          expect(result.isLeft, true);
          expect(result.left.message, equals('Erro ao carregar profile'));
        },
      );

      test(
        'deve retornar erro quando email não foi confirmado no signUp',
        () async {
          // Arrange
          when(
            mockAuthService.signUp(
              email: 'test@email.com',
              password: 'password123',
              username: 'testuser',
              avatarUrl: 'avatar.jpg',
            ),
          ).thenAnswer((_) async => Left(AppError('E-mail não confirmado')));

          // Act
          final result = await authRepository.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'avatar.jpg',
          );

          // Assert
          expect(result.isLeft, true);
          expect(result.left.message, equals('E-mail não confirmado'));
        },
      );

      test('deve retornar erro quando há erro inesperado no cadastro', () async {
        // Arrange
        when(
          mockAuthService.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'avatar.jpg',
          ),
        ).thenAnswer((_) async => Left(AppError('Erro ao fazer cadastro')));

        // Act
        final result = await authRepository.signUp(
          email: 'test@email.com',
          password: 'password123',
          username: 'testuser',
          avatarUrl: 'avatar.jpg',
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Erro ao fazer cadastro'));
      });

      test('deve retornar erro inesperado no signUp', () async {
        // Arrange
        when(
          mockAuthService.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'avatar.jpg',
          ),
        ).thenAnswer((_) async => Left(AppError('Erro inesperado')));

        // Act
        final result = await authRepository.signUp(
          email: 'test@email.com',
          password: 'password123',
          username: 'testuser',
          avatarUrl: 'avatar.jpg',
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Erro inesperado'));
      });
    });

    group('signOut', () {
      test('deve retornar sucesso quando logout é bem-sucedido', () async {
        // Arrange
        when(mockAuthService.singOut()).thenAnswer((_) async => Right(null));

        // Act
        final result = await authRepository.singOut();

        // Assert
        expect(result.isRight, true);
        verify(mockAuthService.singOut()).called(1);
      });

      test('deve retornar erro quando logout falha', () async {
        // Arrange
        when(
          mockAuthService.singOut(),
        ).thenAnswer((_) async => Left(AppError('Erro ao fazer logout')));

        // Act
        final result = await authRepository.singOut();

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Erro ao fazer logout'));
      });
    });

  });

}