/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

#include <tarantool.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

void resolve(void *handle, const char *symbol, void **func) {
    *func = dlsym(handle, symbol);
    if (*func == NULL) {
        printf("can't resolve %s", symbol);
        dlclose(handle);
        exit(1);
    }
}

void tarantool_module_init() {
    void* handle = dlopen(NULL, RTLD_NOW | RTLD_GLOBAL);
    if (!handle) {
        perror("dlopen error");
        exit(1);
    }

    resolve(handle, "fiber_new", (void**)&_fiber_new);
    resolve(handle, "fiber_yield", (void**)&_fiber_yield);
    resolve(handle, "fiber_start", (void**)&_fiber_start);
    resolve(handle, "fiber_wakeup", (void**)&_fiber_wakeup);
    resolve(handle, "fiber_cancel", (void**)&_fiber_cancel);
    resolve(handle, "fiber_set_cancellable", (void**)&_fiber_set_cancellable);
    resolve(handle, "fiber_set_joinable", (void**)&_fiber_set_joinable);
    resolve(handle, "fiber_join", (void**)&_fiber_join);
    resolve(handle, "fiber_sleep", (void**)&_fiber_sleep);
    resolve(handle, "fiber_is_cancelled", (void**)&_fiber_is_cancelled);
    resolve(handle, "fiber_time", (void**)&_fiber_time);
    resolve(handle, "fiber_time64", (void**)&_fiber_time64);
    resolve(handle, "fiber_reschedule", (void**)&_fiber_reschedule);
    resolve(handle, "cord_slab_cache", (void**)&_cord_slab_cache);
    resolve(handle, "coio_wait", (void**)&_coio_wait);
    resolve(handle, "coio_close", (void**)&_coio_close);
    resolve(handle, "coio_getaddrinfo", (void**)&_coio_getaddrinfo);
    resolve(handle, "box_txn", (void**)&_box_txn);
    resolve(handle, "box_txn_begin", (void**)&_box_txn_begin);
    resolve(handle, "box_txn_commit", (void**)&_box_txn_commit);
    resolve(handle, "box_txn_rollback", (void**)&_box_txn_rollback);
    resolve(handle, "box_txn_alloc", (void**)&_box_txn_alloc);
    resolve(handle, "box_tuple_format_default", (void**)&_box_tuple_format_default);
    resolve(handle, "box_tuple_new", (void**)&_box_tuple_new);
    resolve(handle, "box_tuple_ref", (void**)&_box_tuple_ref);
    resolve(handle, "box_tuple_unref", (void**)&_box_tuple_unref);
    resolve(handle, "box_tuple_field_count", (void**)&_box_tuple_field_count);
    resolve(handle, "box_tuple_bsize", (void**)&_box_tuple_bsize);
    resolve(handle, "box_tuple_to_buf", (void**)&_box_tuple_to_buf);
    resolve(handle, "box_tuple_format", (void**)&_box_tuple_format);
    resolve(handle, "box_tuple_field", (void**)&_box_tuple_field);
    resolve(handle, "box_tuple_iterator", (void**)&_box_tuple_iterator);
    resolve(handle, "box_tuple_iterator_free", (void**)&_box_tuple_iterator_free);
    resolve(handle, "box_tuple_position", (void**)&_box_tuple_position);
    resolve(handle, "box_tuple_rewind", (void**)&_box_tuple_rewind);
    resolve(handle, "box_tuple_seek", (void**)&_box_tuple_seek);
    resolve(handle, "box_tuple_next", (void**)&_box_tuple_next);
    resolve(handle, "box_tuple_update", (void**)&_box_tuple_update);
    resolve(handle, "box_tuple_upsert", (void**)&_box_tuple_upsert);
    resolve(handle, "box_tuple_extract_key", (void**)&_box_tuple_extract_key);
    resolve(handle, "box_return_tuple", (void**)&_box_return_tuple);
    resolve(handle, "box_space_id_by_name", (void**)&_box_space_id_by_name);
    resolve(handle, "box_index_id_by_name", (void**)&_box_index_id_by_name);
    resolve(handle, "box_insert", (void**)&_box_insert);
    resolve(handle, "box_replace", (void**)&_box_replace);
    resolve(handle, "box_delete", (void**)&_box_delete);
    resolve(handle, "box_update", (void**)&_box_update);
    resolve(handle, "box_upsert", (void**)&_box_upsert);
    resolve(handle, "box_truncate", (void**)&_box_truncate);
    resolve(handle, "box_index_iterator", (void**)&_box_index_iterator);
    resolve(handle, "box_iterator_next", (void**)&_box_iterator_next);
    resolve(handle, "box_iterator_free", (void**)&_box_iterator_free);
    resolve(handle, "box_index_len", (void**)&_box_index_len);
    resolve(handle, "box_index_bsize", (void**)&_box_index_bsize);
    resolve(handle, "box_index_random", (void**)&_box_index_random);
    resolve(handle, "box_index_get", (void**)&_box_index_get);
    resolve(handle, "box_index_min", (void**)&_box_index_min);
    resolve(handle, "box_index_max", (void**)&_box_index_max);
    resolve(handle, "box_index_count", (void**)&_box_index_count);
    resolve(handle, "box_error_type", (void**)&_box_error_type);
    resolve(handle, "box_error_code", (void**)&_box_error_code);
    resolve(handle, "box_error_message", (void**)&_box_error_message);
    resolve(handle, "box_error_last", (void**)&_box_error_last);
    resolve(handle, "box_error_clear", (void**)&_box_error_clear);
    resolve(handle, "box_error_set", (void**)&_box_error_set);
    resolve(handle, "box_latch_new", (void**)&_box_latch_new);
    resolve(handle, "box_latch_delete", (void**)&_box_latch_delete);
    resolve(handle, "box_latch_lock", (void**)&_box_latch_lock);
    resolve(handle, "box_latch_trylock", (void**)&_box_latch_trylock);
    resolve(handle, "box_latch_unlock", (void**)&_box_latch_unlock);
    resolve(handle, "clock_realtime", (void**)&_clock_realtime);
    resolve(handle, "clock_monotonic", (void**)&_clock_monotonic);
    resolve(handle, "clock_process", (void**)&_clock_process);
    resolve(handle, "clock_thread", (void**)&_clock_thread);
    resolve(handle, "clock_realtime64", (void**)&_clock_realtime64);
    resolve(handle, "clock_monotonic64", (void**)&_clock_monotonic64);
    resolve(handle, "clock_process64", (void**)&_clock_process64);
    resolve(handle, "clock_thread64", (void**)&_clock_thread64);

    dlclose(handle);
}

int fiber_invoke(va_list ap) {
    void *ctx = va_arg(ap, void*);
    void (*closure)(void*) = va_arg(ap, void*);
    closure(ctx);
    return 0;
}

void fiber_wrapper(void* ctx, void (*closure)(void*)) {
    struct fiber *swift_closure = _fiber_new("fiber_wrapper", fiber_invoke);
    _fiber_start(swift_closure, ctx, closure);
}

int box_error_set_wrapper(const char* file, unsigned line, uint32_t code, const char* message) {
    int len = strlen(message);
    if (len <= 0)
        return -1;

    char buf[len*2];
    bzero(buf, len*2);
    for(int i = 0, j = 0; i < len; i++, j++) {
        buf[j] = message[i];
        if(buf[j] == '%') {
            buf[++j] = '%';
        }
    }

    return _box_error_set(file, line, code, buf);
}
