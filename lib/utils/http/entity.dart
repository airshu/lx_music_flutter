
typedef EntityGetter<T> = T Function(dynamic data);

class EntityFactory<T> {

  final EntityGetter<T> constructor;

  EntityFactory(this.constructor);

  Type get type => T;

  @override
  String toString() {
    return 'EntityFactory(type:${type})';
  }
}

class ResponseCode {
  static const int SUCCESS = 0;
  static const int FAILED = -1;
}

class ResponseEntity<T> {
  final int code;
  final String msg;
  final String subMsg;
  final T data;

  ResponseEntity._({required this.code, required this.msg, required this.subMsg, required this.data});

  factory ResponseEntity.fromJson(Map<String, dynamic> json, {EntityFactory<T>? factory}) {
    var retData;
    if(json.containsKey('data')) {
      retData = json['data'];
    } else if(json.containsKey('result')) {
      retData = json['result'];
    }
    if(factory != null && retData != null) {
      retData = factory.constructor(retData);
    }

    var retCode = ResponseCode.FAILED;
    if(json.containsKey('code')) {
      retCode = json['code'];
    } else if(json.containsKey('errorCode')) {
      retCode = json['errorCode'];
    }

    var retMsg = '';
    if(json.containsKey('msg')) {
      retMsg = json['msg'];
    } else if(json.containsKey('errorMsg')) {
      retMsg = json['errorMsg'];
    }

    var retSubMsg = '';
    if(json.containsKey('subMsg')) {
      retSubMsg = json['subMsg'];
    }

    return ResponseEntity._(code:retCode, msg:retMsg, subMsg:retSubMsg, data:retData);

  }
}