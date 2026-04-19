# API Client Tests

## 📋 Overview

Unit tests for the HTTP client layer — request methods, error handling, token management, and typed deserialization helpers.

## ▶️ Running

    flutter test test/unit/api

## 📂 Test Files

| File                 | Classes Tested         |
| -------------------- | ---------------------- |
| api_client_test.dart | ApiClient, ApiException |

## 🧪 ApiClient

### Core Functionality

| Area     | Description                                                                                                                         |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| get      | Returns decoded JSON on success                                                                                                     |
| post     | Sends JSON body with correct Content-Type<br/>Returns response on success                                                           |
| patch    | Sends PATCH request, returns response on success                                                                                    |
| delete   | Sends DELETE request, returns response on success                                                                                   |
| postForm | Sends form-encoded body without auth headers<br/>Returns raw response without error checking                                        |
| headers  | Includes `Authorization: Token` when token is set<br/>Omits auth header when no token<br/>Clears auth header after `setToken(null)`<br/>Always includes `Content-Type: application/json` |
| getList  | Parses JSON array via `fromJson` callback                                                                                           |
| getOne   | Parses JSON object via `fromJson` callback                                                                                          |

### Edge Cases

| Case                     | Expected Behavior                             |
| ------------------------ | --------------------------------------------- |
| get on 4xx response      | Throws `ApiException` with status code        |
| get on 5xx response      | Throws `ApiException` with status code        |
| post on 4xx response     | Throws `ApiException`                         |
| patch on 4xx response    | Throws `ApiException`                         |
| delete on 4xx response   | Throws `ApiException`                         |
| postForm on 4xx response | Does NOT throw — returns raw response         |
| Malformed JSON response  | Throws `FormatException` (not `ApiException`) |
| get with empty body      | Parses empty JSON object/array correctly      |
| post with null body      | Sends request without body                    |
| patch with null body     | Sends request without body                    |
| getList with empty array | Returns empty list                             |
| getList on error status  | Throws `ApiException` (delegates to get)       |
| getOne on error status   | Throws `ApiException` (delegates to get)       |

## 🧪 ApiException

### Core Functionality

| Area     | Description                            |
| -------- | -------------------------------------- |
| message  | Includes status code in message string |
| toString | Includes `ApiException:` prefix        |
| fields   | `statusCode` and `body` are accessible |
