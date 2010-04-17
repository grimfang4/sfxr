# Copyright (c) 2007 mjau/GerryJJ
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

CFLAGS=-ggdb
CXXFLAGS=$(CFLAGS) `sdl-config --cflags` `pkg-config gtk+-2.0 --cflags`
LDFLAGS=`sdl-config --libs` `pkg-config gtk+-2.0 --libs`

sfxr: main.cpp tools.h sdlkit.h
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $< -o $@

install: sfxr
	mkdir -p $(DESTDIR)/usr/bin
	mkdir -p $(DESTDIR)/usr/share/sfxr
	mkdir -p $(DESTDIR)/usr/share/applications
	mkdir -p $(DESTDIR)/usr/share/icons/hicolor/48x48/apps
	install -m 755 sfxr $(DESTDIR)/usr/bin
	install -m 644 -p *.tga *.bmp $(DESTDIR)/usr/share/sfxr
	install -p -m 644 sfxr.png \
		$(DESTDIR)/usr/share/icons/hicolor/48x48/apps
	desktop-file-install --vendor "" \
		--dir $(DESTDIR)/usr/share/applications sfxr.desktop

clean:
	rm sfxr
