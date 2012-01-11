#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.64])
AC_INIT([sfxr], [1.2.0], [grimfang4@gmail.com],[sfxr-1.2.0.tar],[http://code.google.com/p/sfxr])
AM_INIT_AUTOMAKE(sfxr, 1.2.0)
AM_CONFIG_HEADER(config.h:config.in)

AC_CONFIG_SRCDIR([source/sdlkit.h])


# Checks for programs.
AC_PROG_CXX
AC_PROG_CC
AC_PROG_INSTALL

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([malloc.h stdlib.h string.h])

AC_CHECK_LIB(SDL, SDL_Init, [], [
        echo "**Error** libSDL was not found."
        exit -1
        ])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL

# Checks for library functions.
AC_FUNC_ERROR_AT_LINE
AC_FUNC_MALLOC
AC_CHECK_FUNCS([atexit memset pow])



AC_OUTPUT(Makefile)
