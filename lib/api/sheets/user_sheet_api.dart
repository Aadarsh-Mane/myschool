import 'package:gsheets/gsheets.dart';
import 'package:myschool/modalsheet/user.dart';

class UserSheetsApi {
  static const _credentials = r'''
{
  "type": "service_account",
  "project_id": "myschool-413218",
  "private_key_id": "17ee6b3ad39638d8f897c4980701aaa8a738f02c",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCuhpbTGwMxnmgs\nrlBrUKYk3PNAIcjuPx2ukJVMB1tGu0K5/LE3Is8cOQujTp0Cqr4CL0O4wlBaxwNe\na8lBLiv5iZWV43IjG4YQMabDiSoegUnsQjquIPpf7PK74+qoejzQsZz56FVJoKFg\noEi8I3UnGeKOOlYWR/e4hFm/ztsfKF0yzk06lX/1rWYJ47K3+RgHIsmYZdH5MGos\n01fOr8DP4aq6UXJDYRpt1xPamFfEiDcbLghPu026nqm9fNFgVgS9Dkl4gBP8+Vh1\nZ02V7gAB084CXenvBOAsHnpZrE3PCMfPy6PBLAejiza+Ls/vocBVQec6WdT1KjxF\nftcn5lttAgMBAAECggEAAS/hqTxrDGSZLUqfOeehxajqD6LbMMGlpEkP9uUq6gN+\ni/DLzMX0FitOKLVxbHH4Wl/zbDeIH+HwJC2EACk9+9PDfHJAVbxLcGNCENznOC9l\nbxGxP/tx8IKWURBXCX/RV5MJsAp0QAyzZEqazArKsnIi4BhF+x9QsETYLm2MAH19\nJW5OptOCckum7oUtHVSiJz+AGBwtAkjXi0gS9v2cCodMO1g0xYEpFrYsLd49vayj\nvy34Ram9FQIrvLhslJDV0ORg90Y22/J2F8vDhEiJgllX/F9jy5SfOi3MAs2+JDUj\nN+lG9VKV0JpButGmZ68lJ0l4ep34AuTAAPFOvnfRAQKBgQDuOEU3zBgtskGYWbEL\nBMSWWfCl2tY+0gsgrTG4OwNg0o6sOGE/fpV4rhNbDgnjonhnXD2quDu9dd+w48jp\nrTx5BkbGgAwf+mwwI6LQbAa4fywlxkdRCFzeyjxdumM6niF/hm9p/2dsRXGwpVWH\nyMWlurvvdY25ZzkfaXh64Y1VAQKBgQC7jUyXAZCMPMKJrUOp2YqpqMzdLh1cna7u\n+Syb80D1zlKzel1ASaT0qsuucCNIGmCMOW4q+dfd8i/TueEaY3ZdfqwGr/xrX9Y3\nP1QH+g+Zs9fZyd8UZTI88CfII/MaZgK/knGxlmHjxElJwC+7HBAHZzHSY1ZxfkkK\nqHHv28cqbQKBgDfnlLbnerUepC4wvk+rqsbuDH+fv6+2c04T1xs5Hi3WvAzGnmvc\nNQ/BKmGwBboaIs9+4inyWnK3+ur0Se4s7YgpZOqomi/XARS7CDaJY3pgveePhKUL\npV/Tbh9A4pCbE5lt3y+s9ISAN5IQ+uWGxHuEOx6TI9Ni2hD5G4Ea9aQBAoGAPsx5\nMLbdZ5eQq/jQBzdILrbOoeCnBDPoNyxHu5Af2C5VkrMONlByY1otCSOTLLloSouQ\nT+OIXFCToxlCPku/fl7DyxlyM6HLYIRb5q/cOWL2i34ErBeWUsE3ENS4ucYedXbb\nitMHw/Qddgxb7xLeaxwqmn+YmjfmzSLJw76bWaECgYBrtaJ5i5QSR1zGzq6YUGBG\nSwu+jfR9/XOOrTLACKoc+Y/1AzaXlKyzwyhddHECAX5DicwfpLaN/eCY1n1wA2Eb\nTcKnGRtN6VcTQ3CLPmi9VJH9L/ad/rcNaM0HcUex8UF5gauheH38jdJSywfEqc1W\nAGJ4m2BxfcoMEJmE0jqF8g==\n-----END PRIVATE KEY-----\n",
  "client_email": "myschool@myschool-413218.iam.gserviceaccount.com",
  "client_id": "111480500259438207400",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/myschool%40myschool-413218.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}


''';
  static final _spreasheetId = '1Pl64P3jxgIhBuuccbRyftwHgpCjbeSVoSI7H6AXCNYM';

  static Worksheet? _userSheet;
  static final _gsheets = GSheets(_credentials);

  static Future init() async {
    try {
      final spreadsheet = await _gsheets.spreadsheet(_spreasheetId);
      _userSheet = await _getWorkSheet(spreadsheet, title: 'Sheet1');
      final firstRow = UserFields.getFields();
      _userSheet!.values.insertRow(1, firstRow);
    } catch (e) {
      print('init error:$e');
    }
  }

  static Future<Worksheet> _getWorkSheet(
    Spreadsheet spreadsheet, {
    required String title,
  }) async {
    try {
      return await spreadsheet.addWorksheet(title);
    } catch (e) {}
    return await spreadsheet.worksheetByTitle(title)!;
  }

  static Future insert(List<Map<String, dynamic>> rowList) async {
    if (_userSheet == null) {
      return;
    }
    _userSheet!.values.map.appendRows(rowList);
  }
}
