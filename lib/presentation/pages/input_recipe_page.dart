import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/process_recipe/process_recipe_state.dart';
import '../blocs/process_recipe/process_recipe_cubit.dart';
import '../blocs/recipe_list/recipe_list_cubit.dart';
import '../widgets/basic_button.dart';
import '../widgets/basic_scaffold.dart';
import 'parsed_recipe_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProcessRecipeCubit, ProcessRecipeState>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (context, state) {
        if (state.status == ProcessStatus.success && state.recipe != null) {
          context.read<RecipeListCubit>().load();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ParsedRecipePage(recipe: state.recipe!)),
          );
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        return BasicScaffold(
          bottomArea: BasicButton(
            label: 'Verwerken',
            loading: state.status == ProcessStatus.loading,
            onPressed: () {
              FocusScope.of(context).unfocus();
              context.read<ProcessRecipeCubit>().process(_controller.text);
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 10,
                  maxLines: 20,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              const SizedBox(height: 16),
              if (state.status == ProcessStatus.success && state.recipe != null)
                Text(
                  'Laatste resultaat: ${state.recipe!.title}',
                  style: theme.textTheme.bodyMedium,
                ),
            ],
          ),
        );
      },
    );
  }
}
