/// Generic sealed hierarchy for async data loading (initial/loading/loaded/error).
sealed class DataState<T> {
  const DataState();
}

/// No data fetch has been attempted yet.
class DataInitial<T> extends DataState<T> {
  const DataInitial();
}

/// Data fetch is in progress.
class DataLoading<T> extends DataState<T> {
  const DataLoading();
}

/// Data was fetched successfully.
class DataLoaded<T> extends DataState<T> {
  final T data;
  const DataLoaded(this.data);
}

/// Data fetch failed with an error message.
class DataError<T> extends DataState<T> {
  final String message;
  const DataError(this.message);
}
