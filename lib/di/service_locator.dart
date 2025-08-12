import 'package:app4_receitas/data/repositories/recipe_repository.dart';
import 'package:app4_receitas/data/services/recipe_service.dart';
import 'package:app4_receitas/ui/auth/auth_viewmodel.dart';
import 'package:app4_receitas/ui/fav_recipes/fav_recipes_viewmodel.dart';
import 'package:app4_receitas/ui/recipedetail/recipe_detail_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app4_receitas/ui/recipes/recipes_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // SupabaseClient
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

  //Recipe Service
  getIt.registerLazySingleton<RecipeService>(() => RecipeService());

  // Recipe Repository
  getIt.registerLazySingleton<RecipeRepository>(() => RecipeRepository());

  // ViewModels
  getIt.registerLazySingleton<RecipesViewModel>(() => RecipesViewModel());
  getIt.registerLazySingleton<RecipeDetailViewModel>(() => RecipeDetailViewModel());
  getIt.registerLazySingleton<FavRecipesViewModel>(() => FavRecipesViewModel());
  getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel());
}