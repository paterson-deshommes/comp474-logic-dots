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
	ColumnsSum=:=RowsSum);
	write('Board is not solvable').
