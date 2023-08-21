class HttpResponseNot200Exception implements Exception {
  String cause;

  HttpResponseNot200Exception(this.cause);

  @override
  String toString() {
    return "HttpResponseNot200Exception: $cause";
  }
}

class HttpResponseCodeNotSuccess implements Exception {
  int code;
  String message;
  String? subMsg;

  HttpResponseCodeNotSuccess(this.code, this.message, {this.subMsg});

  @override
  String toString() {
    return "HttpResponseCodeNotSuccess: {message:$message,code:$code,subMsg:$subMsg}";
  }
}
