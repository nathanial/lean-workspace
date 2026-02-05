/*
 * Chronos FFI
 * Wall clock time bindings using POSIX time functions
 */

#include <lean/lean.h>
#include <time.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>

/* ============================================================================
 * Platform detection for timezone APIs
 *
 * Note: While localtime_rz/mktime_z exist on modern macOS and glibc, they
 * require specific header configurations. For simplicity and portability,
 * we use the TZ environment variable approach which works everywhere.
 * ============================================================================ */

/* Uncomment to enable localtime_rz on systems that support it:
 * #define HAVE_LOCALTIME_RZ 1
 */

/* ============================================================================
 * Helper: Create IO error result
 * ============================================================================ */

static lean_obj_res mk_io_error(const char* msg) {
    return lean_io_result_mk_error(lean_mk_io_user_error(lean_mk_string(msg)));
}

/* ============================================================================
 * Helper: Create a Prod (pair)
 * Prod A B is represented as: lean_alloc_ctor(0, 2, 0) with fields set
 * ============================================================================ */

static lean_obj_res mk_pair(lean_obj_arg fst, lean_obj_arg snd) {
    lean_object* pair = lean_alloc_ctor(0, 2, 0);
    lean_ctor_set(pair, 0, fst);
    lean_ctor_set(pair, 1, snd);
    return pair;
}

/* ============================================================================
 * chronos_now : IO (Int64 × UInt32)
 *
 * Get current wall clock time as (seconds, nanoseconds) since Unix epoch.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_now(lean_obj_arg world) {
    struct timespec ts;

    if (clock_gettime(CLOCK_REALTIME, &ts) != 0) {
        return mk_io_error("clock_gettime failed");
    }

    /* Return pair of (seconds : Int64, nanoseconds : UInt32) */
    lean_obj_res seconds = lean_int64_to_int(ts.tv_sec);
    lean_obj_res nanos = lean_box_uint32((uint32_t)ts.tv_nsec);

    return lean_io_result_mk_ok(mk_pair(seconds, nanos));
}

/* ============================================================================
 * DateTime representation
 *
 * We return DateTime fields as a nested tuple:
 * (year : Int32, month : UInt8, day : UInt8, hour : UInt8,
 *  minute : UInt8, second : UInt8, nanosecond : UInt32)
 *
 * Represented as: Prod Int32 (Prod UInt8 (Prod UInt8 (Prod UInt8 (Prod UInt8 (Prod UInt8 UInt32)))))
 * ============================================================================ */

static lean_obj_res mk_datetime_tuple(int32_t year, uint8_t month, uint8_t day,
                                       uint8_t hour, uint8_t minute, uint8_t second,
                                       uint32_t nanosecond) {
    /* Build from inside out:
     * innermost: Prod UInt8 UInt32 = (second, nanosecond)
     * then: Prod UInt8 (Prod UInt8 UInt32) = (minute, ...)
     * etc.
     *
     * Note: We use lean_int_to_int32 which creates a boxed Int representation
     * that Lean will interpret as Int32.
     */
    lean_obj_res p6 = mk_pair(lean_box(second), lean_box_uint32(nanosecond));
    lean_obj_res p5 = mk_pair(lean_box(minute), p6);
    lean_obj_res p4 = mk_pair(lean_box(hour), p5);
    lean_obj_res p3 = mk_pair(lean_box(day), p4);
    lean_obj_res p2 = mk_pair(lean_box(month), p3);
    /* For Int32, box it directly since it fits in a small int */
    lean_obj_res p1 = mk_pair(lean_box((size_t)(int64_t)year), p2);

    return p1;
}

/* ============================================================================
 * chronos_to_utc : Int64 → UInt32 → IO DateTimeTuple
 *
 * Convert Unix timestamp to UTC date/time components.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_to_utc(lean_obj_arg seconds_obj, uint32_t nanos, lean_obj_arg world) {
    int64_t seconds = lean_int64_of_int(seconds_obj);
    lean_dec(seconds_obj);

    time_t t = (time_t)seconds;
    struct tm tm_result;

    if (gmtime_r(&t, &tm_result) == NULL) {
        return mk_io_error("gmtime_r failed");
    }

    lean_obj_res tuple = mk_datetime_tuple(
        (int32_t)(tm_result.tm_year + 1900),  /* year */
        (uint8_t)(tm_result.tm_mon + 1),       /* month: 1-12 */
        (uint8_t)tm_result.tm_mday,            /* day: 1-31 */
        (uint8_t)tm_result.tm_hour,            /* hour: 0-23 */
        (uint8_t)tm_result.tm_min,             /* minute: 0-59 */
        (uint8_t)tm_result.tm_sec,             /* second: 0-59 */
        nanos                                   /* nanosecond */
    );

    return lean_io_result_mk_ok(tuple);
}

