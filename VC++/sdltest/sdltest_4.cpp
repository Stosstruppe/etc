#pragma comment(lib, "SDL2")
#pragma comment(lib, "SDL2main")
#pragma comment(lib, "SDL2_ttf")

#include <SDL.h>
#include <SDL_ttf.h>

SDL_Texture* texDigits;
SDL_Texture* texMsg;
SDL_Rect rcTex;
int digw;
int digh;

void dispDigits(SDL_Renderer* rnd, int num, int len, int x, int y)
{
        for (int i = 0; i < len; i++) {
                int d = num % 10;
                SDL_Rect rcSrc{ digw * d, 0, digw, digh };
                SDL_Rect rcDst{ x + (len - i - 1) * digw, y, digw, digh };
                SDL_RenderCopy(rnd, texDigits, &rcSrc, &rcDst);
                num /= 10;
        }
}

void Render(SDL_Renderer* rnd)
{
        static int frame;
        static int count;
        static int fps;
        static Uint32 prev;

        // fps計測
        Uint32 tick = SDL_GetTicks() / 1000;
        if (prev != tick) {
                prev = tick;
                fps = count;
                count = 0;
        }
        count++;
        frame++;

        //
        SDL_SetRenderDrawColor(rnd, 0, 0, 128, 255);
        SDL_RenderClear(rnd);

        SDL_Rect rc{};
        SDL_QueryTexture(texMsg, nullptr, nullptr, &rc.w, &rc.h);
        SDL_RenderCopy(rnd, texMsg, &rc, &rc);

        dispDigits(rnd, fps, 3, digw * 4, 0);
        dispDigits(rnd, frame, 4, digw * 14, 0);

        rc = rcTex;
        rc.y += digh;
        SDL_RenderCopy(rnd, texDigits, &rcTex, &rc);

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

        // フォント開始
        ret = TTF_Init();
        TTF_Font* font = TTF_OpenFont("C:\\Windows\\Fonts\\consola.ttf", 24);

        // 数字テクスチャの作成
        SDL_Surface* sur = TTF_RenderUTF8_Blended(
                font, "0123456789", SDL_Color{ 255, 255, 0, 255 });
        texDigits = SDL_CreateTextureFromSurface(rnd, sur);
        SDL_FreeSurface(sur);

        SDL_QueryTexture(texDigits, nullptr, nullptr, &rcTex.w, &rcTex.h);
        digw = rcTex.w / 10;
        digh = rcTex.h;

        //
        sur = TTF_RenderUTF8_Blended(
                font, "FPS:___ FRAME:____", SDL_Color{ 0xc0, 0xc0, 0xc0, 0xff });
        texMsg = SDL_CreateTextureFromSurface(rnd, sur);
        SDL_FreeSurface(sur);

        // フォント終了               
        TTF_CloseFont(font);
        TTF_Quit();

        SDL_Event ev;
        bool run = true;
        while (run) {
                while (SDL_PollEvent(&ev)) {
                        if (ev.type == SDL_QUIT) run = false;
                }
                Render(rnd);
        }

        SDL_DestroyTexture(texDigits);
        SDL_DestroyTexture(texMsg);

        SDL_DestroyRenderer(rnd);
        SDL_DestroyWindow(wnd);
        SDL_Quit();
        return 0;
}
