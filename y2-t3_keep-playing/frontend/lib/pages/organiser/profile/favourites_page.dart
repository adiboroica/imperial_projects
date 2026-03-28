import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'coach_checklist_page.dart';
import 'organiser_cubit.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CoachChecklistPage(
      title: 'Favourites',
      exitGuardContent: 'Any unsaved changes to your favourites will be lost.',
      confirmTitle: 'Save favourites?',
      initialSelectedPks:
          context.read<OrganiserCubit>().state.favourites.toSet(),
      onSave: (apiOrganiser, pks) => apiOrganiser.updateFavourites(pks),
    );
  }
}