/* ============================================================================
 * chronos_to_local : Int64 → UInt32 → IO DateTimeTuple
 *
 * Convert Unix timestamp to local date/time components.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_to_local(lean_obj_arg seconds_obj, uint32_t nanos, lean_obj_arg world) {
    int64_t seconds = lean_int64_of_int(seconds_obj);
    lean_dec(seconds_obj);

    time_t t = (time_t)seconds;
    struct tm tm_result;

    if (localtime_r(&t, &tm_result) == NULL) {
        return mk_io_error("localtime_r failed");
    }

    lean_obj_res tuple = mk_datetime_tuple(
        (int32_t)(tm_result.tm_year + 1900),  /* year */
        (uint8_t)(tm_result.tm_mon + 1),       /* month: 1-12 */
        (uint8_t)tm_result.tm_mday,            /* day: 1-31 */
        (uint8_t)tm_result.tm_hour,            /* hour: 0-23 */
        (uint8_t)tm_result.tm_min,             /* minute: 0-59 */
        (uint8_t)tm_result.tm_sec,             /* second: 0-59 */
        nanos                                   /* nanosecond */
    );

    return lean_io_result_mk_ok(tuple);
}

/* ============================================================================
 * chronos_from_utc : Int32 → UInt8 → UInt8 → UInt8 → UInt8 → UInt8 → UInt32 → IO (Int64 × UInt32)
 *
 * Convert UTC date/time components back to Unix timestamp.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_from_utc(
    int32_t year, uint8_t month, uint8_t day,
    uint8_t hour, uint8_t minute, uint8_t second,
    uint32_t nanosecond,
    lean_obj_arg world
) {
    struct tm tm_input;
    tm_input.tm_year = year - 1900;
    tm_input.tm_mon = month - 1;
    tm_input.tm_mday = day;
    tm_input.tm_hour = hour;
    tm_input.tm_min = minute;
    tm_input.tm_sec = second;
    tm_input.tm_isdst = 0;  /* UTC has no DST */

    /* timegm is a BSD/GNU extension that converts struct tm in UTC to time_t
     * On systems without timegm, we could use a portable workaround */
    errno = 0;
    time_t t = timegm(&tm_input);

    /* -1 is both a valid timestamp (1969-12-31 23:59:59 UTC) and an error indicator.
     * We distinguish by checking errno: if errno is set, it's an error. */
    if (t == (time_t)-1 && errno != 0) {
        return mk_io_error("timegm failed");
    }

    lean_obj_res seconds = lean_int64_to_int((int64_t)t);
    lean_obj_res nanos = lean_box_uint32(nanosecond);

    return lean_io_result_mk_ok(mk_pair(seconds, nanos));
}

/* ============================================================================
 * chronos_get_timezone_offset : IO Int32
 *
 * Get the current timezone offset in seconds (local - UTC).
 * Positive for east of UTC, negative for west.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_get_timezone_offset(lean_obj_arg world) {
    time_t now = time(NULL);
    struct tm local_tm, utc_tm;

    if (localtime_r(&now, &local_tm) == NULL) {
        return mk_io_error("localtime_r failed");
    }

    if (gmtime_r(&now, &utc_tm) == NULL) {
        return mk_io_error("gmtime_r failed");
    }

    /* To find the offset, interpret both tm structs as local time using mktime.
     * mktime(&local_tm) gives the correct epoch seconds.
     * mktime(&utc_tm) treats UTC fields as if they were local time, which is wrong
     * by exactly the timezone offset. So the difference is the offset. */
    time_t local_as_local = mktime(&local_tm);
    time_t utc_as_local = mktime(&utc_tm);

    int32_t offset = (int32_t)(local_as_local - utc_as_local);

    /* Box as small int - offset fits within range */
    return lean_io_result_mk_ok(lean_box((size_t)(int64_t)offset));
}

