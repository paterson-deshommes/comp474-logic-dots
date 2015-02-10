:- use_module(library(clpfd)).

isSolvable([],_).
isSolvable([Head|Tail],Rows) :-
        delete(Rows,0,NonZeroList),
        length(NonZeroList,Length),
        Length@>=Head,
        isSolvable(Tail,Rows).


canSolve(Columns,Rows) :-
        (isSolvable(Columns,Rows),
        isSolvable(Rows,Columns),
        sum_list(Columns, ColumnsSum),
        sum_list(Rows, RowsSum),
        ColumnsSum=:=RowsSum).


%Rule for generating the possible positions along a row
createPairs(_,0,List,List).
createPairs(LeftNum,RightNum,List,List2) :-
        NewRightNum is RightNum-1,
        createPairs(LeftNum,NewRightNum,[LeftNum/RightNum|List],List2).


%Rule for creating a board
createBoard(MaxPos,List) :-
        createPositionList(MaxPos,MaxPos,[],List).


%Rule for generating all the possible position on a board
createPositionList(_,0,List,List).
createPositionList(MaxPos, CurrentPos, List,List3) :-
        createPairs(CurrentPos,MaxPos,List,List2),
        NewCurrentPos is CurrentPos-1,
        createPositionList(MaxPos,NewCurrentPos,List2,List3).


%Main rule to play the game
playLogicDots(Columns,Rows) :-
        (canSolve(Columns,Rows),
        length(Columns,MaxNum),
        createBoard(MaxNum,List),
        move(Columns,Rows,List,[],Sol),
        write(Sol));
        write('Board is not solvable').

newConfig([Head|Tail],CurrentPos,WantedPos,Acc,List) :-
         CurrentPos=\=WantedPos,
         append([Head],Acc,TempList),
         NewCurrentPos is CurrentPos + 1,
         newConfig(Tail,NewCurrentPos,WantedPos,TempList,List).

newConfig([Head|Tail],CurrentPos,WantedPos,Acc,List) :-
         CurrentPos=:=WantedPos,
         NewHead is Head-1,
         append([NewHead],Acc,TempList),
         reverse(TempList,ReversedList),
         append(ReversedList,Tail,List).

fufill_req(Columns,Rows,X/Y):-
         nth1(X,Columns,ColumnsPos),
         nth1(Y,Rows,RowsPos),
         ColumnsPos@>0,
         RowsPos@>0.


move(Columns,Rows,_,TempSol,TempSol) :-
       goal(Columns,Rows).
move(Columns,Rows,[ColPos/RowPos|PosTail],TempSol,FinalSol) :-
        fufill_req(Columns,Rows,ColPos/RowPos),
        newConfig(Columns,1,ColPos,[],NewColumns),
        newConfig(Rows,1,RowPos,[],NewRows),
        canSolve(NewColumns,NewRows),
        move(NewColumns,NewRows,PosTail,[ColPos/RowPos|TempSol],FinalSol).
move(Columns,Rows,[ColPos/RowPos|PosTail],TempSol,FinalSol) :-
        not(fufill_req(Columns,Rows,ColPos/RowPos)),
        move(Columns,Rows,PosTail,TempSol,FinalSol).

goal(Columns,Rows) :-
        delete(Columns,0,NewColumns),
        delete(Rows,0,NewRows),
        length(NewColumns,ColLength),
        length(NewRows,RowLength),
        ColLength=:=0,
        RowLength=:=0.


        
