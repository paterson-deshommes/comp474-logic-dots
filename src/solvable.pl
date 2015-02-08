isSolvable([],_).

% private rule
isSolvable([Head|Tail],Rows) :- 
        delete(Rows,0,NonZeroList),
        length(NonZeroList,Length),
        Length@>=Head,
        isSolvable(Tail,Rows).

%public rule
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
        write(List));
        write('Board is not solvable').
        
