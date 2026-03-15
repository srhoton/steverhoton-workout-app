"""Peloton API client for fetching workout data."""

from __future__ import annotations

import os
from datetime import datetime, timezone
from typing import Any

import pylotoncycle


def get_credentials() -> tuple[str, str]:
    """Read Peloton credentials from environment variables.

    Returns:
        Tuple of (username, password).

    Raises:
        SystemExit: If credentials are not set.
    """
    username = os.environ.get("PELOTON_USERNAME")
    password = os.environ.get("PELOTON_PASSWORD")
    if not username or not password:
        raise SystemExit("Set PELOTON_USERNAME and PELOTON_PASSWORD environment variables.")
    return username, password


def fetch_workouts() -> list[dict[str, Any]]:
    """Fetch all cycling workouts from the Peloton API.

    Returns:
        List of workout dicts with keys: date, total_output, avg_resistance,
        avg_cadence, avg_watts, duration_min, ride_title.
    """
    username, password = get_credentials()
    conn = pylotoncycle.PylotonCycle(username, password)
    raw_workouts = conn.GetRecentWorkouts(num_workouts=500)

    workouts: list[dict[str, Any]] = []
    for w in raw_workouts:
        if w.get("fitness_discipline") != "cycling":
            continue

        created_at = w.get("created_at", 0)
        date = datetime.fromtimestamp(created_at, tz=timezone.utc).date()

        total_output = w.get("total_work", 0) / 1000  # joules -> kJ

        ride = w.get("ride", {}) or {}
        duration_sec = ride.get("duration", w.get("ride", {}).get("duration", 0))
        ride_title = ride.get("title", "Unknown")

        avg_resistance = _safe_float(w, "avg_resistance")
        avg_cadence = _safe_float(w, "avg_cadence")
        avg_watts = _safe_float(w, "avg_watts")

        workouts.append(
            {
                "date": date,
                "total_output": round(total_output, 1),
                "avg_resistance": avg_resistance,
                "avg_cadence": avg_cadence,
                "avg_watts": avg_watts,
                "duration_min": round(duration_sec / 60, 1),
                "ride_title": ride_title,
            }
        )

    return workouts


def _safe_float(data: dict[str, Any], key: str) -> float:
    """Extract a float value from a dict, returning 0.0 on failure."""
    val = data.get(key, 0)
    try:
        return round(float(val), 1)
    except (TypeError, ValueError):
        return 0.0
