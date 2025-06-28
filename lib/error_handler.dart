import 'dart:io';

enum ErrorType {
  network,
  authentication,
  sessionExpired,
  serverError,
  validation,
  parsing,
  unknown
}

class AppError {
  final ErrorType type;
  final String message;
  final String userMessage;
  final bool canRetry;
  final Exception? originalException;

  const AppError({
    required this.type,
    required this.message,
    required this.userMessage,
    this.canRetry = false,
    this.originalException,
  });

  @override
  String toString() => 'AppError($type): $message';
}

class ErrorHandler {
  static AppError handleException(Exception exception, {String? context}) {
    if (exception is SocketException) {
      return const AppError(
        type: ErrorType.network,
        message: 'Network connection failed',
        userMessage: 'Nelze se připojit k internetu. Zkontrolujte připojení.',
        canRetry: true,
      );
    }

    if (exception is HttpException) {
      return const AppError(
        type: ErrorType.serverError,
        message: 'HTTP error',
        userMessage: 'Problém se serverem. Zkuste to znovu za chvíli.',
        canRetry: true,
      );
    }

    if (exception is FormatException) {
      return const AppError(
        type: ErrorType.parsing,
        message: 'Data parsing failed',
        userMessage: 'Chyba při zpracování dat ze serveru.',
        canRetry: false,
      );
    }

    final message = exception.toString();
    if (message.contains('timeout')) {
      return const AppError(
        type: ErrorType.network,
        message: 'Request timeout',
        userMessage: 'Připojení vypršelo. Zkuste to znovu.',
        canRetry: true,
      );
    }

    return AppError(
      type: ErrorType.unknown,
      message: 'Unknown error: $message',
      userMessage: 'Nastala neočekávaná chyba. Zkuste to znovu.',
      canRetry: true,
      originalException: exception,
    );
  }

  static AppError handleApiResponse(Map<String, dynamic> response, {String? context}) {
    // Check for API error structure based on the documentation
    if (response.containsKey('severity') && response.containsKey('msg')) {
      final severity = response['severity'];
      final msg = response['msg'];
      final log = response['log'] ?? '';
      
      if (msg == 'loginerr') {
        return const AppError(
          type: ErrorType.authentication,
          message: 'Login failed',
          userMessage: 'Nesprávné přihlašovací údaje.',
          canRetry: false,
        );
      }
      
      if (msg == 'badreq') {
        // This could indicate session expiry if we're logged in
        return const AppError(
          type: ErrorType.sessionExpired,
          message: 'Bad request - possibly expired session',
          userMessage: 'Relace vypršela. Přihlašujeme vás znovu...',
          canRetry: true,
        );
      }
      
      // Generic API error
      return AppError(
        type: ErrorType.serverError,
        message: 'API error: $msg',
        userMessage: _getLocalizedApiError(msg, log),
        canRetry: severity == 1, // Retry on warnings, not on errors
      );
    }

    return const AppError(
      type: ErrorType.unknown,
      message: 'Unknown API response format',
      userMessage: 'Neočekávaná odpověď ze serveru.',
      canRetry: false,
    );
  }

  static String _getLocalizedApiError(String msg, String log) {
    switch (msg) {
      case 'loginerr':
        return 'Nesprávné přihlašovací údaje.';
      case 'badreq':
        return 'Neplatný požadavek. Zkuste to znovu.';
      case 'internal':
        return 'Chyba serveru. Zkuste to znovu za chvíli.';
      case 'timeout':
        return 'Operace vypršela. Zkuste to znovu.';
      case 'noaccess':
        return 'Nemáte oprávnění k této operaci.';
      case 'notfound':
        return 'Požadovaná data nebyla nalezena.';
      default:
        // Return a user-friendly version of the log message if available
        if (log.isNotEmpty && !log.contains('Internal error')) {
          return 'Chyba: ${log.replaceAll('!', '')}';
        }
        return 'Nastala chyba při komunikaci se serverem.';
    }
  }

  static AppError createSessionExpiredError() {
    return const AppError(
      type: ErrorType.sessionExpired,
      message: 'Session expired based on time',
      userMessage: 'Relace vypršela. Přihlašujeme vás znovu...',
      canRetry: true,
    );
  }

  static AppError createNetworkError({String? details}) {
    return AppError(
      type: ErrorType.network,
      message: 'Network error${details != null ? ': $details' : ''}',
      userMessage: 'Problém s připojením. Zkontrolujte internet.',
      canRetry: true,
    );
  }

  static AppError createValidationError(String field) {
    return AppError(
      type: ErrorType.validation,
      message: 'Validation error for $field',
      userMessage: 'Zkontrolujte zadané údaje.',
      canRetry: false,
    );
  }
}