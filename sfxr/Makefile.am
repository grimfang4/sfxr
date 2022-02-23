AUTOMAKE_OPTIONS = foreign

CFLAGS = --pedantic -Wall -O2 -g
CXXFLAGS=$(CFLAGS) `sdl2-config --cflags`
CPPFLAGS=-DDATADIR='$(pkgdatadir)'
LDFLAGS=`sdl2-config --libs`

bin_PROGRAMS = sfxr

sfxr_SOURCES := source/main.cpp source/sdlkit.cpp source/tools.cpp source/sdlkit.h source/tools.h
