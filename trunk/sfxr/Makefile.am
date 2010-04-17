AUTOMAKE_OPTIONS = foreign

CFLAGS = --pedantic -Wall -O2
CXXFLAGS=$(CFLAGS) `sdl-config --cflags` `pkg-config gtk+-2.0 --cflags`
CPPFLAGS=-DDATADIR='$(pkgdatadir)'
LDFLAGS=`sdl-config --libs` `pkg-config gtk+-2.0 --libs`

bin_PROGRAMS = sfxr

sfxr_SOURCES := main.cpp ddrawkit.h sdlkit.h tools.h
