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

#include "sdlkit.h"


#include <stdio.h>
#include <string.h>

void error (const char *file, unsigned int line, const char *msg)
{
	fprintf(stderr, "[!] %s:%u  %s\n", file, line, msg);
	exit(1);
}


bool keys[SDLK_LAST];

bool DPInput::KeyPressed(SDLKey key)
{
	bool r = keys[key];
	keys[key] = false;
	return r;
}

Uint32 *ddkscreen32;
Uint16 *ddkscreen16;
int ddkpitch;
int mouse_x, mouse_y, mouse_px, mouse_py;
bool mouse_left = false, mouse_right = false, mouse_middle = false;
bool mouse_leftclick = false, mouse_rightclick = false, mouse_middleclick = false;

SDL_Surface *sdlscreen = NULL;

void sdlupdate ()
{
	mouse_px = mouse_x;
	mouse_py = mouse_y;
	Uint8 buttons = SDL_GetMouseState(&mouse_x, &mouse_y);
	bool mouse_left_p = mouse_left;
	bool mouse_right_p = mouse_right;
	bool mouse_middle_p = mouse_middle;
	mouse_left = buttons & SDL_BUTTON(1);
	mouse_right = buttons & SDL_BUTTON(3);
	mouse_middle = buttons & SDL_BUTTON(2);
	mouse_leftclick = mouse_left && !mouse_left_p;
	mouse_rightclick = mouse_right && !mouse_right_p;
	mouse_middleclick = mouse_middle && !mouse_middle_p;
}

bool ddkLock ()
{
	if(SDL_MUSTLOCK(sdlscreen))
	{
		if(SDL_LockSurface(sdlscreen) < 0)
			return false;
	}
	ddkpitch = sdlscreen->pitch / (sdlscreen->format->BitsPerPixel == 32 ? 4 : 2);
	ddkscreen16 = (Uint16*)(sdlscreen->pixels);
	ddkscreen32 = (Uint32*)(sdlscreen->pixels);
	return true;
}

void ddkUnlock ()
{
	if(SDL_MUSTLOCK(sdlscreen))
	{
		SDL_UnlockSurface(sdlscreen);
	}
}

void ddkSetMode (int width, int height, int bpp, int refreshrate, int fullscreen, const char *title)
{
	VERIFY(sdlscreen = SDL_SetVideoMode(width, height, bpp, fullscreen ? SDL_FULLSCREEN : 0));
	SDL_WM_SetCaption(title, title);
}

#include <string.h>
#include <malloc.h>


bool Button(int x, int y, bool highlight, const char* text, int id);

#include <string>
#include <list>


#include <sys/stat.h>
#include <dirent.h>

bool ioIsDir(const std::string& filename)
{
	using namespace std;
    struct stat status;
    stat(filename.c_str(), &status);

    return (status.st_mode & S_IFDIR);
}

std::list<std::string> ioList(const std::string& dirname, bool directories, bool files)
{
	using namespace std;
    list<string> dirList;
    list<string> fileList;
    
    DIR* dir = opendir(dirname.c_str());
    dirent* entry;
    
    while ((entry = readdir(dir)) != NULL)
    {
        #ifdef WIN32
        if(ioIsDir(dirname + "/" + entry->d_name))
        #else
        if(entry->d_type == DT_DIR)
        #endif
        {
            if(directories)
                dirList.push_back(entry->d_name);
        }
        else if(files)
            fileList.push_back(entry->d_name);
    }
 
    closedir(dir);
    
    dirList.sort();
    fileList.sort();
    
    fileList.splice(fileList.begin(), dirList);
    
    
    return fileList;
}

extern DPInput *input;

bool file_select_update()
{
	input->Update(); // (for keyboard input)

	//keydown=false;

	return true;
}

std::string stoupper(const std::string& s)
{
	std::string result = s;
	std::string::iterator i = result.begin();
	std::string::iterator end = result.end();
	
	while(i != end)
	{
		*i = std::toupper((unsigned char)*i);
		++i;
	}
	return result;
}


bool ioExists(const std::string& filename)
{
    return (access(filename.c_str(), 0) == 0);
}

bool ioNew(const std::string& filename, bool readable, bool writeable)
{
    if(ioExists(filename))
        return false;
    
    FILE* file = fopen(filename.c_str(), "wb");
    if(file == NULL)
        return false;
    fclose(file);
    return true;
}


void ClearScreen(DWORD color);
extern int vcurbutton;

#include "tools.h"

extern Spriteset font;

