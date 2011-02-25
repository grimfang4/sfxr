AUTOMAKE_OPTIONS = foreign

CFLAGS = --pedantic -Wall -O2
CXXFLAGS=$(CFLAGS) `sdl-config --cflags`
CPPFLAGS=-DDATADIR='$(pkgdatadir)'
LDFLAGS=`sdl-config --libs`

bin_PROGRAMS = sfxr

sfxr_SOURCES := main.cpp sdlkit.cpp tools.cpp sdlkit.h tools.h
