#include "lean_bridge_internal.h"
#include <lean/mimalloc.h>

LEAN_EXPORT lean_obj_res lean_afferent_runtime_get_process_info(lean_obj_arg world) {
    size_t elapsed_msecs = 0;
    size_t user_msecs = 0;
    size_t system_msecs = 0;
    size_t current_rss = 0;
    size_t peak_rss = 0;
    size_t current_commit = 0;
    size_t peak_commit = 0;
    size_t page_faults = 0;

    mi_process_info(
        &elapsed_msecs,
        &user_msecs,
        &system_msecs,
        &current_rss,
        &peak_rss,
        &current_commit,
        &peak_commit,
        &page_faults
    );

    lean_object* info = lean_alloc_ctor(0, 8, 0);
    lean_ctor_set(info, 0, lean_usize_to_nat(elapsed_msecs));
    lean_ctor_set(info, 1, lean_usize_to_nat(user_msecs));
    lean_ctor_set(info, 2, lean_usize_to_nat(system_msecs));
    lean_ctor_set(info, 3, lean_usize_to_nat(current_rss));
    lean_ctor_set(info, 4, lean_usize_to_nat(peak_rss));
    lean_ctor_set(info, 5, lean_usize_to_nat(current_commit));
    lean_ctor_set(info, 6, lean_usize_to_nat(peak_commit));
    lean_ctor_set(info, 7, lean_usize_to_nat(page_faults));

    return lean_io_result_mk_ok(info);
}

