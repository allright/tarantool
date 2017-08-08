/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

#ifndef wrappers_h
#define wrappers_h

#include <stdlib.h>
#include <stdint.h>

void fiber_wrapper(void* ctx, void (*closure)(void*));
int box_error_set_wrapper(const char* file, unsigned line, uint32_t code, const char* message);

#endif /* wrappers_h */
