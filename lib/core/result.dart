sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.failure(String code, String message) = Failure<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.code, this.message);
  final String code;
  final String message;
}
