import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/currency_format.dart';
import '../blocs/process_recipe/process_recipe_state.dart';
import '../blocs/process_recipe/process_recipe_cubit.dart';
import '../blocs/recipe_list/recipe_list_cubit.dart';
import '../widgets/primary_button.dart';
import 'parsed_recipe_page.dart';
import 'recipe_list_page.dart';

class InputRecipePage extends StatefulWidget {
  const InputRecipePage({super.key});

  @override
  State<InputRecipePage> createState() => _InputRecipePageState();
}

class _InputRecipePageState extends State<InputRecipePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toList() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecipeListPage()));
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recept verwerken'),
        actions: [
          IconButton(
            tooltip: 'Alle recepten',
            onPressed: _toList,
            icon: const Icon(Icons.menu_book_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.surfaceContainerHighest, color.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<ProcessRecipeCubit, ProcessRecipeState>(
            listenWhen: (prev, next) => prev.status != next.status,
            listener: (context, state) {
              if (state.status == ProcessStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error ?? 'Er ging iets mis')),
                );
              }
              if (state.status == ProcessStatus.success && state.recipe != null) {
                context.read<RecipeListCubit>().load();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ParsedRecipePage(recipe: state.recipe!)),
                );
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: TextField(
                        controller: _controller,
                        minLines: 10,
                        maxLines: 20,
                        decoration: const InputDecoration(
                          hintText: 'Plak je recept‑tekst hier…',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Verwerken',
                      loading: state.status == ProcessStatus.loading,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        context.read<ProcessRecipeCubit>().process(_controller.text);
                      },
                    ),
                    const SizedBox(height: 24),
                    if (state.status == ProcessStatus.success && state.recipe != null)
                      Text(
                        'Laatste resultaat: ${state.recipe!.title} – ${formatEuro(state.recipe!.totalCostEur)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
