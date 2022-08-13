#pragma comment(lib, "SDL2")
#pragma comment(lib, "SDL2main")
#pragma comment(lib, "SDL2_ttf")

#include <SDL.h>
#include <SDL_ttf.h>

TTF_Font* font;
SDL_Texture* tex;
SDL_Rect rcTex;

void Render(SDL_Renderer* rnd)
{
        SDL_SetRenderDrawColor(rnd, 0, 0, 128, 255);
        SDL_RenderClear(rnd);
        SDL_RenderCopy(rnd, tex, &rcTex, &rcTex);
        SDL_RenderPresent(rnd);
}

int main(int, char**) // SDL_main
{
        int ret;
        ret = SDL_Init(SDL_INIT_EVERYTHING);
        SDL_Window* const wnd = SDL_CreateWindow(
                "sdltest",
                SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                640, 480, 0); // SDL_WINDOW_SHOWN
        SDL_Renderer* const rnd = SDL_CreateRenderer(
                wnd, -1,
                SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);

        // フォント作成
        ret = TTF_Init();
        TTF_Font* font = TTF_OpenFont("C:\\Windows\\Fonts\\cour.ttf", 20);

        SDL_Surface* sur = TTF_RenderUTF8_Blended(
                font, "hello, world", SDL_Color{ 255, 255, 255, 255 });
        tex = SDL_CreateTextureFromSurface(rnd, sur);
        int w, h;
        SDL_QueryTexture(tex, nullptr, nullptr, &w, &h);
        rcTex = SDL_Rect{ 0, 0, w, h };

        SDL_Event ev;
        bool run = true;
        while (run) {
                while (SDL_PollEvent(&ev)) {
                        if (ev.type == SDL_QUIT) run = false;
                }
                Render(rnd);
        }

        SDL_DestroyTexture(tex);
        SDL_FreeSurface(sur);

        TTF_CloseFont(font);
        TTF_Quit();

        SDL_DestroyRenderer(rnd);
        SDL_DestroyWindow(wnd);
        SDL_Quit();
        return 0;
}
