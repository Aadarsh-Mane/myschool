class UserFields {
  static final String rollno = '';
  static final String name = 'name';
  static final String email = 'email';
  static final String isBeginner = 'isBeginner';
  // static final String id = '';
  // static final String id = '';

  static List<String> getFields() => [rollno, name, email, isBeginner];
}

class User {
  final int? rollno;
  final String name;
  final String email;
  final bool isBeginner;

  const User(
      {this.rollno,
      required this.name,
      required this.email,
      required this.isBeginner});

  Map<String, dynamic> toJson() => {
        UserFields.rollno: rollno,
        UserFields.name: name,
        UserFields.email: email,
        UserFields.isBeginner: isBeginner,
      };
}
