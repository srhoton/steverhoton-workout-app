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


def _extract_metrics(metrics_data: dict[str, Any] | None) -> dict[str, float]:
    """Extract avg watts, resistance, and cadence from average_summaries.

    Args:
        metrics_data: Performance graph data from GetWorkoutMetricsById.

    Returns:
        Dict with avg_watts, avg_resistance, avg_cadence keys.
    """
    if not metrics_data:
        return {"avg_watts": 0.0, "avg_resistance": 0.0, "avg_cadence": 0.0}

    avg_summaries = metrics_data.get("average_summaries", [])
    result: dict[str, float] = {"avg_watts": 0.0, "avg_resistance": 0.0, "avg_cadence": 0.0}

    for summary in avg_summaries:
        slug = summary.get("slug", "")
        value = summary.get("value", 0)
        try:
            if slug == "avg_output":
                result["avg_watts"] = round(float(value), 1)
            elif slug == "avg_resistance":
                result["avg_resistance"] = round(float(value), 1)
            elif slug == "avg_cadence":
                result["avg_cadence"] = round(float(value), 1)
        except (TypeError, ValueError):
            pass

    return result


def fetch_workouts() -> list[dict[str, Any]]:
    """Fetch all cycling workouts from the Peloton API.

    Returns:
        List of workout dicts with keys: date, total_output, avg_resistance,
        avg_cadence, avg_watts, duration_min, ride_title.
    """
    username, password = get_credentials()
    conn = pylotoncycle.PylotonCycle(username, password)
    workout_list = conn.GetWorkoutList(num_workouts=500)

    workouts: list[dict[str, Any]] = []
    for w in workout_list:
        if w.get("fitness_discipline") != "cycling":
            continue

        created_at = w.get("created_at", 0)
        date = datetime.fromtimestamp(created_at, tz=timezone.utc).date()

        total_output = w.get("total_work", 0) / 1000  # joules -> kJ

        ride = w.get("ride") or {}
        duration_sec = ride.get("duration", 0)
        ride_title = ride.get("title", "Unknown")

        # Fetch performance metrics with frequency=0 to get only averages
        workout_id = w.get("id")
        metrics = {}
        if workout_id:
            try:
                metrics = conn.GetWorkoutMetricsById(workout_id, frequency=0)
            except Exception:
                pass

        avg_watts = 0.0
        avg_resistance = 0.0
        avg_cadence = 0.0
        if metrics:
            avg_data = _extract_metrics(metrics)
            avg_watts = avg_data["avg_watts"]
            avg_resistance = avg_data["avg_resistance"]
            avg_cadence = avg_data["avg_cadence"]

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
