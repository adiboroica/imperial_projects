import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/feed_events_cubit.dart';
import 'feed_view.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        FeedEventsCubit feedEventsCubit = FeedEventsCubit();
        feedEventsCubit.retrieveFeedEvents();
        return feedEventsCubit;
      },
      child: const FeedView(),
    );
  }
}
