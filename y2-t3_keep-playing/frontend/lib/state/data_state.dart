sealed class DataState<T> {
  const DataState();
}

class DataInitial<T> extends DataState<T> {
  const DataInitial();
}

class DataLoading<T> extends DataState<T> {
  const DataLoading();
}

class DataLoaded<T> extends DataState<T> {
  final T data;
  const DataLoaded(this.data);
}

class DataError<T> extends DataState<T> {
  final String message;
  const DataError(this.message);
}
