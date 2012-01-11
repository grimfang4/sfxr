# Copyright (c) 2010 Bart Veldstra
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

cmake_minimum_required (VERSION 2.6)
project (sfxr)

find_package(SDL REQUIRED)
include_directories(include ${SDL_INCLUDE_DIR})
link_libraries(${SDL_LIBRARY})

add_definitions("-Wall -pedantic")

set(SRC_FILES
	main.cpp
	sdlkit.cpp
	tools.cpp
)

add_executable(sfxr ${SRC_FILES})

install(TARGETS sfxr
        RUNTIME DESTINATION .)
install(FILES font.tga ld48.tga sfxr.bmp readme.txt
        DESTINATION share/sfxr)
install(FILES sfxr.png
        DESTINATION share/icons/hicolor/48x48/apps)
install(FILES sfxr.1
        DESTINATION share/man/man1)
install(FILES sfxr.desktop
        DESTINATION share/applications)

