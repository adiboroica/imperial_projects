class BaseServiceError(Exception):
    """Shared base for all service-layer errors.

    Views catch this single type via ``_error_response`` in
    ``app/views/_errors.py`` and map the ``not_found`` / ``forbidden`` flags
    to HTTP 404 / 403 / 400.
    """

    def __init__(self, message, *, forbidden=False, not_found=False):
        super().__init__(message)
        self.message = message
        self.forbidden = forbidden
        self.not_found = not_found