/* ============================================================================
 * chronos_monotonic_now : IO (Int64 × UInt32)
 *
 * Get current monotonic clock time as (seconds, nanoseconds).
 * Monotonic clocks are unaffected by NTP adjustments or DST changes.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_monotonic_now(lean_obj_arg world) {
    struct timespec ts;

    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) {
        return mk_io_error("clock_gettime(CLOCK_MONOTONIC) failed");
    }

    lean_obj_res seconds = lean_int64_to_int(ts.tv_sec);
    lean_obj_res nanos = lean_box_uint32((uint32_t)ts.tv_nsec);

    return lean_io_result_mk_ok(mk_pair(seconds, nanos));
}

/* ============================================================================
 * chronos_weekday : Int64 → IO UInt8
 *
 * Get the day of week (0=Sunday, 1=Monday, ..., 6=Saturday) for a timestamp.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_weekday(lean_obj_arg seconds_obj, lean_obj_arg world) {
    int64_t seconds = lean_int64_of_int(seconds_obj);
    lean_dec(seconds_obj);

    time_t t = (time_t)seconds;
    struct tm tm_result;

    if (gmtime_r(&t, &tm_result) == NULL) {
        return mk_io_error("gmtime_r failed");
    }

    /* tm_wday: days since Sunday (0-6) */
    return lean_io_result_mk_ok(lean_box((uint8_t)tm_result.tm_wday));
}

/* ============================================================================
 * chronos_day_of_year : Int64 → IO UInt16
 *
 * Get the day of year (1-366) for a timestamp.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_day_of_year(lean_obj_arg seconds_obj, lean_obj_arg world) {
    int64_t seconds = lean_int64_of_int(seconds_obj);
    lean_dec(seconds_obj);

    time_t t = (time_t)seconds;
    struct tm tm_result;

    if (gmtime_r(&t, &tm_result) == NULL) {
        return mk_io_error("gmtime_r failed");
    }

    /* tm_yday: days since January 1 (0-365), we add 1 for 1-366 */
    uint16_t day_of_year = (uint16_t)(tm_result.tm_yday + 1);
    return lean_io_result_mk_ok(lean_box(day_of_year));
}

/* ============================================================================
 * Timezone External Class
 *
 * Provides IANA timezone support using system tzdata.
 * On modern systems (macOS 10.12+, glibc 2.29+), uses thread-safe
 * localtime_rz/mktime_z. Falls back to TZ environment variable on older systems.
 * ============================================================================ */

/* Wrapper structure for timezone handles */
typedef struct {
#ifdef HAVE_LOCALTIME_RZ
    timezone_t handle;      /* Thread-safe timezone handle */
#else
    char* tz_name;          /* Timezone name for TZ env fallback */
#endif
    char* name;             /* Canonical name for name() function */
    int is_utc;             /* 1 if this is UTC (special handling) */
} TimezoneWrapper;

static lean_external_class* g_timezone_class = NULL;

static void timezone_finalizer(void* ptr) {
    TimezoneWrapper* tz = (TimezoneWrapper*)ptr;
    if (tz) {
#ifdef HAVE_LOCALTIME_RZ
        if (tz->handle && !tz->is_utc) {
            tzfree(tz->handle);
        }
#else
        if (tz->tz_name) {
            free(tz->tz_name);
        }
#endif
        if (tz->name) free(tz->name);
        free(tz);
    }
}

static void noop_foreach(void* ptr, b_lean_obj_arg f) {
    (void)ptr;
    (void)f;
}

static void init_timezone_class(void) {
    if (g_timezone_class == NULL) {
        g_timezone_class = lean_register_external_class(timezone_finalizer, noop_foreach);
    }
}

/* ============================================================================
 * chronos_timezone_from_name : String -> IO (Option Timezone)
 *
 * Load a timezone by IANA name (e.g., "America/New_York").
 * Returns None if the timezone name is not recognized.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_timezone_from_name(b_lean_obj_arg name_obj, lean_obj_arg world) {
    init_timezone_class();
    const char* name = lean_string_cstr(name_obj);

    TimezoneWrapper* wrapper = (TimezoneWrapper*)malloc(sizeof(TimezoneWrapper));
    if (!wrapper) {
        return lean_io_result_mk_ok(lean_box(0));  /* None */
    }
    wrapper->name = strdup(name);
    wrapper->is_utc = (strcmp(name, "UTC") == 0 || strcmp(name, "Etc/UTC") == 0);

#ifdef HAVE_LOCALTIME_RZ
    /* Use tzalloc to load timezone - returns NULL if invalid */
    wrapper->handle = tzalloc(name);
    if (wrapper->handle == NULL && !wrapper->is_utc) {
        free(wrapper->name);
        free(wrapper);
        return lean_io_result_mk_ok(lean_box(0));  /* None */
    }
