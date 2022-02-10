#include <memory.h>
#include <stdio.h>

#define LEN 6

char msg[] = "GAKKOU";
char pick[LEN];
int flag[LEN];
char rec[720][LEN];
int cnt;

void perm(int n);
void sort();
void swap(char *s1, char *s2, int len);
void disp();

int main()
{
	perm(0);
	sort();
	disp();
}

void perm(int n)
{
	if (n == LEN) {
		memcpy(rec[cnt++], pick, LEN);
		return;
	}
	for (int i = 0; i < LEN; i++) {
		if (flag[i] == 0) {
			flag[i] = 1;
			pick[n] = msg[i];
			perm(n + 1);
			flag[i] = 0;
		}
	}
}

void sort()
{
	for (int i = 0; i < cnt - 1; i++) {
		for (int j = 0; j < cnt - 1 - i; j++) {
			if (memcmp(rec[j], rec[j+1], LEN) > 0) {
				swap(rec[j], rec[j+1], LEN);
			}
		}
	}
}

void swap(char *s1, char *s2, int len)
{
	for (int i = 0; i < LEN; i++) {
		char c = *s1;
		*(s1++) = *s2;
		*(s2++) = c;
	}
}

void disp()
{
	char t[LEN];
	t[0] = 0;
	int c = 0;
	for (int i = 0; i < cnt; i++) {
		if (memcmp(t, rec[i], LEN)) {
			memcpy(t, rec[i], LEN);
			printf("%d:%.6s\n", ++c, t);
			if (c >= 100) break;
		}
	}
}
