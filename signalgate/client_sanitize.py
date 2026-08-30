"""Lightweight client-error sanitization safe for isolated fuzz packaging."""

from typing import Any

_STACKTRACE_MARKERS = (
    'Traceback (most recent call last):',
    '  File "',
)

_BANNED_ERROR_KEYS = {
    'trace',
    'traceback',
    'stack',
    'stacktrace',
    'stack_trace',
    'exc',
    'exception',
    'exc_info',
    'debug_trace',
    'decision_trace',
}


def sanitize_for_client(obj: Any) -> Any:
    """Best-effort scrubber to prevent leaking stack traces or internal debug fields."""

    if obj is None:
        return None

    if isinstance(obj, str):
        if any(marker in obj for marker in _STACKTRACE_MARKERS):
            return 'redacted'
        return obj

    if isinstance(obj, (int, float, bool)):
        return obj

    if isinstance(obj, list):
        return [sanitize_for_client(item) for item in obj]

    if isinstance(obj, dict):
        out: dict[Any, Any] = {}
        for key, value in obj.items():
            if str(key).lower() in _BANNED_ERROR_KEYS:
                continue
            out[key] = sanitize_for_client(value)
        return out

    return str(obj)
