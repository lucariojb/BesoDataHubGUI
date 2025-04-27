import 'dart:convert';
import 'package:http/http.dart' as http;

class MySQL {
  // Consider making URL configurable or using an environment variable
  static const String _baseUrl =
      "http://127.0.0.1:5000"; // Use your actual base URL

  static Future<String> _postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return ''; // Handle empty response gracefully
      } else {
        return response.body;
      }
    } else {
      // Provide more context in the exception
      String errorMessage =
          'Request failed to endpoint "$endpoint". Status: ${response.statusCode}';
      if (response.body.isNotEmpty) {
        errorMessage += '\nResponse Body: ${response.body}';
      }
      throw Exception(errorMessage);
    }
  }

  static Future<List<Map<String, dynamic>>> runQueryAsMap(String query) async {
    try {
      // Assuming your '/runquery' endpoint expects {"query": "SELECT ..."}
      final responseBody = await _postRequest('runquery', {'query': query});
      // Handle cases where the response might not be valid JSON or an empty list
      if (responseBody.isEmpty) return [];
      final decoded = jsonDecode(responseBody);
      if (decoded is List) {
        // Ensure all elements are maps
        return decoded.cast<Map<String, dynamic>>();
      } else {
        throw FormatException("Expected a JSON list, but received: $decoded");
      }
    } catch (e) {
      // Re-throw with more context or handle differently
      print("Error in runQueryAsMap for query '$query': $e");
      return []; // Return an empty list on error
    }
  }

  // Method for single inserts (if needed elsewhere)
  static Future<bool> insertSingleIntoTable(
      String table, Map<String, dynamic> data) async {
    try {
      await _postRequest('insert', {"table": table, "data": data});
      return true; // Assume success if no exception
    } catch (e) {
      print("Error in insertSingleIntoTable for table '$table': $e");
      return false; // Indicate failure
    }
  }

  // Method for bulk inserts using the modified backend endpoint
  static Future<bool> insertManyIntoTable(
      String table, List<Map<String, dynamic>> data) async {
    if (data.isEmpty) {
      print("insertManyIntoTable called with empty data list.");
      return true; // Nothing to insert, technically success? Or return false?
    }
    try {
      // Send the entire list under the 'data' key
      await _postRequest('insert', {"table": table, "data": data});
      return true; // Assume success if no exception
    } catch (e) {
      print("Error in insertManyIntoTable for table '$table': $e");
      return false; // Indicate failure
    }
  }

  /// Executes a DELETE query on the specified table based on the whereClause.
  ///
  /// WARNING: Constructing the [whereClause] by directly concatenating user input
  /// is highly vulnerable to SQL injection if not handled carefully on the backend.
  /// Ideally, use parameterized queries on the backend endpoint.
  ///
  /// Assumes the backend endpoint '/runquery' (or similar) can execute DELETE statements.
  ///
  /// Parameters:
  ///   - [table]: The name of the table to delete from.
  ///   - [whereClause]: The SQL WHERE clause (e.g., "Konnektor = 'SomeName' AND Typ = 'Konfig'").
  ///
  /// Returns `true` if the backend responds with a success status code (2xx),
  /// `false` otherwise.
  static Future<bool> deleteFromTable(String table, String whereClause) async {
    // Basic validation to prevent accidental full table delete if whereClause is empty
    if (whereClause.trim().isEmpty) {
      print(
          "Error: deleteFromTable called with an empty whereClause. Aborting deletion from table '$table'.");
      return false;
    }
    // Construct the raw SQL query string. Use backticks for table name safety.
    final String deleteQuery = "DELETE FROM `$table` WHERE $whereClause";

    print("Executing Delete Query: $deleteQuery"); // Log the query being sent

    try {
      // Send the raw SQL query to the backend endpoint.
      // Ensure your '/runquery' endpoint is configured to allow DELETE statements.
      await _postRequest('runquery', {'query': deleteQuery});
      print(
          "Deletion request sent successfully for table '$table' with condition: $whereClause");
      return true; // Assume success if no exception is thrown and status code was 2xx
    } catch (e) {
      print(
          "Error executing delete query on table '$table' with condition '$whereClause': $e");
      return false; // Indicate failure
    }
  }
}
