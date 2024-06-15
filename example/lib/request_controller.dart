import 'package:deex/deex.dart';

class RequestController extends DeexStore {
  final Rx<RequestState> state = Rx<RequestState>(InitialRequestState());

  void sendRequest() {
    _setLoadingState();
    _simulateRequest()
        .then((data) => _setCompletedState(data))
        .catchError((error) => _setErrorState(error));
  }

  void _setLoadingState() {
    state.value = LoadingRequestState();
  }

  void _setCompletedState(dynamic data) {
    state.value = CompletedRequestState(data);
  }

  void _setErrorState(dynamic error) {
    state.value = ErrorRequestState(error.toString());
  }

  Future<dynamic> _simulateRequest() {
    return Future.delayed(const Duration(seconds: 2), () {
      return {'data': 'Hello World!'};
    });
  }
}

abstract class RequestState {
  final String message;
  RequestState(this.message);
}

class InitialRequestState extends RequestState {
  InitialRequestState() : super('Request State');
}

class LoadingRequestState extends RequestState {
  LoadingRequestState() : super('Loading...');
}

class CompletedRequestState extends RequestState {
  final dynamic data;
  CompletedRequestState(this.data) : super('Request completed');
}

class ErrorRequestState extends RequestState {
  ErrorRequestState(String message) : super('Error: $message');
}
