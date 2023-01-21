class AppBaseResponse {
  String message;

  AppBaseResponse({this.message});

  factory AppBaseResponse.fromJson(Map<String, dynamic> json) {
    return AppBaseResponse(
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    return data;
  }
}
