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

#ifndef wrappers_h
#define wrappers_h

#include <stdlib.h>
#include <stdint.h>

struct fiber_attr;

void fiber_wrapper(void* ctx, void (*closure)(void*));
void fiber_wrapper_ex(void* ctx, struct fiber_attr* attr, void (*closure)(void*));
int box_error_set_wrapper(const char* file, unsigned line, uint32_t code, const char* message);

#endif /* wrappers_h */
