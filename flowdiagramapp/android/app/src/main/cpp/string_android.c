/*
 * string_android.c
 * Reemplazo de picoc/cstdlib/string.c para Android.
 *
 * string.c original usa index() y rindex() que no están disponibles en
 * Android Bionic (son funciones POSIX obsoletas — equivalentes a strchr/strrchr).
 * Este archivo provee exactamente las mismas funciones de string.h que
 * FlowCode necesita, usando solo funciones estándar disponibles en Bionic.
 */
#include "picoc/interpreter.h"

#ifndef BUILTIN_MINI_STDLIB

static int String_ZeroValue = 0;

void StringStrcpy(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strcpy(A[0]->Val->Pointer, A[1]->Val->Pointer); }

void StringStrncpy(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strncpy(A[0]->Val->Pointer, A[1]->Val->Pointer, A[2]->Val->Integer); }

void StringStrcmp(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Integer = strcmp(A[0]->Val->Pointer, A[1]->Val->Pointer); }

void StringStrncmp(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Integer = strncmp(A[0]->Val->Pointer, A[1]->Val->Pointer, A[2]->Val->Integer); }

void StringStrcat(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strcat(A[0]->Val->Pointer, A[1]->Val->Pointer); }

void StringStrncat(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strncat(A[0]->Val->Pointer, A[1]->Val->Pointer, A[2]->Val->Integer); }

void StringStrlen(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Integer = (int)strlen(A[0]->Val->Pointer); }

void StringMemset(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = memset(A[0]->Val->Pointer, A[1]->Val->Integer, A[2]->Val->Integer); }

void StringMemcpy(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = memcpy(A[0]->Val->Pointer, A[1]->Val->Pointer, A[2]->Val->Integer); }

void StringMemcmp(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Integer = memcmp(A[0]->Val->Pointer, A[1]->Val->Pointer, A[2]->Val->Integer); }

void StringMemmove(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = memmove(A[0]->Val->Pointer, A[1]->Val->Pointer, A[2]->Val->Integer); }

void StringMemchr(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = memchr(A[0]->Val->Pointer, A[1]->Val->Integer, A[2]->Val->Integer); }

void StringStrchr(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strchr(A[0]->Val->Pointer, A[1]->Val->Integer); }

void StringStrrchr(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strrchr(A[0]->Val->Pointer, A[1]->Val->Integer); }

void StringStrcoll(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Integer = strcoll(A[0]->Val->Pointer, A[1]->Val->Pointer); }

void StringStrerror(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strerror(A[0]->Val->Integer); }

void StringStrspn(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Integer = (int)strspn(A[0]->Val->Pointer, A[1]->Val->Pointer); }

void StringStrcspn(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Integer = (int)strcspn(A[0]->Val->Pointer, A[1]->Val->Pointer); }

void StringStrpbrk(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strpbrk(A[0]->Val->Pointer, A[1]->Val->Pointer); }

void StringStrstr(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strstr(A[0]->Val->Pointer, A[1]->Val->Pointer); }

void StringStrtok(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strtok(A[0]->Val->Pointer, A[1]->Val->Pointer); }

void StringStrxfrm(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Integer = (int)strxfrm(A[0]->Val->Pointer, A[1]->Val->Pointer, A[2]->Val->Integer); }

void StringStrdup(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strdup(A[0]->Val->Pointer); }

void StringStrtok_r(struct ParseState *P, struct Value *R, struct Value **A, int N)
    { R->Val->Pointer = strtok_r(A[0]->Val->Pointer, A[1]->Val->Pointer, (char **)A[2]->Val->Pointer); }

/* ---------- Library function table ---------- */
struct LibraryFunction StringFunctions[] =
{
    { StringMemcpy,   "void *memcpy(void *,void *,int);"    },
    { StringMemmove,  "void *memmove(void *,void *,int);"   },
    { StringMemchr,   "void *memchr(char *,int,int);"       },
    { StringMemcmp,   "int memcmp(void *,void *,int);"      },
    { StringMemset,   "void *memset(void *,int,int);"       },
    { StringStrcat,   "char *strcat(char *,char *);"        },
    { StringStrncat,  "char *strncat(char *,char *,int);"   },
    { StringStrchr,   "char *strchr(char *,int);"           },
    { StringStrrchr,  "char *strrchr(char *,int);"          },
    { StringStrcmp,   "int strcmp(char *,char *);"          },
    { StringStrncmp,  "int strncmp(char *,char *,int);"     },
    { StringStrcoll,  "int strcoll(char *,char *);"         },
    { StringStrcpy,   "char *strcpy(char *,char *);"        },
    { StringStrncpy,  "char *strncpy(char *,char *,int);"   },
    { StringStrerror, "char *strerror(int);"                },
    { StringStrlen,   "int strlen(char *);"                 },
    { StringStrspn,   "int strspn(char *,char *);"          },
    { StringStrcspn,  "int strcspn(char *,char *);"         },
    { StringStrpbrk,  "char *strpbrk(char *,char *);"       },
    { StringStrstr,   "char *strstr(char *,char *);"        },
    { StringStrtok,   "char *strtok(char *,char *);"        },
    { StringStrxfrm,  "int strxfrm(char *,char *,int);"     },
    { StringStrdup,   "char *strdup(char *);"               },
    { StringStrtok_r, "char *strtok_r(char *,char *,char **);"},
    { NULL, NULL }
};

void StringSetupFunc(Picoc *pc)
{
    if (!VariableDefined(pc, TableStrRegister(pc, "NULL")))
        VariableDefinePlatformVar(pc, NULL, "NULL", &pc->IntType,
                                  (union AnyValue *)&String_ZeroValue, FALSE);
}

#endif /* !BUILTIN_MINI_STDLIB */