#else
    /* Fallback: validate by temporarily setting TZ and checking localtime behavior */
    wrapper->tz_name = strdup(name);

    /* Quick validation: set TZ and try a conversion */
    char* old_tz = getenv("TZ");
    char* saved_tz = old_tz ? strdup(old_tz) : NULL;

    char tz_val[512];
    snprintf(tz_val, sizeof(tz_val), ":%s", name);
    setenv("TZ", tz_val, 1);
    tzset();

    /* Try converting a known timestamp */
    time_t test_time = 0;
    struct tm result;
    struct tm* success = localtime_r(&test_time, &result);

    /* Restore original TZ */
    if (saved_tz) {
        setenv("TZ", saved_tz, 1);
        free(saved_tz);
    } else {
        unsetenv("TZ");
    }
    tzset();

    if (!success && !wrapper->is_utc) {
        free(wrapper->tz_name);
        free(wrapper->name);
        free(wrapper);
        return lean_io_result_mk_ok(lean_box(0));  /* None */
    }
#endif

    /* Create external object wrapped in Option.some */
    lean_object* tz_obj = lean_alloc_external(g_timezone_class, wrapper);
    lean_object* some_tz = lean_alloc_ctor(1, 1, 0);  /* Some */
    lean_ctor_set(some_tz, 0, tz_obj);
    return lean_io_result_mk_ok(some_tz);
}

/* ============================================================================
 * chronos_timezone_utc : IO Timezone
 *
 * Get the UTC timezone.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_timezone_utc(lean_obj_arg world) {
    init_timezone_class();

    TimezoneWrapper* wrapper = (TimezoneWrapper*)malloc(sizeof(TimezoneWrapper));
    wrapper->name = strdup("UTC");
    wrapper->is_utc = 1;

#ifdef HAVE_LOCALTIME_RZ
    wrapper->handle = tzalloc("UTC");
#else
    wrapper->tz_name = strdup("UTC");
#endif

    lean_object* obj = lean_alloc_external(g_timezone_class, wrapper);
    return lean_io_result_mk_ok(obj);
}

/* ============================================================================
 * chronos_timezone_local : IO Timezone
 *
 * Get the local system timezone.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_timezone_local(lean_obj_arg world) {
    init_timezone_class();

    TimezoneWrapper* wrapper = (TimezoneWrapper*)malloc(sizeof(TimezoneWrapper));
    wrapper->is_utc = 0;

#ifdef HAVE_LOCALTIME_RZ
    wrapper->handle = tzalloc(NULL);  /* NULL = local timezone */

    /* Get timezone name by examining a conversion */
    time_t now = time(NULL);
    struct tm local_tm;
    localtime_rz(wrapper->handle, &now, &local_tm);
    wrapper->name = strdup(local_tm.tm_zone ? local_tm.tm_zone : "Local");
#else
    wrapper->tz_name = NULL;  /* NULL means use default local */

    time_t now = time(NULL);
    struct tm local_tm;
    localtime_r(&now, &local_tm);
    wrapper->name = strdup(local_tm.tm_zone ? local_tm.tm_zone : "Local");
#endif

    lean_object* obj = lean_alloc_external(g_timezone_class, wrapper);
    return lean_io_result_mk_ok(obj);
}

/* ============================================================================
 * chronos_timezone_name : Timezone -> IO String
 *
 * Get the name of a timezone.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_timezone_name(b_lean_obj_arg tz_obj, lean_obj_arg world) {
    TimezoneWrapper* wrapper = (TimezoneWrapper*)lean_get_external_data(tz_obj);
    return lean_io_result_mk_ok(lean_mk_string(wrapper->name ? wrapper->name : "Unknown"));
}

/* ============================================================================
 * chronos_timezone_to_datetime : Timezone -> Int -> UInt32 -> IO DateTimeTuple
 *
 * Convert UTC timestamp to DateTime in the specified timezone.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_timezone_to_datetime(
    b_lean_obj_arg tz_obj,
    lean_obj_arg seconds_obj,
    uint32_t nanos,
    lean_obj_arg world
) {
    TimezoneWrapper* wrapper = (TimezoneWrapper*)lean_get_external_data(tz_obj);
    int64_t seconds = lean_int64_of_int(seconds_obj);
    lean_dec(seconds_obj);

    time_t t = (time_t)seconds;
    struct tm result;

    if (wrapper->is_utc) {
        /* UTC: use gmtime_r */
        if (gmtime_r(&t, &result) == NULL) {
            return mk_io_error("gmtime_r failed");
        }
    }
