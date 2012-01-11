AUTOMAKE_OPTIONS = foreign

CFLAGS = --pedantic -Wall -O2
CXXFLAGS=$(CFLAGS) `sdl-config --cflags`
CPPFLAGS=-DDATADIR='$(pkgdatadir)'
LDFLAGS=`sdl-config --libs`

bin_PROGRAMS = sfxr

sfxr_SOURCES := source/main.cpp source/sdlkit.cpp source/tools.cpp source/sdlkit.h source/tools.h
