import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/ui/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final viewModel = getIt<ProfileViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await viewModel.getCurrentuser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (viewModel.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (viewModel.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(viewModel.errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('SAIR'),
              ),
            ],
          ),
        );
      }

      final user = viewModel.profile.value;
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                user?.avatarUrl ?? '',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) =>
                    loadingProgress == null
                        ? child
                        : Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: 200,
                  color: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(user?.username?? '', style: GoogleFonts.dancingScript(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 8),
            Text(user?.email?? ''),
            const SizedBox(height: 24),
            SizedBox(height: 50, width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, label: Text('SAIR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),), icon: const Icon(Icons.exit_to_app_rounded),
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)), backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary ),),)
          ],
        ),
      );
    });
  }
}
