class RPCErrorData {
  final int? code;
  final String? message;

  RPCErrorData({
    required this.code,
    required this.message,
  });

  factory RPCErrorData.fromJson(Map<String, dynamic> json) => RPCErrorData(
        code: json["code"] ?? 0,
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
      };
}
