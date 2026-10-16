"""
Prayer Times & Qibla Computational Engine (T-401 & FR-PRY-001..008)
Offline astronomical calculation engine for prayer times and spherical Qibla bearing.
Implements the Egyptian General Authority of Survey (Fajr 19.5°, Isha 17.5°) as default.
"""

import math
from datetime import datetime, date, time, timedelta
from typing import Dict, Tuple, Any

# Kaaba Coordinates in Makkah
MAKKAH_LAT = 21.422487
MAKKAH_LNG = 39.826206

CALCULATION_METHODS = {
    "egypt": {
        "name_ar": "الهيئة المصرية العامة للمساحة",
        "fajr_angle": 19.5,
        "isha_angle": 17.5,
        "isha_fixed_minutes": None
    },
    "makkah": {
        "name_ar": "أم القرى (مكة المكرمة)",
        "fajr_angle": 18.5,
        "isha_angle": 0.0,
        "isha_fixed_minutes": 90
    },
    "mwl": {
        "name_ar": "رابطة العالم الإسلامي",
        "fajr_angle": 18.0,
        "isha_angle": 17.0,
        "isha_fixed_minutes": None
    }
}


def compute_qibla_bearing(lat: float, lng: float) -> float:
    """
    Computes Qibla direction (true azimuth in degrees from North 0..360)
    using the spherical great-circle trigonometry formula.
    """
    phi1 = math.radians(lat)
    phi2 = math.radians(MAKKAH_LAT)
    delta_lambda = math.radians(MAKKAH_LNG - lng)

    y = math.sin(delta_lambda)
    x = math.cos(phi1) * math.tan(phi2) - math.sin(phi1) * math.cos(delta_lambda)

    bearing_rad = math.atan2(y, x)
    bearing_deg = (math.degrees(bearing_rad) + 360.0) % 360.0
    return round(bearing_deg, 2)


def julian_day(year: int, month: int, day: int) -> float:
    if month <= 2:
        year -= 1
        month += 12
    a = math.floor(year / 100)
    b = 2 - a + math.floor(a / 4)
    return math.floor(365.25 * (year + 4716)) + math.floor(30.6001 * (month + 1)) + day + b - 1524.5


def sun_position(jd: float) -> Tuple[float, float, float]:
    """Returns (declination, equation of time in hours, apparent radius)"""
    d = jd - 2451545.0
    q = (280.459 + 0.98564736 * d) % 360.0
    g = math.radians((357.529 + 0.98560028 * d) % 360.0)

    l = q + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g)
    l_rad = math.radians(l % 360.0)

    e = 23.439 - 0.00000036 * d
    e_rad = math.radians(e)

    sin_dec = math.sin(e_rad) * math.sin(l_rad)
    dec = math.asin(sin_dec)

    ra = math.atan2(math.cos(e_rad) * math.sin(l_rad), math.cos(l_rad))
    ra_deg = (math.degrees(ra) + 360.0) % 360.0

    eq_time_hours = (q - ra_deg) / 15.0
    # normalize between -0.5 and 0.5 hours if needed
    if eq_time_hours > 12:
        eq_time_hours -= 24
    elif eq_time_hours < -12:
        eq_time_hours += 24

    return dec, eq_time_hours, 0.267


def compute_prayer_times(
    target_date: date,
    lat: float,
    lng: float,
    timezone_offset_hours: float,
    method_key: str = "egypt",
    hanafi_asr: bool = False
) -> Dict[str, str]:
    """
    Computes Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha in 'HH:MM' 24h format.
    """
    method = CALCULATION_METHODS.get(method_key, CALCULATION_METHODS["egypt"])
    jd = julian_day(target_date.year, target_date.month, target_date.day)
    dec, eqt, _ = sun_position(jd)

    lat_rad = math.radians(lat)

    # Solar noon (Dhuhr)
    dhuhr_hours = 12.0 + timezone_offset_hours - (lng / 15.0) - eqt

    def hour_angle(altitude_deg: float, direction: str = "before") -> float:
        alt_rad = math.radians(altitude_deg)
        cos_ha = (math.sin(alt_rad) - math.sin(lat_rad) * math.sin(dec)) / (
            math.cos(lat_rad) * math.cos(dec)
        )
        if cos_ha > 1.0 or cos_ha < -1.0:
            return 0.0
        ha_deg = math.degrees(math.acos(cos_ha))
        return ha_deg / 15.0

    # Sunrise & Sunset (geometric altitude -0.833° for atmospheric refraction and solar radius)
    ha_rise = hour_angle(-0.833)
    sunrise_hours = dhuhr_hours - ha_rise
    maghrib_hours = dhuhr_hours + ha_rise

    # Fajr
    ha_fajr = hour_angle(-method["fajr_angle"])
    fajr_hours = dhuhr_hours - ha_fajr

    # Asr (shadow length: Shafi'i=1, Hanafi=2)
    shadow_factor = 2.0 if hanafi_asr else 1.0
    asr_alt_rad = math.atan(1.0 / (shadow_factor + math.tan(abs(lat_rad - dec))))
    asr_alt_deg = math.degrees(asr_alt_rad)
    ha_asr = hour_angle(asr_alt_deg)
    asr_hours = dhuhr_hours + ha_asr

    # Isha
    if method["isha_fixed_minutes"] is not None:
        isha_hours = maghrib_hours + (method["isha_fixed_minutes"] / 60.0)
    else:
        ha_isha = hour_angle(-method["isha_angle"])
        isha_hours = dhuhr_hours + ha_isha

    def format_hours(h: float) -> str:
        h = (h + 24.0) % 24.0
        hrs = int(h)
        mins = int(round((h - hrs) * 60))
        if mins >= 60:
            hrs = (hrs + 1) % 24
            mins = 0
        return f"{hrs:02d}:{mins:02d}"

    return {
        "fajr": format_hours(fajr_hours),
        "sunrise": format_hours(sunrise_hours),
        "dhuhr": format_hours(dhuhr_hours),
        "asr": format_hours(asr_hours),
        "maghrib": format_hours(maghrib_hours),
        "isha": format_hours(isha_hours)
    }
