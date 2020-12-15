/* Based on fa1.pml  Copyright 2007 by Moti Ben-Ari under the GNU GPL */

#define LEN 5

inline Input(n) {
  if
  :: i[n] = 'a'
  :: i[n] = 'b'
  :: i[n] = 'c'
  fi
}


active proctype FA() {
  byte h;
  byte i[LEN];
  Input(0); Input(1); Input(2); Input(3); i[4] = '.';
q0: if
    :: i[h] == 'a'  -> printf("@TRANS q0 a q0\n"); h++; goto q0;
    :: i[h] == 'b'  -> printf("@TRANS q0 b q3\n"); h++; goto q3;
    :: i[h] == 'b'  -> printf("@TRANS q0 b q1\n"); h++; goto q1
    fi;
q1: if
    :: i[h] == 'b'  -> printf("@TRANS q1 b q2\n"); h++; goto q2
    fi;
q2: if
    :: i[h] == 'b'  -> printf("@TRANS q2 b q1\n"); h++; goto q1;
    :: i[h] == '.'  -> printf("@TRANS q2 . accept\n"); goto accept
    fi;
q3: if
    :: i[h] == 'c'  -> printf("@TRANS q3 c q3\n"); h++; goto q3;
    :: i[h] == '.'  -> printf("@TRANS q3 . accept\n"); goto accept
    fi;
accept:
    printf("Accepted!\n");
	assert(false)
}

active proctype Watchdog() {
end:	timeout -> printf("Rejected ...\n")
}
