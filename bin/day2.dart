import 'dart:async';
import 'dart:io';
import 'package:http/retry.dart';
import 'package:oxidized/oxidized.dart';
import 'package:http/http.dart' as http;
import 'package:match/match.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'day2.g.dart';
//import 'package:result_monad/result_monad.dart';
//import 'package:result_dart/result_dart.dart';
//import 'package:result_dart/result_dart.dart';
//import 'package:result_monad/result_monad.dart';
//import 'package:result_type/result_type.dart';

Result<String, String> test(String filename) {
  if (File(filename).existsSync()) {
    return Ok(File(filename).readAsStringSync());
  } else {
    return Err("File ${filename} not found");
  }
}

Option<String> stringToOption(Option<String> s) {
  return s;
}

Option<int> stringLen(String s) {
  return Some(s.length);
}

Future<Result<String, String>> getJson(String url) async {
  try {
    var uri = Uri.parse(url);
    var client = await HttpClient().getUrl(uri);
    var request = await http.read(uri);
    return Ok(request);
  } catch (e) {
    return Err(e.toString());
  }
}

Future<Result<String, String>> getJson2(String url) async {
  var tries = 0;
  var out = "";
  for (var i = 0; i < 10; i++) {
    try {
      print(i);
      var uri = Uri.parse(url);
      var out = Result.of(() => HttpClient().getUrl(uri));

      if (out.isOk()) {
        return Ok(out.unwrap().toString());
      }
    } catch (e) {
      print(i);
      if (i == 10) {
        return Err(e.toString());
      }
      continue;
    }
  }

  return Ok(out);
}

bool testMatch(String s) {
  var out = s.match({
    eq("test"): () => true,
    eq("test2"): () => true,
    eq("test3"): () => true,
    any: () => false
  });
  return out;
}

//@JsonCodable() // Macro annotation.
@JsonSerializable()
class Person {
  /// The generated code assumes these values exist in JSON.
  final String firstName, lastName;
  final int? age;

  /// The generated code below handles if the corresponding JSON value doesn't
  /// exist or is empty.
  final DateTime? dateOfBirth;

  Person(
      {required this.firstName,
      required this.lastName,
      this.age,
      this.dateOfBirth});

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}

void main() async {
  var person = Person(
    firstName: "test",
    lastName: "12",
    age: null,
  );
  var p = person.toJson();
  print(p);

  test("file.txt").when(ok: (text) {
    print(text);
  }, err: (err) {
    print(err);
  });

  stringToOption(None());

  final j = await getJson("https://jsonplaceholder.typicode.com/posts/1");

  if (j.isOk()) {
    var x = await j.unwrap();
    print(x);
  } else {
    print(j.toString());
  }

  exit(0);
  // switch (test("file.txt")) {
  //   case Ok:
  //     (final x) => print(x);
  //   case Err:
  //     (final x) => print(x);
  //   case _:
  //     () => print("Error");
  // }
}
