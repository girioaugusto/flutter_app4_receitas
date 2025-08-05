import 'package:app4_receitas/data/repositories/recipe_repository.dart';
import 'package:app4_receitas/data/services/recipe_service.dart';
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

  // Recipe ViewModel
  getIt.registerLazySingleton<RecipesViewModel>(() => RecipesViewModel());

}