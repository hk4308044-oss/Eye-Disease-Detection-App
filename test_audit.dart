import 'dart:io';
import 'dart:convert';

const apiKey = 'AIzaSyB80euTWA-ltZY341sP83soTCZQ3iD6g1o';
const projectId = 'final-year-project-7e02d';

Future<void> main() async {
  print('--- STARTING FIREBASE AUDIT ---');
  
  final client = HttpClient();
  
  try {
    // 1. Test Auth Signup
    print('\\n[TEST 1] Testing Firebase Auth Signup...');
    final signupUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey');
    final signupReq = await client.postUrl(signupUrl);
    signupReq.headers.contentType = ContentType.json;
    signupReq.write(jsonEncode({
      'email': 'test_audit_final@example.com',
      'password': 'Password123!',
      'returnSecureToken': true
    }));
    final signupRes = await signupReq.close();
    final signupBody = await signupRes.transform(utf8.decoder).join();
    
    if (signupRes.statusCode == 200) {
      print('PASS: Signup successful.');
    } else if (signupBody.contains('EMAIL_EXISTS')) {
      print('PASS: User already exists (which means Auth is working).');
    } else {
      print('FAIL: Auth signup failed - $signupBody');
    }

    // 2. Test Auth Login
    print('\\n[TEST 2] Testing Firebase Auth Login...');
    final loginUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey');
    final loginReq = await client.postUrl(loginUrl);
    loginReq.headers.contentType = ContentType.json;
    loginReq.write(jsonEncode({
      'email': 'test_audit_final@example.com',
      'password': 'Password123!',
      'returnSecureToken': true
    }));
    final loginRes = await loginReq.close();
    final loginBody = await loginRes.transform(utf8.decoder).join();
    
    String? idToken;
    String? localId;
    if (loginRes.statusCode == 200) {
      print('PASS: Login successful.');
      final data = jsonDecode(loginBody);
      idToken = data['idToken'];
      localId = data['localId'];
    } else {
      print('FAIL: Auth login failed - $loginBody');
    }

    // 3. Test Firestore Write
    if (idToken != null && localId != null) {
      print('\\n[TEST 3] Testing Firestore Write (Test Data)...');
      final firestoreUrl = Uri.parse('https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/$localId');
      final fsReq = await client.patchUrl(firestoreUrl); // patch to create or update
      fsReq.headers.contentType = ContentType.json;
      fsReq.headers.add('Authorization', 'Bearer $idToken');
      fsReq.write(jsonEncode({
        'fields': {
          'id': {'stringValue': localId},
          'name': {'stringValue': 'TEST DATA AUDIT'},
          'role': {'stringValue': 'test'}
        }
      }));
      final fsRes = await fsReq.close();
      final fsBody = await fsRes.transform(utf8.decoder).join();
      
      if (fsRes.statusCode == 200) {
        print('PASS: Firestore Write successful.');
      } else {
        print('FAIL: Firestore Write failed - $fsBody');
      }

      // 4. Test Firestore Read
      print('\\n[TEST 4] Testing Firestore Read...');
      final fsReadReq = await client.getUrl(firestoreUrl);
      fsReadReq.headers.add('Authorization', 'Bearer $idToken');
      final fsReadRes = await fsReadReq.close();
      final fsReadBody = await fsReadRes.transform(utf8.decoder).join();
      
      if (fsReadRes.statusCode == 200) {
        print('PASS: Firestore Read successful.');
      } else {
        print('FAIL: Firestore Read failed - $fsReadBody');
      }
      
      // Cleanup: Delete User (Optional but good for cleanliness)
      print('\\n[TEST 5] Cleaning up (Deleting Test User)...');
      final deleteUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:delete?key=$apiKey');
      final delReq = await client.postUrl(deleteUrl);
      delReq.headers.contentType = ContentType.json;
      delReq.write(jsonEncode({
        'idToken': idToken
      }));
      final delRes = await delReq.close();
      if (delRes.statusCode == 200) {
        print('PASS: Test user deleted successfully.');
      } else {
        print('FAIL: Could not delete test user.');
      }
    } else {
      print('\\nSKIPPING FIRESTORE TESTS: No Auth Token available.');
    }
    
  } catch (e) {
    print('ERROR: $e');
  } finally {
    client.close();
  }
  
  print('\\n--- END OF FIREBASE AUDIT ---');
}
