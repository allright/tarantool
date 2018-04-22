/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include <wrappers.h>
#include <module.h>


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
    size_t len = strlen(message);
    if (len <= 0)
        return -1;

    char buf[len*2];
    bzero(buf, len*2);
    for(size_t i = 0, j = 0; i < len; i++, j++) {
        buf[j] = message[i];
        if(buf[j] == '%') {
            buf[++j] = '%';
        }
    }

    return _box_error_set(file, line, code, buf);
}