#ifdef HAVE_LOCALTIME_RZ
    else {
        /* Use thread-safe localtime_rz */
        if (localtime_rz(wrapper->handle, &t, &result) == NULL) {
            return mk_io_error("localtime_rz failed");
        }
    }
#else
    else {
        /* Fallback: temporarily set TZ */
        char* old_tz = getenv("TZ");
        char* saved_tz = old_tz ? strdup(old_tz) : NULL;

        if (wrapper->tz_name) {
            char tz_val[512];
            snprintf(tz_val, sizeof(tz_val), ":%s", wrapper->tz_name);
            setenv("TZ", tz_val, 1);
        } else {
            /* Local timezone - unset TZ to use system default */
            unsetenv("TZ");
        }
        tzset();

        struct tm* success = localtime_r(&t, &result);

        /* Restore TZ */
        if (saved_tz) {
            setenv("TZ", saved_tz, 1);
            free(saved_tz);
        } else {
            unsetenv("TZ");
        }
        tzset();

        if (!success) {
            return mk_io_error("localtime_r failed");
        }
    }
#endif

    lean_obj_res tuple = mk_datetime_tuple(
        (int32_t)(result.tm_year + 1900),
        (uint8_t)(result.tm_mon + 1),
        (uint8_t)result.tm_mday,
        (uint8_t)result.tm_hour,
        (uint8_t)result.tm_min,
        (uint8_t)result.tm_sec,
        nanos
    );

    return lean_io_result_mk_ok(tuple);
}

/* ============================================================================
 * chronos_timezone_from_datetime : Timezone -> Int32 -> UInt8 x 5 -> UInt32 -> IO (Int x UInt32)
 *
 * Convert DateTime in the specified timezone to UTC timestamp.
 * ============================================================================ */

LEAN_EXPORT lean_obj_res chronos_timezone_from_datetime(
    b_lean_obj_arg tz_obj,
    int32_t year, uint8_t month, uint8_t day,
    uint8_t hour, uint8_t minute, uint8_t second,
    uint32_t nanosecond,
    lean_obj_arg world
) {
    TimezoneWrapper* wrapper = (TimezoneWrapper*)lean_get_external_data(tz_obj);

    struct tm tm_input;
    memset(&tm_input, 0, sizeof(tm_input));
    tm_input.tm_year = year - 1900;
    tm_input.tm_mon = month - 1;
    tm_input.tm_mday = day;
    tm_input.tm_hour = hour;
    tm_input.tm_min = minute;
    tm_input.tm_sec = second;
    tm_input.tm_isdst = -1;  /* Let system determine DST */

    time_t result;

    if (wrapper->is_utc) {
        /* UTC: use timegm */
        tm_input.tm_isdst = 0;
        errno = 0;
        result = timegm(&tm_input);
    }
#ifdef HAVE_LOCALTIME_RZ
    else {
        /* Use thread-safe mktime_z */
        result = mktime_z(wrapper->handle, &tm_input);
    }
#else
    else {
        /* Fallback: temporarily set TZ and use mktime */
        char* old_tz = getenv("TZ");
        char* saved_tz = old_tz ? strdup(old_tz) : NULL;

        if (wrapper->tz_name) {
            char tz_val[512];
            snprintf(tz_val, sizeof(tz_val), ":%s", wrapper->tz_name);
            setenv("TZ", tz_val, 1);
        } else {
            unsetenv("TZ");
        }
        tzset();

        errno = 0;
        result = mktime(&tm_input);

        /* Restore TZ */
        if (saved_tz) {
            setenv("TZ", saved_tz, 1);
            free(saved_tz);
        } else {
            unsetenv("TZ");
        }
        tzset();
    }
#endif

    /* -1 is both a valid timestamp and an error indicator.
     * For UTC (timegm), we check errno. For local time (mktime), -1 with
     * errno set indicates error. */
    if (result == (time_t)-1 && errno != 0) {
        return mk_io_error("mktime/timegm failed");
    }

    lean_obj_res seconds = lean_int64_to_int((int64_t)result);
    lean_obj_res nanos = lean_box_uint32(nanosecond);

    return lean_io_result_mk_ok(mk_pair(seconds, nanos));
}
