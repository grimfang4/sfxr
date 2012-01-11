/*
   Copyright (c) 2007 Tomas Pettersson <drpetter@gmail.com>

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

#ifndef _TOOLS_H__
#define _TOOLS_H__

typedef Uint32 DWORD;
typedef Uint16 WORD;

struct Spriteset
{
	DWORD *data;
	int width;
	int height;
	int pitch;
};

int LoadTGA(Spriteset& tiles, const char *filename);

void ClearScreen(DWORD color);

void DrawBar(int sx, int sy, int w, int h, DWORD color);

void DrawBox(int sx, int sy, int w, int h, DWORD color);

void DrawSprite(Spriteset& sprites, int sx, int sy, int i, DWORD color);

void DrawText(Spriteset& font, int sx, int sy, DWORD color, const char *string, ...);

bool MouseInBox(int x, int y, int w, int h);

#endif

