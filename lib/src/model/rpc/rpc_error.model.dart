import 'rpc_error_data.model.dart';

class RPCError {
  int? code;
  String? message;
  List<RPCErrorData>?  data;

  RPCError({
    required this.code,
    required this.message,
    this.data = const [],
  });

  factory RPCError.fromJson(Map<String, dynamic> json) => RPCError(
        code: json["code"] ?? 0,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<RPCErrorData>.from(
                json["data"].map((x) => RPCErrorData.fromJson(x)),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}
