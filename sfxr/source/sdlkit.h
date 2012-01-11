/*
   Copyright (c) 2007 mjau/GerryJJ

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.
*/

#ifndef SDLKIT_H
#define SDLKIT_H

#include "SDL.h"
#include <string>


#define ERROR(x) error(__FILE__, __LINE__, #x)
#define VERIFY(x) do { if (!(x)) ERROR(x); } while (0)

typedef Uint32 DWORD;
typedef Uint16 WORD;

#define DIK_SPACE SDLK_SPACE
#define DIK_RETURN SDLK_RETURN
#define DIK_Z SDLK_z
#define DDK_WINDOW 0


extern Uint32 *ddkscreen32;
extern Uint16 *ddkscreen16;
extern int ddkpitch;


extern int mouse_x, mouse_y, mouse_px, mouse_py;
extern bool mouse_left, mouse_right, mouse_middle;
extern bool mouse_leftclick, mouse_rightclick, mouse_middleclick;


void error (const char *file, unsigned int line, const char *msg);

void ddkInit();      // Will be called on startup
bool ddkCalcFrame(); // Will be called every frame, return true to continue running or false to quit
void ddkFree();      // Will be called on shutdown

class DPInput {
public:
	DPInput() {}
	~DPInput() {}
	static void Update () {}

	static bool KeyPressed(SDLKey key);

};

void sdlupdate ();

bool ddkLock ();

void ddkUnlock ();

void ddkSetMode (int width, int height, int bpp, int refreshrate, int fullscreen, const char *title);


//void selected_file (GtkWidget *button, GtkFileSelection *fs);

bool select_file (char *buf, bool showNewButton);
std::string new_file(const std::string& forced_extension);

#define FileSelectorLoad(file,y) select_file(file, false)
#define FileSelectorSave(file,y) select_file(file, true)

void sdlquit ();

void sdlinit ();

void loop ();


#endif