std::string new_file(const std::string& forced_extension)
{
	using namespace std;
	SDL_EnableUNICODE(1);
	SDL_EnableKeyRepeat(0, 0);
	
	string result;
	
	bool done = false;
	SDL_Event e;
	while (!done)
	{
		while(SDL_PollEvent(&e))
		{
			switch (e.type)
			{
				case SDL_QUIT:
					exit(0);
		
				case SDL_KEYDOWN:
					if(e.key.keysym.sym == SDLK_ESCAPE)
					{
						return "";
					}
					if(e.key.keysym.sym == SDLK_RETURN)
					{
						done = true;
						break;
					}
					
					{
						char c = e.key.keysym.unicode;
						if(0x21 <= c && c <= 0x7E)
							result += c;
					}
		
				default: break;
			}
		}
		sdlupdate();
		
		ClearScreen(0xC0B090);
		
		DrawText(font, 90, 150, 0x000000, "TYPE NEW FILE NAME:");
		DrawText(font, 100, 200, 0x000000, "%s", stoupper(result).c_str());

		SDL_Delay(5);
		
		SDL_Flip(sdlscreen);
	}
	
	SDL_EnableKeyRepeat(SDL_DEFAULT_REPEAT_DELAY, SDL_DEFAULT_REPEAT_INTERVAL);
	SDL_EnableUNICODE(0);
	
	//if(result.size() == 0)
	//	throw runtime_error("New file name is empty string.");
	
	if(result.size() < 6 || result.substr(result.size()-1 - 4, string::npos) != forced_extension)
		result += forced_extension;
	
	return result;
}

void DrawFileSelectScreen(std::list<std::string>& files, char* buf, bool& gotFile, bool& done, bool showNewButton)
{
	using namespace std;

	ddkLock();

	ClearScreen(0xC0B090);

	
	int i = 0, j = 0;
	for(list<string>::iterator e = files.begin(); e != files.end(); e++)
	{
		if(40 + 20*i > sdlscreen->h - 50)
		{
			j++;
			i = 0;
		}
		if(Button(30 + 150*j, 40 + 20*i, false, stoupper(*e).c_str(), 31 + i + j))
		{
			gotFile = true;
			sprintf(buf, "%s", e->c_str());
			done = true;
		}
		i++;
	}
	
	if(Button(10, 10, false, "CANCEL", 400))
	{
		gotFile = false;
		done = true;
	}
	
	if(showNewButton && Button(120, 10, false, "NEW FILE", 401))
	{
		string s = new_file(".sfxr");
		if(s != "")
		{
			ioNew(s, true, true);
			files = ioList(".", false, true);
			
			for(list<string>::iterator e = files.begin(); e != files.end();)
			{
				if(e->find(".sfxr") == string::npos)
				{
					e = files.erase(e);
					continue;
				}
				
				e++;
			}
		}
	}

	ddkUnlock();

	if(!mouse_left)
		vcurbutton=-1;
}


bool select_file (char *buf, bool showNewButton)
{
	// FIXME: Needs directory browsing
	
	bool gotFile = false;
	using namespace std;
	list<string> files;
	files = ioList(".", false, true);
	
	for(list<string>::iterator e = files.begin(); e != files.end();)
	{
		if(e->find(".sfxr") == string::npos)
		{
			e = files.erase(e);
			continue;
		}
		
		e++;
	}
	
	bool done = false;
	SDL_Event e;
	while (!done)
	{
		SDL_PollEvent(&e);
		switch (e.type)
		{
			case SDL_QUIT:
				exit(0);
	
			case SDL_KEYDOWN:
				keys[e.key.keysym.sym] = true;
	
			default: break;
		}
		sdlupdate();
		
		DrawFileSelectScreen(files, buf, gotFile, done, showNewButton);

		SDL_Delay(5);
		
		SDL_Flip(sdlscreen);
	}
	return gotFile;
}

void sdlquit ()
{
	ddkFree();
	SDL_Quit();
}

void sdlinit ()
{
	SDL_Surface *icon;
	VERIFY(!SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO));
	icon = SDL_LoadBMP("/usr/local/share/sfxr/images/sfxr.bmp");
	if (!icon)
		icon = SDL_LoadBMP("images/sfxr.bmp");
	if (icon)
		SDL_WM_SetIcon(icon, NULL);
	atexit(sdlquit);
	memset(keys, 0, sizeof(keys));
	ddkInit();
}

void loop (void)
{
	SDL_Event e;
	while (true)
	{
		SDL_PollEvent(&e);
		switch (e.type)
		{
			case SDL_QUIT:
				exit(0);
	
			case SDL_KEYDOWN:
				keys[e.key.keysym.sym] = true;
	
			default: break;
		}
		sdlupdate();
		if (!ddkCalcFrame())
			return;
		SDL_Flip(sdlscreen);
	}
}

int main(int argc, char *argv[])
{
	sdlinit();
	loop();
	return 0;
}

