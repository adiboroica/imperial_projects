import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'coach_checklist_page.dart';
import 'organiser_cubit.dart';

class BlockedPage extends StatelessWidget {
  const BlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CoachChecklistPage(
      title: 'Blocked',
      exitGuardContent:
          'Any unsaved changes to your blocked list will be lost.',
      confirmTitle: 'Save blocked list?',
      initialSelectedPks:
          context.read<OrganiserCubit>().state.blocked.toSet(),
      onSave: (apiOrganiser, pks) => apiOrganiser.updateBlocked(pks),
    );
  }
}
