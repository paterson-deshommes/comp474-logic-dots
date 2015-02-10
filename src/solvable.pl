:- use_module(library(clpfd)).

%Rule that check if a column and row configuration are solvable
%Base Case: Left configuration is empty, we reached our goal
%Recursive Case: Iterate through left configuration and for each
%element, we check if its value is larger or equal than the number of
%non-zero element in the right configuration
isSolvable([],_).
isSolvable([Head|Tail],Rows) :-
        delete(Rows,0,NonZeroList),
        length(NonZeroList,Length),
        Length@>=Head,
        isSolvable(Tail,Rows).

%Rule that check if a board configuration is solvable
canSolve(Columns,Rows) :-
        (isSolvable(Columns,Rows),
        isSolvable(Rows,Columns),
        sum_list(Columns, ColumnsSum),
        sum_list(Rows, RowsSum),
        ColumnsSum=:=RowsSum).


%Rule for generating the possible positions in a board
%Given a LeftNum n and a RightNum m, it will produce the following
%list: [n/m,n/m-1/,n/m-2,n/m-3,...,n/1]
createPairs(_,0,List,List,_,_).
createPairs(LeftNum,RightNum,List,List2,Columns,Rows) :-
        nth1(LeftNum,Columns,ColCount),
        ColCount=\=0,
        nth1(RightNum,Rows,RowCount),
        RowCount=\=0,
        NewRightNum is RightNum-1,
        createPairs(LeftNum,NewRightNum,[LeftNum/RightNum|List],List2,Columns,Rows).
createPairs(LeftNum,RightNum,List,List2,Columns,Rows) :-
        NewRightNum is RightNum-1,
        createPairs(LeftNum,NewRightNum,List,List2,Columns,Rows).


%Rule for creating a board
%List is unify with a list of all the possible positions
%that can be used to solve the board
createBoard(MaxPos,List,Columns,Rows) :-
        createPositionList(MaxPos,MaxPos,[],List,Columns,Rows).


%Rule for generating all the possible position on a board
%From BoardSize to 1, will generate a list of all possible positions
createPositionList(_,0,List,List,_,_).
createPositionList(MaxPos, CurrentPos, List,List3,Columns,Rows) :-
        createPairs(CurrentPos,MaxPos,List,List2,Columns,Rows),
        NewCurrentPos is CurrentPos-1,
        createPositionList(MaxPos,NewCurrentPos,List2,List3,Columns,Rows).


%Main rule to play the game
playLogicDots(Columns,Rows) :-
        (canSolve(Columns,Rows),
        length(Columns,MaxNum),
        createBoard(MaxNum,List,Columns,Rows),
        move(Columns,Rows,List,[],Sol),
        write(Sol));
        write('Board is not solvable').

%Rule to generate a new constraint configuration for the board
%Iterate through the current constraint config until we reach
%the value we want to replace. Replace the value and append
%the rest of the list to the new constraint list
newConstraint([Head|Tail],CurrentPos,WantedPos,Acc,List) :-
         CurrentPos=\=WantedPos,
         append([Head],Acc,TempList),
         NewCurrentPos is CurrentPos + 1,
         newConstraint(Tail,NewCurrentPos,WantedPos,TempList,List).

newConstraint([Head|Tail],CurrentPos,WantedPos,Acc,List) :-
         CurrentPos=:=WantedPos,
         NewHead is Head-1,
         append([NewHead],Acc,TempList),
         reverse(TempList,ReversedList),
         append(ReversedList,Tail,List).

%Rule to check if a position can be added to the solution list
fufill_req(Columns,Rows,X/Y):-
         nth1(X,Columns,ColumnsPos),
         nth1(Y,Rows,RowsPos),
         ColumnsPos@>0,
         RowsPos@>0.


%Rule to move from one state to the other
%For each position, check if it can be added to the solution,
%check if new board configuration can be solved and check for
%when goal is reached
move(Columns,Rows,_,TempSol,TempSol) :-
       goal(Columns,Rows).
move(Columns,Rows,[ColPos/RowPos|PosTail],TempSol,FinalSol) :-
        fufill_req(Columns,Rows,ColPos/RowPos),
        newConstraint(Columns,1,ColPos,[],NewColumns),
        newConstraint(Rows,1,RowPos,[],NewRows),
        canSolve(NewColumns,NewRows),
        move(NewColumns,NewRows,PosTail,[ColPos/RowPos|TempSol],FinalSol).
move(Columns,Rows,[_|PosTail],TempSol,FinalSol) :-
        move(Columns,Rows,PosTail,TempSol,FinalSol).

%Rule for validating when goal is reached
goal(Columns,Rows) :-
        delete(Columns,0,NewColumns),
        delete(Rows,0,NewRows),
        length(NewColumns,ColLength),
        length(NewRows,RowLength),
        ColLength=:=0,
        RowLength=:=0.


        
