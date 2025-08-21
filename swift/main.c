#include <stdio.h>
#include <stdint.h>
#include <caml/callback.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>

static const value * query_server_closure = NULL;

static void init_ocaml(void) __attribute__((constructor));
static void init_ocaml(void) {
    char *argv[] = {"main", NULL};
    caml_startup(argv);
    query_server_closure = caml_named_value("query_server");
}

void query_server(char *inet_addr, int n) {
    caml_callback2(*query_server_closure, caml_copy_string(inet_addr), Val_int(n));
}