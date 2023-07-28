class Categories {
  final int? statusCode;
  final bool? success;
  final List<dynamic>? messages;
  final List<Data>? data;

  Categories({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  Categories.fromJson(Map<String, dynamic> json)
      : statusCode = json['statusCode'] as int?,
        success = json['success'] as bool?,
        messages = json['messages'] as List?,
        data = (json['data'] as List?)
            ?.map((dynamic e) => Data.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'success': success,
        'messages': messages,
        'data': data?.map((e) => e.toJson()).toList()
      };
}

class Data {
  final int? id;
  final String? title;
  final String? filename;
  final String? mimetype;
  final String? cattype;
  final dynamic parentid;
  final List<dynamic>? subcat;

  Data({
    this.id,
    this.title,
    this.filename,
    this.mimetype,
    this.cattype,
    this.parentid,
    this.subcat,
  });

  Data.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        title = json['title'] as String?,
        filename = json['filename'] as String?,
        mimetype = json['mimetype'] as String?,
        cattype = json['cattype'] as String?,
        parentid = json['parentid'],
        subcat = json['subcat'] as List?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filename': filename,
        'mimetype': mimetype,
        'cattype': cattype,
        'parentid': parentid,
        'subcat': subcat
      };
}
