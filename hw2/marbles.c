#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main() {
  int t0 = 10;  // your marbles
  int t1 = 10;  // your emeny's marbles
  int round = 1;
  int secret, t2, t3,
      t4;  // t2: your bets, t3: even or odd? t4: your enemy's bets

  while (round <= 3) {
    printf("Round %d start...\n", round);

    // your side
    printf("Please places a bet: \n");  //# marbles you choose
    scanf("%d", &t2);

    // check your input
    if (t2 <= t0) {
      // enemy's side
      srand(time(NULL));
      secret = rand() % t1;

      printf("Now, even(0) or odd(1)? \n");
      scanf("%d", &t3);

      // game processing
      t4 = secret % 2;  // odd even check

      if (t4 == t3) {
        printf("correct!\n");

        // update marbles
        t0 = t0 + t2;  // yours
        t1 = t1 - t2;  // your enemy's
        printf("you have %d marbels now!\n", t0);
      }

      else {
        printf("incorrect!\n");

        // update marbles
        t0 = t0 - secret;  // yours
        t1 = t1 + secret;  // your enemy's
        printf("you have %d marbels now!\n", t0);
      }

      // check winner
      if (t0 <= 0) {
        // round = round + 1;
        break;
      } else if (t1 <= 0) {
        // round = round + 1;
        break;
      } else {
        round = round + 1;
        continue;
      }
    } else {
      printf("Incorrect input!, you only have %d marbles!\n", t0);
    }
  }

  if (round < 3) {  // the game is finish in three rounds
    if (t0 > t1) {
      printf("you win!\n", t0);
      printf("You have %d merbles\n", t0);
    } else {
      printf("you lose!\n", t0);
      printf("You have %d merbles\n", t0);
    }
  } else {  // if the game is not finish in three rounds
    printf("After three rounds, ");

    if (t0 > t1) {
      printf("you win!\n", t0);
      printf("You have more merbles\n");
    } else if (t0 < t1) {
      printf("you lose!\n", t0);
      printf("Your enemy have more merbles\n");
    } else {
      printf("both you two are lose!\n");
    }
  }
  return 0;
}
