/*
  Frogs puzzle:
  	Five stones
	2 frogs at right facing left
	2 frogs at left facing right
	F-> F-> [EMPTY] <-F <-F
	[1] [2]   [0]   [3]  [4]
*/

#define STONES 5
int frogs[STONES];

inline disp_frogs() {
    printf("\nEMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d",frogs[0],frogs[1],frogs[2],frogs[3],frogs[4]);
}

init {
    frogs[0]= 3; // empty stone
    frogs[1]= 1;
    frogs[2]= 2;
    frogs[3]= 4;
    frogs[4]= 5;    
    disp_frogs();
    run move(1);
    run move(2);
    run move(3);
    run move(4);
    (_nr_pr==1)
    printf("\n");
    assert(!(frogs[3]+frogs[4]==3&&frogs[1]+frogs[2]==9)); //
}

proctype move(int id){
    int temp;
    if
    ::(id>=3) -> printf("\nFROG%d (LEFT) STARTS AT %d",id,frogs[id]);
    ::(id<3) -> printf("\nFROG%d (RIGHT) STARTS AT %d",id,frogs[id]);
    fi;
    do
    ::atomic {
        if
        ::(id<3&&((frogs[0]-frogs[id]==2)||(frogs[0]-frogs[id]==1))) ->
            temp = frogs[0];
            frogs[0]=frogs[id];
            frogs[id]=temp;
            printf("\nFROG%d FROM %d TO %d",id,frogs[0],frogs[id]);
            disp_frogs();
        ::(id>=3&&((frogs[id]-frogs[0]==2)||(frogs[id]-frogs[0]==1))) ->
            temp = frogs[0];
            frogs[0]=frogs[id];
            frogs[id]=temp;
            printf("\nFROG%d FROM %d TO %d",id,frogs[0],frogs[id]);
            disp_frogs();
        fi; 
    }
    ::atomic {
        (frogs[3]+frogs[4]==3&&frogs[1]+frogs[2]==9) 
        break;
    }
    od;
}


