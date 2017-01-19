/*
Copyright (c) 2014 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

Author: Leonardo de Moura
*/
#include "library/constructions/projection.h"
#include "library/constructions/has_sizeof.h"

namespace lean{
void initialize_constructions_module() {
    initialize_def_projection();
    initialize_has_sizeof();
}

void finalize_constructions_module() {
    finalize_has_sizeof();
    finalize_def_projection();
}
}