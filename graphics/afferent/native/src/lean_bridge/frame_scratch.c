#include "lean_bridge_internal.h"

typedef struct {
    lean_object* collect_commands;
    lean_object* collect_deferred;
    lean_object* hit_bounds;
    lean_object* interactive_names;
    size_t collect_commands_capacity;
    size_t collect_deferred_capacity;
    size_t hit_bounds_capacity;
    size_t hit_name_map_capacity;
    size_t hit_parent_map_capacity;
} demos_frame_scratch_t;

static lean_external_class* g_demos_frame_scratch_class = NULL;

static lean_object* frame_scratch_mk_empty_array(size_t capacity) {
    return lean_mk_empty_array_with_capacity(lean_box(capacity));
}

static void frame_scratch_finalizer(void* ptr) {
    demos_frame_scratch_t* scratch = (demos_frame_scratch_t*)ptr;
    if (scratch == NULL) return;
    if (scratch->collect_commands != NULL) lean_dec(scratch->collect_commands);
    if (scratch->collect_deferred != NULL) lean_dec(scratch->collect_deferred);
    if (scratch->hit_bounds != NULL) lean_dec(scratch->hit_bounds);
    if (scratch->interactive_names != NULL) lean_dec(scratch->interactive_names);
    free(scratch);
}

static void frame_scratch_foreach(void* ptr, b_lean_obj_arg f) {
    (void)ptr;
    (void)f;
}

static inline lean_object* frame_scratch_box(demos_frame_scratch_t* scratch) {
    if (g_demos_frame_scratch_class == NULL) {
        g_demos_frame_scratch_class = lean_register_external_class(
            frame_scratch_finalizer,
            frame_scratch_foreach
        );
    }
    return lean_alloc_external(g_demos_frame_scratch_class, scratch);
}

static inline demos_frame_scratch_t* frame_scratch_unbox(b_lean_obj_arg obj) {
    return (demos_frame_scratch_t*)lean_get_external_data(obj);
}

static lean_object* frame_scratch_checkout_array(
    lean_object** slot,
    size_t default_capacity,
    uint8_t clear_size
) {
    if (*slot == NULL) {
        *slot = frame_scratch_mk_empty_array(default_capacity);
    }
    lean_object* out = *slot;
    *slot = NULL;
    if (clear_size) {
        lean_array_set_size(out, 0);
    }
    return out;
}

static void frame_scratch_checkin_array(
    lean_object** slot,
    size_t* capacity_slot,
    b_lean_obj_arg arr
) {
    if (*slot != NULL) {
        lean_dec(*slot);
    }
    lean_inc(arr);
    *slot = (lean_object*)arr;
    if (capacity_slot != NULL) {
        *capacity_slot = lean_array_capacity(arr);
    }
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_create(
    b_lean_obj_arg collect_commands_cap,
    b_lean_obj_arg collect_deferred_cap,
    b_lean_obj_arg hit_bounds_cap,
    b_lean_obj_arg hit_name_map_cap,
    b_lean_obj_arg hit_parent_map_cap,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = (demos_frame_scratch_t*)malloc(sizeof(demos_frame_scratch_t));
    if (scratch == NULL) {
        return lean_io_result_mk_error(lean_mk_io_user_error(lean_mk_string("failed to allocate frame scratch")));
    }

    scratch->collect_commands_capacity = lean_usize_of_nat(collect_commands_cap);
    scratch->collect_deferred_capacity = lean_usize_of_nat(collect_deferred_cap);
    scratch->hit_bounds_capacity = lean_usize_of_nat(hit_bounds_cap);
    scratch->hit_name_map_capacity = lean_usize_of_nat(hit_name_map_cap);
    scratch->hit_parent_map_capacity = lean_usize_of_nat(hit_parent_map_cap);
    scratch->collect_commands = frame_scratch_mk_empty_array(scratch->collect_commands_capacity);
    scratch->collect_deferred = frame_scratch_mk_empty_array(scratch->collect_deferred_capacity);
    scratch->hit_bounds = frame_scratch_mk_empty_array(scratch->hit_bounds_capacity);
    scratch->interactive_names = frame_scratch_mk_empty_array(0);

    return lean_io_result_mk_ok(frame_scratch_box(scratch));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_checkout_collect_commands(
    b_lean_obj_arg scratch_obj,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    return lean_io_result_mk_ok(frame_scratch_checkout_array(
        &scratch->collect_commands,
        scratch->collect_commands_capacity,
        1
    ));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_checkin_collect_commands(
    b_lean_obj_arg scratch_obj,
    b_lean_obj_arg commands,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    frame_scratch_checkin_array(&scratch->collect_commands, &scratch->collect_commands_capacity, commands);
    return lean_io_result_mk_ok(lean_box(0));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_checkout_collect_deferred(
    b_lean_obj_arg scratch_obj,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    return lean_io_result_mk_ok(frame_scratch_checkout_array(
        &scratch->collect_deferred,
        scratch->collect_deferred_capacity,
        1
    ));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_checkin_collect_deferred(
    b_lean_obj_arg scratch_obj,
    b_lean_obj_arg deferred,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    frame_scratch_checkin_array(&scratch->collect_deferred, &scratch->collect_deferred_capacity, deferred);
    return lean_io_result_mk_ok(lean_box(0));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_checkout_hit_bounds(
    b_lean_obj_arg scratch_obj,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    return lean_io_result_mk_ok(frame_scratch_checkout_array(
        &scratch->hit_bounds,
        scratch->hit_bounds_capacity,
        1
    ));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_checkin_hit_bounds(
    b_lean_obj_arg scratch_obj,
    b_lean_obj_arg bounds,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    frame_scratch_checkin_array(&scratch->hit_bounds, &scratch->hit_bounds_capacity, bounds);
    return lean_io_result_mk_ok(lean_box(0));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_get_hit_name_map_capacity(
    b_lean_obj_arg scratch_obj,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    return lean_io_result_mk_ok(lean_usize_to_nat(scratch->hit_name_map_capacity));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_set_hit_name_map_capacity(
    b_lean_obj_arg scratch_obj,
    b_lean_obj_arg capacity,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    scratch->hit_name_map_capacity = lean_usize_of_nat(capacity);
    return lean_io_result_mk_ok(lean_box(0));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_get_hit_parent_map_capacity(
    b_lean_obj_arg scratch_obj,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    return lean_io_result_mk_ok(lean_usize_to_nat(scratch->hit_parent_map_capacity));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_set_hit_parent_map_capacity(
    b_lean_obj_arg scratch_obj,
    b_lean_obj_arg capacity,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    scratch->hit_parent_map_capacity = lean_usize_of_nat(capacity);
    return lean_io_result_mk_ok(lean_box(0));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_checkout_interactive_names(
    b_lean_obj_arg scratch_obj,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    return lean_io_result_mk_ok(frame_scratch_checkout_array(
        &scratch->interactive_names,
        0,
        0
    ));
}

LEAN_EXPORT lean_obj_res lean_demos_frame_scratch_checkin_interactive_names(
    b_lean_obj_arg scratch_obj,
    b_lean_obj_arg names,
    lean_obj_arg world
) {
    (void)world;
    demos_frame_scratch_t* scratch = frame_scratch_unbox(scratch_obj);
    frame_scratch_checkin_array(&scratch->interactive_names, NULL, names);
    return lean_io_result_mk_ok(lean_box(0));
}
